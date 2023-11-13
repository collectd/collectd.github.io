# NAME

collectd-exec - Documentation of collectd's `exec plugin`

# SYNOPSIS

    # See collectd.conf(5)
    LoadPlugin exec
    # ...
    <Plugin exec>
      Exec "myuser:mygroup" "myprog"
      Exec "otheruser" "/path/to/another/binary" "arg0" "arg1"
      NotificationExec "user" "/usr/lib/collectd/exec/handle_notification"
    </Plugin>

# DESCRIPTION

The `exec plugin` forks off an executable either to receive values or to
dispatch notifications to the outside world. The syntax of the configuration is
explained in [collectd.conf(5)](http://man.he.net/man5/collectd.conf) but summarized in the above synopsis.

If you want/need better performance or more functionality you should take a
long look at the `perl plugin`, [collectd-perl(5)](http://man.he.net/man5/collectd-perl).

# EXECUTABLE TYPES

There are currently two types of executables that can be executed by the
`exec plugin`:

- `Exec`

    These programs are forked and values that it writes to `STDOUT` are read back.
    The executable is forked in a fashion similar to [init](https://metacpan.org/pod/init): It is forked once and
    not again until it exits. If it exited, it will be forked again after at most
    _Interval_ seconds. It is perfectly legal for the executable to run for a long
    time and continuously write values to `STDOUT`.

    See ["EXEC DATA FORMAT"](#exec-data-format) below for a description of the output format expected
    from these programs.

    **Warning:** If the executable only writes one value and then exits it will be
    executed every _Interval_ seconds. If _Interval_ is short (the default is 10
    seconds) this may result in serious system load.

- `NotificationExec`

    The program is forked once for each notification that is handled by the daemon.
    The notification is passed to the program on `STDIN` in a fashion similar to
    HTTP-headers. In contrast to programs specified with `Exec` the execution of
    this program is not serialized, so that several instances of this program may
    run at once if multiple notifications are received.

    See ["NOTIFICATION DATA FORMAT"](#notification-data-format) below for a description of the data passed to
    these programs.

# EXEC DATA FORMAT

The forked executable is expected to print values to `STDOUT`. The expected
format is as follows:

- Comments

    Each line beginning with a `#` (hash mark) is ignored.

- **PUTVAL** _Identifier_ \[_OptionList_\] _Valuelist_

    Submits one or more values (identified by _Identifier_, see below) to the
    daemon which will dispatch it to all its write-plugins.

    An _Identifier_ is of the form
    `_host_**/**_plugin_**-**_instance_**/**_type_**-**_instance_` with both
    _instance_-parts being optional. If they're omitted the hyphen must be
    omitted, too. _plugin_ and each _instance_-part may be chosen freely as long
    as the tuple (plugin, plugin instance, type instance) uniquely identifies the
    plugin within collectd. _type_ identifies the type and number of values
    (i. e. data-set) passed to collectd. A large list of predefined
    data-sets is available in the **types.db** file. See [types.db(5)](http://man.he.net/man5/types.db) for a
    description of the format of this file.

    The _OptionList_ is an optional list of _Options_, where each option is a
    key-value-pair. A list of currently understood options can be found below, all
    other options will be ignored. Values that contain spaces must be quoted with
    double quotes.

    _Valuelist_ is a colon-separated list of the time and the values, each either
    an integer if the data-source is a counter, or a double if the data-source is
    of type "gauge". You can submit an undefined gauge-value by using **U**. When
    submitting **U** to a counter the behavior is undefined. The time is given as
    epoch (i. e. standard UNIX time) or **N** to use the current time.

    You can mix options and values, but the order is important: Options only
    effect following values, so specifying an option as last field is allowed, but
    useless. Also, an option applies to **all** following values, so you don't need
    to re-set an option over and over again.

    The currently defined **Options** are:

    - **interval=**_seconds_

        Gives the interval in which the data identified by _Identifier_ is being
        collected.

    - meta:**key**=_value_

        Add meta data with the key **key** and the value _value_.

    Please note that this is the same format as used in the **unixsock plugin**, see
    [collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock). There's also a bit more information on identifiers in
    case you're confused.

    Since examples usually let one understand a lot better, here are some:

        PUTVAL leeloo/cpu-0/cpu-idle N:2299366
        PUTVAL alice/interface/if_octets-eth0 interval=10 1180647081:421465:479194

- **PUTNOTIF** \[_OptionList_\] **message=**_Message_

    Submits a notification to the daemon which will then dispatch it to all plugins
    which have registered for receiving notifications. 

    The **PUTNOTIF** if followed by a list of options which further describe the
    notification. The **message** option is special in that it will consume the rest
    of the line as its value. The **message**, **severity**, and **time** options are
    mandatory.

    Valid options are:

    - **message=**_Message_ (**REQUIRED**)

        Sets the message of the notification. This is the message that will be made
        accessible to the user, so it should contain some useful information. As with
        all options: If the message includes spaces, it must be quoted with double
        quotes. This option is mandatory.

    - **severity=failure**|**warning**|**okay** (**REQUIRED**)

        Sets the severity of the notification. This option is mandatory.

    - **time=**_Time_ (**REQUIRED**)

        Sets the time of the notification. The time is given as "epoch", i. e. as
        seconds since January 1st, 1970, 00:00:00. This option is mandatory.

    - **host=**_Hostname_
    - **plugin=**_Plugin_
    - **plugin\_instance=**_Plugin-Instance_
    - **type=**_Type_
    - **type\_instance=**_Type-Instance_

        These "associative" options establish a relation between this notification and
        collected performance data. This connection is purely informal, i. e. the
        daemon itself doesn't do anything with this information. However, websites or
        GUIs may use this information to place notifications near the affected graph or
        table. All the options are optional, but **plugin\_instance** without **plugin**
        or **type\_instance** without **type** doesn't make much sense and should be
        avoided.

    - **type:key=**_value_

        Sets user defined meta information. The **type** key is a single character
        defining the type of the meta information.

        The current supported types are:

        - **s** A string passed as-is.

Please note that this is the same format as used in the **unixsock plugin**, see
[collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock).

When collectd exits it sends a **SIGTERM** to all still running
child-processes upon which they have to quit.

# NOTIFICATION DATA FORMAT

The notification executables receive values rather than providing them. In
fact, after the program is started `STDOUT` is connected to `/dev/null`.

The data is passed to the executables over `STDIN` in a format very similar to
HTTP: At first there is a "header" with one line per field. Every line consists
of a field name, ended by a colon, and the associated value until end-of-line.
The "header" is ended by two newlines immediately following another,
i.e. an empty line. The rest, basically the "body", is the message of the
notification.

The following is an example notification passed to a program:

    Severity: FAILURE
    Time: 1200928930.515
    Host: myhost.mydomain.org
    \n
    This is a test notification to demonstrate the format

The following header files are currently used. Please note, however, that you
should ignore unknown header files to be as forward-compatible as possible.

- **Severity**

    Severity of the notification. May either be **FAILURE**, **WARNING**, or **OKAY**.

- **Time**

    The time in epoch, i.e. as seconds since 1970-01-01 00:00:00 UTC. The value
    currently has millisecond precision (i.e. three decimal places), but scripts
    should accept arbitrary numbers of decimal places, including no decimal places.

- **Host**
- **Plugin**
- **PluginInstance**
- **Type**
- **TypeInstance**

    Identification of the performance data this notification is associated with.
    All of these fields are optional because notifications do not **need** to be
    associated with a certain value.

# ENVIRONMENT

The following environment variables are set by the plugin before calling
_exec_:

- COLLECTD\_INTERVAL

    Value of the global interval setting.

- COLLECTD\_HOSTNAME

    Hostname used by _collectd_ to dispatch local values.

# USING NAGIOS PLUGINS

Though the interface is far from perfect, there are tons of plugins for Nagios.
You can use these plugins with collectd by using a simple transition layer,
`exec-nagios.px`, which is shipped with the collectd distribution in the
`contrib/` directory. It is a simple Perl script that comes with embedded
documentation. To see it, run the following command:

    perldoc exec-nagios.px

This script expects a configuration file, `exec-nagios.conf`. You can find an
example in the `contrib/` directory, too.

Even a simple mechanism to submit "performance data" to collectd is
implemented. If you need a more sophisticated setup, please rewrite the plugin
to make use of collectd's more powerful interface.

# CAVEATS

- The user, the binary is executed as, may not have root privileges, i. e.
must have an UID that is non-zero. This is for your own good.
- Early versions of the plugin did not use a command but treated all lines as if
they were arguments to the _PUTVAL_ command. When the _PUTNOTIF_ command was
implemented, this behavior was kept for lines which start with an unknown
command for backwards compatibility. This compatibility code has been removed
in _collectd 5_.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[collectd-perl(5)](http://man.he.net/man5/collectd-perl),
[collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock),
[fork(2)](http://man.he.net/man2/fork), [exec(3)](http://man.he.net/man3/exec)

# AUTHOR

Florian Forster <octo@collectd.org>
