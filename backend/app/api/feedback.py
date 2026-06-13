"""Feedback API."""
from datetime import datetime, timezone
from fastapi import APIRouter
from pydantic import BaseModel

from app.database import get_db
from app.models import UserFeedback

router = APIRouter()


class FeedbackRequest(BaseModel):
    user_id: str
    content_id: str
    action: str  # like | dislike | delete | bookmark | not_interested


@router.post("/feedback")
async def submit_feedback(req: FeedbackRequest):
    if req.action not in ("like", "dislike", "delete", "bookmark", "not_interested"):
        return {"ok": False, "error": "invalid action"}
    async for session in get_db():
        session.add(UserFeedback(
            user_id=req.user_id,
            content_id=req.content_id,
            action=req.action,
            created_at=datetime.now(timezone.utc),
        ))
        await session.commit()
    return {"ok": True}
