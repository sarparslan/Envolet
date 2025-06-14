"""FastAPI application entry point."""

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import models  # noqa: F401 - registers models on Base.metadata
from app.core.config import get_settings
from app.db import Base, engine
from app.routers import ai, assets, auth, transactions

logger = logging.getLogger("envolet")


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    if get_settings().uses_dev_secret:
        logger.warning("JWT_SECRET is not set; using an insecure development secret.")
    Base.metadata.create_all(bind=engine)
    yield


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title="Envolet API",
        version="0.1.0",
        description="Backend for the Envolet personal finance tracker.",
        lifespan=lifespan,
    )

    origins = settings.cors_origin_list or ["*"]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials="*" not in origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(auth.router)
    app.include_router(transactions.router)
    app.include_router(assets.router)
    app.include_router(ai.router)

    @app.get("/health", tags=["health"])
    def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()
