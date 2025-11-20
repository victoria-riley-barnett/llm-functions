#!/usr/bin/env bash
set -e

# @describe Perform web search using public SearXNG instances
# @option --query! The query to search for.
# @option --instance? The SearXNG instance URL (optional, will auto-select)
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local query="$argc_query"
    local instance="${argc_instance:-}"

    # If no instance specified, use a reliable one or fetch from searx.space
    if [[ -z "$instance" ]]; then
        # You could fetch from searx.space API or use a known good instance
        instance="https://search.im-in.space/"
        # Alternative good instances:
        # - https://search.us.projectsegfau.lt
        # - https://searx.work
        # - https://searx.nixnet.services
    fi

    # URL encode the query
    encoded_query=$(echo "$query" | jq -sRr @uri)

    # Make request to SearXNG
    response=$(curl -s -G \
        --data-urlencode "q=$query" \
        --data-urlencode "format=json" \
        "${instance}/search")

    # Parse and format results
    if echo "$response" | jq -e '.results' >/dev/null 2>&1; then
        echo "$response" | jq -r '
            "Search Results from SearXNG:",
            (.results[]? | "• \(.title)\n  \(.url)\n  \(.content)\n")
        ' >> "$LLM_OUTPUT"
    else
        echo "No results found or instance unavailable" >> "$LLM_OUTPUT"
        # Could implement fallback to another instance here
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
