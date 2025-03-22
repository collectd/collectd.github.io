# Related sites

The following is a loosely collected list of articles about <span class="collectd">collectd</span>, projects using
<span class="collectd">collectd</span>, similar projects and other stuff that might be interesting for our users and
interested parties. If you have written or found something that should be listed here, or if we made an error, e. g. in
the description of a link, please [tell us](contact.html). All links are sorted alphabetically or not at all. In any
case the order does not reflect any kind of significance.

### Utility programs and projects

<div style="margin-left: 2em; font-style: italic;">

For a **list of graphing front-ends**, see our [List of front-ends](/wiki/index.php/List_of_front-ends) wiki page.

</div>

  - [Collectd-web](/wiki/index.php/Collectd-web) ([Homepage](https://httpdss.github.io/collectd-web/))  
    Web-based graphing front-end using JavaScript and a modified version of *collection 2*.
    <div class="code">
    git://github.com/httpdss/collectd-web.git
    </div>
  - [CollectGraph](/wiki/index.php/CollectGraph) ([Homepage](http://moinmo.in/MacroMarket/CollectGraph))  
    Macro for the [MoinMoin wiki](http://moinmo.in/) that displays graphs using RRD files created and filled by
    <span class="collectd">collectd</span>.
  - [EcoStats](/wiki/index.php/EcoStats) ([Homepage](http://code.google.com/p/ecostats/))  
    Web-based, near-realtime statistics display by Sergiusz Pawłowicz, using tables and numerical values that are
    updated without page reload using JavaScript, a CGI script and the [unixsock
    plugin](/documentation/manpages/collectd-unixsock.5.shtml). When moving your mouse over a value, a floating graph is
    loaded and displayed. A [live sample](http://pawlowicz.name/MyServers) is available.
  - [Graphite](http://graphite.wikidot.com/)  
    Graphite is a storage and visualization solution for numeric time-series data. You can configure
    <span class="collectd">collectd</span> to send data to it using the
    [Write Graphite](/wiki/index.php/Plugin:Write_Graphite) plugin.
  - [Heymon](/wiki/index.php/Heymon) ([Homepage](http://github.com/newobj/heymon))  
    Web-based *Ruby on Rails* application for graphing RRD files created by <span class="collectd">collectd</span>.
    <div class="code">
    git://github.com/newobj/heymon.git
    </div>
  - [kcollectd](/wiki/index.php/Kcollectd)
    ([Homepage](http://www.forwiss.uni-passau.de/~berberic/Linux/kcollectd.html))  
    A X frontend to the RRD files created by <span class="collectd">collectd</span>. It uses KDE/Qt, hence the name.
  - [Librato](http://librato.com/)  
    Hosted metric storage, visualization and alerting solution. Check out the
    [collectd-librato](https://github.com/librato/collectd-librato) project on *Github*.
  - [Visage](/wiki/index.php/Visage) ([Homepage](http://auxesis.github.com/visage/))  
    Web-based graphing frontend for RRD-files written by <span class="collectd">collectd</span>. The data is exported
    via JSON and graphed in the web browser using [Raphaël](http://raphaeljs.com/). There's a short introduction of
    Visage in [Lindsay's
    blog](http://holmwood.id.au/~lindsay/2009/09/08/graphing-collectd-statistics-in-the-browser-with-visage/).

    ```
    git://github.com/auxesis/visage.git
    ```
  - [Module for Puppet](http://github.com/DavidS/module-collectd/tree/development)  
    [Puppet](http://reductivelabs.com/projects/puppet/), a configuration management solution, can manage
    <span class="collectd">collectd</span>'s configuration files, thanks to funding by
    [neoTactics](http://neotactics.com/). The source code is available from:

    ```
    git://github.com/DavidS/module-collectd.git
    ```
  - [ruby-collectd](http://github.com/astro/ruby-collectd/)  
    A *Ruby* implementation of the <span class="collectd">collectd</span> network protocol, written by *Astro*. This
    allows to send statistics from a Ruby script with a native interface. The source code is available from:

    ```
    git://github.com/astro/ruby-collectd.git
    ```
  - [erlang-collectd](http://github.com/astro/erlang-collectd/)  
    An *Erlang* implementation of the <span class="collectd">collectd</span> network protocol, written by *Astro*. This
    allows to send statistics from an Erlang application to a <span class="collectd">collectd</span> server. The source
    code is available from:

    ```
    git://github.com/astro/erlang-collectd.git
    ```
  - [jcollectd](http://support.hyperic.com/display/hypcomm/jcollectd)  
    A pure-Java implementation of the <span class="collectd">collectd</span> network protocol, written by Doug
    MacEachern of [Hyperic, Inc](http://www.hyperic.com/). It can be used as an MBean sender, sending information about
    a running Java application to a <span class="collectd">collectd</span> server, and as an MBean receiver, receiving
    data sent by an <span class="collectd">collectd</span> client.  
    The [source code](http://github.com/hyperic/jcollectd) is available from:

    ```
    git://github.com/hyperic/jcollectd.git
    ```
  - [Reconnoiter](http://labs.omniti.com/trac/reconnoiter)  
    A distributed monitoring system marrying fault detection and trending. It features a [*collectd*
    module](http://labs.omniti.com/docs/reconnoiter/config.noitd.modules.html) which can be used to monitor the
    existence of a *collectd* client on the monitored host.
  - [Splunk Enterprise – collectd app](https://github.com/Nexinto/collectd)
    ([splunkbase](https://splunkbase.splunk.com/app/2875/))  
    *Splunk Enterprise* is a solution for indexing, analysing and presenting all sorts of data. The *collectd app* by
    Nexinto adds a dashboard for system metrics (CPU, memory, disk, …). Licensed under the Apache License 2.0.

### Articles / Blog entries

  - An unknown author at [neoTactics](http://neotactics.com/blog/) is happy about <span class="collectd">collectd</span>
    in general and [jcollectd](http://support.hyperic.com/display/hypcomm/jcollectd) in particular in [“Hyperic Clued on
    Cloud Monitoring”](http://neotactics.com/blog/technology/hyperic-clued-on-cloud-monitoring).
  - [John M. Willis](http://www.johnmwillis.com/) has mentioned <span class="collectd">collectd</span> as one of the
    *“Best Monitoring Tools in the Clouds”* in his [“2008 Cloudies
    Awards”](http://www.johnmwillis.com/cloudies/the-2008-cloudies-awards/) blog entry.
  - The german [Linux-Magazin](http://www.linux-magazin.de/) has written a short [report about our stay at the SYSTEMS
    2008](http://www.linux-magazin.de/news/systems_2008_collectd_zur_performance_analyse_im_cloud_computing) (in
    german).
  - [Ben Martin](http://monkeyiq.blogspot.com/) has written an [article about projects for collecting system
    statistics](http://www.linux.com/feature/151982) published on *linux.com*. Among other projects it mentions
    <span class="collectd">collectd</span>.
  - [Jeff Waugh](http://bethesignal.org/blog/2008/04/24/smooth-upgrade-to-ubuntu-804-lts-on-my-linode/) is happy about
    <span class="collectd">collectd</span> on Ubuntu 8.04.  
    Later, he wrote a [blog
    entry](http://bethesignal.org/blog/2009/04/06/replacing-apache-with-nginx-for-static-file-serving/) which
    demonstrates how the data collected by <span class="collectd">collectd</span> can be used to optimize a web-server
    setup.  
    He also demonstrates [how to monitor
    FastCGI](http://bethesignal.org/blog/2009/07/22/watching-nginx-upstreams-with-collectd/) using the [Tail
    plugin](/wiki/index.php/Plugin:Tail).
  - [Terry Gliedt](http://www.hps.com/~tpg/notebook/collectd.php) uses <span class="collectd">collectd</span> to monitor
    a cluster at University of Michigan.
  - [Astro](http://astroblog.spaceboyz.net/) has written [an introductory
    article](http://blog.superfeedr.com/OSS/collectd/infrastructure/open-source/performance-monitoring-with-collectd/)
    about <span class="collectd">collectd</span> on the *Superfeedr* blog.
  - *Jordan Sissel* has included *collectd* in his sysadmin advent calendar,
    [sysadvent](http://sysadvent.blogspot.com/2009/12/day-21-collectd.html), 2009.

### Projects using <span class="collectd">collectd</span>

  - [oVirt](http://ovirt.org/) is a management console for virtual guest systems, including statistics. It's developed
    by [RedHat's Emerging Technologies group](http://et.redhat.com/).
  - [LuCI](http://luci.freifunk-halle.net/About), a web-based configuration frontend for embedded devices, can display
    statistics collected by <span class="collectd">collectd</span>. There is a
    [screenshot](http://luci.freifunk-halle.net/WebUI/Screenshots/Administration?action=AttachFile&do=view&target=stat-iface.png)
    of the statistics in [OpenWrt](http://openwrt.org/), which uses LuCI as its web-frontend.

### Other users of <span class="collectd">collectd</span>

  - [Stackdriver](http://www.stackdriver.com/) is using <span class="collectd">collectd 5</span> as its agent to monitor
    AWS EC2 nodes.
  - [RightScale Inc.](http://rightscale.com/) use <span class="collectd">collectd</span> on [Amazon
    EC2](http://aws.amazon.com/ec2) nodes.
  - The [BBC](http://bbc.co.uk/) is collecting statistics from more than 200 servers.
  - [noris network AG](http://noris.net/) collects performance data from own and hosted servers as well as a wide
    variety of network equipment using the SNMP plugin.
  - [neoTactics](http://neotactics.com/) use <span class="collectd">collectd</span> in their cloud management framework
    [CloudScale](http://neotactics.com/cloudscale/). They have sponsored the development of a module which allows
    configuring <span class="collectd">collectd</span> with [Puppet](http://reductivelabs.com/projects/puppet/), a
    configuration management solution. See the announcements in [neoTactics'
    blog](http://neotactics.com/blog/technology/cloudscale-updates-more/) and on the [puppet-users mailing
    list](http://groups.google.com/group/puppet-users/browse_thread/thread/cc9a6d612e7bd3ae). Thanks :)

### Similar projects

The following is a list of projects similar to <span class="collectd">collectd</span> and a short note on how they
differ from <span class="collectd">collectd</span>. Projects that focus on monitoring and do some performance
measurement on the side are not on this list. It's easy to find extensive lists of such (monitoring) tools on the web,
though.

  - [Ganglia](http://ganglia.info/)  
    Focus on compute clusters and basic system statistics.
  - [Munin](http://munin.projects.linpro.no/)  
    Data is collected by forking / executing plugins (i. e. scripts).
  - [StatsD](https://github.com/etsy/statsd/)  
    Written in JavaScript for *Node.js*; optimized towards counting events and submitting aggregated counts, e.g. to
    *Graphite*. See also the [StatsD plugin](/wiki/index.php/Plugin:StatsD).
  - [eLuna Graph System](http://steph.eluna.org/eluna_graph_system.html)  
    Written in Perl; relies on cron; local system only.
  - [Monitorix](http://www.monitorix.org/)  
    Written in Perl; network support using HTTP (web server and CGI on client).
  - [openSSI webView](http://openssi-webview.sourceforge.net/)  
    Specialized solution for [openSSI](http://openssi.org/) clusters; written in Perl.
  - [RRDutil](http://www.tnpi.biz/internet/manage/rrdutil/)  
    Written in Perl, relies on cron and SNMP.
  - [collectl](http://collectl.sourceforge.net/)  
    Written in Perl; monolithic structure; designed for realtime viewing in the console.
