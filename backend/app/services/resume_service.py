import io
import re
from typing import List
from pypdf import PdfReader
from app.core.prompts import RESUME_PARSER_SYSTEM_PROMPT
from app.schemas.candidate import ResumeParseResponse
from app.services.openai_service import openai_service

class ResumeService:
    @staticmethod
    def extract_text_from_pdf_bytes(pdf_bytes: bytes) -> str:
        try:
            reader = PdfReader(io.BytesIO(pdf_bytes))
            text_parts: List[str] = []
            for page in reader.pages:
                extracted = page.extract_text()
                if extracted:
                    text_parts.append(extracted)
            return "\n".join(text_parts).strip()
        except Exception:
            # Fallback decoding if not binary PDF
            return pdf_bytes.decode("utf-8", errors="ignore").strip()

    @classmethod
    async def parse_resume(cls, content: str) -> ResumeParseResponse:
        prompt = f"Candidate Resume Content:\n{content[:5000]}"
        parsed = await openai_service.generate_structured_json(
            system_prompt=RESUME_PARSER_SYSTEM_PROMPT,
            user_prompt=prompt,
        )

        name = parsed.get("name") or "Candidate"
        role = parsed.get("target_role") or "Software Engineer"
        exp = int(parsed.get("years_of_experience") or 2)
        skills = parsed.get("skills") or ["Python", "Algorithms", "APIs", "Data Structures"]
        summary = parsed.get("summary") or "Technical candidate with strong foundational experience."

        return ResumeParseResponse(
            name=name,
            target_role=role,
            years_of_experience=exp,
            skills=skills,
            summary=summary,
        )

resume_service = ResumeService()
