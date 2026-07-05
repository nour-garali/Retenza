from pydantic import BaseModel, Field
from typing import List
from state import SwarmState
from llm_provider import get_llm

class FlutterFile(BaseModel):
    file_path: str = Field(description="Path to the file (e.g., lib/screens/crypto_dashboard.dart)")
    code: str = Field(description="The complete Dart/Flutter code for this file")
    dependencies: List[str] = Field(description="List of packages needed (e.g., provider, flutter_bloc)")

class FlutterProject(BaseModel):
    files: List[FlutterFile] = Field(description="List of generated Flutter files")
    pubspec_updates: List[str] = Field(description="Packages to add to pubspec.yaml")

def flutter_dev_node(state: SwarmState):
    print("Flutter Developer Agent is writing code...")
    
    llm = get_llm(temperature=0.2)
    llm_structured = llm.with_structured_output(FlutterProject)
    
    sys_msg = """You are a Senior Flutter Developer at a top fintech company.
Generate clean, highly modular, and production-ready Flutter code.
Use the Design System specifications strictly for colors, fonts, and spacing.
Implement the UX Flows as functional Dart files."""
    
    project = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"UX Flows:\n{state.get('ux_flows')}\nDesign System:\n{state.get('design_system')}"}
    ])
    
    return {
        "flutter_code": project.model_dump(),
        "messages": [{"role": "assistant", "content": "Flutter Dev Agent generated Dart code."}]
    }
