#!/usr/bin/env sh
set -ue

LINKING_MODE="$1"
OS="$2"
FLAGS=
CCLIB=

case "$LINKING_MODE" in
    static)
        CCLIB="-static -no-pie";;
    *)
        ;; # Assume dynamic, no extra flags needed
esac

echo '('
for f in $FLAGS; do echo "  $f"; done
for f in $CCLIB; do echo "  -cclib $f"; done
echo ')'
