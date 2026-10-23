import uuid
from datetime import datetime, timezone
from typing import Dict, List, Optional
from app.core.config import settings
from app.core.prompts import (
    TECHNICAL_INTERVIEWER_PROMPT,
    BEHAVIORAL_INTERVIEWER_PROMPT,
)
from app.schemas.candidate import CandidateProfile, CandidateCreate
from app.schemas.interview import (
    InterviewSession,
    InterviewStage,
    InterviewTurn,
    TurnRole,
)
from app.services.openai_service import openai_service

class InterviewManager:
    def __init__(self):
        self._sessions: Dict[str, Dict] = {}

    def create_session(
        self,
        candidate_input: CandidateCreate,
        total_tech_q: int = 4,
        total_behavioral_q: int = 3,
    ) -> str:
        session_id = str(uuid.uuid4())
        candidate_profile = CandidateProfile(
            id=str(uuid.uuid4()),
            name=candidate_input.name,
            target_role=candidate_input.target_role,
            years_of_experience=candidate_input.years_of_experience,
            skills=candidate_input.skills,
            resume_summary=candidate_input.resume_summary,
        )

        self._sessions[session_id] = {
            "session_id": session_id,
            "candidate": candidate_profile,
            "stage": InterviewStage.TECHNICAL,
            "current_question_index": 1,
            "total_technical_questions": total_tech_q,
            "total_behavioral_questions": total_behavioral_q,
            "turns": [],
            "is_completed": False,
        }
        return session_id

    def get_session(self, session_id: str) -> Optional[Dict]:
        return self._sessions.get(session_id)

    async def get_initial_question(self, session_id: str) -> str:
        session = self._sessions[session_id]
        cand = session["candidate"]

        sys_prompt = TECHNICAL_INTERVIEWER_PROMPT.format(
            name=cand.name,
            target_role=cand.target_role,
            years_of_experience=cand.years_of_experience,
            skills=", ".join(cand.skills),
            question_number=1,
            total_questions=session["total_technical_questions"],
        )

        greeting = (
            f"Hello {cand.name}! Welcome to your technical interview for the {cand.target_role} position. "
            f"I have reviewed your background with {cand.years_of_experience} years of experience and skills in {', '.join(cand.skills[:4])}."
        )

        question = await openai_service.generate_chat_response(
            system_prompt=sys_prompt,
            messages=[{"role": "user", "content": "Please start the technical interview with question 1."}],
        )

        first_ai_message = f"{greeting}\n\n{question}"
        turn = InterviewTurn(
            role=TurnRole.ASSISTANT,
            content=first_ai_message,
            stage=InterviewStage.TECHNICAL,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
        session["turns"].append(turn)
        return first_ai_message

    async def process_candidate_answer(self, session_id: str, answer: str) -> Dict:
        session = self._sessions[session_id]
        cand = session["candidate"]
        current_stage = session["stage"]
        current_q = session["current_question_index"]

        # 1. Record candidate answer
        user_turn = InterviewTurn(
            role=TurnRole.CANDIDATE,
            content=answer,
            stage=current_stage,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
        session["turns"].append(user_turn)

        # 2. Determine state transition
        is_stage_transition = False
        is_interview_complete = False

        if current_stage == InterviewStage.TECHNICAL:
            if current_q >= session["total_technical_questions"]:
                # Transition to behavioral
                session["stage"] = InterviewStage.BEHAVIORAL
                session["current_question_index"] = 1
                is_stage_transition = True
            else:
                session["current_question_index"] += 1
        elif current_stage == InterviewStage.BEHAVIORAL:
            if current_q >= session["total_behavioral_questions"]:
                session["stage"] = InterviewStage.COMPLETED
                session["is_completed"] = True
                is_interview_complete = True
            else:
                session["current_question_index"] += 1

        # 3. Generate Next Question or Conclusion
        if is_interview_complete:
            completion_message = (
                f"Thank you very much, {cand.name}! That concludes both the technical and behavioral portions "
                "of our interview. You demonstrated great focus and shared valuable insights. "
                "Our AI Evaluation Engine is now compiling your comprehensive skill scorecard and actionable improvement plan."
            )
            ai_turn = InterviewTurn(
                role=TurnRole.ASSISTANT,
                content=completion_message,
                stage=InterviewStage.COMPLETED,
                timestamp=datetime.now(timezone.utc).isoformat(),
            )
            session["turns"].append(ai_turn)
            return {
                "session_id": session_id,
                "stage": InterviewStage.COMPLETED,
                "question": completion_message,
                "question_number": session["current_question_index"],
                "total_questions": session["total_behavioral_questions"],
                "is_stage_transition": True,
                "is_completed": True,
            }

        # Build message history for conversational context
        messages = []
        for t in session["turns"][-6:]:
            role = "assistant" if t.role == TurnRole.ASSISTANT else "user"
            messages.append({"role": role, "content": t.content})

        active_stage = session["stage"]
        active_q = session["current_question_index"]

        if active_stage == InterviewStage.TECHNICAL:
            sys_prompt = TECHNICAL_INTERVIEWER_PROMPT.format(
                name=cand.name,
                target_role=cand.target_role,
                years_of_experience=cand.years_of_experience,
                skills=", ".join(cand.skills),
                question_number=active_q,
                total_questions=session["total_technical_questions"],
            )
            total_stage_q = session["total_technical_questions"]
        else:
            sys_prompt = BEHAVIORAL_INTERVIEWER_PROMPT.format(
                name=cand.name,
                target_role=cand.target_role,
                years_of_experience=cand.years_of_experience,
                question_number=active_q,
                total_questions=session["total_behavioral_questions"],
            )
            total_stage_q = session["total_behavioral_questions"]

        ai_question = await openai_service.generate_chat_response(
            system_prompt=sys_prompt,
            messages=messages,
        )

        ai_turn = InterviewTurn(
            role=TurnRole.ASSISTANT,
            content=ai_question,
            stage=active_stage,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
        session["turns"].append(ai_turn)

        return {
            "session_id": session_id,
            "stage": active_stage,
            "question": ai_question,
            "question_number": active_q,
            "total_questions": total_stage_q,
            "is_stage_transition": is_stage_transition,
            "is_completed": False,
        }

interview_manager = InterviewManager()
