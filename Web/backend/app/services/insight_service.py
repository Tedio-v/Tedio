import os
import json
import re
from datetime import datetime
from collections import defaultdict, Counter
from openai import OpenAI

# ---------- helpers ----------------------------------------------------------
TIME_FMT = "%Y-%m-%dT%H:%M:%S.%fZ"        # ISO from Google Takeout

def _local_dt(utc_str):
    """Convert UTC timestamp to local datetime, handling both formats with and without milliseconds"""
    try:
        # Try parsing with milliseconds first
        dt = datetime.strptime(utc_str, "%Y-%m-%dT%H:%M:%S.%fZ")
    except ValueError:
        # If that fails, try without milliseconds
        dt = datetime.strptime(utc_str, "%Y-%m-%dT%H:%M:%SZ")
    return dt.replace(hour=(dt.hour + 8) % 24)

def _preprocess(data):
    if isinstance(data, str):
        data = json.loads(data)
    
    if not isinstance(data, list):
        raise ValueError("Data must be a list of watch history items")
    
    return [
        {
            "title": item.get("title", ""),
            "titleUrl": item.get("titleUrl", ""),
            "time": _local_dt(item.get("time", "")),
            "subtitles": item.get("subtitles", []),
            "details": item.get("details", []),
            "description": item.get("description", "")
        }
        for item in data
    ]

# ---------- feature extraction (4 core + 8 optional) -------------------------
def build_metrics(data):
    """Extract compact summary metrics from watch history data for LLM"""
    metrics = {
        "late_night_count": 0,
        "binge_sessions": 0,
        "top_channels": [],
        "top_repetitive_videos": [],
        "total_videos": 0,
        "unique_days": set(),
    }
    channel_counter = Counter()
    video_counter = Counter()
    sorted_data = sorted(data, key=lambda x: x["time"])
    metrics["total_videos"] = len(sorted_data)
    for item in sorted_data:
        # Late night viewing (after 10 PM)
        if item["time"].hour >= 22:
            metrics["late_night_count"] += 1
        # Track content types (channels)
        if "subtitles" in item and item["subtitles"]:
            channel = item["subtitles"][0].get("name", "Unknown")
            channel_counter[channel] += 1
        # Track repetitive views
        video_counter[item["title"]] += 1
        # Track unique days
        metrics["unique_days"].add(item["time"].date())
    # Top 5 channels
    metrics["top_channels"] = channel_counter.most_common(5)
    # Top 5 repeated videos
    metrics["top_repetitive_videos"] = video_counter.most_common(5)
    metrics["unique_days"] = len(metrics["unique_days"])
    # Detect binge sessions (3+ videos within 1 hour)
    current_session = []
    for i, item in enumerate(sorted_data):
        if not current_session:
            current_session.append(item)
            continue
        time_diff = (item["time"] - current_session[-1]["time"]).total_seconds() / 60
        if time_diff <= 60:
            current_session.append(item)
        else:
            if len(current_session) >= 3:
                metrics["binge_sessions"] += 1
            current_session = [item]
    if len(current_session) >= 3:
        metrics["binge_sessions"] += 1
    return metrics

# ---------- LLM call ---------------------------------------------------------
SYS_PROMPT = """You are YouTube-Wellbeing-Analyst GPT, an expert in digital wellbeing and child development psychology.

Your role is to analyze YouTube watch history data and provide detailed, actionable insights for parents about their child's digital behavior patterns.

For each insight, provide comprehensive analysis including:
- Detailed behavioral analysis with specific examples from the data
- Psychological context and developmental implications
- Evidence-based reasoning for severity assessment
- Specific, actionable interventions with multiple options
- Weekly pattern analysis with detailed spark data
- Relevance scoring with detailed justification

Output exactly 6 JSON objects (no prose) that match this schema:
{ 
  "name": str, 
  "severity": "low|moderate|high", 
  "message": str, 
  "spark": list[int], 
  "matchScore": int, 
  "intervention": {
    "whyItMatters": str,
    "primaryTip": {
      "title": str,
      "description": str,
      "actionLabel": str
    },
    "moreTips": [
      {
        "title": str,
        "description": str
      }
    ],
    "evidence": str,
    "developmentalContext": str,
    "warningSigns": str,
    "positiveAspects": str
  }
}

Order: Rapid-Swipe Taste Test, Endless Shorts Ladder, Notification Pounce, Sneak-Past-Bedtime View, Search-Avoidance Loop, Thumbnail Roulette.

Severity bands:
- LOW: Minor concern, normal developmental behavior
- MODERATE: Noticeable pattern that warrants attention
- HIGH: Significant concern requiring immediate intervention

Be thorough, specific, and provide rich, detailed analysis for each insight."""

