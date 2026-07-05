from langgraph.graph import StateGraph, START, END
from state import SwarmState
from pm_agent import product_manager_node
from ux_agent import ux_research_node
from ui_agent import ui_design_node
from design_system_agent import design_system_node
from backend_agent import backend_architect_node
from qa_agent import qa_review_node
from flutter_agent import flutter_dev_node
from review_agent import code_review_node

def build_graph():
    builder = StateGraph(SwarmState)
    
    # Add nodes
    builder.add_node("product_manager", product_manager_node)
    builder.add_node("ux_research", ux_research_node)
    builder.add_node("ui_design", ui_design_node)
    builder.add_node("design_system", design_system_node)
    builder.add_node("backend_architect", backend_architect_node)
    builder.add_node("qa_review", qa_review_node)
    builder.add_node("flutter_dev", flutter_dev_node)
    builder.add_node("code_review", code_review_node)
    
    # Add edges
    builder.add_edge(START, "product_manager")
    builder.add_edge("product_manager", "ux_research")
    builder.add_edge("ux_research", "ui_design")
    builder.add_edge("ui_design", "design_system")
    builder.add_edge("design_system", "backend_architect")
    builder.add_edge("backend_architect", "qa_review")
    builder.add_edge("qa_review", "flutter_dev")
    builder.add_edge("flutter_dev", "code_review")
    builder.add_edge("code_review", END)
    
    return builder.compile()
