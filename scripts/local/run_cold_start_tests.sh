#!/bin/bash

PROJECT_ROOT="$(pwd)"
RESULTS_DIR="$PROJECT_ROOT/results/cold_start"

mkdir -p "$RESULTS_DIR"

run_cold_start_benchmark() {
    local framework=$1
    local npm_create_command=$2
    local npm_build_command=$3
    local bun_create_command=$4
    local bun_build_command=$5
    local deno_create_command=$6
    local deno_build_command=$7
    
    echo "Running cold start benchmark for $framework"
    
    hyperfine --warmup 3 \
              --min-runs 10 \
              --export-markdown "$RESULTS_DIR/${framework}_results.md" \
              --export-json "$RESULTS_DIR/${framework}_results.json" \
              --prepare "rm -rf ./test-project" \
              "mkdir test-project && cd test-project && $npm_create_command && cd * && $npm_build_command" \
              "mkdir test-project && cd test-project && $bun_create_command && cd * && $bun_build_command" \
              "mkdir test-project && cd test-project && $deno_create_command && cd * && $deno_build_command"
    
    rm -rf ./test-project
}

# Next.js benchmark
run_cold_start_benchmark "nextjs" \
    "npx create-next-app@latest ozzy --typescript --eslint --app --tailwind --no-src-dir --no-import-alias" \
    "npm run build" \
    "bun create next-app ozzy --ts --eslint --app --tailwind --no-src-dir --no-import-alias" \
    "bun run build" \
    "deno create next-app ozzy --ts --eslint --app --tailwind --no-src-dir --no-import-alias" \
    "deno run build"

# Vite benchmark
run_cold_start_benchmark "vite" \
    "npm create vite@latest my-vue-app -- --template react" \
    "npm install && npm run build" \
    "bun create vite my-vue-app --template react" \
    "bun install && bun run build" \
    "deno create vite my-vue-app --template react" \
    "deno install && deno run build"

echo "Cold start benchmarks completed. Results are saved in $RESULTS_DIR"
