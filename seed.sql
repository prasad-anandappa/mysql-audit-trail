-- seed.sql
USE audit_trail_demo;
INSERT INTO customers (full_name, email, status) VALUES
  ('Jordan Ellis','jordan.ellis@example.com','ACTIVE'),
  ('Priya Nair','priya.nair@example.com','ACTIVE'),
  ('Sam Carter','sam.carter@example.com','ACTIVE');
INSERT INTO orders (customer_id, total_amount, status) VALUES
  (1,149.99,'PAID'),
  (1,59.50,'PENDING'),
  (2,320.00,'SHIPPED');
-- Example lifecycle changes that the triggers will capture when run live
UPDATE customers SET status = 'SUSPENDED' WHERE customer_id = 3;
UPDATE orders SET status = 'PAID' WHERE order_id = 2;
