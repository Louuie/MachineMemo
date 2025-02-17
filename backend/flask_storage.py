from gotrue import SyncSupportedStorage
from flask import session
from typing import Optional  # ✅ Import Optional

class FlaskSessionStorage(SyncSupportedStorage):
    def __init__(self):
        self.storage = session

    def get_item(self, key: str) -> Optional[str]:  # ✅ Use Optional instead of |
        if key in self.storage:
            return self.storage[key]
        return None  # ✅ Ensure None is explicitly returned

    def set_item(self, key: str, value: str) -> None:
        self.storage[key] = value

    def remove_item(self, key: str) -> None:
        if key in self.storage:
            self.storage.pop(key, None)
