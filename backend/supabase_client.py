import os
from flask import g
from werkzeug.local import LocalProxy
from supabase import create_client, ClientOptions

SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")

def get_supabase():
    if "supabase" not in g:
        g.supabase = create_client(
            SUPABASE_URL,
            SUPABASE_KEY,
            options=ClientOptions(
                flow_type="pkce",
                auto_refresh_token=True
            ),
        )
    return g.supabase

supabase = LocalProxy(get_supabase)
