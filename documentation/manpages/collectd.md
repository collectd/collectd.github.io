---
title: collectd(1)
---
# NAME

collectd - System statistics collection daemon

# SYNOPSIS

collectd _\[options\]_

# DESCRIPTION

collectd is a daemon that receives system statistics and makes them available
in a number of ways. The main daemon itself doesn't have any real functionality
apart from loading, querying and submitting to plugins. For a description of
available plugins please see ["PLUGINS"](#plugins) below.

# OPTIONS

Most of collectd's configuration is done using using a configfile. See
[collectd.conf(5)](./collectd.conf.md) for an in-depth description of all options.

- **-C** _&lt;config-file>_

    Specify an alternative config file. This is the place to go when you wish to
    change **collectd**'s behavior. The path may be relative to the current working
    directory.

- **-t**

    Test the configuration only. The program immediately exits after parsing the
    config file. A return code not equal to zero indicates an error.

- **-T**

    Test the plugin read callbacks only. The program immediately exits after invoking
    the read callbacks once. A return code not equal to zero indicates an error.

- **-P** _&lt;pid-file>_

    Specify an alternative pid file. This overwrites any settings in the config
    file. This is thought for init-scripts that require the PID-file in a certain
    directory to work correctly. For everyday-usage use the **PIDFile**
    config-option.

- **-B**

    If set, collectd will _not_ try to create its base directory. If the base
    directory does not exist, it will exit rather than trying to create the
    directory.

- **-f**

    Don't fork to the background. _collectd_ will also **not** close standard file
    descriptors, detach from the session nor write a pid file. This is mainly
    thought for 'supervising' init replacements such as _runit_. If using
    _upstart_ or _systemd_ though, starting with version 5.5.0 _collectd_ is
    able to notify these two init replacements, and **does** require forking to the
    background for process supervision. The `contrib/` directory has sample
    _upstart_ and _systemd_ configuration files.

- **-h**

    Output usage information and exit.

# PLUGINS

As noted above, the real power of collectd lies within its plugins. A
(hopefully complete) list of plugins and short descriptions can be found in the
`README` file that is distributed with the sourcecode. If you're using a
package it's a good bet to search somewhere near `/usr/share/doc/collectd`.

There are two big groups of plugins, **input** and **output** plugins:

- Input plugins are queried periodically. They somehow acquire the current value
of whatever they where designed to work with and submit these values back to
the daemon, i. e. they "dispatch" the values. As an example, the `cpu plugin`
reads the current cpu-counters of time spent in the various modes (user,
system, nice, ...) and dispatches these counters to the daemon.
- Output plugins get the dispatched values from the daemon and does something
with them. Common applications are writing to RRD-files, CSV-files or sending
the data over a network link to a remote box.

Of course not all plugins fit neatly into one of the two above categories. The
`network plugin`, for example, is able to send (i. e. "write") **and**
receive (i. e. "dispatch") values. Also, it opens a socket upon
initialization and dispatches the values when it receives them and isn't
triggered at the same time the input plugins are being read. You can think of
the network receive part as working asynchronous if it helps.

In addition to the above, there are "logging plugins". Right now those are the
`logfile plugin` and the `syslog plugin`. With these plugins collectd can
provide information about issues and significant situations to the user.
Several loglevels let you suppress uninteresting messages.

Starting with version `4.3.0` collectd has support for **monitoring**. This is
done by checking thresholds defined by the user. If a value is out of range, a
notification will be dispatched to "notification plugins". See
[collectd.conf(5)](./collectd.conf.md) for more detailed information about threshold checking.

Please note that some plugins, that provide other means of communicating with
the daemon, have manpages of their own to describe their functionality in more
detail. In particular those are [collectd-email(5)](./collectd-email.md), [collectd-exec(5)](./collectd-exec.md),
[collectd-perl(5)](./collectd-perl.md), [collectd-snmp(5)](./collectd-snmp.md), and [collectd-unixsock(5)](./collectd-unixsock.md)

# SIGNALS

**collectd** accepts the following signals:

- **SIGINT**, **SIGTERM**

    These signals cause **collectd** to shut down all plugins and terminate.

- **SIGUSR1**

    This signal causes **collectd** to signal all plugins to flush data from
    internal caches. E. g. the `rrdtool plugin` will write all pending data
    to the RRD files. This is the same as using the `FLUSH -1` command of the
    `unixsock plugin`.

# SEE ALSO

[collectd.conf(5)](./collectd.conf.md),
[collectd-email(5)](./collectd-email.md),
[collectd-exec(5)](./collectd-exec.md),
[collectd-perl(5)](./collectd-perl.md),
[collectd-snmp(5)](./collectd-snmp.md),
[collectd-unixsock(5)](./collectd-unixsock.md),
[types.db(5)]./(./types.db.md),
[http://collectd.org/](http://collectd.org/)

# AUTHOR

Florian Forster <octo@collectd.org>
