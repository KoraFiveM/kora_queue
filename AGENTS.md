# kora_queue agent guide

`kora_queue` is the Kora connection queue (a ConnectQueue fork): it holds players in a deferral with an Adaptive Card while the server is full, orders them by priority, and exposes a small API to other resources. Layout: `fxmanifest.lua`, `server/sv_queue_config.lua` (config), `shared/sh_queue.lua` (server queue logic and the client `Queue:playerActivated` trigger), `connectqueue.lua` (helper script consumers load as `@kora_queue/connectqueue.lua`), `test/smoke/` (offline Lua regression) and `tests/` (kora_qa feature files).

## Documentation

User-facing documentation lives in `docs/` (Markdown, published via the Kora Docusaurus site, kora_docs_next). Read `docs/index.md` first for an overview and the documentation map. Layout: `index.md` (hub), `installation.md` (setup, manifest, convars, consumer facade), `how-to-use.md` (connection flow, card, priority, integration examples), `commands.md` (rcon `queue` commands), and topic pages `api.md` (helper script and export), `configuration.md`, `priority.md`, `events.md`, `troubleshooting.md`. The resource has no legacy `api/` module folder; the whole API is in `api.md`. Update the page that owns the topic you change.

When you add, change, or remove a feature, config option, command, export, event, item, permission, or database table/column, update the matching page in `docs/` in the same change. Keep docs accurate to the code; do not document behaviour that does not exist.

Docs rules: plain Markdown with `title`/`sidebar_position` front matter (no `id`/`slug`), relative links only between docs pages, assets inside `docs/`, fenced code blocks with a language, and no raw `<`, `>`, `{`, `}` outside code (pages are parsed as MDX). The release version comes from `fxmanifest.lua`'s `version` field.
