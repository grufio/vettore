# Postgres Follow-up

- LISTEN/NOTIFY: Replace naive polling in `ProjectRepositoryPg.watchAll()` with a channel-based notifier and trigger on writes to reduce latency and load.
- Backfill: If migrating from local storage, define a one-time importer to seed `projects` from previous data sources, ensuring `created_at`/`updated_at` are preserved.
- Indices: Revisit indexing once real workloads are observed; consider `status, updated_at` composite.
