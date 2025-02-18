import os
from supabase import create_client, ClientOptions

SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")

supabase = create_client(
    SUPABASE_URL,
    SUPABASE_KEY,
    options=ClientOptions(
        flow_type="pkce",
        auto_refresh_token=True
    ),
)
