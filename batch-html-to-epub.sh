#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo "ERROR: Must provide an output directory and at least one HTML file."
	echo "Usage: $0 output-directory file1.html file2.html file3.html ..."
	exit 3
fi

output_dir="$1"
shift

if [[ ! -d "$output_dir" ]]; then
	echo "ERROR: Output directory does not exist: $output_dir"
	exit 5
fi

set -xe

for p in "$@"; do
	if [[ ! -f "$p" ]]; then
		echo "ERROR: File not found: $p"
		exit 4
	fi

	echo "Doing: $p"
	final_name=$(basename "$p" .html).epub
	output_epub="$output_dir/$final_name"
	bash html-to-epub.sh "$p" "$output_epub"
	mv "$p" "$p.done"
done
