-- triggers.sql : capture every change into history + audit_log
USE audit_trail_demo;
DELIMITER $$
CREATE TRIGGER trg_customers_after_insert
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
  INSERT INTO customers_history (customer_id, full_name, email, status, change_type, row_snapshot)
  VALUES (NEW.customer_id, NEW.full_name, NEW.email, NEW.status, 'INSERT',
          JSON_OBJECT('customer_id', NEW.customer_id, 'full_name', NEW.full_name, 'email', NEW.email, 'status', NEW.status));
  INSERT INTO audit_log (table_name, row_pk, change_type, summary)
  VALUES ('customers', CAST(NEW.customer_id AS CHAR), 'INSERT', CONCAT('customer created: ', NEW.email));
END$$
CREATE TRIGGER trg_customers_after_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO customers_history (customer_id, full_name, email, status, change_type, row_snapshot)
  VALUES (NEW.customer_id, NEW.full_name, NEW.email, NEW.status, 'UPDATE',
          JSON_OBJECT('customer_id', NEW.customer_id, 'full_name', NEW.full_name, 'email', NEW.email, 'status', NEW.status, 'old_status', OLD.status));
  INSERT INTO audit_log (table_name, row_pk, change_type, summary)
  VALUES ('customers', CAST(NEW.customer_id AS CHAR), 'UPDATE', CONCAT('customer updated: ', OLD.status, ' -> ', NEW.status));
END$$
CREATE TRIGGER trg_customers_after_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO customers_history (customer_id, full_name, email, status, change_type, row_snapshot)
  VALUES (OLD.customer_id, OLD.full_name, OLD.email, OLD.status, 'DELETE',
          JSON_OBJECT('customer_id', OLD.customer_id, 'full_name', OLD.full_name, 'email', OLD.email, 'status', OLD.status));
  INSERT INTO audit_log (table_name, row_pk, change_type, summary)
  VALUES ('customers', CAST(OLD.customer_id AS CHAR), 'DELETE', CONCAT('customer deleted: ', OLD.email));
END$$
CREATE TRIGGER trg_orders_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO orders_history (order_id, customer_id, total_amount, status, change_type, row_snapshot)
  VALUES (NEW.order_id, NEW.customer_id, NEW.total_amount, NEW.status, 'INSERT',
          JSON_OBJECT('order_id', NEW.order_id, 'customer_id', NEW.customer_id, 'total_amount', NEW.total_amount, 'status', NEW.status));
END$$
CREATE TRIGGER trg_orders_after_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO orders_history (order_id, customer_id, total_amount, status, change_type, row_snapshot)
  VALUES (NEW.order_id, NEW.customer_id, NEW.total_amount, NEW.status, 'UPDATE',
          JSON_OBJECT('order_id', NEW.order_id, 'customer_id', NEW.customer_id, 'total_amount', NEW.total_amount, 'status', NEW.status, 'old_status', OLD.status));
END$$
CREATE TRIGGER trg_orders_after_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO orders_history (order_id, customer_id, total_amount, status, change_type, row_snapshot)
  VALUES (OLD.order_id, OLD.customer_id, OLD.total_amount, OLD.status, 'DELETE',
          JSON_OBJECT('order_id', OLD.order_id, 'customer_id', OLD.customer_id, 'total_amount', OLD.total_amount, 'status', OLD.status));
END$$
DELIMITER ;
