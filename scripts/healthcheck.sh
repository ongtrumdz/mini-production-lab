#!/bin/bash
set -uo pipefail

BASE_URL="http://localhost"
FAILED=0
TIMEOUT=5

checkservice() {
    local name="$1"
    if systemctl is-active --quiet "$name" ;then
        echo "$name ok"
    else
        echo "$name dead"
        FAILED=1
    fi
}

check() {
    local name="$1"
    local url="$2"

    if curl -fsS --max-time "$TIMEOUT" "$url" > /dev/null;then
        echo "$name OK"
    else
        echo "$name FAILED"
        FAILED=1
    fi
}
for service_name in mini-production nginx; do
    checkservice "$service_name"
done

check "backend" "$BASE_URL/health"
check "database" "$BASE_URL/db-health"

if [ "$FAILED" -eq 0 ]; then
    echo "SYSTEM HEALTHY"
else
    echo "SYSTEM UNHEALTHY"
fi

exit "$FAILED"


exit $FAILED
