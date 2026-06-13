"""Feed API."""
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Content, ContentSource, UserPreference
from app.aggregator.classifier import score_content

router = APIRouter()


class FeedFilter(BaseModel):
    topics: list[str] = Field(default_factory=list)
    exclude_sources: list[str] = Field(default_factory=list)


class FeedRequest(BaseModel):
    user_id: str
    page: int = 1
    size: int = 20
    filter: FeedFilter = Field(default_factory=FeedFilter)


class ContentItem(BaseModel):
    content_id: str
    title: str
    summary: str
    full_text: Optional[str] = None
    source: dict
    media: list[dict] = Field(default_factory=list)
    topics: list[str]
    published_at: str
    fetched_at: str
    estimated_read_time_minutes: int = 3
    tone: Optional[dict] = None


class FeedResponse(BaseModel):
    items: list[ContentItem]
    page: int
    has_more: bool
    daily_limit_remaining: int = 10


@router.post("/feed", response_model=FeedResponse)
async def get_feed(req: FeedRequest):
    """Return content feed for user, ranked by relevance and tone."""
    async for session in get_db():
        pref = await session.get(UserPreference, req.user_id)
        user_interests = pref.interests if pref else []
        user_blocklist = pref.blocklist if pref else []
        user_desc = pref.description if pref else ""

        stmt = (
            select(Content)
            .where(Content.is_active.is_(True))
            .order_by(Content.published_at.desc())
            .limit(req.size * 3)
        )
        if req.filter.exclude_sources:
            stmt = stmt.where(
                ~Content.source_name.in_(req.filter.exclude_sources)
            )

        result = await session.execute(stmt)
        candidates = result.scalars().all()

        scored = []
        for c in candidates:
            s = score_content(
                content={
                    "title": c.title,
                    "summary": c.summary,
                    "topics": c.topics,
                    "tone_vector": c.tone_vector,
                },
                user_interests=user_interests,
                user_blocklist=user_blocklist,
                user_description=user_desc,
            )
            if s > 0:
                scored.append((s, c))

        scored.sort(key=lambda x: x[0], reverse=True)
        start = (req.page - 1) * req.size
        end = start + req.size
        page_items = scored[start:end]

        items = [
            ContentItem(
                content_id=c.id,
                title=c.title,
                summary=c.summary,
                full_text=c.full_text,
                source={"name": c.source_name, "url": c.source_url, "type": c.source_type},
                media=c.media or [],
                topics=c.topics or [],
                published_at=c.published_at.isoformat(),
                fetched_at=c.fetched_at.isoformat(),
                estimated_read_time_minutes=c.estimated_read_time_minutes or 3,
                tone=c.tone_vector,
            )
            for _, c in page_items
        ]

        return FeedResponse(
            items=items,
            page=req.page,
            has_more=end < len(scored),
            daily_limit_remaining=max(0, 10 - len(page_items)),
        )
