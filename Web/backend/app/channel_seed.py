# ABOUTME: Seed list of ~100 top kids YouTube channels with quality tier classifications
# ABOUTME: Used as a fast lookup before falling back to LLM classification

import re

SEED_CHANNELS = {
    # ── Educational ──
    "ms rachel": {"tier": "educational", "reason": "Speech and language development for toddlers"},
    "ms rachel - songs for littles": {"tier": "educational", "reason": "Speech and language development for toddlers"},
    "sesame street": {"tier": "educational", "reason": "Foundational literacy and social-emotional learning"},
    "numberblocks": {"tier": "educational", "reason": "Math concepts through animated number characters"},
    "alphablocks": {"tier": "educational", "reason": "Phonics and letter recognition"},
    "khan academy kids": {"tier": "educational", "reason": "Structured early learning curriculum"},
    "crashcourse kids": {"tier": "educational", "reason": "Science and social studies for elementary"},
    "crashcourse": {"tier": "educational", "reason": "Academic subjects explained engagingly"},
    "national geographic kids": {"tier": "educational", "reason": "Nature and science exploration"},
    "sci show kids": {"tier": "educational", "reason": "Age-appropriate science experiments and explanations"},
    "free school": {"tier": "educational", "reason": "Art, music, and history for kids"},
    "peekaboo kidz": {"tier": "educational", "reason": "Science and general knowledge for kids"},
    "dr binocs show": {"tier": "educational", "reason": "Animated science facts for children"},
    "homeschool pop": {"tier": "educational", "reason": "Educational videos aligned with school curriculum"},
    "ted-ed": {"tier": "educational", "reason": "Animated educational lessons on diverse topics"},
    "brain candy tv": {"tier": "educational", "reason": "Colors, shapes, and early learning concepts"},
    "jack hartmann kids music channel": {"tier": "educational", "reason": "Educational songs for counting, reading, movement"},
    "super simple songs": {"tier": "educational", "reason": "Educational nursery rhymes and learning songs"},
    "the singing walrus": {"tier": "educational", "reason": "Educational songs for phonics and math"},
    "art for kids hub": {"tier": "educational", "reason": "Step-by-step drawing tutorials for children"},
    "mystery doug": {"tier": "educational", "reason": "Answers kids' science questions with experiments"},
    "storybots": {"tier": "educational", "reason": "Educational content about science, reading, and math"},
    "learning time with timmy": {"tier": "educational", "reason": "English language learning for young children"},
    "daniel tiger's neighbourhood": {"tier": "educational", "reason": "Social-emotional learning based on Fred Rogers' work"},
    "curious george": {"tier": "educational", "reason": "STEM concepts through storytelling"},
    "sid the science kid": {"tier": "educational", "reason": "Science exploration for preschoolers"},
    "wild kratts": {"tier": "educational", "reason": "Animal science and biology for kids"},
    "odd squad": {"tier": "educational", "reason": "Math skills through detective stories"},
    "wordworld": {"tier": "educational", "reason": "Phonics and word building for early readers"},
    "do you know": {"tier": "educational", "reason": "BBC educational series about how things work"},
    "operation ouch": {"tier": "educational", "reason": "Human body and medicine for kids"},
    "mark rober": {"tier": "educational", "reason": "Engineering and science experiments"},

    # ── Neutral ──
    "bluey": {"tier": "neutral", "reason": "High-quality family storytelling with emotional depth"},
    "peppa pig": {"tier": "neutral", "reason": "Simple stories about family and daily life"},
    "paw patrol": {"tier": "neutral", "reason": "Adventure stories with teamwork themes"},
    "cocomelon": {"tier": "neutral", "reason": "Nursery rhymes with basic learning elements"},
    "cocomelon - nursery rhymes": {"tier": "neutral", "reason": "Nursery rhymes with basic learning elements"},
    "pbs kids": {"tier": "neutral", "reason": "Mix of educational and entertainment content"},
    "disney junior": {"tier": "neutral", "reason": "Character-driven stories for young kids"},
    "nick jr": {"tier": "neutral", "reason": "Preschool entertainment with some learning"},
    "thomas and friends": {"tier": "neutral", "reason": "Stories about friendship and problem-solving"},
    "pokemon": {"tier": "neutral", "reason": "Adventure anime with strategy and friendship themes"},
    "pokemon kids tv": {"tier": "neutral", "reason": "Curated Pokemon content for younger viewers"},
    "lego": {"tier": "neutral", "reason": "Creative building and storytelling content"},
    "playmobil": {"tier": "neutral", "reason": "Animated adventure stories"},
    "hey bear sensory": {"tier": "neutral", "reason": "Sensory videos for babies and toddlers"},
    "little baby bum": {"tier": "neutral", "reason": "Nursery rhymes and simple songs for toddlers"},
    "dave and ava": {"tier": "neutral", "reason": "Nursery rhymes with basic educational elements"},
    "babybus": {"tier": "neutral", "reason": "Animated nursery rhymes and basic safety lessons"},
    "booba": {"tier": "neutral", "reason": "Non-verbal slapstick comedy for young kids"},
    "oddbods": {"tier": "neutral", "reason": "Non-verbal comedy shorts for kids"},
    "shaun the sheep": {"tier": "neutral", "reason": "Clever stop-motion comedy from Aardman"},
    "ben and holly's little kingdom": {"tier": "neutral", "reason": "Gentle fantasy stories from Peppa Pig creators"},
    "fireman sam": {"tier": "neutral", "reason": "Safety-themed adventure stories"},
    "bob the builder": {"tier": "neutral", "reason": "Problem-solving and teamwork themes"},
    "postman pat": {"tier": "neutral", "reason": "Community-focused gentle stories"},
    "octonauts": {"tier": "neutral", "reason": "Marine biology adventures with learning elements"},
    "miraculous ladybug": {"tier": "neutral", "reason": "Animated superhero stories for older kids"},
    "gravity falls": {"tier": "neutral", "reason": "Mystery adventure with strong storytelling"},
    "the amazing world of gumball": {"tier": "neutral", "reason": "Creative animated comedy for older kids"},
    "adventure time": {"tier": "neutral", "reason": "Imaginative animated adventure series"},
    "steven universe": {"tier": "neutral", "reason": "Musical adventure with themes of empathy"},
    "spongebob squarepants": {"tier": "neutral", "reason": "Long-running animated comedy"},
    "teen titans go": {"tier": "neutral", "reason": "Superhero comedy for older kids"},
    "total drama": {"tier": "neutral", "reason": "Animated comedy competition show"},
    "baby shark": {"tier": "neutral", "reason": "Catchy songs and simple animation for toddlers"},
    "pinkfong": {"tier": "neutral", "reason": "Songs and stories for young children"},
    "moonbug kids": {"tier": "neutral", "reason": "Curated kids content including CoComelon and Blippi"},
    "ryan's world": {"tier": "neutral", "reason": "Kid-hosted toy reviews and experiments"},
    "ryans world": {"tier": "neutral", "reason": "Kid-hosted toy reviews and experiments"},
    "diana and roma": {"tier": "neutral", "reason": "Family-friendly pretend play and adventures"},
    "vlad and niki": {"tier": "neutral", "reason": "Kid-hosted pretend play content"},
    "nastya": {"tier": "neutral", "reason": "Family-friendly play and travel content"},
    "kids diana show": {"tier": "neutral", "reason": "Pretend play and family content"},

    # ── Junk ──
    "blippi": {"tier": "junk", "reason": "Hyper-stimulating presentation with shallow educational value"},
    "tv toys": {"tier": "junk", "reason": "Toy unboxing designed to drive purchases"},
    "fgteev": {"tier": "junk", "reason": "Loud, chaotic gaming family content"},
    "unspeakable": {"tier": "junk", "reason": "Extreme challenge and stunt content"},
    "sssniperwolf": {"tier": "junk", "reason": "Reaction content not designed for children"},
    "mrbeast": {"tier": "junk", "reason": "Extreme challenges and consumerism-driven content"},
    "preston": {"tier": "junk", "reason": "Gaming and challenge content with clickbait"},
    "lankybox": {"tier": "junk", "reason": "Loud reaction and unboxing content"},
    "cookie swirl c": {"tier": "junk", "reason": "Toy unboxing and consumption-focused content"},
    "toys and colors": {"tier": "junk", "reason": "Toy-focused content designed to drive purchases"},
    "come play with me": {"tier": "junk", "reason": "Toy unboxing and purchase-driven content"},
    "5-minute crafts": {"tier": "junk", "reason": "Misleading DIY content with dubious advice"},
    "troom troom": {"tier": "junk", "reason": "Sensationalist craft and prank content"},
    "a for adley": {"tier": "junk", "reason": "Highly produced family vlog with toy promotion"},
    "sis vs bro": {"tier": "junk", "reason": "Challenge and competition-driven sibling content"},
    "morgz": {"tier": "junk", "reason": "Extreme challenge and prank content"},
    "guava juice": {"tier": "junk", "reason": "Chaotic challenge and experiment content"},
    "jelly": {"tier": "junk", "reason": "Gaming content with exaggerated reactions"},
    "aphmau": {"tier": "junk", "reason": "Minecraft roleplay with dramatic clickbait"},
    "popularmmos": {"tier": "junk", "reason": "Gaming content with sensationalized titles"},
    "stampylonghead": {"tier": "junk", "reason": "Minecraft let's play with rapid pacing"},
    "dantdm": {"tier": "junk", "reason": "Gaming content not designed for young children"},
    "ellie sparkles": {"tier": "junk", "reason": "Low-effort animated content for passive viewing"},
    "kids channel": {"tier": "junk", "reason": "Generic repackaged nursery content optimized for watch time"},
    "chu chu tv": {"tier": "junk", "reason": "Rapid-fire nursery content designed for maximum retention"},
    "bounce patrol": {"tier": "junk", "reason": "High-stimulation kids music with rapid editing"},
    "famiglia gbl": {"tier": "junk", "reason": "Dubbed toy/challenge content"},
}

_STRIP_SUFFIXES = re.compile(
    r'\s*[-–—]\s*(official(\s+(channel|video)s?)?|vevo|topic|youtube)$',
    re.IGNORECASE
)
_STRIP_PREFIXES = re.compile(
    r'^(official\s+)',
    re.IGNORECASE
)


def normalize_channel_name(name):
    """Lowercase, strip common YouTube suffixes/prefixes, collapse whitespace."""
    if not name:
        return ""
    n = name.strip().lower()
    n = _STRIP_SUFFIXES.sub('', n)
    n = _STRIP_PREFIXES.sub('', n)
    n = re.sub(r'\s+', ' ', n).strip()
    return n


def lookup_seed(channel_name):
    """Check seed list with normalized matching. Returns dict or None."""
    normalized = normalize_channel_name(channel_name)
    return SEED_CHANNELS.get(normalized)
