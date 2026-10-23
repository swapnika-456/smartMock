from typing import List
from pydantic import BaseModel, Field

class TopicScore(BaseModel):
    topic: str
    score: int = Field(..., ge=0, le=100)
    feedback: str

class EvaluationReport(BaseModel):
    session_id: str
    candidate_name: str
    target_role: str
    overall_score: int = Field(..., ge=0, le=100)
    technical_score: int = Field(..., ge=0, le=100)
    problem_solving_score: int = Field(..., ge=0, le=100)
    communication_score: int = Field(..., ge=0, le=100)
    behavioral_score: int = Field(..., ge=0, le=100)
    recommendation: str
    executive_summary: str
    strengths: List[str]
    weaknesses: List[str]
    topic_scores: List[TopicScore]
    action_plan: List[str]
