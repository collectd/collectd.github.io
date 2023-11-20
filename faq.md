# Frequently asked questions

These are *real* frequently asked questions, not some questions we though of while sitting by ourselves and having a
glass of wine. As a consequence, the questions are sometimes very specific and the answers sometimes require some
knowledge about advanced topics. If you're looking for stuff like "What does <span class="collectd">collectd</span> do?"
or "How do I enable plugin *foo*?", please go to the appropriate place, for example the
[documentation](/documentation.shtml) page.

  - 
    
    <div id="faq:diagnostic_output">
    
    <div class="question">
    
    It doesn't work. Where can I find diagnostic output?
    
    </div>
    
    <div class="answer">
    
    In order to get any output at all, you need to load a *log plugin*. The two main log plugins are the
    [LogFile](/wiki/index.php/Plugin:LogFile) and [SysLog](/wiki/index.php/Plugin:SysLog) plugins. We recommend that
    loading one of those plugins is the *first* thing you do in your config file, i.e. put the `LoadPlugin` line at the
    very top.  
    If no *log plugin* is loaded, <span class="collectd">collectd</span> will write to `STDERR`. After the daemon has
    forked to the background, you won't be able to see this output anymore, though.
    
    </div>
    
    </div>

  - 
    
    <div class="question">
    
    I try to use the [`ping`-plugin](/plugins/ping.shtml), but keep getting the message "`` `ping_host_add' failed.``".
    What's the matter?
    
    </div>
    
    <div class="answer">
    
    In order to generate ICMP packets one needs to open a so called "RAW socket". On most UNIX systems only the
    superuser (root) may open such sockets.  
    In addition, some virtualization environments, such as [VServer](http://linux-vserver.org/) and [Solaris
    Zones](http://www.sun.com/bigadmin/content/zones/) have been reported to cause some trouble.
    
    </div>

  - 
    
    <div class="question">
    
    Who receives the multicast traffic?
    
    </div>
    
    <div class="answer">
    
    I don't know. That entirely depends on your network setup. By default <span class="collectd">collectd</span> uses
    "site local" addresses, that should not be routed to outside your AS. If that's really the case is up to you.
    
    </div>

  - 
    
    <div class="question">
    
    How do I use `--with-librrd`?
    
    </div>
    
    <div class="answer">
    
    If you installed libraries in a non-standard (or non-system) path you need to specify them when running the
    `configure` script. Otherwise it will not find them and build the binaries without linking against the library.  
    You need to set the `PATH` as given to the `--prefix` option when compiling the library. The script actually looks
    for the two subdirectories `PATH/include` and `PATH/lib`, so check for their existence if things don't work. If, for
    example, you installed RRDTool in `/opt/rrdtool-x.y.z` you need to run `configure` like this:
    
    <div class="code">
    
    $ ./configure --with-librrd=/opt/rrdtool-x.y.z
    
    </div>
    
    </div>

  - 
    
    <div id="faq:version_numbers">
    
    <div class="question">
    
    What do the version numbers mean?
    
    </div>
    
    <div class="answer">
    
    The version numbers consist of three numbers: The **major-** and **minor-**number and the **patchlevel**.
    
      - Versions with different **major-numbers** are basically not compatible. This means that the definitions of
        RRD-files or config-options have been changed or, in general, that the user has to do something in addition to
        install the new version. This is not nice and avoided when possible, but sometimes necessary to prevent old
        mistakes to become ancient mistakes. We try to provide migration scripts, though, to make a switch as easy as
        possible. See the [V4 to v5 migration guide](/wiki/index.php/V4_to_v5_migration_guide) for details.
      - Versions with differing **minor-numbers** are backwards compatible, i.e. you can replace the lower version with
        the higher one and everything should still work. This means that features are added, but not removed or changed
        and that the default behavior does not change.
      - Versions with different **patchlevels** are both, forward- and backwards-compatible, because no new features
        have been introduced. The only difference between the two versions is one or more bugfixes, so you should
        generally install the higher version of the two.
    
    </div>
    
    </div>

  - 
    
    <div id="faq:enable_plugin">
    
    <div class="question">
    
    I enabled the *foo* plugin using `--enable-foo` but now the build process fails. What's wrong?
    
    </div>
    
    <div class="answer">
    
    Frankly, this is the expected behavior. The `confgure` script tries hard to determine which libraries are installed
    and what compiler and linker flags are required to build applications that use that library. Based on those results
    those plugins whose dependencies are met will be enabled – all other plugins will be disabled.  
    So, if a plugin is displayed as disabled, its dependencies are not met. The normal way to get a plugin compiled is
    to install the missing dependencies and re-run the `configure` script.  
    You can **force** it to be build using `--enable-foo`, but you need to know exactly what you are doing. If you do
    this you're out in the dark, cold woods and totally on your own\!
    
    </div>
    
    </div>

  - 
    
    <div id="faq:missing_dependency">
    
    <div class="question">
    
    I installed the *Debian* package of <span class="collectd">collectd</span>. Now I get the error “lt\_dlopen
    (*foo.so*) failed: file not found” – but the file exists\!
    
    </div>
    
    <div class="answer">
    
    The *Debian* and *Ubuntu* packages of <span class="collectd">collectd</span> contain all plugins that are available
    for the platform you're using. However, they *do not* contain a *Dependency* on all required libraries for all
    plugins, because that would be *a lot* of packages. In all likelihood you're missing one of the required
    libraries.<sup>\[\*\]</sup> Take a look at the file `/usr/share/doc/collectd-core/README.Debian.plugins` which lists
    all the required packages for each plugin. You can also use
    
    <div class="code">
    
    ldd /usr/lib/collectd/*foo.so*
    
    </div>
    
    to figure out which shared object is missing and go from there.  
    \[\*\] Yes, the error message “file not found” is very confusing. It is an automatically stringyfied version of the
    error code returned by `lt_dlopen()`. Versions of <span class="collectd">collectd</span> that were released after
    February 2011 contain a more detailed error message for this case.  
      
    The intuitive way of organizing the <span class="collectd">collectd</span> package would be to put plugins with
    special dependencies in separate packages which have a dependency on the library that's required for the plugin.
    Unfortunately, consensus in the *Debian* community was that this would create too many packages. All the
    dependencies are listed in a field called *Recommendation* which is a sort of soft dependency. Since
    *Recommendations* are installed in the default setting of APT, this way is deemed good enough for the average user.
    
    </div>
    
    </div>

  - 
    
    <div id="faq:static_libs">
    
    <div class="question">
    
    The build process fails with "relocation R\_X86\_64\_32 against \`a local symbol' can not be used when making a
    shared object; recompile with -fPIC". What's wrong?
    
    </div>
    
    <div class="answer">
    
    Many plugins have to be linked against libraries. A few of them (currently [`iptables`](/plugins/iptables.shtml),
    [`netlink`](/plugins/netlink.shtml) and [`nut`](/plugins/nut.shtml) are known to be affected) link against libraries
    that are only available as "[static
    libraries](http://users.actcom.co.il/~choo/lupg/tutorials/libraries/unix-c-libraries.html)" in many distributions.
    Most distributions (e. g. Debian and SuSE GNU/Linux) do not compile static libraries with the "-fPIC" option. Thus
    they cannot be linked with shared objects compiled with "-fPIC". Some architectures (among them i386) do not seem to
    care about that and handle it in some (probably magic) way. However, other architectures (mostly 64bit like amd64 or
    hppa) cannot handle that and thus the compiler aborts with the error message mentioned above.  
    To fix this issue, you need a version of the static library compiled with "-fPIC" (or a shared library). Ask your
    distributor to provide a suitable version of the library or compile it yourself.  
    For more detailed information please refer to:
    
      - [the gentoo documentation](http://www.gentoo.org/proj/en/base/amd64/howtos/index.xml?part=1&chap=3),
      - [Debian Bug \#358637](http://bugs.debian.org/358637)
      - [Debian Bug \#419684](http://bugs.debian.org/419684)
      - [Debian Bug \#430933](http://bugs.debian.org/430933)
    
    </div>
    
    </div>

  - 
    
    <div id="faq:solaris_32bit">
    
    <div class="question">
    
    Solaris support is broken\! The build aborts\! Help\!
    
    </div>
    
    <div class="answer">
    
    Versions **4.4.5** and **4.5.2** include fixes in the build system so the problems described below should be handled
    much more gracefully now.  
    There are two known issues with Solaris, but both can be fixed relatively easy:  
    If you build a 32bit binary, the configure script will (try to) enable LFS. This will result in an error which looks
    somehow like this:
    
    <div class="code">
    
    config.h:832:1: error: "\_FILE\_OFFSET\_BITS" redefined
    
    </div>
    
    Also, the `swap`-plugin has some problems of it's own with this:
    
    <div class="code">
    
    swap.c:197: warning: implicit declaration of function 'swapctl'  
    swap.c:197: error: 'SC\_AINFO' undeclared (first use in this function)
    
    </div>
    
    The problem is that Solaris' swap interface is not available to 32bit applications. The solution is to **build a
    64bit binary**\! If you build a 64bit binary, LFS is not needed and the swap plugin works as intended. To do this,
    pass the `-m64` flag to the compiler (assuming you're using the Sun C compiler).  
    Another problem is that by default Sun defines a version of `getgrnam_r` that isn't POSIX-compatible. To enable
    POSIX-compatibility pass the `_POSIX_PTHREAD_SEMANTICS` define to the compiler. This define is set automatically in
    versions 4.4.5, 4.5.2 and later.  
    Putting all together you need to pass the following flags to the `configure`-script:
    
    <div class="code">
    
    <span class="comment">\# Sun CC</span>  
    $ ./configure CFLAGS="-m64 -mt -D\_POSIX\_PTHREAD\_SEMANTICS"
    
    </div>
    
    Please note that we only test the [Sun C compiler](http://developers.sun.com/sunstudio/) ourselves, but
    [GCC](http://gcc.gnu.org/) may work, too. When using the GCC you need to substitute the `-mt` flag with the
    `-pthreads` flag. So if you use GCC the above invokation of `./configure` becomes:
    
    <div class="code">
    
    <span class="comment">\# GCC</span>  
    $ ./configure CFLAGS="-m64 -pthreads -D\_POSIX\_PTHREAD\_SEMANTICS"
    
    </div>
    
    Thanks to *Christophe Kalt* for sharing his insights :)
    
    </div>
    
    </div>

  - 
    
    <div id="faq:split_up_data_sets">
    
    <div class="question">
    
    Why do many plugins, for example the *CPU plugin*, split related metrics accross so many files? Can I change that?
    
    </div>
    
    <div class="answer">
    
    The **short answer** is: We do this in order to be able to provide strict backwards compatibility. Writing all the
    details to a single file is not possible; for the *CPU plugin*, set the `ReportByState` and `ReportByCpu` options to
    `false` for an aggregated output.  
    The **long answer** and explanation of the short answer is: <span class="collectd">collectd</span> runs on a variety
    of operating systems. Each operating system has it's own method for accounting CPU states, memory consumption, swap
    usage, and so on. If all these data sources where in one data set, every new supported operating system or any
    addition to an already supported operating system would mean that we need to modify the data set. This cannot be
    done without breaking backwards compatibility.  
    To give you a few examples: Sometime in mid-`2.6` the Linux kernel added some Xen-patches which provided a new CPU
    state: "steal time". When adding support for BSD systems we had to add "wired" memory. NFSv4 added some new
    procedures that NFSv3 didn't have, etc pp.  
    Changing the layout of the data is not just a matter of changing the `types.db` file. That file describes the layout
    of the data submitted by plugins. The plugins don't need it - they know what data they submit. It's needed by the
    daemon and writing plugin to know how to store the data. If you mess with the file without knowing what you do, you
    will most likely end up with the data not being collected at all anymore.  
    Going forward, we intend to push the “one data source per file” rule even more and, eventually, make it the only
    supported mode of operation. If you are writing extensions for *collectd*, it would be best to bear this in mind.
    
    </div>
    
    </div>

  - 
    
    <div id="faq:collection_cgi_incomplete">
    
    <div class="question">
    
    Why doesn't `collection.cgi` draw *foo* graphs correctly?
    
    </div>
    
    <div class="answer">
    
    That script is meant as a starting point for own developments, not as a ready to use web frontend for RRD files
    written by <span class="collectd">collectd</span>.  
    It is just an example, because it's not really usable as it is. And it's not really useable, because we are UNIX
    developers and don't enjoy doing web stuff much. Working on the daemon is just so much more fun.. ;) So in the best
    of free / open source traditions: Patches welcome\!  
    There are alternatives, though. We've heard from various people using [Cacti](http://www.cacti.net/) to render the
    graphs. Sergiusz Pawlowicz of the [BBC](http://www.bbc.co.uk/) has written
    [CollectGraph](http://moinmo.in/MacroMarket/CollectGraph), a macro for the [MoinMoin wiki](http://moinmo.in/). And
    of course there's [drraw](http://web.taranis.org/drraw/).
    
    </div>
    
    </div>

  - 
    
    <div id="faq:cpu_jiffies">
    
    <div class="question">
    
    Why don't the CPU states sum up to 100%?
    
    </div>
    
    <div class="answer">
    
    By default, the [CPU plugin](/plugins/cpu.shtml) does not collect the CPU usage in percent, but in *"jiffies"*. If
    you prefer a *percentage*, set the `ValuesPercentage` option to `true`.  
    A *jiffy* is the time-unit which the scheduler in the operating systems uses to manage run times of applications.
    Under Linux, the default configuration is to have 100 jiffies per second, which leads many users to believe they're
    getting a percentage. You can, however, configure your kernel at compile time to use 250 or 1000 jiffies per second,
    usually resulting in a more responsive system but IO-throughput is decreased. Especially on busy systems, virtual
    systems and systems with a *"tickless kernel"* there may not always be the exact number of intended jiffies in one
    second, resulting in the variance you've notice in the graphs.  
    That you see this issue in <span class="collectd">collectd</span> but not in other similar tools is, in many cases,
    due to the fact that <span class="collectd">collectd</span> collects data so frequently. Over the timespan of, say,
    five minutes these variations even out, but the alleged percentages are, in fact *jiffies*.
    
    </div>
    
    </div>

  - 
    
    <div id="faq:network_encryption">
    
    <div class="question">
    
    Is network traffic encrypted or signed?
    
    </div>
    
    <div class="answer">
    
    Yes, starting with *version 4.7.0* you can either sign the traffic using a *Hashed Message Authentication Code*
    (HMAC) or encrypt the traffic. Please refer to the [Network plugin wiki page](/wiki/index.php/Plugin:Network) for
    details.
    
    </div>
    
    </div>

  - 
    
    <div id="faq:value_too_old">
    
    <div class="question">
    
    I get frequent errors that a “value is too old”. What's this about?
    
    </div>
    
    <div class="answer">
    
    The complete error message usually looks like this:
    
    <div class="code">
    
    \[2009-05-06 14:03:05\] uc\_update: Value too old: name = device.domain.tld/snmp/frequency-output; value time =
    1241611385; last cache update = 1241611385;
    
    </div>
    
      
    When adding a new value to the internal cache, the timestamp on that value is checked against the timestamp on the
    last value with the same name that was added to the cache. The error message informs you, that the value already in
    the cache was newer or as new as the value that should have been added. In the example above, a value for
    *device.domain.tld/snmp/frequency-output* should be added, but the current timestamp *(1241611385)* is the same as
    the timestamp already present in the cache, i.e. a duplicate.  
      
    The most common source of this is that somehow two values with the same *identifier* (name) are reported. One
    frequent reason for this is that two hosts report data using the same host name and send it to a central server. If
    the “last cache update time” increases with each message, this is very likely that case. You can use
    [Wireshark](http://www.wireshark.org/) (1.4 or later) to analyze and filter the
    <span class="collectd">collectd</span> network traffic and find out from which IP addresses the duplicate values
    originate. The second most common reason is a misconfiguration of *generic plugins*, such as the [SNMP
    plugin](/wiki/index.php/Plugin:SNMP).  
      
    A similar variant of the above problem is that the daemon is running *twice* on the same host. You can use the `ps`
    command to check if this is the case.  
      
    These errors may also be caused by a plugin being loaded twice. You can check if each plugin is loaded only once by
    checking the `LoadPlugin` lines:
    
    <div class="code">
    
    grep -i LoadPlugin /etc/collectd/collectd.conf | egrep -v '^\[\[:space:\]\]\*\#' | sort | uniq -c
    
    </div>
    
      
    Another common cause is that time on the client jumps backwards. This may happen due to a weekly *ntpdate*
    forcefully setting the time, for example. *Virtual hosts* often have problems providing a steady wallclock time, but
    usually they have jumps *forward* (causing gaps). It might be worth investigating nonetheless.
    
    </div>
    
    </div>
