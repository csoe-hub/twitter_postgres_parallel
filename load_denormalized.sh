#!/bin/sh

file="$1"

unzip -p "$file" \
  | python3 -c 'import sys,csv; w=csv.writer(sys.stdout); [w.writerow([line.rstrip("\n").replace("\x00","").replace("\\u0000","")]) for line in sys.stdin]' \
  | psql -v ON_ERROR_STOP=1 postgresql://postgres:pass@localhost:21001/postgres \
      -c "\copy tweets_jsonb(data) FROM STDIN WITH (FORMAT csv)"
