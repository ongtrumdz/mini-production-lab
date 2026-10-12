##Mini Production Lab

## Overview
Mini Production Lab là một project thực hành học hỏi triển khai một web
application theo mô hình tách web và database mục tiêu để luyện tập các
kiến thức cơ bản nền tảng

## Architecture
                    Client / WSL
                         |
                         | HTTP :80
                         v
              +----------------------+
              |     app-server       |
              |    192.168.5.10      |
              |                      |
              |      Nginx :80       |
              |          |           |
              |          v           |
              | Gunicorn 127.0.0.1   |
              |        :8000         |
              |          |           |
              |          v           |
              |        Flask         |
              +----------+-----------+
                         |
                         | TCP :5432
                         v
              +----------------------+
              |      db-server       |
              |    192.168.5.20      |
              |                      |
              |     PostgreSQL       |
              |                      |
              | systemd backup timer |
              |          |           |
              |          v           |
              |       pg_dump        |
              |          |           |
              |          v           |
              | /var/backups/...     |
              +----------------------+

## Technology Stack
Thành phần	Công nghệ	Vai trò
OS	        Ubuntu Server	Server environment
Reverse Proxy	Nginx	        Nhận HTTP request
App Server	Gunicorn	Chạy Flask production-style
Application	Flask	        API logic
Database	PostgreSQL	Persistent data
Process Manager	systemd	        Quản lý service
Firewall	UFW	        Hạn chế network access
Automation	Bash	        Deploy, healthcheck, backup
Version Control	Git/GitHub	Quản lý source/config
Virtualization	VMware	        Tạo app/db serve

## Request flow
Client
 ↓ HTTP :80
app-server
 ↓
UFW
 ↓
Nginx
 ↓ reverse proxy
Gunicorn :8000
 ↓
Flask
 ↓ psycopg
TCP :5432
 ↓
db-server UFW
 ↓
PostgreSQL
 ↓
response quay ngược lại

## Repository Strucsture
mini-production-lab/
│
├── backend/
│   ├── app.py
│   └── requirements.txt
│
├── config/
│   └── backend.env.example
│
├── ops/
│   ├── nginx/
│   │   └── mini-production.conf
│   │
│   └── systemd/
│       ├── mini-production.service
│       ├── mini-production-backup.service
│       └── mini-production-backup.timer
│
├── scripts/
│   ├── healthcheck.sh
│   ├── backup-db.sh
│   └── deploy.sh
│
├── .gitignore
└── README.md

## Deployment flow
Developer / WSL
      ↓
edit source
      ↓
git commit
      ↓
git push
      ↓
GitHub
      ↓
app-server
      ↓
deploy.sh

## Security Model
Client
 │
 ├── :80  → allowed
 ├── :22  → SSH allowed
 └── :8000 → blocked/not exposed
Nginx      0.0.0.0:80
Gunicorn   127.0.0.1:8000
PostgreSQL:
192.168.5.20:5432

UFW:
chỉ cho 192.168.5.10 → 5432

pg_hba.conf:
chỉ miniuser từ 192.168.5.10

## Backup / Recovery

systemd timer
    ↓
backup service
    ↓
backup-db.sh
    ↓
pg_dump -Fc
    ↓
/var/backups/mini-production

## Failure Drills

Failure	                        Triệu chứng	             Cách xác định
Gunicorn chết	                Nginx 502	             systemctl, journalctl
DB_HOST sai	                /health OK, /db-health fail  ENV + app log
UFW DB chặn	                DB timeout	             network/firewall
PostgreSQL không listen	        connection refused	     ss, postgresql.conf
pg_hba.conf sai	                PostgreSQL reject	     DB auth config
Nginx config lỗi	        nginx -t fail	             deploy bị dừng
Git working tree dirty	        deploy bị dừng	             git status
Backup service sai ExecStart	203/EXEC	             systemd status/log







































































