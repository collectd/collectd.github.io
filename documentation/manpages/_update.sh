#!/bin/bash

for f in ~/collectd/src/*.pod
do
	outfile="$(basename "${f/pod/md}")"
	# Escape characters used by the templating engine, '{', '}', and '%'.
	echo -n "Generating ${outfile} ... "
	pod2markdown --utf8 --html-encode-chars='{%}' "${f}" >"${outfile}"

	# Prevent '{%' and '{{' from appearing, e.g. in code blocks
	sed -i -e 's/{%/{ %/g' -e 's/{{/{ {/g' "${outfile}"

	echo "done"
done
