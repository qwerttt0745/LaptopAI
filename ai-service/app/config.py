from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    gemini_api_key: str = ""
    ai_model: str = "gemini-1.5-flash"
    ai_cache_ttl: int = 86400
    redis_url: str = "redis://redis:6379"

    class Config:
        env_file = ".env"


settings = Settings()