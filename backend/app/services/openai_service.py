import json
import logging
from typing import Any, Dict, List, Optional
from openai import AsyncOpenAI
from app.core.config import settings

logger = logging.getLogger(__name__)

class OpenAIService:
    def __init__(self):
        self._client: Optional[AsyncOpenAI] = None
        if settings.has_valid_openai_key:
            self._client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
            logger.info("OpenAIService initialized with valid API key.")
        else:
            logger.warning(
                "OpenAI API key not configured or using default template. "
                "Running in intelligent simulation / fallback mode."
            )

    @property
    def is_live(self) -> bool:
        return self._client is not None

    async def generate_chat_response(
        self,
        system_prompt: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 600,
    ) -> str:
        if self._client:
            try:
                formatted_messages = [{"role": "system", "content": system_prompt}]
                formatted_messages.extend(messages)
                
                response = await self._client.chat.completions.create(
                    model=settings.OPENAI_MODEL,
                    messages=formatted_messages,
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
                return response.choices[0].message.content or ""
            except Exception as e:
                logger.error(f"OpenAI API call failed: {e}. Falling back to simulation.")

        # Fallback simulation
        return self._simulate_interview_response(system_prompt, messages)

    async def generate_structured_json(
        self,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.3,
    ) -> Dict[str, Any]:
        if self._client:
            try:
                response = await self._client.chat.completions.create(
                    model=settings.OPENAI_MODEL,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt},
                    ],
                    response_format={"type": "json_object"},
                    temperature=temperature,
                )
                content = response.choices[0].message.content or "{}"
                return json.loads(content)
            except Exception as e:
                logger.error(f"OpenAI structured JSON failed: {e}. Using fallback generator.")

        return self._simulate_structured_output(system_prompt, user_prompt)

    async def generate_speech(self, text: str) -> bytes:
        if self._client:
            try:
                response = await self._client.audio.speech.create(
                    model="tts-1",
                    voice=settings.OPENAI_VOICE,
                    input=text[:4000],
                )
                return response.read()
            except Exception as e:
                logger.error(f"OpenAI TTS call failed: {e}")
        # Return empty bytes if not configured
        return b""

    def _simulate_interview_response(self, system_prompt: str, messages: List[Dict[str, str]]) -> str:
        last_user_message = ""
        for m in reversed(messages):
            if m.get("role") == "user":
                last_user_message = m.get("content", "")
                break

        if "Technical Interview" in system_prompt:
            if not messages or len(messages) <= 1:
                return (
                    "Welcome! Let's kick off the technical round. "
                    "To start, could you walk me through how you design high-throughput, "
                    "low-latency APIs? Specifically, what strategies do you employ for database caching, "
                    "connection pooling, and handling sudden traffic spikes?"
                )
            return (
                f"That's a solid breakdown regarding '{last_user_message[:45]}...'. "
                "I like your emphasis on caching layers. To push a bit deeper: "
                "How would you address cache stampede (thundering herd problem) when high-concurrency keys expire, "
                "and how do you ensure eventual consistency across replica nodes?"
            )
        else:
            if not messages or len(messages) <= 1:
                return (
                    "Great work on the technical questions! Let's transition to the behavioral round. "
                    "Tell me about a time when you and a senior teammate strongly disagreed on a fundamental architectural "
                    "or design decision. How did you advocate for your point of view, and how did you reach alignment?"
                )
            return (
                f"Thank you for sharing that experience. Handling conflict constructively is crucial. "
                "Looking back at the outcome, what was the measurable impact on team velocity, and is there anything "
                "you would handle differently with hindsight?"
            )

    def _simulate_structured_output(self, system_prompt: str, user_prompt: str) -> Dict[str, Any]:
        if "resume" in system_prompt.lower() or "resume" in user_prompt.lower():
            return {
                "name": "Alex Mercer",
                "target_role": "Senior Full-Stack Engineer",
                "years_of_experience": 4,
                "skills": ["Python", "FastAPI", "Flutter", "PostgreSQL", "Docker", "System Design"],
                "summary": "Experienced software engineer specializing in scalable cloud APIs and responsive cross-platform client architectures.",
            }
        # Default Evaluation Report Simulation
        return {
            "overall_score": 88,
            "technical_score": 90,
            "problem_solving_score": 86,
            "communication_score": 89,
            "behavioral_score": 85,
            "recommendation": "Strong Hire",
            "executive_summary": (
                "The candidate demonstrated strong domain fundamentals, clear articulation of technical trade-offs, "
                "and an organized approach to problem-solving. Answers exhibited high maturity in handling system edge cases "
                "and collaborative problem resolution."
            ),
            "strengths": [
                "In-depth grasp of concurrency, caching topologies, and distributed persistence",
                "Structured communication following clear logical frameworks",
                "Constructive mindset during behavioral conflicts and deadline pressures",
            ],
            "weaknesses": [
                "Could quantify production latency and throughput metrics with higher specificity",
                "Opportunity to elaborate on automated rollback and canary deployment strategies",
            ],
            "topic_scores": [
                {
                    "topic": "System Architecture & APIs",
                    "score": 92,
                    "feedback": "Articulated clean service boundaries, rate-limiting, and cache invalidation strategies.",
                },
                {
                    "topic": "Concurrency & Performance",
                    "score": 88,
                    "feedback": "Understood async event loops and lock contention mitigation effectively.",
                },
                {
                    "topic": "STAR Behavioral Framework",
                    "score": 85,
                    "feedback": "Clear situation and action; could emphasize final business metrics more forcefully.",
                },
            ],
            "action_plan": [
                "Study canary deployment patterns and zero-downtime database schema migration tools",
                "Incorporate metric-first storytelling (e.g., 'reduced p99 latency from 320ms to 45ms') into behavioral responses",
            ],
        }

openai_service = OpenAIService()
