import os
from langchain_openai import ChatOpenAI
# You would install and import these for multi-model support:
# from langchain_google_genai import ChatGoogleGenerativeAI
# from langchain_anthropic import ChatAnthropic

_RESOLVED_GEMINI_MODEL = None

def get_llm(temperature: float = 0.7):
    """
    Factory method to instantiate the chosen LLM provider based on environment variables.
    Currently supports OpenAI, but extensible to Gemini, Mistral, Anthropic, etc.
    """
    global _RESOLVED_GEMINI_MODEL
    provider = os.getenv("LLM_PROVIDER", "gemini").lower()
    
    if provider == "gemini":
        from langchain_google_genai import ChatGoogleGenerativeAI
        
        if _RESOLVED_GEMINI_MODEL is None:
            target_model = os.getenv("GEMINI_MODEL_NAME", "gemini-1.5-pro")
            try:
                from google import genai
                client = genai.Client()
                available_models = [m.name for m in client.models.list() if "gemini" in m.name.lower()]
                
                target_base = target_model.replace("models/", "")
                
                # Check if exact or substring match exists
                matched_model = next((m for m in available_models if target_base in m), None)
                
                if matched_model:
                    target_model = matched_model
                elif available_models:
                    fallback = next((m for m in available_models if "flash" in m), 
                                    next((m for m in available_models if "pro" in m), available_models[0]))
                    print(f"\n[Provider Warning] Model '{target_model}' not found.")
                    print(f"Available Gemini models: {[m.replace('models/', '') for m in available_models]}")
                    print(f"Automatically falling back to: {fallback}\n")
                    target_model = fallback
            except Exception as e:
                print(f"\n[Provider Warning] Could not validate Gemini model list: {e}\n")
                if target_model == "gemini-1.5-flash":
                    target_model = "gemini-1.5-flash-latest"
            
            _RESOLVED_GEMINI_MODEL = target_model
            print(f"Resolved Gemini Model: {_RESOLVED_GEMINI_MODEL}")
            
        return ChatGoogleGenerativeAI(
            model=_RESOLVED_GEMINI_MODEL, 
            temperature=temperature
        )
        
    elif provider == "openai":
        from langchain_openai import ChatOpenAI
        import httpx
        http_client = httpx.Client(verify=False)
        return ChatOpenAI(
            model=os.getenv("OPENAI_MODEL_NAME", "gpt-4o"), 
            temperature=temperature,
            http_client=http_client
        )
    
    else:
        raise ValueError(f"Unsupported LLM provider: {provider}")
