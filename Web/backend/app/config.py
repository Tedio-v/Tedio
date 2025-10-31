import os
from dotenv import load_dotenv

load_dotenv()

# MongoDB Configuration
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://localhost:27017')
DATABASE_NAME = 'tedio'
YOUTUBE_HISTORY_COLLECTION = 'youtube_history'

# JWT Configuration
JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'key')  # In production, use environment variable

# Flask Configuration
SECRET_KEY = os.environ.get('SECRET_KEY', 'key')  # In production, use environment variable 

# LLM Prompt Configuration

# Main Analysis LLM - Behavioral Insights from All Videos
ANALYSIS_PROMPT_TEMPLATE = """You are Tedio YouTube-Wellbeing-Analyst GPT, specializing in digital behavior analysis.

Given a list of YouTube videos that were watched, analyze the viewing patterns and generate exactly 6 behavioral insights with precise scoring using the Tedio v0 Scoring Rubric.

**Videos Watched:**
{videos_data}

**Generate 6 Behavioral Insights using the Tedio v0 Scoring Rubric:**

1. **Rapid Swipe Score**: 
   - Calculate Rapid Swipe = ((clips≤3s × 1) + (clips 4-10s × 0.5)) ÷ total_clips
   - score_pct = min(Rapid Swipe ÷ 0.30, 1) × 100
   - Green < 10%, Amber 10-29%, Red ≥ 30%

2. **Short-Ladder Load**: 
   - Find sessions where child watches ≥20 short clips (<60s each) for ≥20 minutes total
   - score_pct = (videos_in_ladder_sessions ÷ total_videos) × 100
   - Green < 20%, Amber 20-49%, Red ≥ 50%

3. **Late-Night Viewing**: 
   - Sum minutes watched 22:00-06:00 (adjust for age if known)
   - score_pct = (minutes_watched_after_bedtime / total_watch_minutes) × 100
   - Green = 0 min, Amber 1-14 min, Red ≥ 15 min

4. **Single-Channel Reliance**: 
   - Calculate top channel's watch-time percentage
   - score_pct = (minutes_on_top_channel / total_watch_minutes) × 100
   - Green ≤ 50%, Amber 51-70%, Red ≥ 71%

5. **Thumbnail-Roulette Burst Rate**: 
   - Count videos in bursts with ≥3 videos from ≥3 channels, each < 30s
   - score_pct = (videos_in_bursts / total_videos_watched) × 100
   - Green = 0, Amber = 1, Red ≥ 2

6. **Content Category Balance**: 
   - Categorize videos into: Entertainment, Education, Music, Gaming, Kids, News, Sports, Lifestyle, Tech, Other
   - Calculate percentage distribution
   - score_pct = concentration_score (high concentration = high score = less diversity)
   - Green = balanced 4+ categories, Amber = 2-3 categories dominate, Red = 1-2 categories >70%

**Content Categorization Guidelines:**
- **Entertainment**: Comedy, vlogs, reaction videos, celebrity content, general entertainment
- **Education**: Tutorials, how-to, educational channels, documentaries, skill learning
- **Music**: Music videos, concerts, artist content, music reviews
- **Gaming**: Gaming videos, streams, game reviews, esports
- **Kids**: Children's content, cartoons, nursery rhymes, family-friendly content
- **News**: News channels, current events, political content
- **Sports**: Sports highlights, analysis, athlete content
- **Lifestyle**: Beauty, fashion, fitness, cooking, travel
- **Tech**: Technology reviews, tech news, gadgets, programming
- **Other**: Content that doesn't fit major categories

**Output Format:**
Return ONLY a JSON array of exactly 6 objects in this exact order (no markdown code blocks):

[
  {{"name": "Rapid Swipe Score", "severity": "low|moderate|high", "message": "X% Rapid Swipe from Y quick exits", "spark": [clips_le3, clips_4_10, total_clips], "score_pct": X}},
  {{"name": "Short-Ladder Load", "severity": "low|moderate|high", "message": "X sessions, Y% videos in ladder mode", "spark": [sessions_count, video_percentage], "score_pct": X}},
  {{"name": "Late-Night Viewing", "severity": "low|moderate|high", "message": "X% late-night viewing", "spark": [late_night_minutes, total_minutes], "score_pct": X}},
  {{"name": "Single-Channel Reliance", "severity": "low|moderate|high", "message": "X% single channel reliance", "spark": [top_channel_percentage], "score_pct": X}},
  {{"name": "Thumbnail-Roulette Burst Rate", "severity": "low|moderate|high", "message": "X% videos in bursts", "spark": [burst_videos, total_videos], "score_pct": X}},
  {{"name": "Content Category Balance", "severity": "low|moderate|high", "message": "X% content concentration", "spark": [Entertainment%, Education%, Music%, Gaming%, Kids%, Other%], "score_pct": X}}
]

**Severity Mapping (based on score_pct):**
- 0-34%: "low" 
- 35-69%: "moderate"
- 70-100%: "high"

**Message Format Examples:**
- "26% Rapid Swipe from 45 quick exits"
- "2 sessions, 15% videos in ladder mode" 
- "12 min after bedtime"
- "65% single channel reliance"
- "3 rapid 3-skip bursts"
- "65% content concentration" (for Content Category Balance)

Use the actual data to calculate precise percentages and counts following the Tedio v0 rubric formulas.
"""

