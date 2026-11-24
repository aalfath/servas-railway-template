# Deploy and Host Servas on Railway

Servas is a self-hosted, open-source bookmark manager built on Laravel. You save links with tags, sort them into nested groups or tag-based smart groups, search them, import and export browser bookmarks (HTML or JSON), add links from Firefox and Chrome extensions, and protect each account with two-factor login. It supports several user accounts.

## About Hosting Servas

Servas is a single PHP web app (FrankenPHP) that keeps everything in a SQLite database. Hosting it means running the official image, keeping that database on persistent storage, generating a Laravel `APP_KEY`, running database migrations on each start and making sure no stranger can register. This template does all of that: one Railway service built from our GitHub wrapper around the official `beromir/servas` 1.2.0 image (pinned by digest), a volume for the database, migrations on start, a `/healthz` check, and an owner account created on the first boot with sign-up closed. It fits Railway's Free plan.

## Common Use Cases

* A private bookmark library you can reach from any browser or phone
* Saving links from Firefox or Chrome with the Servas extension and sorting them later from the inbox
* A small shared bookmark server for a family or team, with an account per person

## Dependencies for Servas Hosting

* One Railway service built from [aalfath/servas-railway-template](https://github.com/aalfath/servas-railway-template)
* One Railway volume for the SQLite database (no separate database service)

### Deployment Dependencies

* [Servas on GitHub](https://github.com/beromir/Servas) and its [1.2.0 release](https://github.com/beromir/Servas/releases/tag/v1.2.0)
* [Official Docker image beromir/servas](https://hub.docker.com/r/beromir/servas)
* [Servas browser extension](https://github.com/beromir/servas-extension)

### Implementation Details

**What you get:** the Servas service on a public Railway domain with a volume at `/app/database/sqlite` (accounts, bookmarks, tags, groups, sessions).

**The only prompt** is `SERVAS_ADMIN_EMAIL`, the email of the owner account. Its password (`SERVAS_ADMIN_PASSWORD`) and the Laravel `APP_KEY` are generated for you.

**After deploy:** open the public URL and log in with your email and the generated password (service → Variables → `SERVAS_ADMIN_PASSWORD`). Change the password and turn on two-factor login under Profile. For the browser extension, create an API token under Profile → API Tokens.

**Sign-up is closed** so nobody else can register. To add people, set `SERVAS_ENABLE_REGISTRATION=true` on the service, let them register, then remove it again.

**Updates:** the service builds from our GitHub repo. When we bump the Servas version, Railway shows an "update available" notice in your project, and you apply it when you choose. Migrations run on start and your data stays on the volume. Read the repo's CHANGELOG first.

## Why Deploy Servas on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Servas on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
