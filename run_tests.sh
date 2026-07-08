#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$ROOT/prac"
SRC="$ROOT/prac.cpp"
TEST_DIR="$ROOT/tests"

echo "Compiling prac.cpp..."
g++ -std=c++17 -O2 -o "$BIN" "$SRC"

passed=0
failed=0

for input in "$TEST_DIR"/*.in; do
    name="$(basename "$input" .in)"
    expected="$TEST_DIR/${name}.out"

    if [[ ! -f "$expected" ]]; then
        echo "SKIP $name (missing ${name}.out)"
        continue
    fi

    actual="$(mktemp)"
    "$BIN" < "$input" > "$actual" || {
        echo "FAIL $name (program crashed)"
        rm -f "$actual"
        ((failed++)) || true
        continue
    }

    if diff -u "$expected" "$actual" > /dev/null; then
        echo "PASS $name"
        ((passed++)) || true
    else
        echo "FAIL $name"
        echo "  expected: $(cat "$expected" | od -An -tx1)"
        echo "  got:      $(cat "$actual" | od -An -tx1)"
        ((failed++)) || true
    fi

    rm -f "$actual"
done

echo
echo "Results: $passed passed, $failed failed"
[[ "$failed" -eq 0 ]]
