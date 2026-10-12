#!/bin/bash
set -eou pipefail

PROJECT_DIR="$HOME/projects/mini-production-lab"
cd "$PROJECT_DIR"
echo "=== MINI PRODUCTION DEPLOY==="

if  [ ! -e ".git" ] || [ ! -f "backend/app.py" ];then
    echo "ERROR: not a git repository or not such find file project"
    exit 1
else
    echo "[1/7] Project directory OK"
fi

if [ -n "$(git status --porcelain)" ];then
   echo "ERROR: working tree is not clean \ 
         Commit/stash/restore local changes before deploy."
   exit 1
else
   echo "[2/7] working tree is clean"
fi

git fetch origin
git pull --ff-only origin main
   echo "[3/7] repo ok"

if "$PROJECT_DIR/.venv/bin/pip" install \ -r "$PROJECT_DIR/backend/requirements.txt" ;then
   echo "[4/7] phase OK , environment python Ok"
else 
   echo "ERROR: Lack lib"
   exit 1
fi

SOURCE_FILE="ops/systemd/mini-production.service"
RUNTIME_FILE="/etc/systemd/system/mini-production.service"
SOURCE_NGINX="ops/nginx/mini-production.conf"
RUNTIME_NGINX="/etc/nginx/sites-available/mini-production"

sudo cp "$SOURCE_FILE" "$RUNTIME_FILE"
sudo cp "$SOURCE_NGINX" "$RUNTIME_NGINX"

echo "[5/7] source correct"

sudo systemctl daemon-reload

sudo nginx -t

sudo systemctl restart mini-production
sudo systemctl reload nginx
echo "[6/7] services updated"
if "$PROJECT_DIR/scripts/healthcheck.sh" ;then
    echo "=== DEPLOY SUCCESSFULL ==="
else
    echo "=== DEPLOY FAILED: HEALTCHCHECK FAILED ==="
    exit 1
fi

