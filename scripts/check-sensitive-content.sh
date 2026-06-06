#!/usr/bin/env bash
set -euo pipefail

tracked_files=()
while IFS= read -r -d '' file; do
  if [[ -f "$file" && "$file" != ".gitleaks.toml" && "$file" != "scripts/check-sensitive-content.sh" ]]; then
    tracked_files+=("$file")
  fi
done < <(git ls-files -z)

if ((${#tracked_files[@]} == 0)); then
  exit 0
fi

pattern='MEDIA_SHAPER_API_KEYS|X-API-Key|Authorization:[[:space:]]*Bearer|service-client-key|https?://(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})(:[0-9]+)?'

if rg --line-number --ignore-case --regexp "$pattern" -- "${tracked_files[@]}"; then
  echo "Sensitive API configuration or a private endpoint was found in tracked files." >&2
  exit 1
fi
