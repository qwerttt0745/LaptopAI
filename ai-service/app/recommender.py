import json
from openai import AsyncOpenAI
from app.config import settings
from app.cache import make_cache_key, get_cached, set_cached


client = AsyncOpenAI(api_key=settings.ai_api_key)

SYSTEM_PROMPT = """You are a laptop recommendation expert. 
When given user goals and budget, recommend exactly 5 laptops.
Return a JSON array with objects containing: name, price, cpu, ram, gpu, storage, why.
Only return valid JSON, no extra text."""


async def get_recommendations(goals: str, budget: int, filters: dict) -> list[dict]:
    cache_key = make_cache_key(goals, budget, filters)

    cached = await get_cached(cache_key)
    if cached:
        return json.loads(cached)

    user_message = f"Goals: {goals}\nBudget: ${budget}\nFilters: {json.dumps(filters)}"

    response = await client.chat.completions.create(
        model=settings.ai_model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_message},
        ],
        response_format={"type": "json_object"},
        temperature=0.3,
    )

    content = response.choices[0].message.content
    data = json.loads(content)
    laptops = data.get("laptops", data.get("recommendations", []))

    await set_cached(cache_key, json.dumps(laptops))

    return laptops
