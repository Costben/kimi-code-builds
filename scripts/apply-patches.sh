#!/usr/bin/env bash
# Apply every patch in patches/ (sorted by name) to an upstream checkout.
#
# Usage: scripts/apply-patches.sh <upstream-dir>
#
# Each patch is checked before anything is written, so a patch that no longer
# applies fails the run with the tree untouched. That failure is the signal to
# refresh the patch against the new upstream tag.
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:?usage: apply-patches.sh <upstream-dir>}"

shopt -s nullglob
patches=("$here"/patches/*.patch)
if [ "${#patches[@]}" -eq 0 ]; then
  echo "No patches found in $here/patches" >&2
  exit 1
fi

for patch in "${patches[@]}"; do
  name="$(basename "$patch")"
  if ! git -C "$target" apply --check --whitespace=nowarn "$patch"; then
    echo "::error::$name does not apply to this upstream tag" >&2
    exit 1
  fi
done

for patch in "${patches[@]}"; do
  git -C "$target" apply --whitespace=nowarn "$patch"
  echo "applied $(basename "$patch")"
done
