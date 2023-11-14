---
title: collectdmon(1)
---
# NAME

collectdmon - Monitoring daemon for collectd

# SYNOPSIS

collectdmon _\[options\]_ \[-- _collectd options_\]

# DESCRIPTION

collectdmon is a small "wrapper" daemon which starts and monitors the collectd
daemon. If collectd terminates it will automatically be restarted, unless
collectdmon was told to shut it down.

# OPTIONS

collectdmon supports the following options:

- **-c** _&lt;path>_

    Specify the pathname of the collectd binary. You may either specify an
    absolute path or simply the name of the binary in which case the **PATH**
    variable will be searched for it. The default is "**collectd**".

- **-P** _&lt;pid-file>_

    Specify the pid file. The default is "_/var/run/collectdmon.pid_".

- **-h**

    Output usage information and exit.

- _collectd options_

    Specify options that are passed on to collectd. If it is not already included,
    **-f** will be added to these options. See [collectd(1)](./collectd.md).

# SIGNALS

**collectdmon** accepts the following signals:

- **SIGINT**, **SIGTERM**

    These signals cause **collectdmon** to terminate **collectd**, wait for its
    termination and then shut down.

- **SIGHUP**

    This signal causes **collectdmon** to terminate **collectd**, wait for its
    termination and then restart it.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md),
[http://collectd.org/](http://collectd.org/)

# AUTHOR

collectd has been written by Florian Forster &lt;octo at collectd.org>
and many contributors (see \`AUTHORS').

collectdmon has been written by Sebastian Harl <sh@tokkee.org>.
