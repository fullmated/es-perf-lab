# es-lab

Elasticsearch Painless スクリプトのパフォーマンス検証用環境です

## セットアップ

### 1. Elasticsearch / Kibana の起動

```bash
docker compose up -d
```

起動確認:
```bash
curl http://localhost:29200/_cluster/health
```

### 2. テストデータの生成とインポート

```bash
# 10万件のデータを生成
./generate_seed.sh 100000

# Elasticsearch にインポート
curl -X POST 'http://localhost:29200/_bulk' \
  -H 'Content-Type: application/x-ndjson' \
  --data-binary @seed_large.ndjson
```

## ベンチマークの実行

各パターンのベンチマークスクリプト:

| スクリプト | 説明 |
|-----------|------|
| `bench_pattern_a.sh` | range クエリ（Painless なし） |
| `bench_pattern_b.sh` | Painless + 固定値 |
| `bench_pattern_c.sh` | Painless + params |
| `bench_pattern_d.sh` | 値埋め込み（毎回異なるスクリプト） |
| `bench_pattern_e.sh` | 交互実行（B→C→B→C→B→C） |
| `bench_pattern_f.sh` | 並列実行 |

実行例:
```bash
./bench_pattern_a.sh
./bench_pattern_b.sh
./bench_pattern_c.sh
./bench_pattern_d.sh
./bench_pattern_e.sh
./bench_pattern_f.sh 10  # 並列数を指定
```

## 停止

```bash
docker compose down
```

データを削除する場合:
```bash
docker compose down -v
```