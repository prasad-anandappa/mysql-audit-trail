-- views.sql
USE audit_trail_demo;
CREATE OR REPLACE VIEW v_latest_customer_history AS
SELECT h.* FROM customers_history h
JOIN (SELECT customer_id, MAX(history_id) AS max_id FROM customers_history GROUP BY customer_id) latest
  ON latest.max_id = h.history_id;
CREATE OR REPLACE VIEW v_change_counts_by_table AS
SELECT 'customers' AS table_name, change_type, COUNT(*) AS changes FROM customers_history GROUP BY change_type
UNION ALL
SELECT 'orders' AS table_name, change_type, COUNT(*) AS changes FROM orders_history GROUP BY change_type;
