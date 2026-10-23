from typing import List, Optional
from pydantic import BaseModel, Field

class CandidateCreate(BaseModel):
    name: str = Field(..., json_schema_extra={"example": "Jane Doe"})
    target_role: str = Field(..., json_schema_extra={"example": "Senior Full-Stack Engineer"})
    years_of_experience: int = Field(default=3, ge=0, le=50)
    skills: List[str] = Field(default_factory=list, json_schema_extra={"example": ["Python", "FastAPI", "Flutter", "PostgreSQL"]})
    resume_summary: Optional[str] = None

class CandidateProfile(CandidateCreate):
    id: str

class ResumeParseResponse(BaseModel):
    name: str
    target_role: str
    years_of_experience: int
    skills: List[str]
    summary: str