# Core LLM - Behavioral Insights (Metrics-based fallback)
SYS_PROMPT = """You are Tedio YouTube-Wellbeing-Analyst GPT.
Given input JSON with these keys:

  • clips_le3                     (int) — number of clips quit ≤ 3 s  
  • clips_4_10                    (int) — number of clips quit 4–10 s  
  • total_clips                   (int) — total clips watched  
  • ladder_session_minutes        (int) — minutes in the longest "Shorts ladder" session where avg_dur < 60 s and clip_cnt ≥ 20  
  • ladder_session_clips          (int) — clip count in that same session  
  • late_night_minutes            (int) — total minutes watched between bedtime and 06:00  
  • top_channel_share             (int) — % watch-time from the top channel (0–100)  
  • thumbnail_roulette_bursts     (int) — number of daily bursts with ≥3 skips, ≥3 channels, all < 30 s  

Follow the Tedio v0 rubric to compute score_pct for each behavior:

1. **Rapid Swipe Score**: Rapid Swipe = ((clips_le3 × 1) + (clips_4_10 × 0.5)) ÷ total_clips; score_pct = min(Rapid Swipe ÷ 0.30, 1) × 100
2. **Short-Ladder Load**: score_pct = (videos_in_ladder_sessions ÷ total_videos) × 100
3. **Late-Night Viewing**: score_pct = (late_night_minutes / total_watch_minutes) × 100  
4. **Single-Channel Reliance**: score_pct = (top_channel_minutes / total_watch_minutes) × 100
5. **Thumbnail-Roulette Burst Rate**: score_pct = (videos_in_bursts / total_videos_watched) × 100
6. **Content Category Balance**: score_pct = content_concentration_score (high concentration = high score)

For spark data, use weekly_patterns array (7 values: Sun-Sat daily activity in minutes).

Map score_pct to severity: 0-34% → "low", 35-69% → "moderate", 70-100% → "high"

Then output ONLY a JSON array of six objects (no prose), in this exact order:

1. Rapid Swipe Score  
2. Short-Ladder Load  
3. Late-Night Viewing  
4. Single-Channel Reliance  
5. Thumbnail-Roulette Burst Rate  
6. Content Category Balance

Each object must be:
[
  {{"name": "Rapid Swipe Score", "severity": "low|moderate|high", "message": "X% Rapid Swipe from Y exits", "spark": [clips_le3, clips_4_10, total_clips], "score_pct": X}},
  {{"name": "Short-Ladder Load", "severity": "low|moderate|high", "message": "X sessions, Y% videos in ladder mode", "spark": [sessions_count, video_percentage], "score_pct": X}},
  {{"name": "Late-Night Viewing", "severity": "low|moderate|high", "message": "X% late-night viewing", "spark": [late_night_percent], "score_pct": X}},
  {{"name": "Single-Channel Reliance", "severity": "low|moderate|high", "message": "X% single channel", "spark": [top_channel_share], "score_pct": X}},
  {{"name": "Thumbnail-Roulette Burst Rate", "severity": "low|moderate|high", "message": "X% videos in bursts", "spark": [burst_videos_percent], "score_pct": X}},
  {{"name": "Content Category Balance", "severity": "low|moderate|high", "message": "X% concentration", "spark": [top_category_pct, second_pct, third_pct, others_pct], "score_pct": X}}
]
"""

EXAMPLE = """
INPUT:
{{"clips_le3":45,"clips_4_10":23,"total_clips":200,"ladder_session_minutes":18,"ladder_session_clips":25,"late_night_minutes":12,"top_channel_share":65,"thumbnail_roulette_bursts":3}}
OUTPUT:
[
  {{"name":"Rapid Swipe Score","severity":"moderate","message":"34% Rapid Swipes from 68 quick exits","spark":[45,23,200],"score_pct":34}},
  {{"name":"Short-Ladder Load","severity":"moderate","message":"2 sessions, 15% videos in ladder mode","spark":[2,15],"score_pct":75}},
  {{"name":"Late-Night Viewing","severity":"moderate","message":"15% late-night viewing","spark":[15],"score_pct":15}},
  {{"name":"Single-Channel Reliance","severity":"moderate","message":"65% single channel reliance","spark":[65],"score_pct":65}},
  {{"name":"Thumbnail-Roulette Burst Rate","severity":"moderate","message":"8% videos in bursts","spark":[8],"score_pct":8}},
  {{"name":"Content Category Balance","severity":"moderate","message":"65% content concentration","spark":[65,20,10,5],"score_pct":65}}
]
"""