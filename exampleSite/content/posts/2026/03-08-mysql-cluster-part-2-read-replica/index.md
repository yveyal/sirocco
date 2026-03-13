---
title: "MySQL Cluster Series Part 2: Add a Read Replica"
date: 2026-03-08
tags:
  - "mysql"
  - "replication"
  - "database"
series:
  - "mysql-cluster-from-zero"
summary: "Provision a second MySQL node and configure asynchronous replication for read scaling."
---

This article adds a replica node and verifies replication lag and read-only behavior.

## 1) Configure replica node

Install MySQL and edit `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```ini
[mysqld]
bind-address = 0.0.0.0
server-id = 2
read_only = ON
super_read_only = ON
relay_log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log
gtid_mode = ON
enforce_gtid_consistency = ON
```

```bash
sudo systemctl restart mysql
```

## 2) On primary, capture replication source information

If using GTID auto-positioning, user credentials are enough:

```sql
SHOW MASTER STATUS;
SHOW VARIABLES LIKE 'gtid_mode';
```

## 3) Configure replication on replica

```sql
STOP REPLICA;

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST = '10.0.0.10',
  SOURCE_PORT = 3306,
  SOURCE_USER = 'repl',
  SOURCE_PASSWORD = 'repl_password_change_me',
  SOURCE_AUTO_POSITION = 1,
  GET_SOURCE_PUBLIC_KEY = 1;

START REPLICA;
```

## 4) Verify replica health

```sql
SHOW REPLICA STATUS\G
```

Key checks:

- `Replica_IO_Running: Yes`
- `Replica_SQL_Running: Yes`
- `Seconds_Behind_Source` is low/stable

## 5) Validate read flow

On primary:

```sql
INSERT INTO appdb.tasks (title, status)
VALUES ('replication check item', 'new');
```

On replica:

```sql
SELECT id, title, status, created_at
FROM appdb.tasks
ORDER BY id DESC
LIMIT 5;
```

You now have one writer (primary) and one reader (replica).
