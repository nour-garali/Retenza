from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class QAReport(BaseModel):
    status: str = Field(description="APPROVED or REJECTED")
    issues: List[str] = Field(description="List of detected inconsistencies, missing features, or logic errors")
    improvements: List[str] = Field(description="List of suggestions for better UX, UI, or backend robustness")
    risk_level: str = Field(description="LOW, MEDIUM, or HIGH")

def qa_review_node(state: SwarmState):
    print("QA / Review Agent is analyzing the pipeline output...")
    
    llm = get_llm(temperature=0.2)
    llm_structured = llm.with_structured_output(QAReport)
    
    sys_msg = """You are a strict QA and Architecture Reviewer at a top fintech company (like MonEx).
Your job is to validate the consistency between UX flows, UI design, Design System, and Backend Schema.
Ensure financial logic correctness (transactions, balances, budgets).
Ensure the design system adheres to the UI components described in the UX.
Output a highly structured QA report. If critical logic or design is missing, mark status as REJECTED and risk_level as HIGH."""
    
    report = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"UX Flows:\n{state.get('ux_flows')}\nUI Design:\n{state.get('ui_design')}\nDesign System:\n{state.get('design_system')}\nBackend Architecture:\n{state.get('backend_schema')}"}
    ])
    
    return {
        "qa_report": report.model_dump(),
        "messages": [{"role": "assistant", "content": f"QA Agent finished review. Status: {report.status}"}]
    }
