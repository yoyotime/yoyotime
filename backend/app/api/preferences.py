"""Preferences API."""
from typing import Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.dialects.postgresql import insert as pg_insert

from app.database import get_db
from app.models import UserPreference
from app.aggregator.classifier import extract_interests

router = APIRouter()


class PreferencesRequest(BaseModel):
    user_id: str
    description: str = ""
    interests: list[str] = Field(default_factory=list)
    blocklist: list[str] = Field(default_factory=list)
    prefer_audio: bool = True
    tts_speed: float = 1.0


@router.post("/preferences")
async def update_preferences(req: PreferencesRequest):
    """Save user preferences and extract topics from description."""
    if not req.description and not req.interests:
        raise HTTPException(status_code=400, detail="description or interests required")

    auto_interests = extract_interests(req.description) if req.description else []
    all_interests = list(set(req.interests + auto_interests))

    async for session in get_db():
        existing = await session.get(UserPreference, req.user_id)
        if existing:
            existing.description = req.description
            existing.interests = all_interests
            existing.blocklist = req.blocklist
            existing.prefer_audio = req.prefer_audio
            existing.tts_speed = req.tts_speed
        else:
            session.add(UserPreference(
                id=req.user_id,
                description=req.description,
                interests=all_interests,
                blocklist=req.blocklist,
                prefer_audio=req.prefer_audio,
                tts_speed=req.tts_speed,
            ))
        await session.commit()

    return {
        "user_id": req.user_id,
        "interests": all_interests,
        "blocklist": req.blocklist,
        "auto_extracted": auto_interests,
    }
