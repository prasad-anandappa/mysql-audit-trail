-- queries.sql : point-in-time and audit pack
USE audit_trail_demo;
-- 1. Full history for one customer
SELECT * FROM customers_history WHERE customer_id = 1 ORDER BY changed_at, history_id;
-- 2. Point-in-time: latest customer state at or before a timestamp
SELECT h.* FROM customers_history h
WHERE h.customer_id = 1 AND h.changed_at <= '2026-11-02 23:59:59'
ORDER BY h.changed_at DESC, h.history_id DESC LIMIT 1;
-- 3. Who changed most in the last 7 days (by changed_by)
SELECT changed_by, COUNT(*) AS changes FROM customers_history
WHERE changed_at >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY) GROUP BY changed_by ORDER BY changes DESC;
-- 4. Orders that changed status more than once
SELECT order_id, COUNT(*) AS changes FROM orders_history GROUP BY order_id HAVING COUNT(*) > 1 ORDER BY changes DESC;
-- 5. Audit log across all tables, newest first
SELECT * FROM audit_log ORDER BY changed_at DESC, audit_id DESC LIMIT 100;
-- 6. Deleted rows still recoverable from history
SELECT * FROM customers_history WHERE change_type = 'DELETE' ORDER BY changed_at DESC;
-- 7. Diff-style view: status transitions for orders
SELECT order_id, status, change_type, changed_at,
       LAG(status) OVER (PARTITION BY order_id ORDER BY changed_at, history_id) AS previous_status
FROM orders_history ORDER BY order_id, changed_at;
