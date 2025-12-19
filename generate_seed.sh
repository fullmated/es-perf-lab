#!/bin/bash

# 10万件のデータを生成
COUNT=${1:-100000}
OUTPUT="seed_large.ndjson"

echo "Generating $COUNT documents..."

categories=("electronics" "furniture" "clothing" "food" "books")

# ファイルを空にする
: > "$OUTPUT"

for i in $(seq 1 $COUNT); do
  price=$((RANDOM % 10000 + 100))
  discount_rate=$(awk "BEGIN {printf \"%.2f\", ($RANDOM % 50) / 100}")
  stock=$((RANDOM % 500))
  category=${categories[$((RANDOM % 5))]}

  echo '{"index": {"_index": "products"}}' >> "$OUTPUT"
  echo "{\"name\": \"商品$i\", \"price\": $price, \"discount_rate\": $discount_rate, \"stock\": $stock, \"category\": \"$category\"}" >> "$OUTPUT"

  if [ $((i % 10000)) -eq 0 ]; then
    echo "  Generated $i documents..."
  fi
done

echo "Done. Output: $OUTPUT"
echo ""
echo "To import:"
echo "  curl -X POST 'http://localhost:29200/_bulk' -H 'Content-Type: application/x-ndjson' --data-binary @$OUTPUT"