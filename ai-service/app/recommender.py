import os
import json
from groq import AsyncGroq
from app.config import settings
from app.cache import make_cache_key, get_cached, set_cached

# Ініціалізуємо клієнта Groq. Він бере ключ зі змінної AI_API_KEY, яку прокидає Kubernetes
client = AsyncGroq(
    api_key=os.environ.get("AI_API_KEY")
)

SYSTEM_PROMPT = """You are a laptop recommendation expert.
When given user goals and budget, recommend exactly 5 laptops.
Return a JSON object with key "laptops" containing an array of objects with fields:
name, price, cpu, ram, gpu, storage, why.
Only return valid JSON, no extra text."""

async def get_recommendations(goals: str, budget: int, filters: dict) -> list[dict]:
    # 1. Перевіряємо кеш (Redis)
    cache_key = make_cache_key(goals, budget, filters)
    cached = await get_cached(cache_key)
    if cached:
        return json.loads(cached)

    # 2. Формуємо запит до Groq
    user_message = f"""Recommend exactly 5 laptops for these needs:
Goals: {goals}
Budget: ${budget}
Filters: {json.dumps(filters)}"""

    try:
        chat_completion = await client.chat.completions.create(
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_message}
            ],
            model=os.environ.get("AI_MODEL", "llama3-8b-8192"),
            temperature=0.3,
            response_format={"type": "json_object"}
        )

        # 3. Парсимо відповідь
        text = chat_completion.choices[0].message.content
        data = json.loads(text)
        laptops = data.get("laptops", data.get("recommendations", []))

        # 4. Зберігаємо в кеш
        await set_cached(cache_key, json.dumps(laptops))

        return laptops

    except Exception as e:
        print(f"Groq API Error: {e}")
        return []