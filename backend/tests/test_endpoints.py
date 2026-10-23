import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        res = await ac.get("/health")
        assert res.status_code == 200
        data = res.json()
        assert data["status"] == "healthy"

@pytest.mark.asyncio
async def test_full_interview_lifecycle():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Start interview
        start_payload = {
            "candidate": {
                "name": "Jordan Smith",
                "target_role": "Python Backend Engineer",
                "years_of_experience": 3,
                "skills": ["Python", "FastAPI", "PostgreSQL", "Docker"],
            },
            "total_technical_questions": 2,
            "total_behavioral_questions": 1,
        }
        start_res = await ac.post("/api/v1/interview/start", json=start_payload)
        assert start_res.status_code == 200
        start_data = start_res.json()
        session_id = start_data["session_id"]
        assert session_id is not None
        assert "question" in start_data
        assert start_data["stage"] == "technical"

        # 2. Answer question 1 (Technical)
        ans1 = await ac.post(
            f"/api/v1/interview/{session_id}/answer",
            json={"answer": "I use FastAPI with asynchronous SQLAlchemy and connection pooling via PgBouncer."},
        )
        assert ans1.status_code == 200
        ans1_data = ans1.json()
        assert ans1_data["stage"] == "technical"

        # 3. Answer question 2 (Technical -> Transitions to Behavioral)
        ans2 = await ac.post(
            f"/api/v1/interview/{session_id}/answer",
            json={"answer": "To prevent cache stampede, I use Redis mutex locks and probabilistic early expiration."},
        )
        assert ans2.status_code == 200
        ans2_data = ans2.json()
        assert ans2_data["stage"] == "behavioral"
        assert ans2_data["is_stage_transition"] is True

        # 4. Answer question 3 (Behavioral -> Transitions to Completed)
        ans3 = await ac.post(
            f"/api/v1/interview/{session_id}/answer",
            json={"answer": "In our last sprint, we disagreed on database sharding. I created a benchmark POC to show the data, which convinced the team."},
        )
        assert ans3.status_code == 200
        ans3_data = ans3.json()
        assert ans3_data["is_completed"] is True
        assert ans3_data["stage"] == "completed"

        # 5. Check session status
        status_res = await ac.get(f"/api/v1/interview/{session_id}/status")
        assert status_res.status_code == 200
        status_data = status_res.json()
        assert status_data["is_completed"] is True
        assert len(status_data["conversation"]) >= 6

        # 6. Generate evaluation scorecard
        eval_res = await ac.get(f"/api/v1/evaluation/{session_id}")
        assert eval_res.status_code == 200
        eval_data = eval_res.json()
        assert eval_data["candidate_name"] == "Jordan Smith"
        assert 0 <= eval_data["overall_score"] <= 100
        assert len(eval_data["strengths"]) > 0
        assert len(eval_data["weaknesses"]) > 0
        assert len(eval_data["topic_scores"]) > 0
