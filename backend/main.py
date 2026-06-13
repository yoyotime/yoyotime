"""Yoyotime backend entry point."""
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.api import feed, preferences, feedback
from app.aggregator.scheduler import start_scheduler, stop_scheduler

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("yoyotime")


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    logger.info("Starting Yoyotime backend (env=%s)", settings.env)
    scheduler = start_scheduler()
    try:
        yield
    finally:
        stop_scheduler(scheduler)
        logger.info("Backend shutdown complete")


app = FastAPI(
    title="Yoyotime API",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(feed.router, prefix="/v1", tags=["feed"])
app.include_router(preferences.router, prefix="/v1", tags=["preferences"])
app.include_router(feedback.router, prefix="/v1", tags=["feedback"])


@app.get("/")
async def health():
    return {"status": "ok", "service": "yoyotime", "version": "0.1.0"}
