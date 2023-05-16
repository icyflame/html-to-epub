#!/bin/bash

pandock () {
	command -v docker
	docker run --rm --volume "$(pwd):/data" --user $(id -u):$(id -g) pandoc/latex:2.19.2-alpine $@
}

if [[ -z "$1" || -z "$2" ]];
then
	echo "ERROR: $0 path-to-script path-to-input-html-file";
	exit 1
fi

set -x

script=$1
input=$2

filename=$(basename $input)
dir=$(dirname $input)
filename_without_extension=$(echo $filename | awk -F\. '{ print $1 }')

output_html="${filename_without_extension}-reader-view.html"
output_xhtml="${filename_without_extension}-reader-view.xhtml"
output_metadata="${filename_without_extension}-metadata.xml"
output_epub="${filename_without_extension}.epub"

# Node will read and write form these absolute or relative paths
node $script "$input" "$dir/$output_html" "$dir/$output_metadata"

# Pandock might be using Docker, which uses --volume to mount `pwd` as /data. So, we should change
# directory to the appropriate place before executing the conversino scripts.
cd $dir && \
	pandock --output $output_xhtml $output_html && \
	pandock --output $output_epub --epub-metadata "$output_metadata" "$output_xhtml" && \
	echo "Ouptut file written to $(pwd)/$output_epub"
