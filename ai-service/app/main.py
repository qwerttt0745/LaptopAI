from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.health import router as health_router
from app.recommender import get_recommendations


app = FastAPI(title="LaptopAI — AI Service", version="0.1.0")

app.include_router(health_router)


class RecommendationRequest(BaseModel):
    goals: str
    budget: int
    filters: dict = {}


class RecommendationResponse(BaseModel):
    laptops: list[dict]
    cached: bool = False


@app.post("/recommend", response_model=RecommendationResponse)
async def recommend(request: RecommendationRequest):
    if not request.goals or request.budget <= 0:
        raise HTTPException(
            status_code=422, detail="Goals and positive budget are required"
        )

    laptops = await get_recommendations(request.goals, request.budget, request.filters)

    return RecommendationResponse(laptops=laptops)
