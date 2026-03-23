from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = ""
    redis_url: str = "redis://redis:6379"
    ai_service_url: str = "http://ai-service:8001"

    class Config:
        env_file = ".env"


settings = Settings()
