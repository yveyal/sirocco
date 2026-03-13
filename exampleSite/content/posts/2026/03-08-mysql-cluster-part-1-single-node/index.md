---
title: "MySQL Cluster Series Part 1: Single Node Setup"
date: 2026-03-08
tags:
  - "mysql"
  - "database"
  - "infrastructure"
series:
  - "mysql-cluster-from-zero"
summary: "Install and configure a single MySQL 8 node as the base for replication."
---

This first article establishes a clean single-node MySQL instance that we will later extend with replication.

## 1) Install MySQL 8

```bash
sudo apt update
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
mysql --version
```

## 2) Basic secure setup

```bash
sudo mysql_secure_installation
```

## 3) Configure server for replication readiness

Edit `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```ini
[mysqld]
bind-address = 0.0.0.0
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = ROW
gtid_mode = ON
enforce_gtid_consistency = ON
```

Restart MySQL:

```bash
sudo systemctl restart mysql
```

## 4) Create application and replication users

```sql
CREATE DATABASE appdb;

CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_password_change_me';
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'app_user'@'%';

CREATE USER 'repl'@'%' IDENTIFIED BY 'repl_password_change_me';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';

FLUSH PRIVILEGES;
```

## 5) Seed sample schema/data

```sql
USE appdb;

CREATE TABLE tasks (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  status ENUM('new','in_progress','done') NOT NULL DEFAULT 'new',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, status)
VALUES ('bootstrap mysql node', 'done');
```

## 6) Verify binary log and GTID

```sql
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'gtid_mode';
SHOW MASTER STATUS;
```

At this point, the primary node is ready for adding a replica.
