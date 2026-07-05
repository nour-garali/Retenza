from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class CodeReview(BaseModel):
    status: str = Field(description="APPROVED or REJECTED")
    feedback: List[str] = Field(description="List of specific code review comments")
    optimization_suggestions: List[str] = Field(description="Performance or architecture improvements")

def code_review_node(state: SwarmState):
    print("Code Review Agent is reviewing the Flutter code...")
    
    llm = get_llm(temperature=0.1)
    llm_structured = llm.with_structured_output(CodeReview)
    
    sys_msg = """You are a strict Principal Flutter Engineer.
Review the generated Flutter code for architectural soundness, performance, and adherence to the Design System.
If the code is messy or incorrect, mark as REJECTED."""
    
    review = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"Generated Code:\n{state.get('flutter_code')}\nDesign System:\n{state.get('design_system')}"}
    ])
    
    return {
        "code_review": review.model_dump(),
        "messages": [{"role": "assistant", "content": f"Code Review Agent finished. Status: {review.status}"}]
    }
