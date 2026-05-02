# ABOUTME: Channel quality classification module — seed lookup + LLM fallback + caching
# ABOUTME: Main entry point is get_channel_quality_summary(preprocessed_rows, db)

import os
import json
from datetime import datetime, timezone
from collections import defaultdict

from openai import OpenAI
from .channel_seed import normalize_channel_name, lookup_seed

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def classify_channels_llm(channels_with_titles, db):
    """
    Batch-classify up to 10 channels via GPT-3.5-turbo.
    channels_with_titles: list of {"name": str, "sample_titles": [str]}
    Returns list of {"name", "tier", "reason"}.
    """
    if not channels_with_titles:
        return []

    # Check cache first
    results = []
    uncached = []
    cache_col = db.channel_quality_cache

    for ch in channels_with_titles:
        norm = normalize_channel_name(ch["name"])
        cached = cache_col.find_one({"normalized_name": norm})
        if cached:
            results.append({
                "name": ch["name"],
                "tier": cached["tier"],
                "reason": cached["reason"],
                "source": "cache",
            })
        else:
            uncached.append(ch)

    if not uncached:
        return results

    # Batch up to 10 for LLM
    batch = uncached[:10]
    prompt_channels = []
    for ch in batch:
        titles = ", ".join(ch["sample_titles"][:5])
        prompt_channels.append(f'- {ch["name"]}: [{titles}]')

    prompt = (
        "Classify each YouTube channel as educational, neutral, or junk for children under 10.\n"
        "educational = teaches academic/life skills, neutral = age-appropriate entertainment, "
        "junk = hyper-stimulating, purchase-driven, clickbait, or inappropriate.\n\n"
        "Channels:\n" + "\n".join(prompt_channels) + "\n\n"
        'Return ONLY a JSON array: [{"name":"...","tier":"...","reason":"one sentence"}]'
    )

    try:
        resp = client.chat.completions.create(
            model="gpt-3.5-turbo",
            temperature=0.1,
            max_tokens=800,
            messages=[
                {"role": "system", "content": "You classify YouTube channels for a parental screen-time app. Return valid JSON only."},
                {"role": "user", "content": prompt},
            ],
        )
        raw = resp.choices[0].message.content.strip()
        # Extract JSON array from response
        start = raw.find("[")
        end = raw.rfind("]") + 1
        if start >= 0 and end > start:
            raw = raw[start:end]
        classifications = json.loads(raw)
    except Exception as e:
        print(f"LLM channel classification error: {e}")
        # Fallback: mark uncached as neutral
        classifications = [{"name": ch["name"], "tier": "neutral", "reason": "Could not classify"} for ch in batch]

    # Cache and collect results
    for cls in classifications:
        norm = normalize_channel_name(cls["name"])
        tier = cls.get("tier", "neutral")
        if tier not in ("educational", "neutral", "junk"):
            tier = "neutral"
        reason = cls.get("reason", "")

        cache_col.update_one(
            {"normalized_name": norm},
            {"$set": {
                "channel_name": cls["name"],
                "normalized_name": norm,
                "tier": tier,
                "reason": reason,
                "source": "llm",
                "confidence": 0.8,
                "classified_at": datetime.now(timezone.utc),
            }},
            upsert=True,
        )
        results.append({
            "name": cls["name"],
            "tier": tier,
            "reason": reason,
            "source": "llm",
        })

    return results


def get_channel_quality_summary(preprocessed_rows, db):
    """
    Main entry point. Takes preprocessed video rows (from _preprocess) and db handle.
    Returns {channels: [...], summary: {...}}.
    """
    if not preprocessed_rows:
        return {
            "channels": [],
            "summary": {
                "educational_pct": 0, "neutral_pct": 0, "junk_pct": 0,
                "total_minutes": 0, "good_minutes": 0,
            },
        }

    # Aggregate per-channel: total minutes + sample titles
    channel_data = defaultdict(lambda: {"minutes": 0.0, "titles": []})
    for row in preprocessed_rows:
        ch = row.get("channel") or "Unknown"
        channel_data[ch]["minutes"] += row.get("viewing_time", 0) / 60
        if len(channel_data[ch]["titles"]) < 5:
            channel_data[ch]["titles"].append(row.get("title", ""))

    # Sort by watch time descending, keep top 30 for classification
    sorted_channels = sorted(channel_data.items(), key=lambda x: x[1]["minutes"], reverse=True)
    top_channels = sorted_channels[:30]

    # Phase 1: seed lookup
    classified = []
    need_llm = []

    for ch_name, data in top_channels:
        seed = lookup_seed(ch_name)
        if seed:
            classified.append({
                "name": ch_name,
                "tier": seed["tier"],
                "reason": seed["reason"],
                "minutes": round(data["minutes"], 1),
                "source": "seed",
            })
        else:
            need_llm.append({
                "name": ch_name,
                "sample_titles": data["titles"],
                "minutes": data["minutes"],
            })

    # Phase 2: LLM classification for unknowns (batch of 10 at a time)
    for i in range(0, len(need_llm), 10):
        batch = need_llm[i:i + 10]
        llm_results = classify_channels_llm(batch, db)
        # Merge minutes back in
        minutes_map = {ch["name"]: ch["minutes"] for ch in batch}
        for r in llm_results:
            r["minutes"] = round(minutes_map.get(r["name"], 0), 1)
            classified.append(r)

    # Apply any user overrides stored in db
    override_col = db.channel_quality_overrides
    for ch in classified:
        norm = normalize_channel_name(ch["name"])
        # User overrides are per-user, but we don't have user_id here —
        # the caller should pass it. For now we check without user scope.
        override = override_col.find_one({"normalized_name": norm})
        if override:
            ch["tier"] = override["tier"]
            ch["source"] = "override"

    # Sort classified by minutes descending
    classified.sort(key=lambda c: c.get("minutes", 0), reverse=True)

    # Build summary
    total_minutes = sum(c.get("minutes", 0) for c in classified)
    tier_minutes = {"educational": 0, "neutral": 0, "junk": 0}
    for c in classified:
        tier_minutes[c.get("tier", "neutral")] += c.get("minutes", 0)

    good_minutes = tier_minutes["educational"] + tier_minutes["neutral"]

    summary = {
        "educational_pct": round(tier_minutes["educational"] / total_minutes * 100, 1) if total_minutes else 0,
        "neutral_pct": round(tier_minutes["neutral"] / total_minutes * 100, 1) if total_minutes else 0,
        "junk_pct": round(tier_minutes["junk"] / total_minutes * 100, 1) if total_minutes else 0,
        "total_minutes": round(total_minutes, 1),
        "good_minutes": round(good_minutes, 1),
    }

    return {"channels": classified, "summary": summary}
