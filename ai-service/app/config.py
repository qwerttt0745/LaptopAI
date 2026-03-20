from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ai_api_key: str = ""
    ai_model: str = "gpt-4o-mini"
    ai_cache_ttl: int = 86400
    redis_url: str = "redis://redis:6379"

    class Config:
        env_file = ".env"


settings = Settings()
