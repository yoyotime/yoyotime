"""Application configuration."""
from functools import lru_cache
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    env: str = "dev"
    database_url: str = "sqlite+aiosqlite:///./yoyotime.db"
    aggregator_interval_minutes: int = 30
    cors_origins: list[str] = ["*"]
    tts_provider: str = "edge"
    tts_voice: str = "zh-CN-XiaoxiaoNeural"
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
        env_prefix = "YOYOTIME_"


@lru_cache
def get_settings() -> Settings:
    return Settings()
