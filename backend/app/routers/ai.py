import logging
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from starlette.concurrency import run_in_threadpool

from app.dependencies import CurrentUser, get_suggestion_client
from app.schemas.ai import SuggestionRequest, SuggestionResponse
from app.services.ai import AINotConfiguredError, AIServiceError, SuggestionClient, build_prompt

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/suggestion", response_model=SuggestionResponse)
async def suggestion(
    body: SuggestionRequest,
    _user: CurrentUser,
    client: Annotated[SuggestionClient, Depends(get_suggestion_client)],
) -> SuggestionResponse:
    prompt = build_prompt(
        category=body.category,
        month=body.month,
        month_total=body.monthTotal,
        monthly_average=body.monthlyAverage,
        currency=body.currency,
    )
    try:
        text = await run_in_threadpool(client.complete, prompt)
    except AINotConfiguredError as exc:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="AI suggestions are not configured on the server (OPENROUTER_API_KEY missing)",
        ) from exc
    except AIServiceError as exc:
        logger.warning("AI suggestion failed: %s", exc)
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY, detail="AI provider request failed"
        ) from exc
    return SuggestionResponse(suggestion=text)
