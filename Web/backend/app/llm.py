# insights_endpoint.py - FIXED VERSION with Time Gap Inference
import os, json, re
from datetime import datetime, timezone
from collections import Counter, defaultdict

from flask import Flask, request, jsonify
from openai import OpenAI

from .config import SYS_PROMPT, EXAMPLE, ANALYSIS_PROMPT_TEMPLATE

# Initialize OpenAI client - disable proxy usage
import os
# Clear any proxy environment variables that might interfere
os.environ.pop('HTTP_PROXY', None)
os.environ.pop('HTTPS_PROXY', None) 
os.environ.pop('http_proxy', None)
os.environ.pop('https_proxy', None)

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = Flask(__name__)

# ---------- helpers ----------------------------------------------------------
def _local_dt(iso_z):
    """UTC-ISO-Z → local datetime - handles multiple formats and converts to America/Chicago timezone (patch)."""
    # List of possible formats to try
    formats = [
        "%Y-%m-%dT%H:%M:%S.%fZ",      # 2023-08-30T01:56:18.123Z
        "%Y-%m-%dT%H:%M:%SZ",         # 2023-08-30T01:56:18Z
        "%Y-%m-%dT%H:%M:%S.%f+00:00", # 2023-08-30T01:56:18.123+00:00
        "%Y-%m-%dT%H:%M:%S+00:00",    # 2023-08-30T01:56:18+00:00
        "%Y-%m-%dT%H:%M:%S.%f",       # 2023-08-30T01:56:18.123 (assume UTC)
        "%Y-%m-%dT%H:%M:%S",          # 2023-08-30T01:56:18 (assume UTC)
    ]
    from datetime import datetime, timezone
    try:
        from zoneinfo import ZoneInfo
        user_tz = ZoneInfo("America/Chicago")  # TODO: Use user profile timezone
    except ImportError:
        import pytz
        user_tz = pytz.timezone("America/Chicago")
    for fmt in formats:
        try:
            dt = datetime.strptime(iso_z, fmt)
            dt = dt.replace(tzinfo=timezone.utc)
            local_dt = dt.astimezone(user_tz)
            return local_dt
        except Exception:
            continue
    try:
        clean_time = iso_z.replace('Z', '').replace('+00:00', '')
        if '.' in clean_time:
            utc = datetime.strptime(clean_time, "%Y-%m-%dT%H:%M:%S.%f").replace(tzinfo=timezone.utc)
        else:
            utc = datetime.strptime(clean_time, "%Y-%m-%dT%H:%M:%S").replace(tzinfo=timezone.utc)
        return utc.astimezone(user_tz)
    except Exception as e:
        print(f"Warning: Could not parse date '{iso_z}': {e}")
        return datetime.now().replace(tzinfo=timezone.utc).astimezone(user_tz)

