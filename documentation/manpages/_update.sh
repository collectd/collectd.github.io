#!/bin/bash

for f in ~/collectd/src/*.pod
do
	#perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' "${f}" >$(basename "${f/pod/md}")
	pod2markdown --utf8 "${f}" >$(basename "${f/pod/md}")
done
