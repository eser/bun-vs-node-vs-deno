#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
RESULTS_DIR="$PROJECT_ROOT/results/http"

CONNECTIONS=1250
REQUESTS=100000
TIMEOUT="30s"

BUN_IP="164.92.132.234"
NODE_IP="64.226.107.21"
PORT=6693

# Assume we have 1,000,000 users (must be same with database records)
MAX_USER_ID=1000000

mkdir -p "$RESULTS_DIR"

run_http_benchmark() {
    local test_name=$1
    local path=$2
    local query_params=$3
    local method=${4:-GET}
    local data=${5:-""}
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "$RESULTS_DIR/$test_name"
    
    local full_path="$path"
    if [[ -n "$query_params" ]]; then
        full_path="${path}?${query_params}"
    fi
    
    if [[ "$test_name" == *"user_populated"* ]]; then
        local bun_random_id=$((RANDOM % MAX_USER_ID + 1))
        local node_random_id=$((RANDOM % MAX_USER_ID + 1))
        bun_full_path="${full_path}${bun_random_id}"
        node_full_path="${full_path}${node_random_id}"
    else
        bun_full_path=$full_path
        node_full_path=$full_path
    fi
    
    local bombardier_args="-c $CONNECTIONS -n $REQUESTS -l -p r -o json -t $TIMEOUT"
    if [[ "$method" == "POST" ]]; then
        bombardier_args="$bombardier_args -m POST -f $data"
    fi
    
    if ! bombardier $bombardier_args "http://$BUN_IP:$PORT$bun_full_path" > "$RESULTS_DIR/$test_name/${test_name}_bun_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Bun test: $test_name" >&2
    fi
    
    if ! bombardier $bombardier_args "http://$NODE_IP:$PORT$node_full_path" > "$RESULTS_DIR/$test_name/${test_name}_node_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Node.js test: $test_name" >&2
    fi
    
    echo "HTTP benchmark for $test_name completed. Results saved in $RESULTS_DIR/$test_name/"
}

if ! command -v bombardier &> /dev/null; then
    echo "Bombardier is not installed or not in PATH. Please check your Dockerfile and environment." >&2
    exit 1
fi

TMP_JSON_FILE="$PROJECT_ROOT/tmp_movie_data.json"
echo '{
  "title": "A new movie",
  "genre": "action",
  "date": "1724579665"
}' > "$TMP_JSON_FILE"

run_http_benchmark "static_file_index" "/index.html"
run_http_benchmark "api_user_populated_random" "/api/user" "id="
run_http_benchmark "api_movies_query_date_genre" "/api/movies" "date=1640995200000&genre=sci-fi"
run_http_benchmark "api_movies_insert" "/api/movies" "" "POST" "$TMP_JSON_FILE"

rm "$TMP_JSON_FILE"

echo "All HTTP tests completed. Merging JSON results..."

node "$PROJECT_ROOT/utils/merge_http_results.js"

echo "All HTTP tests completed and results processed. Results are saved in their respective directories under $RESULTS_DIR."
