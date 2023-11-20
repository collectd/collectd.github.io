# Features

## Modularity / Portability

<div class="float right" style="background-color: white;">

[![](/images/architecture-schematic.small.png)](/images/architecture-schematic.png)

<div class="caption">

collectd's architecture  
(schematic overview)

</div>

</div>

Everything in <span class="collectd">collectd</span> is done in plugins. Well, except parsing the configfile. This means
that the main daemon doesn't have any external dependencies and should run on nearly anything that has heard of POSIX.
The daemon has been reported as working on Linux, Solaris, Mac OS X, AIX, FreeBSD, NetBSD, and OpenBSD. It's likely that
other UNIX flavors work to some extend, too.

Support for *Microsoft Windows* is provided by [SSC Serv](http://ssc-serv.com), a native Windows service that implements
<span class="collectd">collectd</span>'s network protocol.

## Reasonable defaults

<span class="collectd">collectd</span>'s configuration is kept as easy as possible: Besides which modules to load you
don't *need* to configure anything else, but you can customize the daemon to your liking if you want.

## High-resolution statistics

In contrast to most similar software, <span class="collectd">collectd</span> is not a script but written in plain C for
performance and portability. As a daemon it stays in memory, so there is no need to start up a heavy interpreter every
time new values should be logged. This allows <span class="collectd">collectd</span> to have a 10 second default
resolution while being nice to the system. It runs on small embedded WLAN routers with [OpenWrt](http://openwrt.org/)
without much impact on the CPU. The result are very high resolution graphics. The sample graph gives you an idea of the
detail you can expect. Please note that this is a ten-minute sample\!

## Sophisticated network code

<span class="collectd">collectd</span> utilizes a **data push model**, i.e. the data is collected and sent (pushed) to a
[multicast group](http://en.wikipedia.org/wiki/Multicast) or server. Thus there is no central instance which *queries*
any values.

The [network code](/wiki/index.php/Plugin:Network) can use the advanced network technologies
[IPv6](http://en.wikipedia.org/wiki/IPv6) and [Multicast](http://en.wikipedia.org/wiki/Multicast). But of course you can
use <span class="collectd">collectd</span> without any of this knickknack (i.e. IPv4 unicast ;), too. Since you can
configure data transmission and reception separately, you can realize the following setups easily (see the
[index.php/Networking\_introduction"\>networking introduction](%3C!--#echo%20var=) for more details):

  - **No networking**: If you don't load the *network plugin*, networking is completely disabled. No sockets, no
    overhead, no problem.
  - **Multicast**: Data can be sent to or received from a multicast group. This is the easiest and most interesting
    solution if you have many "clients" and one or a few "servers" on a local network. Using multicast is trivial:
    Simply enter a multicast address and any "server" will automatically recognize it and join the specific group.
  - **Unicast**: Of course you can simply send data to specific hosts only. This is mostly interesting for scattered
    hosts – network wise.
  - **Proxy operation**: An instance can be configured to forward the data it received over the network. Using this you
    can forward the data received from a multicast group to a unicast address, couple two distinct multicast groups
    without the need for (extra-AS) multicast routing and so on. Of course, IPv4/IPv6 can be wildly mixed with this,
    too.

The [network protocol](/wiki/index.php/Binary_protocol) has been designed to be lightweight, so data collection over
slow network links isn't a problem. The protocol is extensible, so it's open for new features in the future without
breaking backwards compatibility.

Beginning with [index.php/Version\_4.7"\>version 4.7](%3C!--#echo%20var=), the *network plugin* offers **cryptographic
extensions** to sign or encrypt network traffic. Servers can be instructed to only accept signed or encrypted traffic,
so that information cannot be forged and, in case of encrypted data, read.

Using multicast can be thought of as “**auto discovery**”: The server doesn't (need to) know what clients exists (it
never does) and the clients don't need to know the server's IP-address. In fact, they don't even know how many servers
there are. You can think of it like radio communication: Once set to the right channel you can receive all the data
transmitted by some senders – no matter what their position is.

## Custom extensions

There is a variety of means by which you can extend the functionality of <span class="collectd">collectd</span> to your
needs:

  - [C-plugins](/wiki/index.php/Table_of_Plugins): These plugins are compiled to shared objects and can be loaded by the
    daemon directly. These plugins possibly have the longest development cycle, but it is the best performing and most
    elegant solution, too.
  - [Perl-plugins](/wiki/index.php/Plugin:Perl): The *Perl* plugin includes a Perl-interpreter into the daemon which
    provides the C-interface to Perl-modules. This makes it possible to write additions in Perl.
    [`collectd-perl(5)`](/documentation/manpages/collectd-perl.5.shtml) has the juicy details.
  - [Java-plugins](/wiki/index.php/Plugin:Java): The *Java* plugin includes a *Java Virtual Machine* (JVM) into the
    daemon and can load and execute plugins in Java bytecode. The relevant parts of the API have been exported to Java,
    so that you can write a wide variety of plugins in Java. More information is available in the
    [`collectd-java(5)`](/documentation/manpages/collectd-java.5.shtml) manual page.
  - [Python-plugins](/wiki/index.php/Plugin:Python): The *Python* plugin includes a Python-interpreter into the daemon
    which provides the C-interface to Python-modules. This makes it possible to write additions in Python, analogically
    to the *Perl* plugin. [`collectd-python(5)`](/documentation/manpages/collectd-python.5.shtml) has the juicy details.
  - [UNIX domain socket](/wiki/index.php/Plugin:UnixSock): The *UnixSock* plugin opens a UNIX socket to which you can
    connect and submit your values or query collected values. For more information, take a look at the
    [`collectd-unixsock(5)`](/documentation/manpages/collectd-unixsock.5.shtml) manual page
  - [Execute binaries or scripts](/wiki/index.php/Plugin:Exec): Arguably the easiest and least performant solution. The
    *Exec* plugin forks a binary or script which acquires the values somehow and writes them to standard output. See
    [`collectd-exec(5)`](/documentation/manpages/collectd-exec.5.shtml) for details.
  - **Java MBean support**: With [jcollectd](https://github.com/hyperic/jcollectd) there is a pure-Java implementation
    of the <span class="collectd">collectd</span> network protocol. This class can be used as an MBean sender, allowing
    statistics about a Java program to be sent to a <span class="collectd">collectd</span> server, and as an MBean
    receiver, to receive (and work with) data sent by a <span class="collectd">collectd</span> client.

## Built to scale

<span class="collectd">collectd</span> is able to handle any number of hosts, from one to several thousand. This is
achieved by utilizing the resources as efficient as possible, e.g. by merging multiple RRD-updates into one update
operation (see this [in-depth article](/wiki/index.php/Inside_the_RRDtool_plugin)), merging the biggest possible number
of values into each one network packet and so on. The multithreaded layout allows for multiple plugins to be queried
simultaneously – without running into problems due to IO-latencies.

## SNMP support

The *Simple Network Management Protocol* (SNMP) is in widespread use with various network equipment, for example
switches, routers, rack monitoring systems, thermometers, UPSes, and so on. The [SNMP
plugin](/wiki/index.php/Plugin:SNMP) provides a generic interface to the SNM-protocol which you can use to query values
and dispatch them over <span class="collectd">collectd</span>'s mechanisms, e. g. transmit them to a server instance
somewhere else. Since devices one would query using SNMP usually are embedded devices with not very much computing
power, you can set the interval in which data is gathered for each host individually. And since it may take a while for
a timeout to occur or the device may take a little while to answer a request, the hosts are queried in parallel using
multiple threads.

## Integration with monitoring solutions

With version 4.3 the concept of [notifications and thresholds](/wiki/index.php/Notifications_and_thresholds) has been
added to <span class="collectd">collectd</span>. This allows you to send notifications through the daemon and allows for
simple threshold checking. However, <span class="collectd">collectd</span> is **not a monitoring solution**. We will
probably add some features to make the notification system more usable, but at the moment
<span class="collectd">collectd</span> is no match for a sophisticated monitoring solution.

To make it possible to integrate <span class="collectd">collectd</span> into the popular monitoring solution
[Nagios](http://www.nagios.org/), a “check” has been written for that. It's called
[`collectd-nagios(1)`](/documentation/manpages/collectd-nagios.1.shtml) and allows you to use Nagios to monitor if
certain values have been collected and if they were in an appropriate range.
