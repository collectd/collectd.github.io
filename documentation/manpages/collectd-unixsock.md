# NAME

collectd-unixsock - Documentation of collectd's `unixsock plugin`

# SYNOPSIS

    # See collectd.conf(5)
    LoadPlugin unixsock
    # ...
    <Plugin unixsock>
      SocketFile "/path/to/socket"
      SocketGroup "collectd"
      SocketPerms "0770"
      DeleteSocket false
    </Plugin>

# DESCRIPTION

The `unixsock plugin` opens an UNIX-socket over which one can interact with
the daemon. This can be used to use the values collected by collectd in other
applications, such as monitoring solutions, or submit externally collected
values to collectd.

For example, this plugin is used by [collectd-nagios(1)](http://man.he.net/man1/collectd-nagios) to check if some
value is in a certain range and exit with a Nagios-compatible exit code.

# COMMANDS

Upon start the `unixsock plugin` opens a UNIX-socket and waits for
connections. Once a connection is established the client can send commands to
the daemon which it will answer, if it understand them.

In general the plugin answers with a status line of the following form:

_Status_ _Message_

If _Status_ is greater than or equal to zero the message indicates success,
if _Status_ is less than zero the message indicates failure. _Message_ is a
human-readable string that further describes the return value.

On success, _Status_ furthermore indicates the number of subsequent lines of
output (not including the status line). Each such lines usually contains a
single return value. See the description of each command for details.

The following commands are implemented:

- **GETVAL** _Identifier_

    If the value identified by _Identifier_ (see below) is found the complete
    value-list is returned. The response is a list of name-value-pairs, each pair
    on its own line (the number of lines is indicated by the status line - see
    above). Each name-value-pair is of the form _name_**=**_value_.
    Counter-values are converted to a rate, e. g. bytes per second.
    Undefined values are returned as **NaN**.

    Example:
      -> | GETVAL myhost/cpu-0/cpu-user
      <- | 1 Value found
      <- | value=1.260000e+00

- **LISTVAL**

    Returns a list of the values available in the value cache together with the
    time of the last update, so that querying applications can issue a **GETVAL**
    command for the values that have changed. Each return value consists of the
    update time as an epoch value and the identifier, separated by a space. The
    update time is the time of the last value, as provided by the collecting
    instance and may be very different from the time the server considers to be
    "now".

    Example:
      -> | LISTVAL
      <- | 69 Values found
      <- | 1182204284 myhost/cpu-0/cpu-idle
      <- | 1182204284 myhost/cpu-0/cpu-nice
      <- | 1182204284 myhost/cpu-0/cpu-system
      <- | 1182204284 myhost/cpu-0/cpu-user
      ...

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
    data-sets is available in the **types.db** file.

    The _OptionList_ is an optional list of _Options_, where each option is a
    key-value-pair. A list of currently understood options can be found below, all
    other options will be ignored. Values that contain spaces must be quoted with
    double quotes.

    _Valuelist_ is a colon-separated list of the time and the values, each either
    an integer if the data-source is a counter, or a double if the data-source is
    of type "gauge". You can submit an undefined gauge-value by using **U**. When
    submitting **U** to a counter the behavior is undefined. The time is given as
    epoch (i. e. standard UNIX time).

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

    Please note that this is the same format as used in the **exec plugin**, see
    [collectd-exec(5)](http://man.he.net/man5/collectd-exec).

    Example:
      -> | PUTVAL testhost/interface/if\_octets-test0 interval=10 1179574444:123:456
      <- | 0 Success

- **PUTNOTIF** \[_OptionList_\] **message=**_Message_

    Submits a notification to the daemon which will then dispatch it to all plugins
    which have registered for receiving notifications. 

    The **PUTNOTIF** command is followed by a list of options which further describe
    the notification. The **message** option is special in that it will consume the
    rest of the line as its value. The **message**, **severity**, and **time** options
    are mandatory.

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

    Please note that this is the same format as used in the **exec plugin**, see
    [collectd-exec(5)](http://man.he.net/man5/collectd-exec).

    Example:
      -> | PUTNOTIF type=temperature severity=warning time=1201094702 message=The roof is on fire!
      <- | 0 Success

- **FLUSH** \[**timeout=**_Timeout_\] \[**plugin=**_Plugin_ \[...\]\] \[**identifier=**_Ident_ \[...\]\]

    Flushes all cached data older than _Timeout_ seconds. If no timeout has been
    specified, it defaults to -1 which causes all data to be flushed.

    If the **plugin** option has been specified, only the _Plugin_ plugin will be
    flushed. You can have multiple **plugin** options to flush multiple plugins in
    one go. If the **plugin** option is not given all plugins providing a flush
    callback will be flushed.

    If the **identifier** option is given only the specified values will be flushed.
    This is meant to be used by graphing or displaying frontends which want to have
    the latest values for a specific graph. Again, you can specify the
    **identifier** option multiple times to flush several values. If this option is
    not specified at all, all values will be flushed.

    Example:
      -> | FLUSH plugin=rrdtool identifier=localhost/df/df-root identifier=localhost/df/df-var
      <- | 0 Done: 2 successful, 0 errors

## Identifiers

Value or value-lists are identified in a uniform fashion:

_Hostname_/_Plugin_/_Type_

Where _Plugin_ and _Type_ are both either of type "_Name_" or
"_Name_-_Instance_". If the identifier includes spaces, it must be quoted
using double quotes. This sounds more complicated than it is, so here are
some examples:

    myhost/cpu-0/cpu-user
    myhost/load/load
    myhost/memory/memory-used
    myhost/disk-sda/disk_octets
    "myups/snmp/temperature-Outlet 1"

# ABSTRACTION LAYER

**collectd** ships the Perl-Module [Collectd::Unixsock](https://metacpan.org/pod/Collectd::Unixsock) which
provides an abstraction layer over the actual socket connection. It can be
found in the directory `bindings/perl/` in the source distribution or
(usually) somewhere near `/usr/share/perl5/` if you're using a package. If
you want to use Perl to communicate with the daemon, you're encouraged to use
and expand this module.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[collectd-nagios(1)](http://man.he.net/man1/collectd-nagios),
[unix(7)](http://man.he.net/man7/unix)

# AUTHOR

Florian Forster <octo@collectd.org>
