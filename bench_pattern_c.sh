#!/bin/bash
# パターン C: Painless + params（値は params 経由で渡す）

echo "=== Pattern C: Painless + params ==="
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo "Cache cleared."
echo ""

# スクリプト本体は同じで、params の値だけ変える
for i in {1..10}; do
  MIN=$((1000 + i * 100))
  MAX=$((3000 + i * 100))

  QUERY='{"query":{"bool":{"filter":{"script":{"script":{"source":"doc['"'"'price'"'"'].value * (1 - doc['"'"'discount_rate'"'"'].value) >= params.min_price && doc['"'"'price'"'"'].value * (1 - doc['"'"'discount_rate'"'"'].value) <= params.max_price","lang":"painless","params":{"min_price":'"$MIN"',"max_price":'"$MAX"'}}}}}}}'

  RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
    -H "Content-Type: application/json" \
    -d "$QUERY")
  TOOK=$(echo "$RESULT" | sed -n 's/.*"took":\([0-9]*\).*/\1/p')
  echo "${i}回目 (min=$MIN, max=$MAX): ${TOOK}ms"
done