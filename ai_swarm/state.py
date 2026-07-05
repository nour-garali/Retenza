from typing import Annotated, TypedDict, Any
from langgraph.graph.message import add_messages

class SwarmState(TypedDict):
    messages: Annotated[list[Any], add_messages]
    feature_request: str
    product_specs: dict
    ux_flows: dict
    ui_design: dict
    design_system: dict
    backend_schema: dict
    qa_report: dict
    flutter_code: dict
    code_review: dict
