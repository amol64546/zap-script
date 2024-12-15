#!/bin/bash

# Configuration
ZAP_API_KEY="gaianmobius"
ZAP_HOST="https://zap.aidtaas.com"
OPENAPI_URL="$SWAGGER_DOC_URL"

path=$(echo "$OPENAPI_URL" | awk -F"${domain}" '{print $2}')

FILTER_URI=$(echo "$path" | awk -F'/' '{print $2}')

# Import OpenAPI definition
import_response=$(curl -s -G "${ZAP_HOST}/JSON/openapi/action/importUrl/" \
  --data-urlencode "url=${OPENAPI_URL}" \
  --data-urlencode "apikey=${ZAP_API_KEY}")

# Generate JSON report
report=$(curl -s -G "${ZAP_HOST}/OTHER/core/other/jsonreport/" \
  --data-urlencode "apikey=${ZAP_API_KEY}")

# Modify field names in the report
formatted_report=$(echo "$report" | jq 'with_entries(if .key[0:1] == "@" then .key |= .[1:] else . end)')


# Function to add a random "id" field to JSON
add_id_to_json() {
  local input_json="$1"
  
  # Generate a random alphanumeric ID
  random_id=$(uuidgen | tr -d '-' | head -c 9)

  # Add the "id" field to the JSON using jq
  updated_json=$(echo "$input_json" | jq --arg id "$random_id" '. + {id: $id}')
  
  echo "$updated_json"
}

updated_json=$(add_id_to_json "$formatted_report")

# Filter the report to include only instances with specific URI
filtered_report=$(echo "$updated_json" | jq --arg filter_uri "$FILTER_URI" '
  .site |= map(
    .alerts |= map(
      .instances |= map(select(.uri | contains($filter_uri)))
    )
  )
')

echo "$filtered_report"
