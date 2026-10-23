from fastapi import APIRouter, HTTPException
from app.schemas.evaluation import EvaluationReport
from app.services.interview_manager import interview_manager
from app.services.evaluator_service import evaluator_service

router = APIRouter(prefix="/evaluation", tags=["Evaluation"])

@router.post("/{session_id}", response_model=EvaluationReport)
@router.get("/{session_id}", response_model=EvaluationReport)
async def get_evaluation_report(session_id: str):
    session = interview_manager.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Interview session not found")

    if not session["turns"]:
        raise HTTPException(status_code=400, detail="Cannot evaluate an interview with zero turns")

    report = await evaluator_service.evaluate_session(session)
    return report