def calculate_viewing_times_from_gaps(rows):
    """
    IMPROVED: Calculate viewing time based on gaps with better logic
    Avoids arbitrary defaults that cause consistent results
    """
    if not rows:
        return rows
    
    # Calculate statistics for better inference
    all_gaps = []
    for i in range(len(rows) - 1):
        gap = (rows[i + 1]["dt"] - rows[i]["dt"]).total_seconds()
        if gap > 0:  # Only positive gaps
            all_gaps.append(gap)
    
    # Calculate median and percentiles for adaptive thresholds
    if all_gaps:
        all_gaps.sort()
        median_gap = all_gaps[len(all_gaps) // 2]
        p75_gap = all_gaps[int(len(all_gaps) * 0.75)] if len(all_gaps) > 3 else median_gap
    else:
        median_gap = 60  # 1 minute default
        p75_gap = 180    # 3 minutes default
    
    print(f"Gap statistics: median={median_gap:.1f}s, p75={p75_gap:.1f}s")
    
    for i, video in enumerate(rows):
        if i < len(rows) - 1:
            next_video = rows[i + 1]
            gap_seconds = (next_video["dt"] - video["dt"]).total_seconds()
            
            # Adaptive thresholds based on data patterns
            if gap_seconds <= 3:
                # Definite rapid swipe
                video["viewing_time"] = gap_seconds
            elif gap_seconds <= 15:
                # Brief viewing - use most of the gap
                video["viewing_time"] = gap_seconds * 0.9
            elif gap_seconds <= 60:
                # Short viewing - moderate discount for other activities
                video["viewing_time"] = gap_seconds * 0.8
            elif gap_seconds <= median_gap:
                # Medium viewing - use data-driven threshold
                video["viewing_time"] = gap_seconds * 0.7
            elif gap_seconds <= p75_gap:
                # Longer viewing - more conservative
                video["viewing_time"] = gap_seconds * 0.5
            else:
                # Very long gaps - use adaptive estimate based on user's median
                # This prevents always defaulting to 180 seconds
                adaptive_estimate = min(median_gap * 0.8, 300)  # Cap at 5 minutes
                video["viewing_time"] = adaptive_estimate
        else:
            # Last video - use adaptive estimate instead of fixed 120 seconds
            if all_gaps:
                # Use median of user's typical gaps
                video["viewing_time"] = min(median_gap * 0.6, 240)  # Cap at 4 minutes
            else:
                video["viewing_time"] = 90  # Smaller default
    
    # Debug: Show distribution of viewing times
    viewing_times = [r["viewing_time"] for r in rows]
    if viewing_times:
        print(f"Viewing times: min={min(viewing_times):.1f}s, max={max(viewing_times):.1f}s, avg={sum(viewing_times)/len(viewing_times):.1f}s")
    
    return rows

def _preprocess(items):
    """
    FIXED: Now uses time gap inference instead of static duration estimates
    → list of dicts with: video_id, title, channel, dt, date, viewing_time
    """
    rows = []
    for it in items:
        try:
            # Handle missing or malformed data
            if not isinstance(it, dict):
                continue
                
            title_url = it.get("titleUrl", "")
            if not title_url or "v=" not in title_url:
                continue
                
            title = it.get("title", "")
            if not title:
                continue
                
            # Extract video ID safely
            video_id = title_url.split("v=")[-1].split("&")[0]
            
            # Clean title
            clean_title = re.sub(r"^Watched\s+", "", title)
            
            # Extract channel name safely
            subtitles = it.get("subtitles", [])
            channel = subtitles[0].get("name") if subtitles and len(subtitles) > 0 else "Unknown"
            
            # Parse time safely
            time_str = it.get("time", "")
            if not time_str:
                continue
                
            dt = _local_dt(time_str)
            
            rows.append({
                "video_id": video_id,
                "title": clean_title,
                "channel": channel,
                "dt": dt,
                # Note: viewing_time will be calculated after sorting
            })
        except Exception as e:
            print(f"Warning: Skipping malformed item: {e}")
            continue
    
    # Sort by time first
    rows.sort(key=lambda r: r["dt"])
    
    # FIXED: Calculate viewing times from time gaps
    rows = calculate_viewing_times_from_gaps(rows)
    
    # Add date field
    for r in rows:
        r["date"] = r["dt"].date()
    
    return rows

# ---------- chunking helpers -------------------------------------------------
def chunk_videos(videos, chunk_size=200):
    """Chunk videos into smaller batches for processing"""
    for i in range(0, len(videos), chunk_size):
        yield videos[i:i+chunk_size]

def classify_content_categories(rows):
    """
    Classify videos into categories using LLM and calculate concentration score.
    Per product requirement, we only persist five main categories plus an Other bucket:
    Education, Kids, Music, Sports, Gaming, Other.
    """
    if not rows or len(rows) == 0:
        return {}, 0
    
    # Extract unique titles and channels for classification
    video_samples = []
    for r in rows[:50]:  # Sample first 50 videos for classification
        video_samples.append({
            'title': r['title'],
            'channel': r['channel'],
            'viewing_time': r['viewing_time']
        })
    
    # Simplified prompt for content classification limited to the 5 categories (+Other)
    video_titles = [v['title'][:50] for v in video_samples]  # Truncate titles to avoid JSON issues
    classification_prompt = f"""
    Classify these YouTube video titles into categories. Return ONLY a JSON array with one category name per video.

    Categories: Education, Kids, Music, Sports, Gaming, Other

    Video titles: {video_titles}

    Return format: ["Entertainment", "Music", "Gaming", "Kids", "Other", ...]
    """
    
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a content classifier. Return only a JSON array of category names."},
                {"role": "user", "content": classification_prompt}
            ],
            temperature=0.1,
            max_tokens=500
        )
        
        import json
        import re
        categories_result = response.choices[0].message.content.strip()
        print(f"LLM classification response: {categories_result[:200]}")
        
        # Clean up response - extract JSON array
        categories_result = re.sub(r'^[^[\]]*', '', categories_result)  # Remove text before [
        categories_result = re.sub(r'[^[\]]*$', '', categories_result)  # Remove text after ]
        if not categories_result.startswith('['):
            categories_result = '[' + categories_result + ']'
        
        video_categories = json.loads(categories_result)
        
        # Count category distribution
        from collections import Counter
        category_counts = Counter(video_categories)
        
        # Calculate percentages for the five target categories only.
        total_classified = len(video_categories)
        target_categories = ["Education", "Kids", "Music", "Sports", "Gaming"]
        # Map any non-target to Other
        other_count = sum(count for cat, count in category_counts.items() if cat not in target_categories)
        dist_counts = {cat: category_counts.get(cat, 0) for cat in target_categories}
        dist_counts["Other"] = other_count

        category_distribution = {
            cat: round((count / total_classified) * 100, 1) if total_classified else 0.0
            for cat, count in dist_counts.items()
        }
        
        # Calculate concentration score (higher = less diverse)
        # Top category percentage among the five primary categories
        if category_distribution:
            top_primary = max(category_distribution.get(c, 0) for c in target_categories)
            content_concentration_score = top_primary
        else:
            content_concentration_score = 0
            
        print(f"Category distribution: {category_distribution}")
        print(f"Content concentration score: {content_concentration_score}")
        
        return category_distribution, content_concentration_score
        
    except Exception as e:
        print(f"Error in content classification: {e}")
        # Fallback: use channel-based simple classification
        return {"Other": 100.0}, 50.0

