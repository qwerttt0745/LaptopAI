from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
from app.config import settings

router = APIRouter()


class RecommendationRequest(BaseModel):
    goals: str
    budget: int
    filters: dict = {}


@router.post("/recommendations")
async def get_recommendations(request: RecommendationRequest):
    async with httpx.AsyncClient(timeout=60.0) as client:
        try:
            response = await client.post(
                f"{settings.ai_service_url}/recommend",
                json={
                    "goals": request.goals,
                    "budget": request.budget,
                    "filters": request.filters,
                },
            )
            response.raise_for_status()
            return response.json()
        except httpx.TimeoutException:
            raise HTTPException(status_code=504, detail="AI service timeout")
        except httpx.HTTPError as e:
            raise HTTPException(status_code=502, detail=f"AI service error: {str(e)}")
