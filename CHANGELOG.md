# Changelog

Breaking changes are listed first in each entry.

## 1.2.0 (2026-11-24)

- First release of the Railway template: Servas `1.2.0` (`beromir/servas@sha256:662b0d8f37e67addc0448eb0fecb87c9a1314e2ef51dd8eb3ba222e8a2b726e3`).
- SQLite database on a Railway volume at `/app/database/sqlite`.
- Owner account created on the first boot from `SERVAS_ADMIN_EMAIL` and a generated `SERVAS_ADMIN_PASSWORD`; public sign-up closed by default.
- Health check at `/healthz`; PHP threads sized from the service's CPU limit.