def generate_weekly_patterns(rows):
    """Generate weekly activity patterns for spark data (7 days: Sun-Sat)"""
    if not rows:
        return [0, 0, 0, 0, 0, 0, 0]
    
    # Group by day of week (0=Monday, 6=Sunday)
    weekly_activity = [0] * 7
    for r in rows:
        day_of_week = r["dt"].weekday()  # 0=Monday, 6=Sunday
        weekly_activity[day_of_week] += r["viewing_time"] / 60  # Convert to minutes
    
    # Reorder to start with Sunday (Sunday=0, Monday=1, ..., Saturday=6)
    # Python weekday: Monday=0, Sunday=6
    # We want: Sunday=0, Monday=1, ..., Saturday=6  
    reordered = [
        weekly_activity[6],  # Sunday (was index 6)
        weekly_activity[0],  # Monday (was index 0)
        weekly_activity[1],  # Tuesday
        weekly_activity[2],  # Wednesday  
        weekly_activity[3],  # Thursday
        weekly_activity[4],  # Friday
        weekly_activity[5],  # Saturday (was index 5)
    ]
    
    return [round(x) for x in reordered]

def aggregate_metrics(all_metrics):
    """Aggregate metrics from multiple chunks"""
    if not all_metrics:
        return {}
    
    total_clips = sum(m['total_clips'] for m in all_metrics)
    total_watch_minutes = sum(m['total_watch_minutes'] for m in all_metrics)
    total_thumbnail_videos = sum(m['thumbnail_roulette_videos_count'] for m in all_metrics)
    total_late_night_minutes = sum(m['late_night_minutes'] for m in all_metrics)
    
    # Aggregate category distributions (use the one with most content)
    content_concentration_score = max((m['content_category_balance_score'] for m in all_metrics), default=0)
    category_distribution = max((m['category_distribution'] for m in all_metrics), key=lambda d: sum(d.values()) if d else 0, default={})
    
    # Aggregate weekly patterns (sum across chunks)
    weekly_patterns = [0] * 7
    for m in all_metrics:
        if 'weekly_patterns' in m and m['weekly_patterns']:
            for i, val in enumerate(m['weekly_patterns'][:7]):  # Ensure max 7 days
                weekly_patterns[i] += val
    
    return {
        'clips_le3': sum(m['clips_le3'] for m in all_metrics),
        'clips_4_10': sum(m['clips_4_10'] for m in all_metrics), 
        'total_clips': total_clips,
        'total_watch_minutes': total_watch_minutes,
        'short_ladder_load_score': (sum(m.get('total_ladder_videos', 0) for m in all_metrics) / total_clips * 100) if total_clips > 0 else 0,
        'total_ladder_videos': sum(m.get('total_ladder_videos', 0) for m in all_metrics),
        'ladder_sessions_count': sum(m.get('ladder_sessions_found', 0) for m in all_metrics),
        'thumbnail_roulette_score': (total_thumbnail_videos / total_clips * 100) if total_clips > 0 else 0,
        'late_night_score': (total_late_night_minutes / total_watch_minutes * 100) if total_watch_minutes > 0 else 0,
        'single_channel_score': max((m['single_channel_score'] for m in all_metrics), default=0),
        'rapid_swipe_score': min(((sum(m['clips_le3'] for m in all_metrics) + 0.5 * sum(m['clips_4_10'] for m in all_metrics)) / total_clips) / 0.30, 1) * 100 if total_clips > 0 else 0,
        'content_category_balance_score': content_concentration_score,
        'category_distribution': category_distribution,
        'weekly_patterns': weekly_patterns
    }

