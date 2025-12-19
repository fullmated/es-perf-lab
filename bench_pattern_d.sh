#!/bin/bash

echo "=== Pattern D: 値埋め込み（毎回変更） ==="
echo ""

# キャッシュクリア
echo "Clearing cache..."
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo ""

for i in {1..10}; do
  MIN=$((1000 + i * 100))
  MAX=$((3000 + i * 100))

  QUERY="{\"query\":{\"bool\":{\"filter\":{\"script\":{\"script\":{\"source\":\"doc['price'].value >= $MIN && doc['price'].value <= $MAX\",\"lang\":\"painless\"}}}}}}"

  RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
    -H "Content-Type: application/json" \
    -d "$QUERY")
  TOOK=$(echo "$RESULT" | grep -o '"took":[0-9]*' | cut -d':' -f2)
  echo "  ${i}回目 (>=$MIN, <=$MAX): ${TOOK}ms"
done
