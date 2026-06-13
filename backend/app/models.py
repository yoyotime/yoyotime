"""SQLAlchemy ORM models."""
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, DateTime, Boolean, Integer, Float, JSON
from sqlalchemy.dialects.postgresql import ARRAY
from app.database import Base


class ContentSource(Base):
    __tablename__ = "content_sources"

    id = Column(Integer, primary_key=True, autoincrement=True)
    url = Column(String, unique=True, nullable=False)
    name = Column(String, nullable=False)
    type = Column(String, default="rss")
    trust_score = Column(Float, default=0.7)
    is_active = Column(Boolean, default=True)
    last_fetched_at = Column(DateTime, nullable=True)
    fetch_interval_minutes = Column(Integer, default=30)


class Content(Base):
    __tablename__ = "contents"

    id = Column(String, primary_key=True)
    title = Column(Text, nullable=False)
    summary = Column(Text)
    full_text = Column(Text)
    source_name = Column(String)
    source_url = Column(String, unique=True)
    source_type = Column(String, default="rss")
    media = Column(JSON, default=list)
    topics = Column(JSON, default=list)
    tone_vector = Column(JSON, default=dict)
    language = Column(String, default="zh-CN")
    is_active = Column(Boolean, default=True)
    published_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    fetched_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    estimated_read_time_minutes = Column(Integer, default=3)


class UserPreference(Base):
    __tablename__ = "user_preferences"

    id = Column(String, primary_key=True)
    description = Column(Text, default="")
    interests = Column(JSON, default=list)
    blocklist = Column(JSON, default=list)
    prefer_audio = Column(Boolean, default=True)
    tts_speed = Column(Float, default=1.0)
    tts_voice = Column(String, nullable=True)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))


class UserFeedback(Base):
    __tablename__ = "user_feedback"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    content_id = Column(String, nullable=False, index=True)
    action = Column(String, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
