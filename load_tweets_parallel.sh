#!/bin/sh

files=$(find data/*)

echo '================================================================================'
echo 'load pg_denormalized'
echo '================================================================================'
parallel 'unzip -p "{}" \
  | python3 -c '"'"'import sys,csv; w=csv.writer(sys.stdout); [w.writerow([line.rstrip("\n").replace("\x00","").replace("\\u0000","")]) for line in sys.stdin]'"'"' \
  | psql -v ON_ERROR_STOP=1 postgresql://postgres:pass@localhost:15434/postgres \
      -c "\copy tweets_jsonb(data) FROM STDIN WITH (FORMAT csv)"' ::: $files

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
parallel 'python3 ./load_tweets.py \
  --db postgresql://postgres:pass@localhost:15440/postgres \
  --inputs "{}"' ::: $files

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
parallel 'python3 ./load_tweets_batch.py \
  --db postgresql://postgres:pass@localhost:15441/postgres \
  --inputs "{}"' ::: $files
