# 🎯 smartMock — AI-Powered Technical & Behavioral Interview Coach

> An intelligent, multi-stage AI interview platform that conducts realistic technical and behavioral interviews with candidates, probes their problem-solving depth in real-time using OpenAI GPT-4o, and generates comprehensive, rubric-based evaluation scorecards with actionable improvement roadmaps.

---

## 🚀 Key Highlights & Capabilities

- **📋 Multi-Stage Interview Pipeline:**
  1. **Resume & Skill Ingestion:** Upload PDF/text resumes to automatically parse skills, experience, and target roles.
  2. **Technical Interview Round:** Dynamic, interactive technical questions tailored to the candidate's chosen tech stack (Python, Flutter, Systems, React, etc.) with adaptive follow-ups based on their answers.
  3. **Behavioral Round:** Structured situational questions evaluating teamwork, leadership, problem resolution, and communication using the STAR framework.
  4. **Rubric-Based Evaluation Scorecard:** Quantitative score out of 100, topic-by-topic breakdowns, strengths, weaknesses, and a personalized study roadmap.
- **🎙️ Voice & Audio Feedback (TTS):** Optional text-to-speech voice playback using OpenAI's realistic voice synthesis (`tts-1`).
- **🛡️ Built-in Mock / Fallback Simulation Mode:** If an OpenAI API key is not yet configured, the system gracefully operates in interactive demo mode so you can test end-to-end flows immediately.
- **📱 Modern Cross-Platform Frontend:** Beautiful Flutter client with Material 3, dynamic theme, responsive layouts for Web, Desktop, and Mobile.
- **⚡ High-Performance Backend:** FastAPI with async streaming, typed Pydantic models, and clean separation of concerns.

---

## 🏗️ Project Architecture

```
smartMock/
├── backend/                  # FastAPI Application (Python 3.12+)
│   ├── app/
│   │   ├── api/v1/           # API Endpoints (Candidate, Interview, Evaluation, TTS)
│   │   ├── core/             # Configuration, Settings & System Prompts
│   │   ├── schemas/          # Pydantic Schemas (Request/Response contracts)
│   │   └── services/         # OpenAI Client, Interview Manager, Evaluator, Resume Parser
│   ├── tests/                # Pytest Test Suite
│   ├── requirements.txt      # Python Dependencies
│   └── run.py                # Server Runner
│
├── frontend/                 # Flutter Application (Web, Desktop, Mobile)
│   ├── lib/
│   │   ├── core/             # Themes, Colors, Constants
│   │   ├── data/             # Models, Repositories, HTTP Client
│   │   └── ui/               # Screens (Home, Interview Room, Scorecard) & Widgets
│   └── pubspec.yaml
└── README.md
```

---

## 🛠️ Getting Started

### 1. Prerequisites
- **Python 3.10+** (tested on 3.12)
- **Flutter 3.x+** with Dart
- **OpenAI API Key** (from [platform.openai.com](https://platform.openai.com/api-keys))

---

### 2. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
# Windows:
.\venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and paste your OPENAI_API_KEY
```

#### Run Backend Server:
```bash
python run.py
# Or: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
- Health Check: [http://localhost:8000/health](http://localhost:8000/health)

---

### 3. Frontend Setup

```bash
cd frontend

# Get packages
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Or run on Windows desktop
flutter run -d windows
```

---

## 🧪 Running Tests

```bash
cd backend
pytest tests/ -v
```

---

## 📄 License
MIT License. Developed for intelligent interview preparation and candidate evaluation.
