# NAME

collectdctl - Control interface for collectd

# SYNOPSIS

collectdctl _\[options\]_ _&lt;command>_ _\[command options\]_

# DESCRIPTION

collectdctl provides a control interface for collectd, which may be used to
interact with the daemon using the `unixsock plugin`.

# OPTIONS

collectdctl supports the following options:

- **-s** _socket_

    Path to the UNIX socket opened by collectd's `unixsock plugin`.
    Default: /var/run/collectd-unixsock

- **-h**

    Display usage information and exit.

# AVAILABLE COMMANDS

The following commands are supported:

- **getval** _&lt;identifier>_

    Query the latest collected value identified by the specified
    _&lt;identifier>_ (see below). The value-list associated with that
    data-set is returned as a list of key-value-pairs, each on its own line. Keys
    and values are separated by the equal sign (`=`).

- **flush** \[**timeout=**_&lt;seconds>_\] \[**plugin=**_&lt;name>_\]
\[**identifier=**_&lt;id>_\]

    Flush the daemon. This is useful, e. g., to make sure that the latest
    values have been written to the respective RRD file before graphing them or
    copying them to somewhere else.

    The following options are supported by the flush command:

    - **timeout=**_&lt;seconds>_

        Flush values older than the specified timeout (in seconds) only.

    - **plugin=**_&lt;name>_

        Flush the specified plugin only. I. e., data cached by the specified
        plugin is written to disk (or network or whatever), if the plugin supports
        that operation.

        Example: **rrdtool**.

    - **identifier=**_&lt;id>_

        If this option is present, only the data specified by the specified identifier
        (see below) will be flushed. Note that this option is not supported by all
        plugins (e. g., the `network` plugin does not support this).

    The **plugin** and **identifier** options may be specified more than once. In
    that case, all combinations of specified plugins and identifiers will be
    flushed only.

- **listval**

    Returns a list of all values (by their identifier) available to the
    `unixsock` plugin. Each value is printed on its own line. I. e., this
    command returns a list of valid identifiers that may be used with the other
    commands.

- **putval** _&lt;identifier>_ \[**interval=**_&lt;seconds>_\]
_&lt;value-list(s)>_

    Submit one or more values (identified by _&lt;identifier>_, see below)
    to the daemon which will then dispatch them to the write plugins. **interval**
    specifies the interval (in seconds) used to collect the values following that
    option. It defaults to the default of the running collectd instance receiving
    the data. Multiple _&lt;value-list(s)>_ (see below) may be specified.
    Each of them will be submitted to the daemon. The values have to match the
    data-set definition specified by the type as given in the identifier (see
    [types.db(5)](http://man.he.net/man5/types.db) for details).

# IDENTIFIERS

An identifier has the following format:

\[_hostname_/\]_plugin_\[-_plugin\_instance_\]/_type_\[-_type\_instance_\]

Examples:
 somehost/cpu-0/cpu-idle
 uptime/uptime
 otherhost/memory/memory-used

Hostname defaults to the local (non-fully qualified) hostname if omitted. No
error is returned if the specified identifier does not exist (this is a
limitation in the `libcollectdclient` library).

# VALUE-LIST

A value list describes one data-set as handled by collectd. It is a colon
(`:`) separated list of the time and the values. Each value is either given
as an integer if the data-type is a counter, or as a double if the data-type
is a gauge value. A literal `U` is interpreted as an undefined gauge value.
The number of values and the data-types have to match the type specified in
the identifier (see [types.db(5)](http://man.he.net/man5/types.db) for details). The time is specified as
epoch (i. e., standard UNIX time) or as a literal `N` which will be
interpreted as now.

# EXAMPLES

- `collectdctl flush plugin=rrdtool identifier=somehost/cpu-0/cpu-wait`

    Flushes all CPU wait RRD values of the first CPU of the local host.
    I. e., writes all pending RRD updates of that data-source to disk.

- `` for ident in `collectdctl listval | grep users/users`; do
      collectdctl getval $ident;
  done ``

    Query the latest number of logged in users on all hosts known to the local
    collectd instance.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock),
[types.db(5)](http://man.he.net/man5/types.db)

# AUTHOR

collectd has been written by Florian Forster &lt;octo at collectd.org>
and many contributors (see \`AUTHORS').

collectdctl has been written by
Håkon J Dugstad Johnsen &lt;hakon-dugstad.johnsen at telenor.com>
and Sebastian Harl &lt;sh at tokkee.org>.
