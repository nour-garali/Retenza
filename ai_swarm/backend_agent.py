from pydantic import BaseModel, Field
from typing import List, Dict
from state import SwarmState
from llm_provider import get_llm

class DatabaseModel(BaseModel):
    model_name: str = Field(description="Name of the database table/collection (e.g., Users, Transactions)")
    fields: Dict[str, str] = Field(description="Dictionary of field names and their data types (e.g., 'id': 'UUID', 'amount': 'Decimal')")
    relationships: List[str] = Field(description="Relationships to other models (e.g., 'One-to-Many with Transactions')")

class APIEndpoint(BaseModel):
    method: str = Field(description="HTTP Method (GET, POST, PUT, DELETE)")
    path: str = Field(description="Endpoint URL path (e.g., /api/v1/transactions)")
    description: str = Field(description="What this endpoint does")
    request_payload: str = Field(description="Required request body fields")
    response_payload: str = Field(description="Expected response data")

class AuthFlow(BaseModel):
    strategy: str = Field(description="Authentication strategy (e.g., JWT, OAuth2)")
    token_lifecycle: str = Field(description="Rules for access/refresh tokens and expiration")
    security_measures: List[str] = Field(description="Security protocols (e.g., MFA, Biometrics, Rate limiting)")

class FinancialLogic(BaseModel):
    balance_calculation: str = Field(description="Formula or strategy for calculating total net worth/fiat balance safely")
    currency_conversion: str = Field(description="How fiat to crypto conversions are handled (e.g., locking rates)")
    ledger_rules: List[str] = Field(description="Strict rules for double-entry bookkeeping or ledger immutability")

class BackendArchitecture(BaseModel):
    database_schema: List[DatabaseModel] = Field(description="Core database entities")
    api_design: List[APIEndpoint] = Field(description="Core CRUD and operational endpoints")
    auth_flow: AuthFlow = Field(description="Authentication and security system")
    financial_logic: FinancialLogic = Field(description="Core fintech calculation engine")

def backend_architect_node(state: SwarmState):
    print("Backend Architect Agent is thinking...")
    
    llm = get_llm(temperature=0.7)
    llm_structured = llm.with_structured_output(BackendArchitecture)
    
    sys_msg = """You are the Lead Backend Architect at a premium fintech company (like MonEx or Revolut).
Using the product, UX, and UI specifications provided, generate a robust, secure, and highly scalable backend architecture.
Ensure your database models, API endpoints, auth flow, and financial logic are strictly typed and enterprise-ready."""
    
    arch = llm_structured.invoke([
        {"role": "system", "content": sys_msg},
        {"role": "user", "content": f"Product Specs:\n{state.get('product_specs')}\nUX Flows:\n{state.get('ux_flows')}\nUI Design:\n{state.get('ui_design')}"}
    ])
    
    return {
        "backend_schema": arch.model_dump(),
        "messages": [{"role": "assistant", "content": "Backend Architect mapped out the system architecture."}]
    }
