#!/bin/bash

pandock () {
	command -v docker
	docker run --rm --volume "$(pwd):/data" --user $(id -u):$(id -g) pandoc/latex:2.19.2-alpine $@
}

if [[ -z "$1" || -z "$2" ]];
then
	echo "ERROR: $0 path-to-input-html-file path-to-output-epub-file";
	exit 1
fi

set -xe

input="$1"
output="$2"
script="$(pwd)/main.js"

temp_dir=$(mktemp -d)

input_html="input.html"
cp "$input" "$temp_dir/$input_html"

output_html="reader-view.html"
output_html_abs="reader-view.html"
output_metadata="metadata.xml"

# Node will read and write from these absolute or relative paths
node $script "$temp_dir/$input_html" "$temp_dir/$output_html" "$temp_dir/$output_metadata"

pushd $temp_dir

# Pandock might be using Docker, which uses --volume to mount `pwd` as /data. So, we should change
# directory to the appropriate place before executing the conversino scripts.

output_xhtml="reader-view.xhtml"

# output_epub is absolute because we will copy it later
output_epub="output.epub"

# HTML => XHTML
# HTML from websites might have things like <img src="..."> (unclosed img tags).
# These can not be parsed by Pandoc and Pandoc will stop parsing at the first mismatched close tag.
# To avoid this case, we will convert from HTML => XHTML. XHTML is valid XML and has stricter
# requirements, which match the input requirements for Pandoc.
pandock --output "$output_xhtml" "$output_html" && \
    # HTML => EPUB
    # The Epub metadata (title, author) is provided as an XML file.
    pandock --output "$output_epub" --epub-metadata "$output_metadata" "$output_xhtml" && \
        echo "DEBUG: Temporary ouptut written to $(pwd)/$output_epub"

popd

mv "$temp_dir/$output_epub" "$output"

echo "INFO: Final output written to $output"
