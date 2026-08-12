#!/bin/sh
set -e
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname -- "$0")/.." && pwd)}"
make -C "$PROJECT_ROOT" docker/bake
