#!/bin/bash

path=$1
if [[ -z "$path" ]];
then
	echo "ERROR: Path to folder with .zip.html files should be the first argument."
	exit 3
fi

set -xe

mkdir -p ~/sandbox/epub-to-import

fdfind '.zip.html$' --full-path $path | \
	while read p;
	do
		echo "Doing: $p";
		final_name=$(basename "$p" | sed -e 's/ /-/g' -e 's/.zip.html//g' | awk '{ print tolower($0) }' | sed -e 's/[^a-z0-9_\-]//g' -e 's/_/-/g').epub;
		rm -rf ~/sandbox/page; unzip -d ~/sandbox/page "$p"; bash html-to-epub.sh main.js ~/sandbox/page/index.html;
		mv ~/sandbox/page/index.epub ~/sandbox/epub-to-import/$final_name;
		mv "$p" "$p.done"
	done;
