#!/bin/bash

BASE_URL="http://localhost"
FAILED=0

check() {
    local name="$1"
    local url="$2"

    if curl -fsS --max-time 5 "$url" > /dev/null;then
        echo "$name OK"
    else
        echo "$name FAILED"
        FAILED=1
    fi
}

check "backend" "$BASE_URL/health"
check "database" "$BASE_URL/db-health"

exit $FAILED
