#!/bin/bash
SAB_URL="http://localhost:8080"
curl -sf "$SAB_URL/api?mode=version" >/dev/null || exit 1
exit 0