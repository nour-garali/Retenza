from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class Screen(BaseModel):
    screen_name: str = Field(description="Name of the screen")
    purpose: str = Field(description="What the user does here")
    key_elements: List[str] = Field(description="Buttons, charts, inputs, etc.")

class UserJourney(BaseModel):
    journey_name: str = Field(description="E.g., 'First Time Crypto Purchase'")
    steps: List[str] = Field(description="Step-by-step user actions")

class UXFlows(BaseModel):
    information_architecture: str = Field(description="App navigation structure")
    screens: List[Screen] = Field(description="Screens required for this feature")
    user_journeys: List[UserJourney] = Field(description="Key user journeys")

def ux_research_node(state: SwarmState):
    print("UX Research Agent is thinking...")
    
    llm = get_llm(temperature=0.7)
    llm_structured = llm.with_structured_output(UXFlows)
    
    sys_msg = """You are a Lead UX Researcher at a premium fintech company (like MonEx or Revolut).
Using the provided product specifications, generate the optimal UX flows, screen architecture, and user journeys.
Ensure the flow is frictionless, minimal, and modern."""
    
    flows = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"Product Specs:\n{state.get('product_specs')}"}
    ])
    
    return {
        "ux_flows": flows.model_dump(),
        "messages": [{"role": "assistant", "content": "UX Agent successfully mapped user flows and screens."}]
    }
