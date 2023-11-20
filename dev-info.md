# Development Information

## Git repository

<span class="summary">The current development state is stored in a [Git
repository](http://git.verplant.org/?p=collectd.git;a=summary).</span>  
The *Git repository* is also synched to [Github](https://github.com/). To check out the latest development version use
the following command.

<div class="code">

<span class="comment">\# Canonical repository</span>  
git clone git://git.verplant.org/collectd.git  
  
<span class="comment">\# Github mirror</span>  
git clone git://github.com/collectd/collectd.git  

</div>

After "cloning" the repository you will need to generate the automake and autoconf files. You can do this using the
`build.sh` script found in the root directory of the repository.

## Bugtracking system

We're using [GitHub issues](https://github.com/collectd/collectd/issues) to keep track of bugs. Feel free to open and
discuss bugs there. You can conveniently link to issues using `http://collectd.org/bugs/num`.

## Development articles

  - [collectd's plugin architecture](/wiki/index.php/Plugin_architecture)  
    A technical overview of the functions that should be in a plugin and what they do.
  - [index.php/Build\_system"\>collectd's build system](%3C!--#echo%20var=)  
    Some hints how you integrate a new plugin in the autotools-based build-system.
  - [development/submitting-patches.shtml"\>Submitting patches](%3C!--#echo%20var=)  
    A few words on how you best generate patches.
  - [A few words on coding style](/wiki/index.php/Coding_style)  
    A guidline to write, what we consider, "good code".
  - [Roadmap](/wiki/index.php/Roadmap)  
    Some ideas of future development and a rough order in which we plan to implement them.

news.shtml\#news49"\>the news entry. So far, t-shirts have gone to:

  - Sebastian Harl
  - Richard Shade
  - Peter Holik
  - Richard W. M. Jones
  - Stefan Hacker
  - Oleg King
  - Michał Mirosław
  - Alessandro Iurlano
  - M. G. Berberich
  - Michael Stapelberg
  - Luke Heberling
  - Bruno Prémont
  - Doug MacEachern
  - Fabian Linzberger

Thanks, guys :)

\--\>
