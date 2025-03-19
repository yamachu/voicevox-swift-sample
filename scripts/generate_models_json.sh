#!/bin/bash -e

if [ $# -eq 0 ]; then
    echo "No model directory provided. Using default 'models'."
fi

model_dir="$1"

json_output="{ \"models\": ["

# find all .vvm files in the model directory
while read -r file; do
    METAS=`unzip -p "$file" metas.json`
    MODEL_ID=`unzip -p "$file" manifest.json | jq -r '. | .id'`

    # extract file name
    filename=$(basename "$file")

    json_output+="{\"vvm\": \"$filename\", \"id\": \"$MODEL_ID\", \"metas\": $METAS},"
done < <(find "$model_dir" -type f -name "*.vvm" | sort -V)

# remove last comma
json_output=${json_output%,}

json_output+="]}"
echo $json_output
