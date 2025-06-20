# Diagrams

Hand-drawn style diagrams of how Envolet works. They are generated from
[`generate.mjs`](generate.mjs), so edit the script instead of the SVGs:

```bash
node docs/diagrams/generate.mjs
```

The script has no dependencies. The embedded font is
[Virgil](https://github.com/excalidraw/virgil) from Excalidraw (SIL Open Font License).

## System overview

![System overview](architecture.svg)

## Session flow

What happens on app launch and on login (`SplashScreen`, `SessionProvider`, `ApiService`).

![Session flow](session-flow.svg)

## Auth pipeline

`POST /auth/login` and the `get_current_user` guard every protected route goes through.

![Auth pipeline](auth-guard.svg)

## Spending analytics

How `app/services/analytics.py` splits a month into five day-buckets and what each endpoint returns.

![Spending analytics](spending-buckets.svg)

## Tracker page

How `TrackerPage` loads its charts in parallel, drops stale responses and asks for an AI tip.

![Tracker pipeline](tracker-pipeline.svg)
