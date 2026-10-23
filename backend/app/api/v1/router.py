from fastapi import APIRouter
from app.api.v1.candidate import router as candidate_router
from app.api.v1.interview import router as interview_router
from app.api.v1.evaluation import router as evaluation_router
from app.api.v1.tts import router as tts_router

api_v1_router = APIRouter(prefix="/api/v1")
api_v1_router.include_router(candidate_router)
api_v1_router.include_router(interview_router)
api_v1_router.include_router(evaluation_router)
api_v1_router.include_router(tts_router)
