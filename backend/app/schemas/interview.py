from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field
from app.schemas.candidate import CandidateCreate, CandidateProfile

class InterviewStage(str, Enum):
    SETUP = "setup"
    TECHNICAL = "technical"
    BEHAVIORAL = "behavioral"
    COMPLETED = "completed"

class TurnRole(str, Enum):
    ASSISTANT = "assistant"
    CANDIDATE = "candidate"

class InterviewTurn(BaseModel):
    role: TurnRole
    content: str
    stage: InterviewStage
    timestamp: str

class InterviewSession(BaseModel):
    session_id: str
    candidate: CandidateProfile
    stage: InterviewStage
    current_question_index: int
    total_technical_questions: int
    total_behavioral_questions: int
    turns: List[InterviewTurn]
    is_completed: bool

class StartInterviewRequest(BaseModel):
    candidate: CandidateCreate
    total_technical_questions: int = Field(default=4, ge=1, le=10)
    total_behavioral_questions: int = Field(default=3, ge=1, le=10)

class SubmitAnswerRequest(BaseModel):
    answer: str = Field(..., min_length=2)

class InterviewStatusResponse(BaseModel):
    session_id: str
    candidate: CandidateProfile
    stage: InterviewStage
    current_question_number: int
    total_questions_in_current_stage: int
    is_completed: bool
    conversation: List[InterviewTurn]
    latest_message: Optional[str] = None

class NextQuestionResponse(BaseModel):
    session_id: str
    stage: InterviewStage
    question: str
    question_number: int
    total_questions: int
    is_stage_transition: bool = False
    is_completed: bool = False
