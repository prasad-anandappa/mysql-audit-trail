# mysql-audit-trail

I built this MySQL 8 project to answer a question every production system eventually faces: **what did this row look like at 3pm last Tuesday, and who changed it?** I implemented a temporal audit trail with history tables, triggers, and point-in-time reconstruction — no application code required.

## What the schema models

- Live tables: `customers` and `orders` (a deliberately small domain, so the audit machinery is the star)
- History tables: `customers_history` and `orders_history` — one row per change, with `change_type` (`INSERT` / `UPDATE` / `DELETE`), the new values as columns, and a full `row_snapshot` JSON document (including `old_status` on updates)
- `audit_log` — a cross-table, human-readable change feed

## How it works

- **Triggers** (`triggers.sql`) — `AFTER INSERT`, `AFTER UPDATE`, and `AFTER DELETE` triggers on both live tables write to the matching history table; customer changes also write a summary line to `audit_log`. Deletes are captured too, so a deleted row is still recoverable from history.
- **Procedures** (`procedures.sql`) — `reconstruct_customer_at(id, timestamp)` and `reconstruct_order_at(id, timestamp)` return the latest history state at or before any moment in time.
- **Queries** (`queries.sql`) — full history for a row, point-in-time lookups, most active changers, status-transition diffs using `LAG()` window functions, and deleted-row recovery.
- **Views** — latest history state per customer, and change counts by table/type.

## How to load it into MySQL 8

```bash
mysql -u root -p < schema.sql
mysql -u root -p audit_trail_demo < triggers.sql
mysql -u root -p audit_trail_demo < procedures.sql
mysql -u root -p audit_trail_demo < views.sql
mysql -u root -p audit_trail_demo < seed.sql
mysql -u root -p audit_trail_demo < queries.sql   # optional
```

Load `triggers.sql` **before** `seed.sql` if you want the seed's example lifecycle updates captured into history — that ordering is intentional and demonstrates the trail filling up.

## Validation

I validated these files on a machine with **no MySQL/MariaDB server and no Docker**, so I did **not** execute them against a live server and I am not claiming I did. Instead I ran a documented structural lint pass (Python, standard library only) over every `.sql` file in this repo: balanced parentheses and quotes after stripping strings/comments, statement termination, well-formed `DELIMITER` blocks, and a cross-file check that every table/view/procedure referenced is defined in this repo. All files passed that lint. Execution against MySQL 8 remains the reader's final check.

## License

MIT — see `LICENSE`. I am a Software Engineer; this is a personal portfolio project.
