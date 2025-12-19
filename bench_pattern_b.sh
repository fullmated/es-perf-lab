#!/bin/bash
# パターン B: Painless あり（固定値）

echo "=== Pattern B: Painless あり（固定値） ==="
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo "Cache cleared."
echo ""

QUERY='{"query":{"bool":{"filter":{"script":{"script":{"source":"doc['"'"'price'"'"'].value * 0.9 >= 1000 && doc['"'"'price'"'"'].value * 0.9 <= 3000","lang":"painless"}}}}}}'

for i in {1..10}; do
  RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
    -H "Content-Type: application/json" \
    -d "$QUERY")
  TOOK=$(echo "$RESULT" | sed -n 's/.*"took":\([0-9]*\).*/\1/p')
  echo "${i}回目: ${TOOK}ms"
done