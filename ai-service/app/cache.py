import hashlib
import json
import redis.asyncio as redis
from app.config import settings


async def get_redis():
    return redis.from_url(settings.redis_url, decode_responses=True)


def make_cache_key(goals: str, budget: int, filters: dict) -> str:
    payload = json.dumps(
        {"goals": goals, "budget": budget, "filters": filters}, sort_keys=True
    )
    return f"recommendations:{hashlib.sha256(payload.encode()).hexdigest()}"


async def get_cached(key: str) -> str | None:
    client = await get_redis()
    return await client.get(key)


async def set_cached(key: str, value: str) -> None:
    client = await get_redis()
    await client.set(key, value, ex=settings.ai_cache_ttl)
