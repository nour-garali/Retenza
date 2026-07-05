from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class UIComponent(BaseModel):
    element: str = Field(description="Name of the component")
    style_rules: str = Field(description="Visual rules (colors, radii, shadows, etc.)")

class UIDesignSpecs(BaseModel):
    color_palette: List[str] = Field(description="Hex codes and descriptions")
    typography: str = Field(description="Fonts and styling for headers/body")
    spacing_system: str = Field(description="Grid and padding rules")
    components: List[UIComponent] = Field(description="Specific component styling")
    animation_rules: str = Field(description="Guidelines for micro-animations and transitions")

def ui_design_node(state: SwarmState):
    print("UI Design Agent is thinking...")
    
    llm = get_llm(temperature=0.7)
    llm_structured = llm.with_structured_output(UIDesignSpecs)
    
    sys_msg = """You are a Lead UI Designer at a premium fintech company (like MonEx or Revolut).
Using the product specs and UX flows, generate detailed UI design specifications.
Your focus is absolute visual excellence, using modern aesthetics (dark mode, neon accents, sleek typography).
Ensure the design looks extremely premium and state of the art."""
    
    design = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"Product Specs:\n{state.get('product_specs')}\nUX Flows:\n{state.get('ux_flows')}"}
    ])
    
    return {
        "ui_design": design.model_dump(),
        "messages": [{"role": "assistant", "content": "UI Agent successfully generated design specs."}]
    }
