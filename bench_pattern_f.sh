#!/bin/bash
# パターン F: 並列実行（異なるスクリプトを同時にコンパイル）

PARALLEL=${1:-10}

echo "=== Pattern F: 並列実行 (並列数: $PARALLEL) ==="
curl -s -X POST "http://localhost:29200/_cache/clear" > /dev/null
echo "Cache cleared."
echo ""

# 一時ファイルに結果を保存
TMPDIR=$(mktemp -d)

start_time=$(date +%s%3N)

for i in $(seq 1 $PARALLEL); do
  MIN=$((1000 + i * 100))
  MAX=$((3000 + i * 100))

  QUERY='{"query":{"bool":{"filter":{"script":{"script":{"source":"doc['"'"'price'"'"'].value >= '"$MIN"' && doc['"'"'price'"'"'].value <= '"$MAX"'","lang":"painless"}}}}}}'

  (
    RESULT=$(curl -s -X POST "http://localhost:29200/products/_search" \
      -H "Content-Type: application/json" \
      -d "$QUERY")
    TOOK=$(echo "$RESULT" | sed -n 's/.*"took":\([0-9]*\).*/\1/p')
    echo "$i $TOOK" > "$TMPDIR/result_$i.txt"
  ) &
done

wait

end_time=$(date +%s%3N)
total_time=$((end_time - start_time))

echo "各クエリの took:"
for i in $(seq 1 $PARALLEL); do
  if [ -f "$TMPDIR/result_$i.txt" ]; then
    read idx took < "$TMPDIR/result_$i.txt"
    echo "  クエリ${idx}: ${took}ms"
  fi
done

echo ""
echo "全体の実行時間: ${total_time}ms"

# 一時ファイル削除
rm -rf "$TMPDIR"