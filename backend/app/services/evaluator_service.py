from typing import Dict
from app.core.prompts import EVALUATION_SYSTEM_PROMPT
from app.schemas.evaluation import EvaluationReport, TopicScore
from app.schemas.interview import TurnRole
from app.services.openai_service import openai_service

class EvaluatorService:
    @classmethod
    async def evaluate_session(cls, session: Dict) -> EvaluationReport:
        cand = session["candidate"]
        turns = session["turns"]

        # Compile formatted transcript
        transcript_lines = []
        for t in turns:
            prefix = f"[{t.stage.upper()}] {'AI INTERVIEWER' if t.role == TurnRole.ASSISTANT else 'CANDIDATE'}:"
            transcript_lines.append(f"{prefix} {t.content}")

        transcript_text = "\n\n".join(transcript_lines)
        user_prompt = (
            f"Candidate: {cand.name}\n"
            f"Target Role: {cand.target_role}\n"
            f"Years of Experience: {cand.years_of_experience}\n"
            f"Skills: {', '.join(cand.skills)}\n\n"
            f"Full Interview Transcript:\n{transcript_text[:12000]}"
        )

        raw_eval = await openai_service.generate_structured_json(
            system_prompt=EVALUATION_SYSTEM_PROMPT,
            user_prompt=user_prompt,
            temperature=0.2,
        )

        topic_scores = [
            TopicScore(
                topic=item.get("topic", "Core Knowledge"),
                score=int(item.get("score", 80)),
                feedback=item.get("feedback", "Good proficiency shown."),
            )
            for item in raw_eval.get("topic_scores", [])
        ]

        if not topic_scores:
            topic_scores = [
                TopicScore(topic=cand.target_role, score=85, feedback="Sound grasp of key principles."),
                TopicScore(topic="Problem Solving", score=82, feedback="Structured approach to design."),
                TopicScore(topic="Communication", score=88, feedback="Articulate and transparent."),
            ]

        return EvaluationReport(
            session_id=session["session_id"],
            candidate_name=cand.name,
            target_role=cand.target_role,
            overall_score=int(raw_eval.get("overall_score", 85)),
            technical_score=int(raw_eval.get("technical_score", 85)),
            problem_solving_score=int(raw_eval.get("problem_solving_score", 84)),
            communication_score=int(raw_eval.get("communication_score", 88)),
            behavioral_score=int(raw_eval.get("behavioral_score", 82)),
            recommendation=raw_eval.get("recommendation", "Hire"),
            executive_summary=raw_eval.get("executive_summary", "Candidate demonstrated good domain proficiency."),
            strengths=raw_eval.get("strengths", ["Solid fundamentals", "Clear communication"]),
            weaknesses=raw_eval.get("weaknesses", ["Opportunity to optimize edge case solutions"]),
            topic_scores=topic_scores,
            action_plan=raw_eval.get("action_plan", ["Continue practicing system design trade-offs"]),
        )

evaluator_service = EvaluatorService()
