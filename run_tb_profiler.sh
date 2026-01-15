#!/bin/bash

# 1. Check if an argument was provided
# $# counts the number of arguments. If it's 0, the script stops and explains why.
if [ $# -eq 0 ]; then
    echo "Usage: $0 <accession_number>"
    exit 1
fi

# 2. Assign the first argument ($1) to a descriptive variable
ACCESSION=$1

# 3. Use the variable in your pipeline
echo "Starting pipeline for Accession: $ACCESSION"

# Example: Using it to create a directory or download a file
# mkdir -p "./data/$ACCESSION"
# fastq-dump "$ACCESSION" --outdir "./data/$ACCESSION"

prefetch "$ACCESSION"

fasterq-dump --split-files "$ACCESSION"

# Run the TB-Profiler pipeline
docker run --rm \
    -v "$(pwd):/data" \
    -w /data \
    quay.io/biocontainers/tb-profiler:6.6.6--pyhdfd78af_0 \
    tb-profiler profile \
    -1 "${ACCESSION}_1.fastq" \
    -2 "${ACCESSION}_2.fastq" \
    -p "$ACCESSION" -t 2

# Collate the results
docker run --rm \
    -v $(pwd):/data \
    -w /data \
    quay.io/biocontainers/tb-profiler:6.6.6--pyhdfd78af_0 \
    tb-profiler collate

echo "Process complete for $ACCESSION."
