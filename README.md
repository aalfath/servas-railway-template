[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/servas?utm_medium=integration&utm_source=button&utm_campaign=servas)

# Servas on Railway

One-click [Servas](https://github.com/beromir/Servas) for [Railway](https://railway.com): a self-hosted bookmark manager with tags, nested groups, smart groups, import/export, two-factor login and browser extensions.

This template runs the official image **`beromir/servas:1.2.0`** (pinned by digest in the [`Dockerfile`](Dockerfile)) as a single Railway service with its SQLite database on a Railway volume.

## What you get

- **Servas** web app (FrankenPHP + PHP 8.5) on Railway's public domain, health check at `/healthz`.
- **Volume** at `/app/database/sqlite`: the SQLite database with every account, bookmark, tag, group and session.
- **Owner account created on the first boot**, before the public port opens, from the email you enter and a generated password. Public sign-up is **closed**, so a stranger can't register on your instance.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `SERVAS_ADMIN_EMAIL` | *(you enter it)* | Email of the owner account created on the first boot. It is your login. |
| `SERVAS_ADMIN_PASSWORD` | `${{secret(24)}}` | Generated password of the owner account, used on the first boot only. Read it in the service's Variables tab. |
| `APP_KEY` | `${{secret(32)}}` | Laravel encryption key (sessions, two-factor secrets). Don't change it after the first deploy. |
| `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used in links. |
| `PORT` | `8080` | Port the web server listens on. |

Optional, not in the template (add them in the service's Variables tab if you need them):

- `SERVAS_ENABLE_REGISTRATION=true` opens public sign-up at `/register` (anyone can then create an account).
- `SERVAS_ADMIN_NAME` sets the owner's display name on the first boot (default `Admin`).
- `SERVAS_SHOW_APP_VERSION=false` hides the version number in the profile menu.

Changing `SERVAS_ADMIN_EMAIL` or `SERVAS_ADMIN_PASSWORD` after the first boot does nothing: the account exists by then. Change the password in Servas under **Profile**.

## After deploy

1. Open the service's public URL and log in with `SERVAS_ADMIN_EMAIL` and the value of `SERVAS_ADMIN_PASSWORD` (service → Variables).
2. Change the password and switch on two-factor login under **Profile**.
3. For the [browser extension](https://github.com/beromir/servas-extension), create an API token under **Profile → API Tokens**.
4. To add more people, temporarily set `SERVAS_ENABLE_REGISTRATION=true`, let them register, then remove it again.

## Resources

Servas idles at about 50 MB of RAM and fits Railway's Free plan (0.5 GB RAM, one volume). The start script sizes PHP threads from the service's CPU limit, not the host's.

## How updates reach you

The service builds from this repository. When we bump the pinned Servas image on `main`, Railway shows you an "update available" notice for your project, and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed at the top of each entry. Database migrations run automatically on start, and your data stays on the volume.

## How it works

- [`Dockerfile`](Dockerfile): `FROM beromir/servas:<version>@sha256:<digest>` plus the files in [`railway/`](railway).
- [`railway/start.sh`](railway/start.sh): sets production defaults, checks `APP_KEY`, sizes PHP threads from the cgroup, runs migrations, creates the owner account (and stops the service with an error if that fails), then starts FrankenPHP on `$PORT`. If the web server stops unexpectedly, the container exits non-zero and Railway restarts it.
- [`railway/Caddyfile`](railway/Caddyfile): listens on `$PORT` and trusts Railway's proxy ranges for `X-Forwarded-*`.
- [`railway/healthz.php`](railway/healthz.php): health check that answers 200 once the database is migrated.

Servas is © its authors and licensed under the GPL-3.0. This wrapper is published under the same licence.
