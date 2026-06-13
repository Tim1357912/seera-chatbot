from typing import List

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


_VALID_APP_ENVS = {"development", "local", "test", "production"}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    APP_NAME: str = "Seera Chatbot API"
    APP_ENV: str = "development"
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000

    DATABASE_URL: str = "sqlite:///./seera_chatbot.db"

    CORS_ORIGINS: str = "http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000"
    S3_ASSET_BUCKET: str = ""
    ASSET_BASE_URL: str = ""
    AWS_REGION: str = "ap-southeast-1"

    @field_validator("APP_ENV")
    @classmethod
    def validate_app_env(cls, value: str) -> str:
        normalized = value.strip().lower()
        if normalized not in _VALID_APP_ENVS:
            allowed = ", ".join(sorted(_VALID_APP_ENVS))
            raise ValueError(f"APP_ENV must be one of: {allowed}")
        return normalized

    @field_validator("ASSET_BASE_URL")
    @classmethod
    def normalize_asset_base_url(cls, value: str) -> str:
        return value.strip().rstrip("/")

    @property
    def cors_origin_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]

    @property
    def is_production(self) -> bool:
        return self.APP_ENV == "production"

    @model_validator(mode="after")
    def validate_production_config(self) -> "Settings":
        if not self.is_production:
            return self

        missing: list[str] = []
        if not self.DATABASE_URL or self.DATABASE_URL.startswith("sqlite"):
            missing.append("DATABASE_URL")
        if not self.cors_origin_list:
            missing.append("CORS_ORIGINS")
        if not self.S3_ASSET_BUCKET.strip():
            missing.append("S3_ASSET_BUCKET")
        if not self.ASSET_BASE_URL:
            missing.append("ASSET_BASE_URL")
        if not self.AWS_REGION.strip():
            missing.append("AWS_REGION")

        if missing:
            fields = ", ".join(missing)
            raise ValueError(f"Missing required production setting(s): {fields}")

        if "*" in self.cors_origin_list:
            raise ValueError("CORS_ORIGINS cannot contain '*' when APP_ENV=production")

        insecure_cors = [origin for origin in self.cors_origin_list if not origin.startswith("https://")]
        if insecure_cors:
            raise ValueError("CORS_ORIGINS must use HTTPS when APP_ENV=production")

        if not self.ASSET_BASE_URL.startswith("https://"):
            raise ValueError("ASSET_BASE_URL must use HTTPS when APP_ENV=production")

        return self

    def asset_url(self, key: str) -> str:
        normalized_key = key.lstrip("/")
        if self.ASSET_BASE_URL:
            return f"{self.ASSET_BASE_URL}/{normalized_key}"
        return f"/{normalized_key}"


settings = Settings()