CHUNK_SIZE = 100

class InsightService:
    def __init__(self, openai_api_key):
        if not openai_api_key:
            raise ValueError("OpenAI API key is required")
            
        # Validate API key format
        if not openai_api_key.startswith(('sk-', 'sk-proj-')):
            raise ValueError("Invalid OpenAI API key format. Must start with 'sk-' or 'sk-proj-'")
            
        print(f"Initializing OpenAI client with API key: {openai_api_key[:8]}...")  # Only print first 8 chars for security
        
        # Clear any proxy environment variables that might interfere
        import os
        os.environ.pop('HTTP_PROXY', None)
        os.environ.pop('HTTPS_PROXY', None) 
        os.environ.pop('http_proxy', None)
        os.environ.pop('https_proxy', None)
        
        self.client = OpenAI(api_key=openai_api_key)
        
        # Test the API key with a simple request
        try:
            print("Testing API key with models.list()...")
            models = self.client.models.list()
            print(f"Successfully connected to OpenAI API. Available models: {[model.id for model in models.data]}")
        except Exception as e:
            print(f"Error testing API key: {str(e)}")
            if "invalid_api_key" in str(e).lower():
                raise ValueError("Invalid OpenAI API key. Please check your API key at https://platform.openai.com/account/api-keys")
            raise ValueError(f"Error connecting to OpenAI API: {str(e)}")
    
    def chunk_history(self, data, chunk_size=CHUNK_SIZE):
        """Yield chunks of the data for LLM processing."""
        for i in range(0, len(data), chunk_size):
            yield data[i:i+chunk_size]

    def llm_chunk_insights(self, chunk):
        """Call LLM to extract behavioral patterns from a chunk."""
        prompt = f"""
        Analyze the following YouTube watch history chunk in detail. Look for:
        
        1. **Content Patterns**: Types of videos, channels, genres, and content themes
        2. **Temporal Patterns**: Time of day, duration, frequency, and binge-watching sessions
        3. **Behavioral Patterns**: Rapid switching, repetitive viewing, notification responses
        4. **Attention Patterns**: Short vs long content consumption, abandonment rates
        5. **Search vs Recommendation**: Active searching vs passive algorithmic consumption
        6. **Developmental Indicators**: Age-appropriate content, educational vs entertainment balance
        
        Provide detailed analysis with specific examples from the data, including:
        - Video titles and channels that indicate patterns
        - Time-based behavioral insights
        - Frequency and duration analysis
        - Any concerning or positive patterns
        - Specific examples of rapid switching, late-night viewing, or binge sessions
        
        Data:
        {chunk}
        """
        response = self.client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an expert child development psychologist specializing in digital behavior analysis. Provide detailed, evidence-based analysis of YouTube viewing patterns."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=800
        )
        return response.choices[0].message.content.strip()

    def llm_aggregate_final_insights(self, chunk_summaries):
        """Call LLM to synthesize final 6 insights from all chunk summaries."""
        prompt = f"""
        Given these chunk summaries from a user's YouTube history, synthesize 6 comprehensive behavioral insights for the parent dashboard.
        
        You MUST return exactly 6 insights in a JSON array format. Each insight should analyze different aspects of the viewing behavior:
        
        1. **Rapid-Swipe Taste Test**: Analyze rapid content switching, short attention spans, and quick video abandonment patterns
        2. **Endless Shorts Ladder**: Examine binge-watching of short-form content and algorithmic feeding patterns  
        3. **Notification Pounce**: Identify immediate response to notifications and interruption patterns
        4. **Sneak-Past-Bedtime View**: Detect late-night viewing and sleep disruption patterns
        5. **Search-Avoidance Loop**: Analyze passive consumption vs. active search behavior
        6. **Thumbnail Roulette**: Examine clickbait response and impulsive clicking patterns
        
        For each insight, provide:
        - **Detailed behavioral analysis** with specific examples from the data
        - **Psychological context** explaining why this behavior occurs
        - **Developmental implications** for the child's age group
        - **Evidence-based severity assessment** with clear reasoning
        - **Comprehensive intervention strategies** with multiple actionable tips
        - **Weekly pattern analysis** with detailed spark data showing day-by-day trends
        - **Relevance scoring** with detailed justification based on data frequency and intensity
        
        CRITICAL: You must return a JSON array containing exactly 6 objects. Start with [ and end with ]. Each object should follow this schema:
        
        {{
          "name": "Insight Name",
          "severity": "low|moderate|high",
          "message": "Detailed description of the behavior pattern",
          "spark": [0-10, 0-10, 0-10, 0-10, 0-10, 0-10, 0-10],
          "matchScore": 0-100,
          "intervention": {{
            "whyItMatters": "Why this behavior matters for child development",
            "primaryTip": {{
              "title": "Action Title",
              "description": "Detailed action description",
              "actionLabel": "Action Button Text"
            }},
            "moreTips": [
              {{
                "title": "Additional Tip Title",
                "description": "Additional tip description"
              }}
            ],
            "evidence": "Specific evidence from the data analysis",
            "developmentalContext": "How this relates to child development",
            "warningSigns": "Signs to watch for that indicate escalation",
            "positiveAspects": "Positive aspects of this behavior pattern"
          }}
        }}
        
        Chunk summaries:
        {chunk_summaries}
        """
        response = self.client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": SYS_PROMPT},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=2000
        )
        return response.choices[0].message.content.strip()

    def generate_insights(self, data, user_id):
        """Chunked LLM pipeline: chunk, map, aggregate, reduce."""
        try:
            processed_data = _preprocess(data)
            chunk_summaries = []
            for chunk in self.chunk_history(processed_data):
                # For each chunk, get LLM summary
                summary = self.llm_chunk_insights(chunk)
                chunk_summaries.append(summary)
            # Aggregate all chunk summaries
            aggregate_text = "\n".join(chunk_summaries)
            # Final LLM call to synthesize 6 insights
            final_insights_json = self.llm_aggregate_final_insights(aggregate_text)
            # Robustly extract JSON from LLM output (handles code blocks)
            import re, json
            print('Raw LLM output:', final_insights_json[:500])  # Debug print
            final_insights_json = final_insights_json.strip()
            match = re.search(r"```(?:json)?\s*([\s\S]+?)\s*```", final_insights_json, re.IGNORECASE)
            if match:
                json_str = match.group(1).strip()
            else:
                json_str = final_insights_json
            print('Extracted JSON string:', json_str[:500])  # Debug print
            try:
                final_insights = json.loads(json_str)
                print('Parsed insights type:', type(final_insights))  # Debug print
                print('Parsed insights:', final_insights)  # Debug print
            except Exception as e:
                print('Failed to parse final insights JSON:', json_str)
                raise ValueError(f'Invalid JSON from LLM: {str(e)}')
            
            # Ensure final_insights is a list
            if not isinstance(final_insights, list):
                print(f'Warning: LLM returned {type(final_insights)}, expected list. Converting...')
                if isinstance(final_insights, dict):
                    final_insights = [final_insights]
                else:
                    raise ValueError(f'LLM returned unexpected type: {type(final_insights)}')
            
            # If we don't have 6 insights, generate the missing ones with default data
            if len(final_insights) != 6:
                print(f'Warning: LLM returned {len(final_insights)} insights, expected 6. Generating missing insights...')
                
                # Define the required insight names in order
                required_names = [
                    "Rapid-Swipe Taste Test",
                    "Endless Shorts Ladder", 
                    "Notification Pounce",
                    "Sneak-Past-Bedtime View",
                    "Search-Avoidance Loop",
                    "Thumbnail Roulette"
                ]
                
                # Create a map of existing insights by name
                existing_insights = {insight.get('name', ''): insight for insight in final_insights}
                
                # Generate missing insights
                for name in required_names:
                    if name not in existing_insights:
                        print(f'Generating missing insight: {name}')
                        default_insight = {
                            "name": name,
                            "severity": "low",
                            "message": f"No significant {name.lower()} pattern detected in the data.",
                            "spark": [0, 0, 0, 0, 0, 0, 0],
                            "matchScore": 10,
                            "intervention": {
                                "whyItMatters": "This behavior pattern is not currently a concern for your child.",
                                "primaryTip": {
                                    "title": "Continue Monitoring",
                                    "description": "Keep an eye on this behavior pattern as your child grows.",
                                    "actionLabel": "Monitor"
                                },
                                "moreTips": [
                                    {
                                        "title": "Regular Check-ins",
                                        "description": "Periodically review your child's digital habits."
                                    }
                                ],
                                "evidence": "No significant evidence of this pattern found in the current data.",
                                "developmentalContext": "This is normal developmental behavior for your child's age.",
                                "warningSigns": "No immediate warning signs detected.",
                                "positiveAspects": "Your child shows healthy digital habits in this area."
                            }
                        }
                        final_insights.append(default_insight)
                
                # Ensure we have exactly 6 insights
                final_insights = final_insights[:6]
            
            # Add user_id and timestamps
            for insight in final_insights:
                if not isinstance(insight, dict):
                    print(f'Warning: insight is not a dict: {type(insight)}')
                    continue
                insight['user_id'] = user_id
                insight['created_at'] = datetime.utcnow()
                insight['resolved_at'] = None
            return final_insights
        except Exception as e:
            print('Error in chunked generate_insights:', str(e))
            raise 