import json
import google.generativeai as genai
from app.config import settings
from app.cache import make_cache_key, get_cached, set_cached


genai.configure(api_key=settings.gemini_api_key)

SYSTEM_PROMPT = """You are a laptop recommendation expert.
When given user goals and budget, recommend exactly 5 laptops.
Return a JSON object with key "laptops" containing an array of objects with fields:
name, price, cpu, ram, gpu, storage, why.
Only return valid JSON, no extra text."""


async def get_recommendations(goals: str, budget: int, filters: dict) -> list[dict]:
    cache_key = make_cache_key(goals, budget, filters)

    cached = await get_cached(cache_key)
    if cached:
        return json.loads(cached)

    user_message = f"Goals: {goals}\nBudget: ${budget}\nFilters: {json.dumps(filters)}"

    model = genai.GenerativeModel(
        model_name=settings.ai_model,
        system_instruction=SYSTEM_PROMPT,
    )

    response = model.generate_content(
        user_message,
        generation_config=genai.GenerationConfig(
            temperature=0.3,
            response_mime_type="application/json",
        ),
    )

    data = json.loads(response.text)
    laptops = data.get("laptops", data.get("recommendations", []))

    await set_cached(cache_key, json.dumps(laptops))

    return laptops