-- procedures.sql : point-in-time reconstruction
USE audit_trail_demo;
DELIMITER $$
CREATE PROCEDURE reconstruct_customer_at(IN p_customer_id INT UNSIGNED, IN p_at TIMESTAMP)
BEGIN
  SELECT customer_id, full_name, email, status, change_type, changed_at
  FROM customers_history
  WHERE customer_id = p_customer_id AND changed_at <= p_at
  ORDER BY changed_at DESC, history_id DESC
  LIMIT 1;
END$$
CREATE PROCEDURE reconstruct_order_at(IN p_order_id BIGINT UNSIGNED, IN p_at TIMESTAMP)
BEGIN
  SELECT order_id, customer_id, total_amount, status, change_type, changed_at
  FROM orders_history
  WHERE order_id = p_order_id AND changed_at <= p_at
  ORDER BY changed_at DESC, history_id DESC
  LIMIT 1;
END$$
DELIMITER ;
