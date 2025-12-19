#!/bin/bash
# パターン A: Painless なし（通常の range クエリ）

echo "=== Pattern A: Painless なし（range クエリ） ==="
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo "Cache cleared."
echo ""

for i in {1..10}; do
  MIN=$((1000 + i * 100))
  MAX=$((3000 + i * 100))

  QUERY='{"query":{"range":{"price":{"gte":'"$MIN"',"lte":'"$MAX"'}}}}'

  RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
    -H "Content-Type: application/json" \
    -d "$QUERY")
  TOOK=$(echo "$RESULT" | sed -n 's/.*"took":\([0-9]*\).*/\1/p')
  echo "${i}回目 (min=$MIN, max=$MAX): ${TOOK}ms"
done