#!/usr/bin/env bash
set -e

# @describe Perform a web search using Serper API to get up-to-date information or additional context.
# Use this when you need current information or feel a search could provide a better answer.

# @option --query! The query to search for.

# @env SERPER_API_KEY! The api key
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    result=$(curl -fsSL -X POST https://google.serper.dev/search \
        -H "content-type: application/json" \
        -H "X-API-KEY: $SERPER_API_KEY" \
        -d '
{
    "q": "'"$argc_query"'"
}')

    # Check if knowledgeGraph exists and is not empty
    kg=$(echo "$result" | jq '.knowledgeGraph // empty')

    if [[ -n "$kg" ]] && [[ "$kg" != "null" ]]; then
        # Return knowledgeGraph if available
        echo "$result" | jq '.knowledgeGraph' >> "$LLM_OUTPUT"
    else
        # Otherwise return answerBox or top 5 organic results
        answer=$(echo "$result" | jq '.answerBox // empty')
        if [[ -n "$answer" ]] && [[ "$answer" != "null" ]]; then
            echo "$result" | jq '.answerBox' >> "$LLM_OUTPUT"
        else
            echo "$result" | jq '.organic[:5]' >> "$LLM_OUTPUT"
        fi
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
