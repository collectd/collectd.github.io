---
title: Download
---

On this page you can download the collectd sources as GZip or BZip2 compressed
tar&nbsp;archive. Some Linux distributions provide binary packages of
collectd&nbsp;&ndash; you can find links to the package description pages where
appropriate. Also on this page are links to numerous user-provided binary
packages which are provided as-is&nbsp;&ndash; we object any responsibility for
these packages!

The packages available are:

*   [Source packages](#source)
    *   [Git repository](#git_repository)
    *   [Daily snapshots](#snapshot)
*   [Debian packages](#debian)
*   [Fedora](#fedora)
*   [RPM packages](#rpm)
*   [FreeBSD port](#freebsd)
*   [Solaris](#solaris)
*   [OpenWrt package](#openwrt)
*   [T2 SDE](#t2_sde)
*   [Windows client](#windows)
*   [Older files](#older)

## Source packages {#source}

These tarballs hold the collectd sources as published by the collectd
developers. These are the *supported* versions, previous versions will not get
updates.

*   Version {{ site.data.version.current.number }}
    *   [collectd-{{ site.data.version.current.number }}.tar.bz2]({{ site.data.version.current.url }})<br>
        SHA-256: `{{ site.data.version.current.sha256 }}`
*   Version {{ site.data.version.previous.number }}
    *   [collectd-{{ site.data.version.previous.number }}.tar.bz2]({{ site.data.version.previous.url }})<br>
        SHA-256: `{{ site.data.version.previous.sha256 }}`

### How to compile source packages

To compile these source packages you may need to install other libraries first, depending on the
features you want your built to have. A summary at the end of the `./configure` run will tell
you which libraries could be found and the appropriate plugins will be enabled automatically based on
that. If one or more plugins that you need are disabled, check the &rdquo;Prerequisites&ldquo; section in
the `README` file to find out which libraries your are missing.

After downloading the package you need to unpack, compile and install the sources:

```shell
tar xf collectd-{{ site.current.version }}.tar.bz2
cd collectd-{{ site.current.version }}
./configure
make all install
```

### Git repository {#git_repository}

The Git repository, along with issue tracker and Pull Requests, is hosted on GitHub at
http://github.com/collectd/collectd/.

```shell
git clone git://github.com/collectd/collectd.git
```

More information is available in [the development documentation](dev-info.md).

### Daily snapshots {#snapshot}

Sebastian Harl provides [daily snapshot tarballs](http://snapshots.tokkee.org/collectd/) of the
development Git repository. Since they're automatically pulled from the repository they may be in any state
possible, from including untested new code to being totally broken and not even build at all. Using these
tarballs on a production system is highly discouraged. Using these tarballs to test new features and report bugs
is very welcome, of course&nbsp;:)

*   http://snapshots.tokkee.org/collectd/

## Debian / Ubuntu packages {#debian}

Both, Debian and Ubuntu provide packages for collectd.

```shell
apt-get install collectd
```

**Note:** The package does not *depend* on all packages that are
required by all of the plugins. The file
`/usr/share/doc/collectd-core/README.Debian.plugins`
lists which additional packages are required for each plugin.

Our continuous integration environment also builds Debian and Ubuntu packages if you need more
up-to-date versions. Add the following Apt source:

```
# File /etc/apt/sources.list.d/pkg.ci.collectd.org.list
deb http://pkg.ci.collectd.org/deb ${distribution} ${component}

# Example:
# deb http://pkg.ci.collectd.org/deb trusty collectd-5.6
```

Where *distribution* is one of:

*   jessie
*   precise
*   squeeze
*   trusty
*   wheezy
*   xenial

And *component* is one of:

*   master
*   collectd-5.6
*   collectd-5.5

To verify downloaded packages, you need to add our continous integration PGP key to Apt:

```shell
gpg --recv-keys 3994D24FB8543576
gpg --export -a 3994D24FB8543576 | apt-key add -
```

## Fedora {#fedora}

Information about the *collectd* Fedora package is available at
https://apps.fedoraproject.org/packages/collectd/overview/.

## RPM packages {#rpm}

Packages for *openSUSE* and *SUSE Linux Enterprise Server* (SLES) are contained in the
[server:monitoring project](http://download.opensuse.org/repositories/server:/monitoring/).
You can [search the openSUSE
  package repositories](http://software.opensuse.org/search?baseproject=ALL&p=1&q=collectd) for suitable RPM packages.

For *Red&nbsp;Hat*, *CentOS* and *fedora*, there are
collectd RPM packages
[in Dag Wieers' repository](http://dag.wieers.com/rpm/packages/collectd/).

### Building an source-RPM package

collectd includes sample `.spec`&nbsp;files in the
`contrib/` directory in the tarball. Unfortunately these files are usually out-of-date, but you
can use them as a starting point for your own packages.

## FreeBSD port {#freebsd}
A *FreeBSD port* is available
([FreshPorts.org page](http://www.freshports.org/net-mgmt/collectd/)). You can install the
collectd (binary) *package* using:

```shell
pkg_add -r collectd
```

To install the *port* (source package), use:

```shell
cd /usr/ports/net-mgmt/collectd
make clean install
```

Thanks to [Matt Peterson](http://matt.peterson.org/) for creating this port and
*Krzysztof Stryjek* for maintaining it. By the way, in case you were wondering, a “port” is
basically the FreeBSD word for a “source package”&nbsp;- you can configure and compile
collectd under FreeBSD without sourcecode modifications and without port,
too.

## Solaris {#solaris}

*collectd* is available for *Solaris* from [OpenCSW](http://www.opencsw.org/).
Packages are available for Solaris 10/11 on x86 and SPARC. The available packages are:

*   [collectd](http://www.opencsw.org/packages/collectd/)<br>
    Collects system performance statistics periodically
*   [collectd_plugins_all](http://www.opencsw.org/packages/collectd_plugins_all/)<br>
    CollectD Metapackage that pulls in all plugins

Use the following command to install the package:

```shell
pkgadd -d http://get.opencsw.org/now
/opt/csw/bin/pkgutil -i collectd
```

## OpenWrt package {#openwrt}

collectd on the [WRT54G](http://en.wikipedia.org/wiki/WRT54G)

This client only binary package adds collectd to an
[OpenWrt Whiterussian](http://openwrt.org/) installation. The main plugins (network, cpu, interfaces,
load,&nbsp;...) are in the main package, the other packages are optional and provide further plugins. Since
**many of these packages are untested** please report back wether they have been working for you or not.

*   [collectd_4.1.0-1_mipsel.ipk](/files/ipkg/collectd_4.1.0-1_mipsel.ipk)
*   [collectd-csv_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-csv_4.1.0-1_mipsel.ipk)
*   [collectd-df_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-df_4.1.0-1_mipsel.ipk)
*   [collectd-disk_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-disk_4.1.0-1_mipsel.ipk)
*   [collectd-entropy_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-entropy_4.1.0-1_mipsel.ipk)
*   [collectd-exec_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-exec_4.1.0-1_mipsel.ipk)
*   [collectd-iptables_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-iptables_4.1.0-1_mipsel.ipk)
*   [collectd-irq_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-irq_4.1.0-1_mipsel.ipk)
*   [collectd-netlink_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-netlink_4.1.0-1_mipsel.ipk)
*   [collectd-ping_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-ping_4.1.0-1_mipsel.ipk)
*   [collectd-processes_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-processes_4.1.0-1_mipsel.ipk)
*   [collectd-swap_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-swap_4.1.0-1_mipsel.ipk)
*   [collectd-wireless_4.1.0-1_mipsel.ipk](/files/ipkg/collectd-wireless_4.1.0-1_mipsel.ipk)

## T2 SDE {#t2_sde}

Users of the T2 <acronym title="System Development Environment">SDE</acronym> can include
collectd into their build directly.
[Information about the collectd T2 package](http://www.t2-project.org/packages/collectd.html) can be
found on the [T2 web site](http://www.t2-project.org/).

## Windows client {#windows}

Support for *Microsoft Windows* is provided by [SSC&nbsp;Serv](http://ssc-serv.com/),
a native Windows application that can collect and dispatch performance data using the collectd network
protocol. More information and a free-of-cost trial is available at
https://ssc-serv.com/.

## Older files {#older}

Files of previous versions are still available.

However, please use a recent version if possible. If a bug in collectd prevents
you to upgrade to a new version, by all means, please
[issue a bugreport](https://github.com/collectd/collectd/issues).

Bugs are usually only fixed in the two most recent versions. If you ask on the mailing list about such bugs
you're likely to get an unamiable answer.

*   [Older files](/files/)<br>
    You have been warned