# ---------- FIXED feature extraction -------------------------
def build_metrics(rows):
    """
    FIXED: Now uses actual viewing_time from time gap inference
    Return the metrics dict to feed the LLM with behavioral analysis format.
    """
    if not rows:
        return {
            'clips_le3': 0, 'clips_4_10': 0, 'total_clips': 0,
            'total_watch_minutes': 0, 'short_ladder_load_score': 0,
            'late_night_score': 0, 'single_channel_score': 0,
            'rapid_swipe_score': 0, 'thumbnail_roulette_score': 0,
            'thumbnail_roulette_videos_count': 0, 'late_night_minutes': 0,
            'content_category_balance_score': 0, 'category_distribution': {},
            'weekly_patterns': generate_weekly_patterns([])
        }

    # Group by date for analysis
    by_date = defaultdict(list)
    for r in rows:
        by_date[r["date"]].append(r)

    # Calculate gap statistics for adaptive thresholds
    all_gaps = []
    for i in range(len(rows) - 1):
        gap = (rows[i + 1]["dt"] - rows[i]["dt"]).total_seconds()
        if gap > 0:
            all_gaps.append(gap)
    
    if all_gaps:
        all_gaps.sort()
        median_gap = all_gaps[len(all_gaps) // 2]
    else:
        median_gap = 60  # 1 minute default

    # Debug: Print first 5 viewing times (should now be varied, not uniform)
    print("Sample viewing times:", [r["viewing_time"] for r in rows[:5]])

    # Calculate total watch time
    total_watch_minutes = sum(r["viewing_time"] for r in rows) / 60

    # 1. Rapid-Swipe Score (RSI) - CORRECTED per specification
    clips_le3 = sum(1 for r in rows if r["viewing_time"] <= 3)
    clips_4_10 = sum(1 for r in rows if 4 <= r["viewing_time"] <= 10)
    total_clips = len(rows)
    
    if total_clips > 0:
        rsi = (clips_le3 + 0.5 * clips_4_10) / total_clips
        rapid_swipe_score = min(rsi / 0.30, 1) * 100
    else:
        rapid_swipe_score = 0

    # 2. Short-Ladder Load - Proper implementation
    # Step 1: Sessionize with 30-minute gaps
    sessions = []
    current_session = []
    session_gap_threshold = 30 * 60  # 30 minutes in seconds
    
    for r in rows:
        if current_session:
            gap_seconds = (r["dt"] - current_session[-1]["dt"]).total_seconds()
            if gap_seconds > session_gap_threshold:
                sessions.append(current_session)
                current_session = [r]
            else:
                current_session.append(r)
        else:
            current_session = [r]
    
    if current_session:
        sessions.append(current_session)
    
    # Step 2: Identify short clips (< 60s viewing time)
    short_clip_threshold = 60  # seconds
    
    # Step 3: Find ladder sessions
    ladder_sessions = []
    total_ladder_videos = 0
    
    for session in sessions:
        # Filter to only short clips in this session
        short_clips = [r for r in session if r["viewing_time"] < short_clip_threshold]
        
        if len(short_clips) >= 20:  # At least 20 clips
            total_time_seconds = sum(r["viewing_time"] for r in short_clips)
            total_time_minutes = total_time_seconds / 60
            avg_duration = total_time_seconds / len(short_clips)
            
            if total_time_minutes >= 20 and avg_duration < 60:  # 20+ minutes total, avg < 60s
                ladder_sessions.append({
                    'clip_count': len(short_clips),
                    'total_time_minutes': total_time_minutes,
                    'avg_duration': avg_duration
                })
                total_ladder_videos += len(short_clips)
                print(f"Short ladder session found: {len(short_clips)} clips, {avg_duration:.1f}s avg, {total_time_minutes:.1f} minutes")
    
    # Step 4: Calculate metrics
    if ladder_sessions:
        # Total time across all ladder sessions
        total_ladder_minutes = sum(s['total_time_minutes'] for s in ladder_sessions)
        # Score: percentage of videos that were in ladder sessions (more intuitive)
        ladder_video_percentage = (total_ladder_videos / total_clips) * 100 if total_clips > 0 else 0
        short_ladder_load_score = ladder_video_percentage
    else:
        short_ladder_load_score = 0
        total_ladder_minutes = 0
        ladder_video_percentage = 0
    
    # Keep for aggregation
    total_minutes_in_short_sessions = total_ladder_minutes
    short_sessions_found = len(ladder_sessions)
    
    print(f"Found {len(ladder_sessions)} ladder sessions, {total_ladder_videos} videos ({ladder_video_percentage:.1f}%), {total_ladder_minutes:.1f} minutes total")

    # 3. Late-Night Viewing - CORRECTED per specification  
    late_night_minutes = sum(
        r["viewing_time"] for r in rows 
        if r["dt"].hour >= 22 or r["dt"].hour < 6  # TODO: Use age-appropriate bedtime
    ) / 60
    
    if total_watch_minutes > 0:
        late_night_score = (late_night_minutes / total_watch_minutes) * 100
    else:
        late_night_score = 0

    # 4. Single-Channel Reliance - ALREADY CORRECT per specification
    channel_viewing_time = defaultdict(float)
    for r in rows:
        channel_viewing_time[r["channel"] or "Unknown"] += r["viewing_time"]
    
    if channel_viewing_time and total_watch_minutes > 0:
        top_channel_time = max(channel_viewing_time.values()) / 60
        single_channel_score = (top_channel_time / total_watch_minutes) * 100
    else:
        single_channel_score = 0

    # 5. Thumbnail-Roulette Burst Rate - CORRECTED per specification
    thumbnail_roulette_videos_count = 0
    for day_rows in by_date.values():
        # Group by hour to find bursts
        by_hour = defaultdict(list)
        for r in day_rows:
            by_hour[r["dt"].hour].append(r)
        
        for hour_rows in by_hour.values():
            if len(hour_rows) >= 3:
                # Check for burst: ≥3 videos from ≥3 channels, each <30s
                quick_views = [r for r in hour_rows if r["viewing_time"] < 30]
                channels = set(r["channel"] for r in quick_views if r["channel"])
                
                if len(quick_views) >= 3 and len(channels) >= 3:
                    # Count all videos in this burst
                    thumbnail_roulette_videos_count += len(quick_views)

    # Calculate as percentage of total videos
    if total_clips > 0:
        thumbnail_roulette_score = (thumbnail_roulette_videos_count / total_clips) * 100
    else:
        thumbnail_roulette_score = 0

    # 6. Content Category Balance - LLM-based classification
    category_distribution, content_concentration_score = classify_content_categories(rows)

    # 7. Generate weekly activity patterns
    weekly_patterns = generate_weekly_patterns(rows)

    metrics = {
        'clips_le3': clips_le3,
        'clips_4_10': clips_4_10,
        'total_clips': total_clips,
        'total_watch_minutes': total_watch_minutes,
        'short_ladder_load_score': short_ladder_load_score,
        'ladder_sessions_found': len(ladder_sessions),  # Track for debugging
        'total_ladder_videos': total_ladder_videos,  # Keep for aggregation
        'ladder_video_percentage': ladder_video_percentage,
        'total_minutes_in_short_sessions': total_minutes_in_short_sessions,  # Keep for aggregation
        'late_night_score': late_night_score,
        'late_night_minutes': late_night_minutes,  # Keep for aggregation
        'single_channel_score': single_channel_score,
        'rapid_swipe_score': rapid_swipe_score,
        'thumbnail_roulette_score': thumbnail_roulette_score,
        'thumbnail_roulette_videos_count': thumbnail_roulette_videos_count,  # Keep for aggregation
        'content_category_balance_score': content_concentration_score,
        'category_distribution': category_distribution,  # Keep for aggregation
        'weekly_patterns': weekly_patterns,  # 7-day activity pattern
    }
    
    print("\n===== DETAILED METRICS DEBUG =====")
    print(f"Total videos processed: {len(rows)}")
    print(f"Total watch time: {total_watch_minutes:.1f} minutes")
    print(f"Median gap between videos: {median_gap:.1f} seconds")
    print(f"Clips ≤3s: {clips_le3} ({clips_le3/total_clips*100:.1f}%)")
    print(f"Clips 4-10s: {clips_4_10} ({clips_4_10/total_clips*100:.1f}%)")
    print(f"Rapid swipe score: {rapid_swipe_score:.1f}")
    print(f"Short ladder load: {short_ladder_load_score:.1f}% ({len(ladder_sessions)} sessions, {total_ladder_videos} videos, {ladder_video_percentage:.1f}%)")
    print(f"Late night minutes: {late_night_minutes:.1f} ({late_night_score:.1f}%)")
    print(f"Single channel score: {single_channel_score:.1f}")
    print(f"Thumbnail roulette videos: {thumbnail_roulette_videos_count} ({thumbnail_roulette_score:.1f}%)")
    print("All metrics:")
    for k, v in metrics.items():
        if isinstance(v, (int, float)):
            print(f"  {k}: {v:.1f}")
        else:
            print(f"  {k}: {v}")
    print("=======================================\n")
    
    return metrics

# ---------- Core LLM call ---------------------------------------------------------
def call_llm(metrics):
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        temperature=0.2,
        messages=[
            {"role": "system", "content": SYS_PROMPT},
            {"role": "user", "content": EXAMPLE.strip()},
            {"role": "user", "content": f"INPUT:\n{json.dumps(metrics)}\nOUTPUT:"},
        ],
    )
    text = resp.choices[0].message.content.strip()
    try:
        insights = json.loads(text)
        
        # Add weekly_patterns and category_distribution to each insight
        weekly_patterns = metrics.get('weekly_patterns', [0, 0, 0, 0, 0, 0, 0])
        category_distribution = metrics.get('category_distribution', {})
        for insight in insights:
            insight['spark'] = weekly_patterns
            insight['category_distribution'] = category_distribution
            
        return insights
    except Exception as e:
        print("\n===== RAW LLM OUTPUT (INVALID JSON) =====")
        print(text)
        print("========================================\n")
        raise

