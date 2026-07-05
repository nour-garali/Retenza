from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class ProductSpecs(BaseModel):
    feature_name: str = Field(description="Name of the feature")
    business_goal: str = Field(description="Primary business objective")
    target_audience: str = Field(description="Who this feature is for")
    core_functionalities: List[str] = Field(description="List of core functionalities")
    user_stories: List[str] = Field(description="List of user stories (Agile format)")
    success_metrics: List[str] = Field(description="KPIs to measure success")
    ui_ux_guidelines: str = Field(description="High-level UX/UI directions (MonEx/Revolut style)")

def product_manager_node(state: SwarmState):
    print("Product Manager Agent is thinking...")
    
    llm = get_llm(temperature=0.7)
    llm_structured = llm.with_structured_output(ProductSpecs)
    
    sys_msg = """You are a senior fintech Product Manager at a leading startup. 
Analyze the user's feature request and generate highly professional product specifications.
Your style is modern, sleek, and focused on premium user experiences (like MonEx or Revolut).
Ensure your core functionalities and user stories are robust and ready for an engineering team."""
    
    specs = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": state["feature_request"]}
    ])
    
    return {
        "product_specs": specs.model_dump(),
        "messages": [{"role": "assistant", "content": f"PM Agent successfully generated specs for: {specs.feature_name}"}]
    }
