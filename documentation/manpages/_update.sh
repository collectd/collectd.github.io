#!/bin/bash

set -e

while read NAME SECT
do
	outfile="${NAME}.md"
	echo -n "Generating ${outfile} ... "
	(
		cat <<EOF
---
title: ${NAME}(${SECT})
---
EOF
		pod2markdown --utf8 --html-encode-chars='|<' ~/collectd/src/"${NAME}.pod"
	)>"${outfile}"

	# Prevent '{%' and '{{' from appearing, e.g. in code blocks
	sed -i -e 's/{%/{ %/g' -e 's/{{/{ {/g' "${outfile}"

	# Fix links
	sed -r -i \
		-e 's!\(http://man.he.net/man[0-9]/(collectd[^)]*)\)!(./\1.md)!g' \
		-e 's!\(http://man.he.net/man5/types.db\)!./(./types.db.md)!g' \
		"${outfile}"

	echo "done"
done <_update.conf