# ---------- FIXED Main processing pipeline ---------------------------------------------------------
def process_youtube_history(watch_history):
    """
    FIXED: Chunked metrics-based pipeline with time gap inference
    """
    print("Starting FIXED chunked metrics-based analysis...")
    
    # Preprocess videos (now includes time gap inference)
    rows = _preprocess(watch_history)
    print(f"Preprocessed {len(rows)} videos from history")
    
    if len(rows) == 0:
        print("No videos found in history. Returning empty insights.")
        return []
    
    # Process in chunks and aggregate metrics
    print(f"Processing {len(rows)} videos in chunks of 200...")
    all_metrics = []
    
    for i, chunk in enumerate(chunk_videos(rows, chunk_size=200)):
        print(f"Processing chunk {i+1}, size: {len(chunk)}")
        chunk_metrics = build_metrics(chunk)
        all_metrics.append(chunk_metrics)
    
    # Aggregate all metrics
    final_metrics = aggregate_metrics(all_metrics)
    print(f"Aggregated metrics from {len(all_metrics)} chunks")
    print(f"Final aggregated metrics: {final_metrics}")
    
    # Generate insights from aggregated metrics
    insights = call_llm(final_metrics)
    print(f"Generated {len(insights)} insights from aggregated metrics")
    
    # Extract total watch minutes for frontend summary
    total_watch_minutes = final_metrics.get('total_watch_minutes', 0)
    
    return insights, total_watch_minutes

# ---------- Flask route ------------------------------------------------------
@app.route("/insights", methods=["POST"])
def insights():
    """
    POST /insights
    Body: JSON array of raw watch-history items.
    Response: list of insight objects.
    """
    items = request.get_json(force=True)
    insights, total_watch_minutes = process_youtube_history(items)
    return jsonify(insights)