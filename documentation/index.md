---
title: Documentation
---
**collectd's** documentation consists primarily of the manpages that come
with the daemon, accompanied with some special documents on certain aspects. A more generic source of
information is the file
`[README](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README)` that's
included in the source tarball. Also, some more specialized documentation, including a
[getting started guide](/wiki/index.php/First_steps), can be found below.</p>

## Manual pages {#manual_pages}

The manpages, that come with the daemon, are provided here in HTML form for your convenience. Since
converting them to HTML format is not fully automatic they may be a little outdated here. If in doubt,
please refer to the manpages that come with the distribution.

*   `[collectd(1)](/documentation/manpages/collectd.html)`
*   `[collectdmon(1)](/documentation/manpages/collectdmon.html)`
*   **`[collectd.conf(5)](/documentation/manpages/collectd.conf.html)`**
*   `[collectd-email(5)](/documentation/manpages/collectd-email.html)`
*   `[collectd-exec(5)](/documentation/manpages/collectd-exec.html)`
*   `[collectd-nagios(1)](/documentation/manpages/collectd-nagios.html)`
*   `[collectd-perl(5)](/documentation/manpages/collectd-perl.html)`
*   `[collectd-python(5)](/documentation/manpages/collectd-python.html)`
*   `[collectd-java(5)](/documentation/manpages/collectd-java.html)`
*   `[collectd-snmp(5)](/documentation/manpages/collectd-snmp.html)`
*   `[collectd-tg(1)](/documentation/manpages/collectd-tg.html)`
*   `[collectd-unixsock(5)](/documentation/manpages/collectd-unixsock.html)`
*   `[types.db(5)](/documentation/manpages/types.db.html)`

## collectd Wiki

In order to make it easier to contribute documentation, we have moved some of the documentation into a
wiki. You can switch to the wiki (and back to the homepage) using the buttons in the upper right corner of
the site. Or follow this link:

*   [collectd Wiki](https://collectd.org/wiki/)

## Special documentation

The following documentation describes some special aspects of the daemon.

*   [First steps with collectd](/wiki/index.php/First_steps)
*   [Networking introduction](/wiki/index.php/Networking_introduction)
*   [Inside the RRDtool plugin](/wiki/index.php/Inside_the_RRDtool_plugin)
*   [Notifications and thresholds](/wiki/index.php/Notifications_and_thresholds)
*   [Introduction to <em>chains</em>](/wiki/index.php/Chains), <span class="collectd">collectd</span>'s filtering mechanism.
*   [collectd v3 to v4 migration guide](/wiki/index.php/V3_to_v4_migration_guide)
*   [General development information and documentation](dev-info.shtml)
*   [How to Report Bugs Effectively](http://www.chiark.greenend.org.uk/~sgtatham/bugs.html)

## Reference documentation

A lot of projects refer to their technical documentation under &quot;reference documentation&quot;. If
you're looking for that, please read the [manual pages](#manual_pages) above. We provide links
to specific parts of our documentation here.

[Plugins](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README)
:   A list of all plugins, together with a short description for each, can be found in the
    `[README](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README)`
    file included in the source code distribution.<br />
    There's also the [Table of Plugins](/wiki/index.php/Table_of_Plugins) wiki page.
[Libraries / Dependencies](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README)
:   A list of all supported libraries and which plugins make use of each library is documented in the
    `[README](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=README)` file under
    &quot;Prerequisites&quot;.
[Configuration options](/documentation/manpages/collectd.conf.html)
:   All configuration options, both, for the server and for all plugins, are documented in
    `[collectd.conf(5)](/documentation/manpages/collectd.conf.html)`.
[Contributors](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=AUTHORS)
:   A list of all contributors can be found in the file
    `[AUTHORS](http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=AUTHORS)`
    included in the source code distribution.

## Help writing documentation!

Writing documentation is, along with reporting bugs, an easy and very much appreciated way of
contributing to an open source project. You can do this without any coding skills whats-o-ever and
everybody will benefit from it&nbsp;- users and developers alike. If you have written something up, or
plan to, [let us know](/contact.shtml)&nbsp;:)

## External documentation

The following documentation has been found on the web or has been submitted by users.

*   [&quot;Overview of the Monitoring System&quot;](http://wiki.rightscale.com/2._References/01-RightScale/01-RightScale_Dashboard/04-General_Topics/Monitoring_System)
    in the [RightScale](http://www.rightscale.com/) wiki
*   [Entry &quot;collectd&quot;](http://wiki.monitoring-fr.org/nagios/integration/collectd)
    in the [monitoring-fr.org wiki](http://wiki.monitoring-fr.org/) (french)

<!-- vim: set sw=2 sts=2 ts=8 et tw=120 : -->
