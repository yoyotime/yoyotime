"""Content aggregation scheduler."""
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from sqlalchemy import select
from datetime import datetime, timezone

from app.database import get_db
from app.aggregator.rss import fetch_and_parse_source
from app.models import Content, ContentSource
from app.config import get_settings

_settings = get_settings()


def start_scheduler() -> AsyncIOScheduler:
    scheduler = AsyncIOScheduler()
    scheduler.add_job(
        _aggregate_all,
        trigger=IntervalTrigger(minutes=_settings.aggregator_interval_minutes),
        id="aggregate_all",
        replace_existing=True,
    )
    scheduler.start()
    return scheduler


def stop_scheduler(scheduler: AsyncIOScheduler) -> None:
    if scheduler.running:
        scheduler.shutdown(wait=False)


async def _aggregate_all():
    print(f"[{datetime.now()}] Running aggregation cycle")
    try:
        async for session in get_db():
            result = await session.execute(
                select(ContentSource).where(ContentSource.is_active.is_(True))
            )
            sources = result.scalars().all()
            for source in sources:
                new_contents = await fetch_and_parse_source(source, session)
                for c in new_contents:
                    session.add(c)
            await session.commit()
            print(f"[{datetime.now()}] Aggregated {len(sources)} sources")
    except Exception as e:
        print(f"Aggregation failed: {e}")


DEFAULT_SOURCES = [
    {"name": "新华社", "url": "https://www.xinhuanet.com/rss/news.xml", "type": "rss", "trust_score": 0.95},
    {"name": "人民网", "url": "http://www.people.com.cn/rss/politics.xml", "type": "rss", "trust_score": 0.9},
    {"name": "联合国新闻", "url": "https://news.un.org/feed/subscribe/zh", "type": "rss", "trust_score": 0.9},
    {"name": "新华网国际", "url": "https://www.xinhuanet.com/world/rss.xml", "type": "rss", "trust_score": 0.9},
]
