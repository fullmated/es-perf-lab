#!/bin/bash
# パターン E: 異なるスクリプトを交互に実行（B→C→B→C→B→C）

echo "=== Pattern E: 交互実行 (B→C→B→C→B→C) ==="
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo "Cache cleared."
echo ""

QUERY_B='{"query":{"bool":{"filter":{"script":{"script":{"source":"doc['"'"'price'"'"'].value * 0.9 >= 1000 && doc['"'"'price'"'"'].value * 0.9 <= 3000","lang":"painless"}}}}}}'
QUERY_C='{"query":{"bool":{"filter":{"script":{"script":{"source":"doc['"'"'price'"'"'].value * (1 - doc['"'"'discount_rate'"'"'].value) >= params.min_price && doc['"'"'price'"'"'].value * (1 - doc['"'"'discount_rate'"'"'].value) <= params.max_price","lang":"painless","params":{"min_price":1000,"max_price":3000}}}}}}}'

run_query() {
  local query="$1"
  RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
    -H "Content-Type: application/json" \
    -d "$query")
  echo "$RESULT" | sed -n 's/.*"took":\([0-9]*\).*/\1/p'
}

for round in 1 2 3; do
  echo "${round}周目:"
  TOOK_B=$(run_query "$QUERY_B")
  echo "  B: ${TOOK_B}ms"
  TOOK_C=$(run_query "$QUERY_C")
  echo "  C: ${TOOK_C}ms"
done