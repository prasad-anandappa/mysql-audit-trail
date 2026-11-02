-- mysql-audit-trail : schema.sql
CREATE DATABASE IF NOT EXISTS audit_trail_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE audit_trail_demo;
CREATE TABLE customers (
  customer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  status ENUM('ACTIVE','SUSPENDED','CLOSED') NOT NULL DEFAULT 'ACTIVE',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customers_email (email)
) ENGINE=InnoDB;
CREATE TABLE orders (
  order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id INT UNSIGNED NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  status ENUM('PENDING','PAID','SHIPPED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
) ENGINE=InnoDB;
CREATE TABLE customers_history (
  history_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id INT UNSIGNED NOT NULL,
  full_name VARCHAR(120) NULL,
  email VARCHAR(160) NULL,
  status VARCHAR(20) NULL,
  change_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(80) NOT NULL DEFAULT 'system',
  row_snapshot JSON NULL,
  PRIMARY KEY (history_id),
  KEY idx_cust_hist_id_time (customer_id, changed_at)
) ENGINE=InnoDB;
CREATE TABLE orders_history (
  history_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  customer_id INT UNSIGNED NULL,
  total_amount DECIMAL(12,2) NULL,
  status VARCHAR(20) NULL,
  change_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(80) NOT NULL DEFAULT 'system',
  row_snapshot JSON NULL,
  PRIMARY KEY (history_id),
  KEY idx_order_hist_id_time (order_id, changed_at)
) ENGINE=InnoDB;
CREATE TABLE audit_log (
  audit_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  table_name VARCHAR(64) NOT NULL,
  row_pk VARCHAR(64) NOT NULL,
  change_type VARCHAR(20) NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  summary VARCHAR(500) NULL,
  PRIMARY KEY (audit_id),
  KEY idx_audit_table_time (table_name, changed_at)
) ENGINE=InnoDB;
