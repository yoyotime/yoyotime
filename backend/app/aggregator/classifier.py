"""Content scoring and interest extraction."""
import re
import math
from typing import Iterable

# Common Chinese stopwords
STOPWORDS = {
    "的", "了", "是", "在", "我", "你", "他", "她", "它", "们", "和", "与",
    "或", "也", "就", "都", "不", "没", "很", "太", "非常", "比较", "最",
    "可以", "应该", "需要", "今天", "明天", "昨天", "现在", "过去", "以后",
    "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "几",
    "什么", "怎么", "为什么", "因为", "所以", "如果", "虽然", "但是",
    "以及", "等等", "例如", "比如", "另", "另外", "还有", "包括",
}

# Default interest keywords mapped to topic tags
TOPIC_RULES = {
    "儿童安全": ["儿童", "小孩", "孩子", "幼儿", "未成年", "校园", "幼儿园", "小学"],
    "防拐卖": ["拐卖", "人贩", "失踪", "找孩子", "寻人", "团圆"],
    "国际新闻": ["联合国", "国际", "美国", "俄罗斯", "伊朗", "以色列", "乌克兰", "欧洲", "亚洲"],
    "和平": ["和平", "停火", "谈判", "调解", "调停", "外交"],
    "国家大事": ["国务院", "中央", "两会", "国家", "政府", "政策", "改革", "战略", "规划"],
    "种菜": ["种菜", "蔬菜", "番茄", "黄瓜", "辣椒", "葱", "蒜", "阳台种菜", "菜园"],
    "看海": ["海", "海边", "海洋", "渔船", "海浪", "海风"],
    "时政": ["时政", "政治", "国家", "政策", "改革", "中央"],
    "环境": ["环保", "生态", "污染", "绿色", "气候", "碳"],
    "社会": ["社会", "民生", "新闻", "事件"],
    "科技": ["科技", "人工智能", "AI", "芯片", "互联网"],
}

SENSATIONAL_KEYWORDS = [
    "震惊", "恐怖", "血腥", "残暴", "惨烈", "惊呆", "吓死", "跪了", "刷屏",
    "气死", "气炸", "傻眼", "崩溃", "惨不忍睹", "惨绝人寰",
]


def extract_interests(description: str) -> list[str]:
    if not description:
        return []
    interests = set()
    for topic, keywords in TOPIC_RULES.items():
        if any(kw in description for kw in keywords):
            interests.add(topic)
    return list(interests)


def classify_tone(title: str, summary: str, full_text: str = "") -> dict:
    text = f"{title}。{summary}。{full_text[:500]}"
    sensational_count = sum(1 for kw in SENSATIONAL_KEYWORDS if kw in text)
    is_negative = any(c in text for c in ["死", "伤", "凶", "暴力", "恐怖袭击", "战争"])
    is_neutral = sensational_count == 0 and not is_negative

    return {
        "polarity": -1 if is_negative else (0 if is_neutral else 1),
        "sensational": min(1.0, sensational_count / 3),
        "violence": min(1.0, sum(1 for c in ["血腥", "残暴", "暴力", "战争"] if c in text) / 2),
        "suitable_for": (
            ["morning", "evening"] if is_neutral
            else ["morning"] if sensational_count < 2
            else ["adult_only"]
        ),
    }


def score_content(
    content: dict,
    user_interests: Iterable[str],
    user_blocklist: Iterable[str],
    user_description: str = "",
) -> float:
    interests = set(user_interests or [])
    blocklist = set(user_blocklist or [])

    topics = set(content.get("topics") or [])
    text = (content.get("title") or "") + (content.get("summary") or "")

    for blocked in blocklist:
        if blocked and (blocked in text or any(blocked in t for t in topics)):
            return 0.0

    if interests:
        topic_match = len(topics & interests) / max(1, len(topics | interests))
    else:
        topic_match = 0.5

    desc_match = 0.0
    if user_description:
        keywords = [k for k in re.split(r"[，,。\s]+", user_description) if len(k) >= 2]
        hits = sum(1 for k in keywords if k in text)
        desc_match = min(1.0, hits / max(1, len(keywords) * 0.2))

    source_trust = 0.7

    tone = content.get("tone_vector") or {}
    sensational = float(tone.get("sensational", 0) or 0)
    violence = float(tone.get("violence", 0) or 0)
    tone_factor = max(0.1, 1.0 - 0.5 * sensational - 0.4 * violence)

    from datetime import datetime
    recency_bonus = 0.0
    pub = content.get("published_at")
    if pub:
        try:
            if isinstance(pub, str):
                pub_dt = datetime.fromisoformat(pub.replace("Z", "+00:00"))
            else:
                pub_dt = pub
            hours = (datetime.now(pub_dt.tzinfo) - pub_dt).total_seconds() / 3600
            recency_bonus = max(0.0, 0.3 * math.exp(-hours / 12))
        except Exception:
            pass

    score = (
        0.5 * topic_match
        + 0.2 * desc_match
        + 0.2 * source_trust
        + 0.1 * tone_factor
        + recency_bonus
    )
    return max(0.0, min(1.0, score))
