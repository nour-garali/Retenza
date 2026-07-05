---
name: Retenza backend MongoDB setup
description: How the backend connects to MongoDB in dev vs production, and what's required before deploying.
---

The backend (`backend/config/db.js`) requires `MONGODB_URI`. In production (`NODE_ENV=production`) it throws if unset — no fallback.

In non-production environments, if `MONGODB_URI` is not set, it auto-starts an in-memory MongoDB instance (`mongodb-memory-server`, already a devDependency) so the app runs without any external DB configured. Data does not persist across restarts in this mode.

**Why:** The original project (RetenzaConnect) expects MongoDB Atlas, which isn't a native Replit service. The in-memory fallback lets the app run immediately after import without requiring the user to provide Atlas credentials up front.

**How to apply:** Before publishing/deploying this app for real use, get a real `MONGODB_URI` (e.g. MongoDB Atlas connection string) from the user and set it as a secret — otherwise the production deployment will fail to start (by design, no silent in-memory fallback in prod).
