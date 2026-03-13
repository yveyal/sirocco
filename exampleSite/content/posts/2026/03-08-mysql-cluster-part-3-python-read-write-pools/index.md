---
title: "MySQL Cluster Series Part 3: Python App with Read/Write Thread Pools"
date: 2026-03-08
tags:
  - "mysql"
  - "python"
  - "threading"
series:
  - "mysql-cluster-from-zero"
summary: "Build a Python app that routes writes to primary and reads to replica using separate thread pools."
---

This article demonstrates a practical read/write split in Python with separate worker pools.

## 1) Install dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install mysql-connector-python
```

## 2) Sample app

```python
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
import mysql.connector
from mysql.connector.pooling import MySQLConnectionPool

WRITE_POOL = MySQLConnectionPool(
    pool_name="write_pool",
    pool_size=5,
    host=os.getenv("MYSQL_PRIMARY_HOST", "10.0.0.10"),
    port=3306,
    user="app_user",
    password="app_password_change_me",
    database="appdb",
)

READ_POOL = MySQLConnectionPool(
    pool_name="read_pool",
    pool_size=10,
    host=os.getenv("MYSQL_REPLICA_HOST", "10.0.0.11"),
    port=3306,
    user="app_user",
    password="app_password_change_me",
    database="appdb",
)


def create_task(title: str) -> int:
    conn = WRITE_POOL.get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO tasks (title, status) VALUES (%s, 'new')",
                (title,),
            )
            conn.commit()
            return cur.lastrowid
    finally:
        conn.close()


def list_recent_tasks(limit: int = 10):
    conn = READ_POOL.get_connection()
    try:
        with conn.cursor(dictionary=True) as cur:
            cur.execute(
                "SELECT id, title, status, created_at FROM tasks ORDER BY id DESC LIMIT %s",
                (limit,),
            )
            return cur.fetchall()
    finally:
        conn.close()


def run_demo():
    write_executor = ThreadPoolExecutor(max_workers=4, thread_name_prefix="write")
    read_executor = ThreadPoolExecutor(max_workers=8, thread_name_prefix="read")

    try:
        write_futures = [
            write_executor.submit(create_task, f"task-{i}")
            for i in range(1, 21)
        ]
        for f in as_completed(write_futures):
            task_id = f.result()
            print(f"inserted task id={task_id}")

        read_futures = [
            read_executor.submit(list_recent_tasks, 5)
            for _ in range(6)
        ]
        for f in as_completed(read_futures):
            rows = f.result()
            print("read batch:", [r["id"] for r in rows])
    finally:
        write_executor.shutdown(wait=True)
        read_executor.shutdown(wait=True)


if __name__ == "__main__":
    run_demo()
```

## 3) Run

```bash
export MYSQL_PRIMARY_HOST=10.0.0.10
export MYSQL_REPLICA_HOST=10.0.0.11
python app.py
```

## 4) Operational notes

- Keep writes on primary only.
- Reads can tolerate mild replica lag for most dashboards and listings.
- For strongly consistent reads after writes, route that query to primary.
