# Retenza

A full-stack AI-powered financial management platform for the Moroccan market.

## Structure

| Directory | Description |
|-----------|-------------|
| `ai_swarm/` | LangGraph multi-agent AI swarm (PM → UX → UI → Design System → Backend → QA → Flutter → Code Review) |
| `backend/` | Backend API and database schema |
| `retenza_flutter/` | Flutter mobile application |
| `ai_swarm/output/` | Generated Flutter module and backend schema from the AI Swarm execution |

## AI Swarm

The AI Swarm is a production LangGraph pipeline powered by Google Gemini that generates:
- Product requirements
- UX research & UI design specs
- A full Flutter design system
- Backend schemas & API definitions
- QA reports
- Production-ready Flutter code

### Run the swarm

```bash
cd ai_swarm
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# Add GEMINI_API_KEY to .env
python main.py
```

## Flutter App

```bash
cd retenza_flutter
flutter pub get
flutter run
```

## Backend

```bash
cd backend
# See backend README for setup
```
