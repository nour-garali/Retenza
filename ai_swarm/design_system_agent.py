import os
from llm_provider import get_llm
from pydantic import BaseModel, Field
from typing import List
from state import SwarmState

class ColorPalette(BaseModel):
    mode: str = Field(description="'light' or 'dark'")
    primary: str = Field(description="Primary brand color hex")
    secondary: str = Field(description="Secondary accent color hex")
    background: str = Field(description="Main background hex")
    surface: str = Field(description="Card/Surface hex")
    text_primary: str = Field(description="Primary text hex")
    text_secondary: str = Field(description="Secondary text hex")
    success: str = Field(description="Success/Positive action hex")
    error: str = Field(description="Error/Destructive action hex")

class Typography(BaseModel):
    font_family: str
    h1: str
    h2: str
    body: str
    caption: str

class Spacing(BaseModel):
    grid_base: str
    padding_small: str
    padding_medium: str
    padding_large: str

class ComponentRule(BaseModel):
    component_name: str
    rules: str

class DesignSystem(BaseModel):
    light_palette: ColorPalette
    dark_palette: ColorPalette
    typography: Typography
    spacing: Spacing
    components: List[ComponentRule]

def design_system_node(state: SwarmState):
    print("Design System Agent is thinking...")
    
    llm = get_llm(temperature=0.2)
    llm_structured = llm.with_structured_output(DesignSystem)
    
    sys_msg = """You are a meticulous Design System Engineer at a premium fintech company.
Based on the UI Design Specs, create a strict, concrete Design System.
Use specific hex codes, font sizes (px), and exact padding values.
This system will be consumed by Flutter Developers, so it must be completely unambiguous."""
    
    system = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"UI Design Specs:\n{state.get('ui_design')}"}
    ])
    
    return {
        "design_system": system.model_dump(),
        "messages": [{"role": "assistant", "content": "Design System Agent created the final design system."}]
    }
