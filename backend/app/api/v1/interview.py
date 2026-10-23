from fastapi import APIRouter, HTTPException
from app.schemas.interview import (
    StartInterviewRequest,
    SubmitAnswerRequest,
    NextQuestionResponse,
    InterviewStatusResponse,
)
from app.services.interview_manager import interview_manager

router = APIRouter(prefix="/interview", tags=["Interview"])

@router.post("/start", response_model=NextQuestionResponse)
async def start_interview(request: StartInterviewRequest):
    session_id = interview_manager.create_session(
        candidate_input=request.candidate,
        total_tech_q=request.total_technical_questions,
        total_behavioral_q=request.total_behavioral_questions,
    )
    first_question = await interview_manager.get_initial_question(session_id)

    return NextQuestionResponse(
        session_id=session_id,
        stage="technical",
        question=first_question,
        question_number=1,
        total_questions=request.total_technical_questions,
        is_stage_transition=False,
        is_completed=False,
    )

@router.post("/{session_id}/answer", response_model=NextQuestionResponse)
async def submit_candidate_answer(session_id: str, request: SubmitAnswerRequest):
    session = interview_manager.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Interview session not found")

    result = await interview_manager.process_candidate_answer(session_id, request.answer)
    return NextQuestionResponse(**result)

@router.get("/{session_id}/status", response_model=InterviewStatusResponse)
async def get_interview_status(session_id: str):
    session = interview_manager.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Interview session not found")

    turns = session["turns"]
    latest_msg = turns[-1].content if turns else None
    current_stage = session["stage"]
    total_q = (
        session["total_technical_questions"]
        if current_stage == "technical"
        else session["total_behavioral_questions"]
    )

    return InterviewStatusResponse(
        session_id=session_id,
        candidate=session["candidate"],
        stage=session["stage"],
        current_question_number=session["current_question_index"],
        total_questions_in_current_stage=total_q,
        is_completed=session["is_completed"],
        conversation=turns,
        latest_message=latest_msg,
    )
