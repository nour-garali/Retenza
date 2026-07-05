import json
import os
import certifi
import httpx
from dotenv import load_dotenv

# Bypass SSL globally for httpx due to corporate proxy/MITM certificate issues
original_client_init = httpx.Client.__init__
def patched_client_init(self, *args, **kwargs):
    kwargs['verify'] = False
    original_client_init(self, *args, **kwargs)
httpx.Client.__init__ = patched_client_init

os.environ["SSL_CERT_FILE"] = certifi.where()

load_dotenv()

load_dotenv()

from graph import build_graph

def main():
    print("Initializing LangGraph Swarm (Production Execution: Expense Tracking)...")
    graph = build_graph()
    
    feature_request = "Create a premium expense tracking feature"
    initial_state = {
        "messages": [],
        "feature_request": feature_request,
        "product_specs": {},
        "ux_flows": {},
        "ui_design": {},
        "design_system": {},
        "backend_schema": {},
        "qa_report": {},
        "flutter_code": {},
        "code_review": {}
    }
    
    print(f"\nUser Request: '{feature_request}'")
    
    print("\nExecuting graph...")
    result = graph.invoke(initial_state)
    
    print("\n=== Graph Execution Completed ===")
    
    os.makedirs("output/backend", exist_ok=True)
    os.makedirs("output/flutter/lib/screens", exist_ok=True)
    os.makedirs("output/flutter/lib/widgets", exist_ok=True)
    
    backend_schema = result.get("backend_schema", {})
    with open("output/backend/database_schema.json", "w") as f:
        json.dump(backend_schema.get("database_schema", []), f, indent=2)
        
    with open("output/backend/api_endpoints.json", "w") as f:
        json.dump(backend_schema.get("api_design", []), f, indent=2)
        
    print("Generated backend schema files in output/backend/")

    flutter_res = result.get("flutter_code", {})
    files = flutter_res.get("files", [])
    
    for file_obj in files:
        file_path = f"output/flutter/{file_obj.get('file_path')}"
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(file_obj.get("code", ""))
        print(f"Generated Flutter file: {file_path}")
        
    with open("output/flutter/pubspec_updates.txt", "w") as f:
        f.write("\n".join(flutter_res.get("pubspec_updates", [])))

if __name__ == "__main__":
    main()
