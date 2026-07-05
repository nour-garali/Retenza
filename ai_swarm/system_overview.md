# LangGraph Fintech Swarm Architecture

This document provides a high-level overview of the production-ready multi-agent system built for the MonEx fintech application.

## 🧠 System Overview
The architecture is built using **LangGraph**, **LangChain**, and **Pydantic**. It employs an 8-agent linear swarm that systematically transforms a simple user feature request into fully documented, rigorously architected, reviewed, and generated Flutter code and Backend specifications.

All data is strictly structured using Pydantic, ensuring that each downstream agent receives precise and strongly-typed data.

## 🔄 Data Flow (The Graph)
The system leverages a state machine (`StateGraph`) passing a `SwarmState` dictionary.

1. **Product Manager Agent**
   - **Input:** `feature_request` (string)
   - **Output:** `product_specs` (Business goals, User stories, Metrics)
2. **UX Research Agent**
   - **Input:** `product_specs`
   - **Output:** `ux_flows` (Information Architecture, Screens, User Journeys)
3. **UI Design Agent**
   - **Input:** `product_specs`, `ux_flows`
   - **Output:** `ui_design` (Colors, Typography, Component layout rules)
4. **Design System Agent**
   - **Input:** `ui_design`
   - **Output:** `design_system` (Strict Hex codes, Padding/Grid values, Scaled typography)
5. **Backend Architect Agent**
   - **Input:** `product_specs`, `ux_flows`, `ui_design`
   - **Output:** `backend_schema` (Database models, APIs, Auth flows, Financial logic)
6. **QA Review Agent**
   - **Input:** `ux_flows`, `ui_design`, `design_system`, `backend_schema`
   - **Output:** `qa_report` (Cross-validation of frontend flows vs backend schema)
7. **Flutter Developer Agent**
   - **Input:** `ux_flows`, `design_system`
   - **Output:** `flutter_code` (Dart source code, pubspec dependencies)
8. **Code Review Agent**
   - **Input:** `flutter_code`, `design_system`
   - **Output:** `code_review` (Architectural soundness, optimizations)

## ⚡ Real LLM Integration (`llm_provider.py`)
The system abstracts the model provider layer, allowing seamless interchangeable usage of OpenAI, Gemini, or Anthropic (Claude).
To use, ensure your `.env` contains:
```env
LLM_PROVIDER=openai
OPENAI_MODEL_NAME=gpt-4o
OPENAI_API_KEY=sk-...
```

To switch models, just change `LLM_PROVIDER=gemini` and ensure `langchain-google-genai` is installed.

## 🛠 How to Modify or Extend
1. **Define State:** Add a new dictionary key to `SwarmState` in `state.py`.
2. **Create Agent Node:** Create a new Python file (e.g., `marketing_agent.py`). Use `get_llm()` from `llm_provider.py`. Define a Pydantic model for output.
3. **Update Graph:** Open `graph.py`, import your new node, call `builder.add_node()`, and update the `add_edge()` pipeline.
4. **Update Main:** Print the new state key output in `main.py`.
