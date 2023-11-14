# NAME

collectd.conf - Configuration for the system statistics collection daemon **collectd**

# SYNOPSIS

    BaseDir "/var/lib/collectd"
    PIDFile "/run/collectd.pid"
    Interval 10.0

    LoadPlugin cpu
    LoadPlugin load

    <LoadPlugin df>
      Interval 3600
    </LoadPlugin>
    <Plugin df>
      ValuesPercentage true
    </Plugin>

    LoadPlugin ping
    <Plugin ping>
      Host "example.org"
      Host "provider.net"
    </Plugin>

# DESCRIPTION

This config file controls how the system statistics collection daemon
**collectd** behaves. The most significant option is **LoadPlugin**, which
controls which plugins to load. These plugins ultimately define collectd's
behavior. If the **AutoLoadPlugin** option has been enabled, the explicit
**LoadPlugin** lines may be omitted for all plugins with a configuration block,
i.e. a `<Plugin ...>` block.

The syntax of this config file is similar to the config file of the famous
_Apache_ webserver. Each line contains either an option (a key and a list of
one or more values) or a section-start or -end. Empty lines and everything
after a non-quoted hash-symbol (`#`) are ignored. _Keys_ are unquoted
strings, consisting only of alphanumeric characters and the underscore (`_`)
character. Keys are handled case insensitive by _collectd_ itself and all
plugins included with it. _Values_ can either be an _unquoted string_, a
_quoted string_ (enclosed in double-quotes) a _number_ or a _boolean_
expression. _Unquoted strings_ consist of only alphanumeric characters and
underscores (`_`) and do not need to be quoted. _Quoted strings_ are
enclosed in double quotes (`"`). You can use the backslash character (`\`)
to include double quotes as part of the string. _Numbers_ can be specified in
decimal and floating point format (using a dot `.` as decimal separator),
hexadecimal when using the `0x` prefix and octal with a leading zero (`0`).
_Boolean_ values are either **true** or **false**.

Lines may be wrapped by using `\` as the last character before the newline.
This allows long lines to be split into multiple lines. Quoted strings may be
wrapped as well. However, those are treated special in that whitespace at the
beginning of the following lines will be ignored, which allows for nicely
indenting the wrapped lines.

The configuration is read and processed in order, i.e. from top to bottom. So
the plugins are loaded in the order listed in this config file. It is a good
idea to load any logging plugins first in order to catch messages from plugins
during configuration. Also, unless **AutoLoadPlugin** is enabled, the
**LoadPlugin** option _must_ occur _before_ the appropriate
`<**Plugin** ...>` block.

# GLOBAL OPTIONS

- **BaseDir** _Directory_

    Sets the base directory. This is the directory beneath which all RRD-files are
    created. Possibly more subdirectories are created. This is also the working
    directory for the daemon.

- **LoadPlugin** _Plugin_

    Loads the plugin _Plugin_. This is required to load plugins, unless the
    **AutoLoadPlugin** option is enabled (see below). Without any loaded plugins,
    _collectd_ will be mostly useless.

    Only the first **LoadPlugin** statement or block for a given plugin name has any
    effect. This is useful when you want to split up the configuration into smaller
    files and want each file to be "self contained", i.e. it contains a **Plugin**
    block _and_ the appropriate **LoadPlugin** statement. The downside is that if
    you have multiple conflicting **LoadPlugin** blocks, e.g. when they specify
    different intervals, only one of them (the first one encountered) will take
    effect and all others will be silently ignored.

    **LoadPlugin** may either be a simple configuration _statement_ or a _block_
    with additional options, affecting the behavior of **LoadPlugin**. A simple
    statement looks like this:

        LoadPlugin "cpu"

    Options inside a **LoadPlugin** block can override default settings and
    influence the way plugins are loaded, e.g.:

        <LoadPlugin perl>
          Interval 60
        </LoadPlugin>

    The following options are valid inside **LoadPlugin** blocks:

    - **Globals** **true|false**

        If enabled, collectd will export all global symbols of the plugin (and of all
        libraries loaded as dependencies of the plugin) and, thus, makes those symbols
        available for resolving unresolved symbols in subsequently loaded plugins if
        that is supported by your system.

        This is useful (or possibly even required), e.g., when loading a plugin that
        embeds some scripting language into the daemon (e.g. the _Perl_ and
        _Python plugins_). Scripting languages usually provide means to load
        extensions written in C. Those extensions require symbols provided by the
        interpreter, which is loaded as a dependency of the respective collectd plugin.
        See the documentation of those plugins (e.g., [collectd-perl(5)](http://man.he.net/man5/collectd-perl) or
        [collectd-python(5)](http://man.he.net/man5/collectd-python)) for details.

        By default, this is disabled. As a special exception, if the plugin name is
        either `perl` or `python`, the default is changed to enabled in order to keep
        the average user from ever having to deal with this low level linking stuff.

    - **Interval** _Seconds_

        Sets a plugin-specific interval for collecting metrics. This overrides the
        global **Interval** setting. If a plugin provides its own support for specifying
        an interval, that setting will take precedence.

    - **FlushInterval** _Seconds_

        Specifies the interval, in seconds, to call the flush callback if it's
        defined in this plugin. By default, this is disabled.

    - **FlushTimeout** _Seconds_

        Specifies the value of the timeout argument of the flush callback.

- **AutoLoadPlugin** **false**|**true**

    When set to **false** (the default), each plugin needs to be loaded explicitly,
    using the **LoadPlugin** statement documented above. If a
    **<Plugin ...>** block is encountered and no configuration
    handling callback for this plugin has been registered, a warning is logged and
    the block is ignored.

    When set to **true**, explicit **LoadPlugin** statements are not required. Each
    **<Plugin ...>** block acts as if it was immediately preceded by a
    **LoadPlugin** statement. **LoadPlugin** statements are still required for
    plugins that don't provide any configuration, e.g. the _Load plugin_.

- **CollectInternalStats** **false**|**true**

    When set to **true**, various statistics about the _collectd_ daemon will be
    collected, with "collectd" as the _plugin name_. Defaults to **false**.

    The following metrics are reported:

    - `collectd-write_queue/queue_length`

        The number of metrics currently in the write queue. You can limit the queue
        length with the **WriteQueueLimitLow** and **WriteQueueLimitHigh** options.

    - `collectd-write_queue/derive-dropped`

        The number of metrics dropped due to a queue length limitation.
        If this value is non-zero, your system can't handle all incoming metrics and
        protects itself against overload by dropping metrics.

    - `collectd-cache/cache_size`

        The number of elements in the metric cache (the cache you can interact with
        using [collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock)).

- **Include** _Path_ \[_pattern_\]

    If _Path_ points to a file, includes that file. If _Path_ points to a
    directory, recursively includes all files within that directory and its
    subdirectories. If the `wordexp` function is available on your system,
    shell-like wildcards are expanded before files are included. This means you can
    use statements like the following:

        Include "/etc/collectd.d/*.conf"

    Starting with version 5.3, this may also be a block in which further options
    affecting the behavior of **Include** may be specified. The following option is
    currently allowed:

        <Include "/etc/collectd.d">
          Filter "*.conf"
        </Include>

    - **Filter** _pattern_

        If the `fnmatch` function is available on your system, a shell-like wildcard
        _pattern_ may be specified to filter which files to include. This may be used
        in combination with recursively including a directory to easily be able to
        arbitrarily mix configuration files and other documents (e.g. README files).
        The given example is similar to the first example above but includes all files
        matching `*.conf` in any subdirectory of `/etc/collectd.d`.

    If more than one file is included by a single **Include** option, the files
    will be included in lexicographical order (as defined by the `strcmp`
    function). Thus, you can e. g. use numbered prefixes to specify the
    order in which the files are loaded.

    To prevent loops and shooting yourself in the foot in interesting ways the
    nesting is limited to a depth of 8 levels, which should be sufficient for
    most uses. Since symlinks are followed it is still possible to crash the daemon
    by looping symlinks. In our opinion significant stupidity should result in an
    appropriate amount of pain.

    It is no problem to have a block like `<Plugin foo>` in more than one
    file, but you cannot include files from within blocks.

- **PIDFile** _File_

    Sets where to write the PID file to. This file is overwritten when it exists
    and deleted when the program is stopped. Some init-scripts might override this
    setting using the **-P** command-line option.

- **PluginDir** _Directory_

    Path to the plugins (shared objects) of collectd.

- **TypesDB** _File_ \[_File_ ...\]

    Set one or more files that contain the data-set descriptions. See
    [types.db(5)](http://man.he.net/man5/types.db) for a description of the format of this file.

    If this option is not specified, a default file is read. If you need to define
    custom types in addition to the types defined in the default file, you need to
    explicitly load both. In other words, if the **TypesDB** option is encountered
    the default behavior is disabled and if you need the default types you have to
    also explicitly load them.

- **Interval** _Seconds_

    Configures the interval in which to query the read plugins. Obviously smaller
    values lead to a higher system load produced by collectd, while higher values
    lead to more coarse statistics.

    **Warning:** You should set this once and then never touch it again. If you do,
    _you will have to delete all your RRD files_ or know some serious RRDtool
    magic! (Assuming you're using the _RRDtool_ or _RRDCacheD_ plugin.)

- **MaxReadInterval** _Seconds_

    A read plugin doubles the interval between queries after each failed attempt
    to get data.

    This options limits the maximum value of the interval. The default value is
    **86400**.

- **Timeout** _Iterations_

    Consider a value list "missing" when no update has been read or received for
    _Iterations_ iterations. By default, _collectd_ considers a value list
    missing when no update has been received for twice the update interval. Since
    this setting uses iterations, the maximum allowed time without update depends
    on the _Interval_ information contained in each value list. This is used in
    the _Threshold_ configuration to dispatch notifications about missing values,
    see [collectd-threshold(5)](http://man.he.net/man5/collectd-threshold) for details.

- **ReadThreads** _Num_

    Number of threads to start for reading plugins. The default value is **5**, but
    you may want to increase this if you have more than five plugins that take a
    long time to read. Mostly those are plugins that do network-IO. Setting this to
    a value higher than the number of registered read callbacks is not recommended.

- **WriteThreads** _Num_

    Number of threads to start for dispatching value lists to write plugins. The
    default value is **5**, but you may want to increase this if you have more than
    five plugins that may take relatively long to write to.

- **WriteQueueLimitHigh** _HighNum_
- **WriteQueueLimitLow** _LowNum_

    Metrics are read by the _read threads_ and then put into a queue to be handled
    by the _write threads_. If one of the _write plugins_ is slow (e.g. network
    timeouts, I/O saturation of the disk) this queue will grow. In order to avoid
    running into memory issues in such a case, you can limit the size of this
    queue.

    By default, there is no limit and memory may grow indefinitely. This is most
    likely not an issue for clients, i.e. instances that only handle the local
    metrics. For servers it is recommended to set this to a non-zero value, though.

    You can set the limits using **WriteQueueLimitHigh** and **WriteQueueLimitLow**.
    Each of them takes a numerical argument which is the number of metrics in the
    queue. If there are _HighNum_ metrics in the queue, any new metrics _will_ be
    dropped. If there are less than _LowNum_ metrics in the queue, all new metrics
    _will_ be enqueued. If the number of metrics currently in the queue is between
    _LowNum_ and _HighNum_, the metric is dropped with a probability that is
    proportional to the number of metrics in the queue (i.e. it increases linearly
    until it reaches 100%.)

    If **WriteQueueLimitHigh** is set to non-zero and **WriteQueueLimitLow** is
    unset, the latter will default to half of **WriteQueueLimitHigh**.

    If you do not want to randomly drop values when the queue size is between
    _LowNum_ and _HighNum_, set **WriteQueueLimitHigh** and **WriteQueueLimitLow**
    to the same value.

    Enabling the **CollectInternalStats** option is of great help to figure out the
    values to set **WriteQueueLimitHigh** and **WriteQueueLimitLow** to.

- **Hostname** _Name_

    Sets the hostname that identifies a host. If you omit this setting, the
    hostname will be determined using the [gethostname(2)](http://man.he.net/man2/gethostname) system call.

- **FQDNLookup** **true|false**

    If **Hostname** is determined automatically this setting controls whether or not
    the daemon should try to figure out the "fully qualified domain name", FQDN.
    This is achieved by using `getaddrinfo()` to look up full web address of the
    first network interface that has one. This option is enabled by default.

- **PreCacheChain** _ChainName_
- **PostCacheChain** _ChainName_

    Configure the name of the "pre-cache chain" and the "post-cache chain". Please
    see ["FILTER CONFIGURATION"](#filter-configuration) below on information on chains and how these
    setting change the daemon's behavior.

# PLUGIN OPTIONS

Some plugins may register own options. These options must be enclosed in a
`Plugin`-Section. Which options exist depends on the plugin used. Some plugins
require external configuration, too. The `apache plugin`, for example,
required `mod_status` to be configured in the webserver you're going to
collect data from. These plugins are listed below as well, even if they don't
require any configuration within collectd's configuration file.

A list of all plugins and a short summary for each plugin can be found in the
`README` file shipped with the sourcecode and hopefully binary packets as
well.

## Plugin `aggregation`

The _Aggregation plugin_ makes it possible to aggregate several values into
one using aggregation functions such as _sum_, _average_, _min_ and _max_.
This can be put to a wide variety of uses, e.g. average and total CPU
statistics for your entire fleet.

The grouping is powerful but, as with many powerful tools, may be a bit
difficult to wrap your head around. The grouping will therefore be
demonstrated using an example: The average and sum of the CPU usage across
all CPUs of each host is to be calculated.

To select all the affected values for our example, set `Plugin cpu` and
`Type cpu`. The other values are left unspecified, meaning "all values". The
_Host_, _Plugin_, _PluginInstance_, _Type_ and _TypeInstance_ options
work as if they were specified in the `WHERE` clause of an `SELECT` SQL
statement.

    Plugin "cpu"
    Type "cpu"

Although the _Host_, _PluginInstance_ (CPU number, i.e. 0, 1, 2, ...)  and
_TypeInstance_ (idle, user, system, ...) fields are left unspecified in the
example, the intention is to have a new value for each host / type instance
pair. This is achieved by "grouping" the values using the `GroupBy` option.
It can be specified multiple times to group by more than one field.

    GroupBy "Host"
    GroupBy "TypeInstance"

We do neither specify nor group by _plugin instance_ (the CPU number), so all
metrics that differ in the CPU number only will be aggregated. Each
aggregation needs _at least one_ such field, otherwise no aggregation would
take place.

The full example configuration looks like this:

    <Plugin "aggregation">
      <Aggregation>
        Plugin "cpu"
        Type "cpu"

        GroupBy "Host"
        GroupBy "TypeInstance"

        CalculateSum true
        CalculateAverage true
      </Aggregation>
    </Plugin>

There are a couple of limitations you should be aware of:

- The _Type_ cannot be left unspecified, because it is not reasonable to add
apples to oranges. Also, the internal lookup structure won't work if you try
to group by type.
- There must be at least one unspecified, ungrouped field. Otherwise nothing
will be aggregated.

As you can see in the example above, each aggregation has its own
**Aggregation** block. You can have multiple aggregation blocks and aggregation
blocks may match the same values, i.e. one value list can update multiple
aggregations. The following options are valid inside **Aggregation** blocks:

- **Host** _Host_
- **Plugin** _Plugin_
- **PluginInstance** _PluginInstance_
- **Type** _Type_
- **TypeInstance** _TypeInstance_

    Selects the value lists to be added to this aggregation. **Type** must be a
    valid data set name, see [types.db(5)](http://man.he.net/man5/types.db) for details.

    If the string starts with and ends with a slash (`/`), the string is
    interpreted as a _regular expression_. The regex flavor used are POSIX
    extended regular expressions as described in [regex(7)](http://man.he.net/man7/regex). Example usage:

        Host "/^db[0-9]\\.example\\.com$/"

- **GroupBy** **Host**|**Plugin**|**PluginInstance**|**TypeInstance**

    Group valued by the specified field. The **GroupBy** option may be repeated to
    group by multiple fields.

- **SetHost** _Host_
- **SetPlugin** _Plugin_
- **SetPluginInstance** _PluginInstance_
- **SetTypeInstance** _TypeInstance_

    Sets the appropriate part of the identifier to the provided string.

    The _PluginInstance_ should include the placeholder `%{aggregation}` which
    will be replaced with the aggregation function, e.g. "average". Not including
    the placeholder will result in duplication warnings and/or messed up values if
    more than one aggregation function are enabled.

    The following example calculates the average usage of all "even" CPUs:

        <Plugin "aggregation">
          <Aggregation>
            Plugin "cpu"
            PluginInstance "/[0,2,4,6,8]$/"
            Type "cpu"

            SetPlugin "cpu"
            SetPluginInstance "even-%{aggregation}"

            GroupBy "Host"
            GroupBy "TypeInstance"

            CalculateAverage true
          </Aggregation>
        </Plugin>

    This will create the files:

    - foo.example.com/cpu-even-average/cpu-idle
    - foo.example.com/cpu-even-average/cpu-system
    - foo.example.com/cpu-even-average/cpu-user
    - ...

- **CalculateNum** **true**|**false**
- **CalculateSum** **true**|**false**
- **CalculateAverage** **true**|**false**
- **CalculateMinimum** **true**|**false**
- **CalculateMaximum** **true**|**false**
- **CalculateStddev** **true**|**false**

    Boolean options for enabling calculation of the number of value lists, their
    sum, average, minimum, maximum and / or standard deviation. All options
    are disabled by default.

## Plugin `amqp`

The _AMQP plugin_ can be used to communicate with other instances of
_collectd_ or third party applications using an AMQP 0.9.1 message broker.
Values are sent to or received from the broker, which handles routing,
queueing and possibly filtering out messages.

**Synopsis:**

    <Plugin "amqp">
      # Send values to an AMQP broker
      <Publish "some_name">
        Host "localhost"
        Host "fallback-amqp.example.com"
        Port "5672"
        VHost "/"
        User "guest"
        Password "guest"
        Exchange "amq.fanout"
    #   ExchangeType "fanout"
    #   RoutingKey "collectd"
    #   Persistent false
    #   ConnectionRetryDelay 0
    #   Format "command"
    #   StoreRates false
    #   TLSEnabled false
    #   TLSVerifyPeer true
    #   TLSVerifyHostName true
    #   TLSCACert "/path/to/ca.pem"
    #   TLSClientCert "/path/to/client-cert.pem"
    #   TLSClientKey "/path/to/client-key.pem"
    #   GraphitePrefix "collectd."
    #   GraphiteEscapeChar "_"
    #   GraphiteSeparateInstances false
    #   GraphiteAlwaysAppendDS false
    #   GraphitePreserveSeparator false
      </Publish>

      # Receive values from an AMQP broker
      <Subscribe "some_name">
        Host "localhost"
        Port "5672"
        VHost "/"
        User "guest"
        Password "guest"
        Exchange "amq.fanout"
    #   ExchangeType "fanout"
    #   Queue "queue_name"
    #   QueueDurable false
    #   QueueAutoDelete true
    #   RoutingKey "collectd.#"
    #   ConnectionRetryDelay 0
    #   TLSEnabled false
    #   TLSVerifyPeer true
    #   TLSVerifyHostName true
    #   TLSCACert "/path/to/ca.pem"
    #   TLSClientCert "/path/to/client-cert.pem"
    #   TLSClientKey "/path/to/client-key.pem"
      </Subscribe>
    </Plugin>

The plugin's configuration consists of a number of _Publish_ and _Subscribe_
blocks, which configure sending and receiving of values respectively. The two
blocks are very similar, so unless otherwise noted, an option can be used in
either block. The name given in the blocks starting tag is only used for
reporting messages, but may be used to support _flushing_ of certain
_Publish_ blocks in the future.

- **Host** _Host_ \[_Host_ ...\]

    Hostname or IP-address of the AMQP broker. Defaults to the default behavior of
    the underlying communications library, _rabbitmq-c_, which is "localhost".

    If multiple hosts are specified, then a random one is chosen at each
    (re)connection attempt. This is useful for failover with a clustered broker.

- **Port** _Port_

    Service name or port number on which the AMQP broker accepts connections. This
    argument must be a string, even if the numeric form is used. Defaults to
    "5672".

- **VHost** _VHost_

    Name of the _virtual host_ on the AMQP broker to use. Defaults to "/".

- **User** _User_
- **Password** _Password_

    Credentials used to authenticate to the AMQP broker. By default "guest"/"guest"
    is used.

- **Exchange** _Exchange_

    In _Publish_ blocks, this option specifies the _exchange_ to send values to.
    By default, "amq.fanout" will be used.

    In _Subscribe_ blocks this option is optional. If given, a _binding_ between
    the given exchange and the _queue_ is created, using the _routing key_ if
    configured. See the **Queue** and **RoutingKey** options below.

- **ExchangeType** _Type_

    If given, the plugin will try to create the configured _exchange_ with this
    _type_ after connecting. When in a _Subscribe_ block, the _queue_ will then
    be bound to this exchange.

- **Queue** _Queue_ (Subscribe only)

    Configures the _queue_ name to subscribe to. If no queue name was configured
    explicitly, a unique queue name will be created by the broker.

- **QueueDurable** **true**|**false** (Subscribe only)

    Defines if the _queue_ subscribed to is durable (saved to persistent storage)
    or transient (will disappear if the AMQP broker is restarted). Defaults to
    "false".

    This option should be used in conjunction with the _Persistent_ option on the
    publish side.

- **QueueAutoDelete** **true**|**false** (Subscribe only)

    Defines if the _queue_ subscribed to will be deleted once the last consumer
    unsubscribes. Defaults to "true".

- **RoutingKey** _Key_

    In _Publish_ blocks, this configures the routing key to set on all outgoing
    messages. If not given, the routing key will be computed from the _identifier_
    of the value. The host, plugin, type and the two instances are concatenated
    together using dots as the separator and all containing dots replaced with
    slashes. For example "collectd.host/example/com.cpu.0.cpu.user". This makes it
    possible to receive only specific values using a "topic" exchange.

    In _Subscribe_ blocks, configures the _routing key_ used when creating a
    _binding_ between an _exchange_ and the _queue_. The usual wildcards can be
    used to filter messages when using a "topic" exchange. If you're only
    interested in CPU statistics, you could use the routing key "collectd.\*.cpu.#"
    for example.

- **Persistent** **true**|**false** (Publish only)

    Selects the _delivery method_ to use. If set to **true**, the _persistent_
    mode will be used, i.e. delivery is guaranteed. If set to **false** (the
    default), the _transient_ delivery mode will be used, i.e. messages may be
    lost due to high load, overflowing queues or similar issues.

- **ConnectionRetryDelay** _Delay_

    When the connection to the AMQP broker is lost, defines the time in seconds to
    wait before attempting to reconnect. Defaults to 0, which implies collectd will
    attempt to reconnect at each read interval (in Subscribe mode) or each time
    values are ready for submission (in Publish mode).

- **Format** **Command**|**JSON**|**Graphite** (Publish only)

    Selects the format in which messages are sent to the broker. If set to
    **Command** (the default), values are sent as `PUTVAL` commands which are
    identical to the syntax used by the _Exec_ and _UnixSock plugins_. In this
    case, the `Content-Type` header field will be set to `text/collectd`.

    If set to **JSON**, the values are encoded in the _JavaScript Object Notation_,
    an easy and straight forward exchange format. The `Content-Type` header field
    will be set to `application/json`.

    If set to **Graphite**, values are encoded in the _Graphite_ format, which is
    "&lt;metric> &lt;value> &lt;timestamp>\\n". The `Content-Type` header field will be set to
    `text/graphite`.

    A subscribing client _should_ use the `Content-Type` header field to
    determine how to decode the values. Currently, the _AMQP plugin_ itself can
    only decode the **Command** format.

- **StoreRates** **true**|**false** (Publish only)

    Determines whether or not `COUNTER`, `DERIVE` and `ABSOLUTE` data sources
    are converted to a _rate_ (i.e. a `GAUGE` value). If set to **false** (the
    default), no conversion is performed. Otherwise the conversion is performed
    using the internal value cache.

    Please note that currently this option is only used if the **Format** option has
    been set to **JSON**.

- **GraphitePrefix** (Publish and **Format**=_Graphite_ only)

    A prefix can be added in the metric name when outputting in the _Graphite_ format.
    It's added before the _Host_ name.
    Metric name will be "&lt;prefix>&lt;host>&lt;postfix>&lt;plugin>&lt;type>&lt;name>"

- **GraphitePostfix** (Publish and **Format**=_Graphite_ only)

    A postfix can be added in the metric name when outputting in the _Graphite_ format.
    It's added after the _Host_ name.
    Metric name will be "&lt;prefix>&lt;host>&lt;postfix>&lt;plugin>&lt;type>&lt;name>"

- **GraphiteEscapeChar** (Publish and **Format**=_Graphite_ only)

    Specify a character to replace dots (.) in the host part of the metric name.
    In _Graphite_ metric name, dots are used as separators between different
    metric parts (host, plugin, type).
    Default is "\_" (_Underscore_).

- **GraphiteSeparateInstances** **true**|**false**

    If set to **true**, the plugin instance and type instance will be in their own
    path component, for example `host.cpu.0.cpu.idle`. If set to **false** (the
    default), the plugin and plugin instance (and likewise the type and type
    instance) are put into one component, for example `host.cpu-0.cpu-idle`.

- **GraphiteAlwaysAppendDS** **true**|**false**

    If set to **true**, append the name of the _Data Source_ (DS) to the "metric"
    identifier. If set to **false** (the default), this is only done when there is
    more than one DS.

- **GraphitePreserveSeparator** **false**|**true**

    If set to **false** (the default) the `.` (dot) character is replaced with
    _GraphiteEscapeChar_. Otherwise, if set to **true**, the `.` (dot) character
    is preserved, i.e. passed through.

- **TLSEnabled** **true**|**false**

    If set to **true** then connect to the broker using a TLS connection.
    If set to **false** (the default), then a plain text connection is used.

    Requires rabbitmq-c >= 0.4.

- **TLSVerifyPeer** **true**|**false**

    If set to **true** (the default) then the server certificate chain is verified.
    Setting this to **false** will skip verification (insecure).

    Requires rabbitmq-c >= 0.8.

- **TLSVerifyHostName** **true**|**false**

    If set to **true** (the default) then the server host name is verified.
    Setting this to **false** will skip verification (insecure).

    Requires rabbitmq-c >= 0.8.

- **TLSCACert** _Path_

    Path to the CA cert file in PEM format.

- **TLSClientCert** _Path_

    Path to the client certificate in PEM format.
    If this is set, then **TLSClientKey** must be set as well.

- **TLSClientKey** _Path_

    Path to the client key in PEM format.
    If this is set, then **TLSClientCert** must be set as well.

## Plugin `amqp1`

The _AMQP1 plugin_ can be used to communicate with other instances of
_collectd_ or third party applications using an AMQP 1.0 message
intermediary. Metric values or notifications are sent to the
messaging intermediary which may handle direct messaging or
queue based transfer.

**Synopsis:**

    <Plugin "amqp1">
      # Send values to an AMQP 1.0 intermediary
     <Transport "name">
       Host "localhost"
       Port "5672"
       User "guest"
       Password "guest"
       Address "collectd"
   #    RetryDelay 1
       <Instance "some_name">
           Format "command"
           PreSettle false
           Notify false
    #      StoreRates false
    #      GraphitePrefix "collectd."
    #      GraphiteEscapeChar "_"
    #      GraphiteSeparateInstances false
    #      GraphiteAlwaysAppendDS false
    #      GraphitePreserveSeparator false
       </Instance>
     </Transport>
    </Plugin>

The plugin's configuration consists of a _Transport_ that configures
communications to the AMQP 1.0 messaging bus and one or more _Instance_
corresponding to metric or event publishers to the messaging system.

The address in the _Transport_ block concatenated with the name given in the
_Instance_ block starting tag will be used as the send-to address for
communications over the messaging link.

The following options are accepted within each _Transport_ block:

- **Host** _Host_

    Hostname or IP-address of the AMQP 1.0 intermediary. Defaults to the
    default behavior of the underlying communications library,
    _libqpid-proton_, which is "localhost".

- **Port** _Port_

    Service name or port number on which the AMQP 1.0 intermediary accepts
    connections. This argument must be a string, even if the numeric form
    is used. Defaults to "5672".

- **User** _User_
- **Password** _Password_

    Credentials used to authenticate to the AMQP 1.0 intermediary. By
    default "guest"/"guest" is used.

- **Address** _Address_

    This option specifies the prefix for the send-to value in the message.
    By default, "collectd" will be used.

- **RetryDelay** _RetryDelay_

    When the AMQP1 connection is lost, defines the time in seconds to wait
    before attempting to reconnect. Defaults to 1, which implies attempt
    to reconnect at 1 second intervals.

- **SendQueueLimit** _SendQueueLimit_

    If there is no AMQP1 connection, the plugin will continue to queue
    messages to send, which could result in unbounded memory consumption. This
    parameter is used to limit the number of messages in the outbound queue to
    the specified value. The default value is 0, which disables this feature.

The following options are accepted within each _Instance_ block:

- **Format** **Command**|**JSON**|**Graphite**

    Selects the format in which messages are sent to the intermediary. If set to
    **Command** (the default), values are sent as `PUTVAL` commands which are
    identical to the syntax used by the _Exec_ and _UnixSock plugins_. In this
    case, the `Content-Type` header field will be set to `text/collectd`.

    If set to **JSON**, the values are encoded in the _JavaScript Object Notation_,
    an easy and straight forward exchange format. The `Content-Type` header field
    will be set to `application/json`.

    If set to **Graphite**, values are encoded in the _Graphite_ format, which is
    "&lt;metric> &lt;value> &lt;timestamp>\\n". The `Content-Type` header field will be set to
    `text/graphite`.

    A subscribing client _should_ use the `Content-Type` header field to
    determine how to decode the values.

- **PreSettle** **true**|**false**

    If set to **false** (the default), the plugin will wait for a message
    acknowledgement from the messaging bus before sending the next
    message. This indicates transfer of ownership to the messaging
    system. If set to **true**, the plugin will not wait for a message
    acknowledgement and the message may be dropped prior to transfer of
    ownership.

- **Notify** **true**|**false**

    If set to **false** (the default), the plugin will service the
    instance write call back as a value list. If set to **true** the
    plugin will service the instance as a write notification callback
    for alert formatting.

- **StoreRates** **true**|**false**

    Determines whether or not `COUNTER`, `DERIVE` and `ABSOLUTE` data sources
    are converted to a _rate_ (i.e. a `GAUGE` value). If set to **false** (the
    default), no conversion is performed. Otherwise the conversion is performed
    using the internal value cache.

    Please note that currently this option is only used if the **Format** option has
    been set to **JSON**.

- **GraphitePrefix**

    A prefix can be added in the metric name when outputting in the _Graphite_ format.
    It's added before the _Host_ name.
    Metric name will be "&lt;prefix>&lt;host>&lt;postfix>&lt;plugin>&lt;type>&lt;name>"

- **GraphitePostfix**

    A postfix can be added in the metric name when outputting in the _Graphite_ format.
    It's added after the _Host_ name.
    Metric name will be "&lt;prefix>&lt;host>&lt;postfix>&lt;plugin>&lt;type>&lt;name>"

- **GraphiteEscapeChar**

    Specify a character to replace dots (.) in the host part of the metric name.
    In _Graphite_ metric name, dots are used as separators between different
    metric parts (host, plugin, type).
    Default is "\_" (_Underscore_).

- **GraphiteSeparateInstances** **true**|**false**

    If set to **true**, the plugin instance and type instance will be in their own
    path component, for example `host.cpu.0.cpu.idle`. If set to **false** (the
    default), the plugin and plugin instance (and likewise the type and type
    instance) are put into one component, for example `host.cpu-0.cpu-idle`.

- **GraphiteAlwaysAppendDS** **true**|**false**

    If set to **true**, append the name of the _Data Source_ (DS) to the "metric"
    identifier. If set to **false** (the default), this is only done when there is
    more than one DS.

- **GraphitePreserveSeparator** **false**|**true**

    If set to **false** (the default) the `.` (dot) character is replaced with
    _GraphiteEscapeChar_. Otherwise, if set to **true**, the `.` (dot) character
    is preserved, i.e. passed through.

## Plugin `apache`

To configure the `apache`-plugin you first need to configure the Apache
webserver correctly. The Apache-plugin `mod_status` needs to be loaded and
working and the `ExtendedStatus` directive needs to be **enabled**. You can use
the following snipped to base your Apache config upon:

    ExtendedStatus on
    <IfModule mod_status.c>
      <Location /mod_status>
        SetHandler server-status
      </Location>
    </IfModule>

Since its `mod_status` module is very similar to Apache's, **lighttpd** is
also supported. It introduces a new field, called `BusyServers`, to count the
number of currently connected clients. This field is also supported.

The configuration of the _Apache_ plugin consists of one or more
`<Instance />` blocks. Each block requires one string argument
as the instance name. For example:

    <Plugin "apache">
      <Instance "www1">
        URL "http://www1.example.com/mod_status?auto"
      </Instance>
      <Instance "www2">
        URL "http://www2.example.com/mod_status?auto"
      </Instance>
    </Plugin>

The instance name will be used as the _plugin instance_. To emulate the old
(version 4) behavior, you can use an empty string (""). In order for the
plugin to work correctly, each instance name must be unique. This is not
enforced by the plugin and it is your responsibility to ensure it.

The following options are accepted within each _Instance_ block:

- **URL** _http://host/mod\_status?auto_

    Sets the URL of the `mod_status` output. This needs to be the output generated
    by `ExtendedStatus on` and it needs to be the machine readable output
    generated by appending the `?auto` argument. This option is _mandatory_.

- **User** _Username_

    Optional user name needed for authentication.

- **Password** _Password_

    Optional password needed for authentication.

- **VerifyPeer** **true|false**

    Enable or disable peer SSL certificate verification. See
    [http://curl.haxx.se/docs/sslcerts.html](http://curl.haxx.se/docs/sslcerts.html) for details. Enabled by default.

- **VerifyHost** **true|false**

    Enable or disable peer host name verification. If enabled, the plugin checks
    if the `Common Name` or a `Subject Alternate Name` field of the SSL
    certificate matches the host name provided by the **URL** option. If this
    identity check fails, the connection is aborted. Obviously, only works when
    connecting to a SSL enabled server. Enabled by default.

- **CACert** _File_

    File that holds one or more SSL certificates. If you want to use HTTPS you will
    possibly need this option. What CA certificates come bundled with `libcurl`
    and are checked by default depends on the distribution you use.

- **SSLCiphers** _list of ciphers_

    Specifies which ciphers to use in the connection. The list of ciphers
    must specify valid ciphers. See
    [http://www.openssl.org/docs/apps/ciphers.html](http://www.openssl.org/docs/apps/ciphers.html) for details.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the overall timeout for HTTP requests to **URL**, in
    milliseconds. By default, the configured **Interval** is used to set the
    timeout.

## Plugin `apcups`

- **Host** _Hostname_

    Hostname of the host running **apcupsd**. Defaults to **localhost**. Please note
    that IPv6 support has been disabled unless someone can confirm or decline that
    **apcupsd** can handle it.

- **Port** _Port_

    TCP-Port to connect to. Defaults to **3551**.

- **ReportSeconds** **true**|**false**

    If set to **true**, the time reported in the `timeleft` metric will be
    converted to seconds. This is the recommended setting. If set to **false**, the
    default for backwards compatibility, the time will be reported in minutes.

- **PersistentConnection** **true**|**false**

    The plugin is designed to keep the connection to _apcupsd_ open between reads.
    If plugin poll interval is greater than 15 seconds (hardcoded socket close
    timeout in _apcupsd_ NIS), then this option is **false** by default.

    You can instruct the plugin to close the connection after each read by setting
    this option to **false** or force keeping the connection by setting it to **true**.

    If _apcupsd_ appears to close the connection due to inactivity quite quickly,
    the plugin will try to detect this problem and switch to an open-read-close mode.

## Plugin `aquaero`

This plugin collects the value of the available sensors in an
_Aquaero 5_ board. Aquaero 5 is a water-cooling controller board,
manufactured by Aqua Computer GmbH [http://www.aquacomputer.de/](http://www.aquacomputer.de/), with a USB2
connection for monitoring and configuration. The board can handle multiple
temperature sensors, fans, water pumps and water level sensors and adjust the
output settings such as fan voltage or power used by the water pump based on
the available inputs using a configurable controller included in the board.
This plugin collects all the available inputs as well as some of the output
values chosen by this controller. The plugin is based on the _libaquaero5_
library provided by _aquatools-ng_.

- **Device** _DevicePath_

    Device path of the Aquaero 5's USB HID (human interface device), usually
    in the form `/dev/usb/hiddevX`. If this option is no set the plugin will try
    to auto-detect the Aquaero 5 USB device based on vendor-ID and product-ID.

## Plugin `ascent`

This plugin collects information about an Ascent server, a free server for the
"World of Warcraft" game. This plugin gathers the information by fetching the
XML status page using `libcurl` and parses it using `libxml2`.

The configuration options are the same as for the `apache` plugin above:

- **URL** _http://localhost/ascent/status/_

    Sets the URL of the XML status output.

- **User** _Username_

    Optional user name needed for authentication.

- **Password** _Password_

    Optional password needed for authentication.

- **VerifyPeer** **true|false**

    Enable or disable peer SSL certificate verification. See
    [http://curl.haxx.se/docs/sslcerts.html](http://curl.haxx.se/docs/sslcerts.html) for details. Enabled by default.

- **VerifyHost** **true|false**

    Enable or disable peer host name verification. If enabled, the plugin checks
    if the `Common Name` or a `Subject Alternate Name` field of the SSL
    certificate matches the host name provided by the **URL** option. If this
    identity check fails, the connection is aborted. Obviously, only works when
    connecting to a SSL enabled server. Enabled by default.

- **CACert** _File_

    File that holds one or more SSL certificates. If you want to use HTTPS you will
    possibly need this option. What CA certificates come bundled with `libcurl`
    and are checked by default depends on the distribution you use.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the overall timeout for HTTP requests to **URL**, in
    milliseconds. By default, the configured **Interval** is used to set the
    timeout.

## Plugin `barometer`

This plugin reads absolute air pressure using digital barometer sensor on a I2C
bus. Supported sensors are:

- _MPL115A2_ from Freescale,
see [http://www.freescale.com/webapp/sps/site/prod\_summary.jsp?code=MPL115A](http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=MPL115A).
- _MPL3115_ from Freescale
see [http://www.freescale.com/webapp/sps/site/prod\_summary.jsp?code=MPL3115A2](http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=MPL3115A2).
- _BMP085_ from Bosch Sensortec

The sensor type - one of the above - is detected automatically by the plugin
and indicated in the plugin\_instance (you will see subdirectory
"barometer-mpl115" or "barometer-mpl3115", or "barometer-bmp085"). The order of
detection is BMP085 -> MPL3115 -> MPL115A2, the first one found will be used
(only one sensor can be used by the plugin).

The plugin provides absolute barometric pressure, air pressure reduced to sea
level (several possible approximations) and as an auxiliary value also internal
sensor temperature. It uses (expects/provides) typical metric units - pressure
in \[hPa\], temperature in \[C\], altitude in \[m\].

It was developed and tested under Linux only. The only platform dependency is
the standard Linux i2c-dev interface (the particular bus driver has to
support the SM Bus command subset).

The reduction or normalization to mean sea level pressure requires (depending
on selected method/approximation) also altitude and reference to temperature
sensor(s).  When multiple temperature sensors are configured the minimum of
their values is always used (expecting that the warmer ones are affected by
e.g. direct sun light at that moment).

Synopsis:

    <Plugin "barometer">
       Device            "/dev/i2c-0";
       Oversampling      512
       PressureOffset    0.0
       TemperatureOffset 0.0
       Normalization     2
       Altitude          238.0
       TemperatureSensor "myserver/onewire-F10FCA000800/temperature"
    </Plugin>

- **Device** _device_

    The only mandatory configuration parameter.

    Device name of the I2C bus to which the sensor is connected. Note that
    typically you need to have loaded the i2c-dev module.
    Using i2c-tools you can check/list i2c buses available on your system by:

        i2cdetect -l

    Then you can scan for devices on given bus. E.g. to scan the whole bus 0 use:

        i2cdetect -y -a 0

    This way you should be able to verify that the pressure sensor (either type) is
    connected and detected on address 0x60.

- **Oversampling** _value_

    Optional parameter controlling the oversampling/accuracy. Default value
    is 1 providing fastest and least accurate reading.

    For _MPL115_ this is the size of the averaging window. To filter out sensor
    noise a simple averaging using floating window of this configurable size is
    used. The plugin will use average of the last `value` measurements (value of 1
    means no averaging).  Minimal size is 1, maximal 1024.

    For _MPL3115_ this is the oversampling value. The actual oversampling is
    performed by the sensor and the higher value the higher accuracy and longer
    conversion time (although nothing to worry about in the collectd context).
    Supported values are: 1, 2, 4, 8, 16, 32, 64 and 128. Any other value is
    adjusted by the plugin to the closest supported one.

    For _BMP085_ this is the oversampling value. The actual oversampling is
    performed by the sensor and the higher value the higher accuracy and longer
    conversion time (although nothing to worry about in the collectd context).
    Supported values are: 1, 2, 4, 8. Any other value is adjusted by the plugin to
    the closest supported one.

- **PressureOffset** _offset_

    Optional parameter for MPL3115 only.

    You can further calibrate the sensor by supplying pressure and/or temperature
    offsets.  This is added to the measured/caclulated value (i.e. if the measured
    value is too high then use negative offset).
    In hPa, default is 0.0.

- **TemperatureOffset** _offset_

    Optional parameter for MPL3115 only.

    You can further calibrate the sensor by supplying pressure and/or temperature
    offsets.  This is added to the measured/caclulated value (i.e. if the measured
    value is too high then use negative offset).
    In C, default is 0.0.

- **Normalization** _method_

    Optional parameter, default value is 0.

    Normalization method - what approximation/model is used to compute the mean sea
    level pressure from the air absolute pressure.

    Supported values of the `method` (integer between from 0 to 2) are:

    - **0** - no conversion, absolute pressure is simply copied over. For this method you
           do not need to configure `Altitude` or `TemperatureSensor`.
    - **1** - international formula for conversion ,
    See
    [http://en.wikipedia.org/wiki/Atmospheric\_pressure#Altitude\_atmospheric\_pressure\_variation](http://en.wikipedia.org/wiki/Atmospheric_pressure#Altitude_atmospheric_pressure_variation).
    For this method you have to configure `Altitude` but do not need
    `TemperatureSensor` (uses fixed global temperature average instead).
    - **2** - formula as recommended by the Deutsche Wetterdienst (German
    Meteorological Service).
    See [http://de.wikipedia.org/wiki/Barometrische\_H%C3%B6henformel#Theorie](http://de.wikipedia.org/wiki/Barometrische_H%C3%B6henformel#Theorie)
    For this method you have to configure both  `Altitude` and
    `TemperatureSensor`.

- **Altitude** _altitude_

    The altitude (in meters) of the location where you meassure the pressure.

- **TemperatureSensor** _reference_

    Temperature sensor(s) which should be used as a reference when normalizing the
    pressure using `Normalization` method 2.
    When specified more sensors a minimum is found and used each time.  The
    temperature reading directly from this pressure sensor/plugin is typically not
    suitable as the pressure sensor will be probably inside while we want outside
    temperature.  The collectd reference name is something like
    &lt;hostname>/&lt;plugin\_name>-&lt;plugin\_instance>/&lt;type>-&lt;type\_instance>
    (&lt;type\_instance> is usually omitted when there is just single value type). Or
    you can figure it out from the path of the output data files.

## Plugin `battery`

The _battery plugin_ reports the remaining capacity, power and voltage of
laptop batteries.

- **ValuesPercentage** **false**|**true**

    When enabled, remaining capacity is reported as a percentage, e.g. "42%
    capacity remaining". Otherwise the capacity is stored as reported by the
    battery, most likely in "Wh". This option does not work with all input methods,
    in particular when only `/proc/pmu` is available on an old Linux system.
    Defaults to **false**.

- **ReportDegraded** **false**|**true**

    Typical laptop batteries degrade over time, meaning the capacity decreases with
    recharge cycles. The maximum charge of the previous charge cycle is tracked as
    "last full capacity" and used to determine that a battery is "fully charged".

    When this option is set to **false**, the default, the _battery plugin_ will
    only report the remaining capacity. If the **ValuesPercentage** option is
    enabled, the relative remaining capacity is calculated as the ratio of the
    "remaining capacity" and the "last full capacity". This is what most tools,
    such as the status bar of desktop environments, also do.

    When set to **true**, the battery plugin will report three values: **charged**
    (remaining capacity), **discharged** (difference between "last full capacity"
    and "remaining capacity") and **degraded** (difference between "design capacity"
    and "last full capacity").

- **QueryStateFS** **false**|**true**

    When set to **true**, the battery plugin will only read statistics
    related to battery performance as exposed by StateFS at
    /run/state. StateFS is used in Mer-based Sailfish OS, for
    example.

## Plugin `bind`

Starting with BIND 9.5.0, the most widely used DNS server software provides
extensive statistics about queries, responses and lots of other information.
The bind plugin retrieves this information that's encoded in XML and provided
via HTTP and submits the values to collectd.

To use this plugin, you first need to tell BIND to make this information
available. This is done with the `statistics-channels` configuration option:

    statistics-channels {
      inet localhost port 8053;
    };

The configuration follows the grouping that can be seen when looking at the
data with an XSLT compatible viewer, such as a modern web browser. It's
probably a good idea to make yourself familiar with the provided values, so you
can understand what the collected statistics actually mean.

Synopsis:

    <Plugin "bind">
      URL "http://localhost:8053/"
      ParseTime       false
      OpCodes         true
      QTypes          true

      ServerStats     true
      ZoneMaintStats  true
      ResolverStats   false
      MemoryStats     true

      <View "_default">
        QTypes        true
        ResolverStats true
        CacheRRSets   true

        Zone "127.in-addr.arpa/IN"
      </View>
    </Plugin>

The bind plugin accepts the following configuration options:

- **URL** _URL_

    URL from which to retrieve the XML data. If not specified,
    `http://localhost:8053/` will be used.

- **ParseTime** **true**|**false**

    When set to **true**, the time provided by BIND will be parsed and used to
    dispatch the values. When set to **false**, the local time source is queried.

    This setting is set to **true** by default for backwards compatibility; setting
    this to **false** is _recommended_ to avoid problems with timezones and
    localization.

- **OpCodes** **true**|**false**

    When enabled, statistics about the _"OpCodes"_, for example the number of
    `QUERY` packets, are collected.

    Default: Enabled.

- **QTypes** **true**|**false**

    When enabled, the number of _incoming_ queries by query types (for example
    `A`, `MX`, `AAAA`) is collected.

    Default: Enabled.

- **ServerStats** **true**|**false**

    Collect global server statistics, such as requests received over IPv4 and IPv6,
    successful queries, and failed updates.

    Default: Enabled.

- **ZoneMaintStats** **true**|**false**

    Collect zone maintenance statistics, mostly information about notifications
    (zone updates) and zone transfers.

    Default: Enabled.

- **ResolverStats** **true**|**false**

    Collect resolver statistics, i. e. statistics about outgoing requests
    (e. g. queries over IPv4, lame servers). Since the global resolver
    counters apparently were removed in BIND 9.5.1 and 9.6.0, this is disabled by
    default. Use the **ResolverStats** option within a **View "\_default"** block
    instead for the same functionality.

    Default: Disabled.

- **MemoryStats**

    Collect global memory statistics.

    Default: Enabled.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the overall timeout for HTTP requests to **URL**, in
    milliseconds. By default, the configured **Interval** is used to set the
    timeout.

- **View** _Name_

    Collect statistics about a specific _"view"_. BIND can behave different,
    mostly depending on the source IP-address of the request. These different
    configurations are called "views". If you don't use this feature, you most
    likely are only interested in the `_default` view.

    Within a <**View** _name_> block, you can specify which
    information you want to collect about a view. If no **View** block is
    configured, no detailed view statistics will be collected.

    - **QTypes** **true**|**false**

        If enabled, the number of _outgoing_ queries by query type (e. g. `A`,
        `MX`) is collected.

        Default: Enabled.

    - **ResolverStats** **true**|**false**

        Collect resolver statistics, i. e. statistics about outgoing requests
        (e. g. queries over IPv4, lame servers).

        Default: Enabled.

    - **CacheRRSets** **true**|**false**

        If enabled, the number of entries (_"RR sets"_) in the view's cache by query
        type is collected. Negative entries (queries which resulted in an error, for
        example names that do not exist) are reported with a leading exclamation mark,
        e. g. "!A".

        Default: Enabled.

    - **Zone** _Name_

        When given, collect detailed information about the given zone in the view. The
        information collected if very similar to the global **ServerStats** information
        (see above).

        You can repeat this option to collect detailed information about multiple
        zones.

        By default no detailed zone information is collected.

## Plugin `buddyinfo`

The **buddyinfo** plugin collects information by reading "/proc/buddyinfo".
This file contains information about the number of available contagious
physical pages at the moment.

- **Zone** _ZoneName_

    Zone to collect info about. Will collect all zones by default.

## Plugin `capabilities`

The `capabilities` plugin collects selected static platform data using
_dmidecode_ and expose it through micro embedded webserver. The data
returned by plugin is in json format.

**Synopsis:**

    <Plugin capabilities>
      Host "localhost"
      Port "9104"
    </Plugin>

Available configuration options for the `capabilities` plugin:

- **Host** _Hostname_

    Bind to the hostname / address _Host_. By default, the plugin will bind to the
    "any" address, i.e. accept packets sent to any of the hosts addresses.

    This option is supported only for libmicrohttpd newer than 0.9.0.

- **Port** _Port_

    Port the embedded webserver should listen on. Defaults to **9104**.

## Plugin `ceph`

The ceph plugin collects values from JSON data to be parsed by **libyajl**
([https://lloyd.github.io/yajl/](https://lloyd.github.io/yajl/)) retrieved from ceph daemon admin sockets.

A separate **Daemon** block must be configured for each ceph daemon to be
monitored. The following example will read daemon statistics from four
separate ceph daemons running on the same device (two OSDs, one MON, one MDS) :

    <Plugin ceph>
      LongRunAvgLatency false
      ConvertSpecialMetricTypes true
      <Daemon "osd.0">
        SocketPath "/var/run/ceph/ceph-osd.0.asok"
      </Daemon>
      <Daemon "osd.1">
        SocketPath "/var/run/ceph/ceph-osd.1.asok"
      </Daemon>
      <Daemon "mon.a">
        SocketPath "/var/run/ceph/ceph-mon.ceph1.asok"
      </Daemon>
      <Daemon "mds.a">
        SocketPath "/var/run/ceph/ceph-mds.ceph1.asok"
      </Daemon>
    </Plugin>

The ceph plugin accepts the following configuration options:

- **LongRunAvgLatency** **true**|**false**

    If enabled, latency values(sum,count pairs) are calculated as the long run
    average - average since the ceph daemon was started = (sum / count).
    When disabled, latency values are calculated as the average since the last
    collection = (sum\_now - sum\_last) / (count\_now - count\_last).

    Default: Disabled

- **ConvertSpecialMetricTypes** **true**|**false**

    If enabled, special metrics (metrics that differ in type from similar counters)
    are converted to the type of those similar counters. This currently only
    applies to filestore.journal\_wr\_bytes which is a counter for OSD daemons. The
    ceph schema reports this metric type as a sum,count pair while similar counters
    are treated as derive types. When converted, the sum is used as the counter
    value and is treated as a derive type.
    When disabled, all metrics are treated as the types received from the ceph schema.

    Default: Enabled

Each **Daemon** block must have a string argument for the plugin instance name.
A **SocketPath** is also required for each **Daemon** block:

- **Daemon** _DaemonName_

    Name to be used as the instance name for this daemon.

- **SocketPath** _SocketPath_

    Specifies the path to the UNIX admin socket of the ceph daemon.

## Plugin `cgroups`

This plugin collects the CPU user/system time for each _cgroup_ by reading the
`cpuacct.stat` files in the first cpuacct-mountpoint (typically
`/sys/fs/cgroup/cpu.cpuacct` on machines using systemd).

- **CGroup** _Directory_

    Select _cgroup_ based on the name. Whether only matching _cgroups_ are
    collected or if they are ignored is controlled by the **IgnoreSelected** option;
    see below.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Invert the selection: If set to true, all cgroups _except_ the ones that
    match any one of the criteria are collected. By default only selected
    cgroups are collected if a selection is made. If no selection is configured
    at all, **all** cgroups are selected.

## Plugin `check_uptime`

The _check\_uptime plugin_ designed to check and notify about host or service
status based on _uptime_ metric.

When new metric of _uptime_ type appears in cache, OK notification is sent.
When new value for metric is less than previous value, WARNING notification is
sent about host/service restart.
When no new updates comes for metric and cache entry expires, then FAILURE
notification is sent about unreachable host or service.

By default (when no explicit configuration), plugin checks for _uptime_ metric.

**Synopsis:**

    <Plugin "check_uptime">
      Type "uptime"
      Type "my_uptime_type"
    </Plugin>

- **Type** _Type_

    Metric type to check for status/values. The type should consist single GAUGE
    data source.

## Plugin `chrony`

The `chrony` plugin collects ntp data from a **chronyd** server, such as clock
skew and per-peer stratum.

For talking to **chronyd**, it mimics what the **chronyc** control program does
on the wire.

Available configuration options for the `chrony` plugin:

- **Host** _Hostname_

    Hostname of the host running **chronyd**. Defaults to **localhost**.

- **Port** _Port_

    UDP-Port to connect to. Defaults to **323**.

- **Timeout** _Timeout_

    Connection timeout in seconds. Defaults to **2**.

## Plugin Connectivity

connectivity - Documentation of collectd's `connectivity plugin`

    LoadPlugin connectivity
    # ...
    <Plugin connectivity>
      Interface eth0
    </Plugin>

The `connectivity plugin` queries interface status using netlink (man 7 netlink) which provides information about network interfaces via the NETLINK\_ROUTE family (man 7 rtnetlink). The plugin translates the value it receives to collectd's internal format and, depending on the write plugins you have loaded, it may be written to disk or submitted to another instance.
The plugin listens to interfaces enumerated within the plugin configuration (see below).  If no interfaces are listed, then the default is for all interfaces to be monitored.

This example shows `connectivity plugin` monitoring all interfaces.
LoadPlugin connectivity
<Plugin connectivity>
&lt;/Plugin>

This example shows `connectivity plugin` monitoring 2 interfaces, "eth0" and "eth1".
LoadPlugin connectivity
<Plugin connectivity>
  Interface eth0
  Interface eth1
&lt;/Plugin>

This example shows `connectivity plugin` monitoring all interfaces except "eth1".
LoadPlugin connectivity
<Plugin connectivity>
  Interface eth1
  IgnoreSelected true
&lt;/Plugin>

- **Interface** _interface\_name_

    interface(s) to monitor connect to.

## Plugin `conntrack`

This plugin collects IP conntrack statistics.

- **OldFiles**

    Assume the **conntrack\_count** and **conntrack\_max** files to be found in
    `/proc/sys/net/ipv4/netfilter` instead of `/proc/sys/net/netfilter/`.

## Plugin `cpu`

The _CPU plugin_ collects CPU usage metrics. By default, CPU usage is reported
as Jiffies, using the `cpu` type. Two aggregations are available:

- Sum, per-state, over all CPUs installed in the system; and
- Sum, per-CPU, over all non-idle states of a CPU, creating an "active" state.

The two aggregations can be combined, leading to _collectd_ only emitting a
single "active" metric for the entire system. As soon as one of these
aggregations (or both) is enabled, the _cpu plugin_ will report a percentage,
rather than Jiffies. In addition, you can request individual, per-state,
per-CPU metrics to be reported as percentage.

The following configuration options are available:

- **ReportByState** **true**|**false**

    When set to **true**, the default, reports per-state metrics, e.g. "system",
    "user" and "idle".
    When set to **false**, aggregates (sums) all _non-idle_ states into one
    "active" metric.

- **ReportByCpu** **true**|**false**

    When set to **true**, the default, reports per-CPU (per-core) metrics.
    When set to **false**, instead of reporting metrics for individual CPUs, only a
    global sum of CPU states is emitted.

- **ValuesPercentage** **false**|**true**

    This option is only considered when both, **ReportByCpu** and **ReportByState**
    are set to **true**. In this case, by default, metrics will be reported as
    Jiffies. By setting this option to **true**, you can request percentage values
    in the un-aggregated (per-CPU, per-state) mode as well.

- **ReportNumCpu** **false**|**true**

    When set to **true**, reports the number of available CPUs.
    Defaults to **false**.

- **ReportGuestState** **false**|**true**

    When set to **true**, reports the "guest" and "guest\_nice" CPU states.
    Defaults to **false**.

- **SubtractGuestState** **false**|**true**

    This option is only considered when **ReportGuestState** is set to **true**.
    "guest" and "guest\_nice" are included in respectively "user" and "nice".
    If set to **true**, "guest" will be subtracted from "user" and "guest\_nice"
    will be subtracted from "nice".
    Defaults to **true**.

## Plugin `cpufreq`

This plugin is available on Linux and FreeBSD only.  It doesn't have any
options.  On Linux it reads
`/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` (for the first CPU
installed) to get the current CPU frequency. If this file does not exist make
sure **cpufreqd** ([http://cpufreqd.sourceforge.net/](http://cpufreqd.sourceforge.net/)) or a similar tool is
installed and an "cpu governor" (that's a kernel module) is loaded.

On Linux, if the system has the _cpufreq-stats_ kernel module loaded, this
plugin reports the rate of p-state (cpu frequency) transitions and the
percentage of time spent in each p-state.

On FreeBSD it does a sysctl dev.cpu.0.freq and submits this as instance 0.
At this time FreeBSD only has one frequency setting for all cores.
See the BUGS section in the FreeBSD man page for cpufreq(4) for more details.

On FreeBSD the plugin checks the success of sysctl dev.cpu.0.freq and
unregisters the plugin when this fails.  A message will be logged to indicate
this.

## Plugin `cpusleep`

This plugin doesn't have any options. It reads CLOCK\_BOOTTIME and
CLOCK\_MONOTONIC and reports the difference between these clocks. Since
BOOTTIME clock increments while device is suspended and MONOTONIC
clock does not, the derivative of the difference between these clocks
gives the relative amount of time the device has spent in suspend
state. The recorded value is in milliseconds of sleep per seconds of
wall clock.

## Plugin `csv`

- **DataDir** _Directory_

    Set the directory to store CSV-files under. Per default CSV-files are generated
    beneath the daemon's working directory, i. e. the **BaseDir**.
    The special strings **stdout** and **stderr** can be used to write to the standard
    output and standard error channels, respectively. This, of course, only makes
    much sense when collectd is running in foreground- or non-daemon-mode.

- **StoreRates** **true|false**

    If set to **true**, convert counter values to rates. If set to **false** (the
    default) counter values are stored as is, i. e. as an increasing integer
    number.

- **FileDate** **true|false**

    If set to **true** (the default value), the generated files will include the date.
    If set to **false** the date will not be included in the generated files.

## cURL Statistics

All cURL-based plugins support collection of generic, request-based
statistics. These are disabled by default and can be enabled selectively for
each page or URL queried from the curl, curl\_json, or curl\_xml plugins. See
the documentation of those plugins for specific information. This section
describes the available metrics that can be configured for each plugin. All
options are disabled by default.

See [http://curl.haxx.se/libcurl/c/curl\_easy\_getinfo.html](http://curl.haxx.se/libcurl/c/curl_easy_getinfo.html) for more details.

- **TotalTime** **true|false**

    Total time of the transfer, including name resolving, TCP connect, etc.

- **NamelookupTime** **true|false**

    Time it took from the start until name resolving was completed.

- **ConnectTime** **true|false**

    Time it took from the start until the connect to the remote host (or proxy)
    was completed.

- **AppconnectTime** **true|false**

    Time it took from the start until the SSL/SSH connect/handshake to the remote
    host was completed.

- **PretransferTime** **true|false**

    Time it took from the start until just before the transfer begins.

- **StarttransferTime** **true|false**

    Time it took from the start until the first byte was received.

- **RedirectTime** **true|false**

    Time it took for all redirection steps include name lookup, connect,
    pre-transfer and transfer before final transaction was started.

- **RedirectCount** **true|false**

    The total number of redirections that were actually followed.

- **SizeUpload** **true|false**

    The total amount of bytes that were uploaded.

- **SizeDownload** **true|false**

    The total amount of bytes that were downloaded.

- **SpeedDownload** **true|false**

    The average download speed that curl measured for the complete download.

- **SpeedUpload** **true|false**

    The average upload speed that curl measured for the complete upload.

- **HeaderSize** **true|false**

    The total size of all the headers received.

- **RequestSize** **true|false**

    The total size of the issued requests.

- **ContentLengthDownload** **true|false**

    The content-length of the download.

- **ContentLengthUpload** **true|false**

    The specified size of the upload.

- **NumConnects** **true|false**

    The number of new connections that were created to achieve the transfer.

## Plugin `curl`

The curl plugin uses the **libcurl** ([http://curl.haxx.se/](http://curl.haxx.se/)) to read web pages
and the match infrastructure (the same code used by the tail plugin) to use
regular expressions with the received data.

The following example will read the current value of AMD stock from Google's
finance page and dispatch the value to collectd.

    <Plugin curl>
      <Page "stock_quotes">
        Plugin "quotes"
        URL "http://finance.google.com/finance?q=NYSE%3AAMD"
        AddressFamily "any"
        User "foo"
        Password "bar"
        Digest false
        VerifyPeer true
        VerifyHost true
        CACert "/path/to/ca.crt"
        Header "X-Custom-Header: foobar"
        Post "foo=bar"

        MeasureResponseTime false
        MeasureResponseCode false

        <Match>
          Regex "<span +class=\"pr\"[^>]*> *([0-9]*\\.[0-9]+) *</span>"
          DSType "GaugeAverage"
          # Note: `stock_value' is not a standard type.
          Type "stock_value"
          Instance "AMD"
        </Match>
      </Page>
    </Plugin>

In the **Plugin** block, there may be one or more **Page** blocks, each defining
a web page and one or more "matches" to be performed on the returned data. The
string argument to the **Page** block is used as plugin instance.

The following options are valid within **Page** blocks:

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to `curl`.

- **URL** _URL_

    URL of the web site to retrieve. Since a regular expression will be used to
    extract information from this data, non-binary data is a big plus here ;)

- **AddressFamily** _Type_

    IP version to resolve URL to. Useful in cases when hostname in URL resolves
    to both IPv4 and IPv6 addresses, and you are interested in using one of them
    specifically.
    Use `ipv4` to enforce IPv4, `ipv6` to enforce IPv6, or `any` to keep the
    default behavior of resolving addresses to all IP versions your system allows.
    If `libcurl` is compiled without IPv6 support, using `ipv6` will result in
    a warning and fallback to `any`.
    If `Type` cannot be parsed, a warning will be printed and the whole **Page**
    block will be ignored.

- **User** _Name_

    Username to use if authorization is required to read the page.

- **Password** _Password_

    Password to use if authorization is required to read the page.

- **Digest** **true**|**false**

    Enable HTTP digest authentication.

- **VerifyPeer** **true**|**false**

    Enable or disable peer SSL certificate verification. See
    [http://curl.haxx.se/docs/sslcerts.html](http://curl.haxx.se/docs/sslcerts.html) for details. Enabled by default.

- **VerifyHost** **true**|**false**

    Enable or disable peer host name verification. If enabled, the plugin checks if
    the `Common Name` or a `Subject Alternate Name` field of the SSL certificate
    matches the host name provided by the **URL** option. If this identity check
    fails, the connection is aborted. Obviously, only works when connecting to a
    SSL enabled server. Enabled by default.

- **CACert** _file_

    File that holds one or more SSL certificates. If you want to use HTTPS you will
    possibly need this option. What CA certificates come bundled with `libcurl`
    and are checked by default depends on the distribution you use.

- **Header** _Header_

    A HTTP header to add to the request. Multiple headers are added if this option
    is specified more than once.

- **Post** _Body_

    Specifies that the HTTP operation should be a POST instead of a GET. The
    complete data to be posted is given as the argument.  This option will usually
    need to be accompanied by a **Header** option to set an appropriate
    `Content-Type` for the post body (e.g. to
    `application/x-www-form-urlencoded`).

- **MeasureResponseTime** **true**|**false**

    Measure response time for the request. If this setting is enabled, **Match**
    blocks (see below) are optional. Disabled by default.

    Beware that requests will get aborted if they take too long to complete. Adjust
    **Timeout** accordingly if you expect **MeasureResponseTime** to report such slow
    requests.

    This option is similar to enabling the **TotalTime** statistic but it's
    measured by collectd instead of cURL.

- **MeasureResponseCode** **true**|**false**

    Measure response code for the request. If this setting is enabled, **Match**
    blocks (see below) are optional. Disabled by default.

- **<Statistics>**

    One **Statistics** block can be used to specify cURL statistics to be collected
    for each request to the remote web site. See the section "cURL Statistics"
    above for details. If this setting is enabled, **Match** blocks (see below) are
    optional.

- **<Match>**

    One or more **Match** blocks that define how to match information in the data
    returned by `libcurl`. The `curl` plugin uses the same infrastructure that's
    used by the `tail` plugin, so please see the documentation of the `tail`
    plugin below on how matches are defined. If the **MeasureResponseTime** or
    **MeasureResponseCode** options are set to **true**, **Match** blocks are
    optional.

- **Interval** _Interval_

    Sets the interval (in seconds) in which the values will be collected from this
    URL. By default the global **Interval** setting will be used.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the overall timeout for HTTP requests to **URL**, in
    milliseconds. By default, the configured **Interval** is used to set the
    timeout. Prior to version 5.5.0, there was no timeout and requests could hang
    indefinitely. This legacy behaviour can be achieved by setting the value of
    **Timeout** to 0.

    If **Timeout** is 0 or bigger than the **Interval**, keep in mind that each slow
    network connection will stall one read thread. Adjust the **ReadThreads** global
    setting accordingly to prevent this from blocking other plugins.

## Plugin `curl_json`

The **curl\_json plugin** collects values from JSON data to be parsed by
**libyajl** ([https://lloyd.github.io/yajl/](https://lloyd.github.io/yajl/)) retrieved via
either **libcurl** ([http://curl.haxx.se/](http://curl.haxx.se/)) or read directly from a
unix socket. The former can be used, for example, to collect values
from CouchDB documents (which are stored JSON notation), and the
latter to collect values from a uWSGI stats socket.

The following example will collect several values from the built-in
`_stats` runtime statistics module of _CouchDB_
([http://wiki.apache.org/couchdb/Runtime\_Statistics](http://wiki.apache.org/couchdb/Runtime_Statistics)).

    <Plugin curl_json>
      <URL "http://localhost:5984/_stats">
        AddressFamily "any"
        Instance "httpd"
        <Key "httpd/requests/count">
          Type "http_requests"
        </Key>

        <Key "httpd_request_methods/*/count">
          Type "http_request_methods"
        </Key>

        <Key "httpd_status_codes/*/count">
          Type "http_response_codes"
        </Key>
      </URL>
    </Plugin>

This example will collect data directly from a _uWSGI_ "Stats Server" socket.

    <Plugin curl_json>
      <Sock "/var/run/uwsgi.stats.sock">
        Instance "uwsgi"
        <Key "workers/*/requests">
          Type "http_requests"
        </Key>

        <Key "workers/*/apps/*/requests">
          Type "http_requests"
        </Key>
      </Sock>
    </Plugin>

In the **Plugin** block, there may be one or more **URL** blocks, each
defining a URL to be fetched via HTTP (using libcurl) or **Sock**
blocks defining a unix socket to read JSON from directly.  Each of
these blocks may have one or more **Key** blocks.

The **Key** string argument must be in a path format. Each component is
used to match the key from a JSON map or the index of an JSON
array. If a path component of a **Key** is a _\*_ wildcard, the
values for all map keys or array indices will be collectd.

The following options are valid within **URL** blocks:

- **AddressFamily** _Type_

    IP version to resolve URL to. Useful in cases when hostname in URL resolves
    to both IPv4 and IPv6 addresses, and you are interested in using one of them
    specifically.
    Use `ipv4` to enforce IPv4, `ipv6` to enforce IPv6, or `any` to keep the
    default behavior of resolving addresses to all IP versions your system allows.
    If `libcurl` is compiled without IPv6 support, using `ipv6` will result in
    a warning and fallback to `any`.
    If `Type` cannot be parsed, a warning will be printed and the whole **URL**
    block will be ignored.

- **Host** _Name_

    Use _Name_ as the host name when submitting values. Defaults to the global
    host name setting.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to `curl_json`.

- **Instance** _Instance_

    Sets the plugin instance to _Instance_.

- **Interval** _Interval_

    Sets the interval (in seconds) in which the values will be collected from this
    URL. By default the global **Interval** setting will be used.

- **User** _Name_
- **Password** _Password_
- **Digest** **true**|**false**
- **VerifyPeer** **true**|**false**
- **VerifyHost** **true**|**false**
- **CACert** _file_
- **Header** _Header_
- **Post** _Body_
- **Timeout** _Milliseconds_

    These options behave exactly equivalent to the appropriate options of the
    _cURL_ plugin. Please see there for a detailed description.

- **<Statistics>**

    One **Statistics** block can be used to specify cURL statistics to be collected
    for each request to the remote URL. See the section "cURL Statistics" above
    for details.

The following options are valid within **Key** blocks:

- **Type** _Type_

    Sets the type used to dispatch the values to the daemon. Detailed information
    about types and their configuration can be found in [types.db(5)](http://man.he.net/man5/types.db). This
    option is mandatory.

- **Instance** _Instance_

    Type-instance to use. Defaults to the current map key or current string array element value.

## Plugin `curl_jolokia`

The **curl\_jolokia plugin** collects values from MBeanServevr - servlet engines equipped 
with the jolokia ([https://jolokia.org](https://jolokia.org)) MBean. It sends a pre-configured
JSON-Postbody to the servlet via HTTP commanding the jolokia Bean to reply with
a singe JSON equipped with all JMX counters requested.
By reducing TCP roundtrips in comparison to conventional JMX clients that
query one value via tcp at a time, it can return hundrets of values in one roundtrip.
Moreof - no java binding is required in collectd to do so.

It uses **libyajl** ([https://lloyd.github.io/yajl/](https://lloyd.github.io/yajl/)) to parse the 
Jolokia JSON reply retrieved via **libcurl** ([http://curl.haxx.se/](http://curl.haxx.se/))

    <Plugin curl_jolokia>
      <URL "http://10.10.10.10:7101/jolokia-war-1.2.0/?ignoreErrors=true&canonicalNaming=false";>
        Host "_APPPERF_JMX"
        User "webloginname"
        Password "passvoid"
        Post <JOLOKIA json post data>

      <BeanName "PS_Scavenge">
           MBean "java.lang:name=PS Scavenge,type=GarbageCollector"
           BeanNameSpace "java_lang"
           <AttributeName "collectiontime" >
                  Attribute "CollectionTime"
                  type "gauge"
           </AttributeName>
           <AttributeName "collectioncount" >
                  Attribute "CollectionCount"
                  type "gauge"
           </AttributeName>
      </BeanName>
     </Plugin>

The plugin is intended to be written in a simple manner. Thus it doesn't 
try to solve the task of generating the jolokia post data, or automatically 
map the values, but rather leans on a verbose config containing the prepared
flat JSON post data and a config section per gauge transformed (as one sample shown
above). However, Jolokia can output all available gauges, and we have a python 
script to filter them, and generate a configuration for you: 

    jolokia_2_collectcfg.py

it can gather all interesting gauges, write a simple one value per line config 
for itself and subsequent calls.
You can remove lines from this file manually, or create filter lists. 
You then use the script to generate a collectd config. 
The script can then inspect data files from some testruns, and remove 
all gauges, that don't contain any movement. 

The base config looks like this:

The following options are valid within **URL** blocks:

- **Host** _Name_

    Use _Name_ as the host name when submitting values. Defaults to the global
    host name setting.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to `curl_jolokia`.

- **Instance** _Instance_

    Sets the plugin instance to _Instance_.

- **Interval** _Interval_

    Sets the interval (in seconds) in which the values will be collected from this
    URL. By default the global **Interval** setting will be used.

- **User** _Name_
- **Password** _Password_
- **Digest** **true**|**false**
- **VerifyPeer** **true**|**false**
- **VerifyHost** **true**|**false**
- **CACert** _file_
- **Header** _Header_
- **Post** _Body_
- **Timeout** _Milliseconds_

    These options behave exactly equivalent to the appropriate options of the
    _cURL_ plugin. Please see there for a detailed description.

- **<BeanName>**

    One **BeanName** block configures the translation of the gauges of one bean
    to their respective collectd names, where BeanName sets the main name.

- **MBean** _MBean_

    The name of the Bean on the server

- **BeanNameSpace** _BeanNameSpace_

    The name space the Bean resides under

    - **AttributeName** _AttributeName_

        A bean can contain several Attributes with gauges. Each one can be matched by a 
        AttributeName section or be ignored. 

    - **Attribute** _Attribute_

        How should this attribute be called under the BeanName in the collectd hierarchy?

    - **Type** _Type_

        Sets the type used to dispatch the values to the daemon. Detailed information
        about types and their configuration can be found in [types.db(5)](http://man.he.net/man5/types.db). This
        option is mandatory.

## Plugin `curl_xml`

The **curl\_xml plugin** uses **libcurl** ([http://curl.haxx.se/](http://curl.haxx.se/)) and **libxml2**
([http://xmlsoft.org/](http://xmlsoft.org/)) to retrieve XML data via cURL.

    <Plugin "curl_xml">
      <URL "http://localhost/stats.xml">
        AddressFamily "any"
        Host "my_host"
        #Plugin "curl_xml"
        Instance "some_instance"
        User "collectd"
        Password "thaiNg0I"
        VerifyPeer true
        VerifyHost true
        CACert "/path/to/ca.crt"
        Header "X-Custom-Header: foobar"
        Post "foo=bar"

        <XPath "table[@id=\"magic_level\"]/tr">
          Type "magic_level"
          #InstancePrefix "prefix-"
          InstanceFrom "td[1]"
          #PluginInstanceFrom "td[1]"
          ValuesFrom "td[2]/span[@class=\"level\"]"
        </XPath>
      </URL>
    </Plugin>

In the **Plugin** block, there may be one or more **URL** blocks, each defining a
URL to be fetched using libcurl. Within each **URL** block there are
options which specify the connection parameters, for example authentication
information, and one or more **XPath** blocks.

Each **XPath** block specifies how to get one type of information. The
string argument must be a valid XPath expression which returns a list
of "base elements". One value is dispatched for each "base element". The
_type instance_ and values are looked up using further _XPath_ expressions
that should be relative to the base element.

Within the **URL** block the following options are accepted:

- **AddressFamily** _Type_

    IP version to resolve URL to. Useful in cases when hostname in URL resolves
    to both IPv4 and IPv6 addresses, and you are interested in using one of them
    specifically.
    Use `ipv4` to enforce IPv4, `ipv6` to enforce IPv6, or `any` to keep the
    default behavior of resolving addresses to all IP versions your system allows.
    If `libcurl` is compiled without IPv6 support, using `ipv6` will result in
    a warning and fallback to `any`.
    If `Type` cannot be parsed, a warning will be printed and the whole **URL**
    block will be ignored.

- **Host** _Name_

    Use _Name_ as the host name when submitting values. Defaults to the global
    host name setting.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to 'curl\_xml'.

- **Instance** _Instance_

    Use _Instance_ as the plugin instance when submitting values.
    May be overridden by **PluginInstanceFrom** option inside **XPath** blocks.
    Defaults to an empty string (no plugin instance).

- **Interval** _Interval_

    Sets the interval (in seconds) in which the values will be collected from this
    URL. By default the global **Interval** setting will be used.

- **Namespace** _Prefix_ _URL_

    If an XPath expression references namespaces, they must be specified
    with this option. _Prefix_ is the "namespace prefix" used in the XML document.
    _URL_ is the "namespace name", an URI reference uniquely identifying the
    namespace. The option can be repeated to register multiple namespaces.

    Examples:

        Namespace "s" "http://schemas.xmlsoap.org/soap/envelope/"
        Namespace "m" "http://www.w3.org/1998/Math/MathML"

- **User** _User_
- **Password** _Password_
- **Digest** **true**|**false**
- **VerifyPeer** **true**|**false**
- **VerifyHost** **true**|**false**
- **CACert** _CA Cert File_
- **Header** _Header_
- **Post** _Body_
- **Timeout** _Milliseconds_

    These options behave exactly equivalent to the appropriate options of the
    _cURL plugin_. Please see there for a detailed description.

- **<Statistics>**

    One **Statistics** block can be used to specify cURL statistics to be collected
    for each request to the remote URL. See the section "cURL Statistics" above
    for details.

- <**XPath** _XPath-expression_>

    Within each **URL** block, there must be one or more **XPath** blocks. Each
    **XPath** block specifies how to get one type of information. The string
    argument must be a valid XPath expression which returns a list of "base
    elements". One value is dispatched for each "base element".

    Within the **XPath** block the following options are accepted:

    - **Type** _Type_

        Specifies the _Type_ used for submitting patches. This determines the number
        of values that are required / expected and whether the strings are parsed as
        signed or unsigned integer or as double values. See [types.db(5)](http://man.he.net/man5/types.db) for details.
        This option is required.

    - **InstancePrefix** _InstancePrefix_

        Prefix the _type instance_ with _InstancePrefix_. The values are simply
        concatenated together without any separator.
        This option is optional.

    - **InstanceFrom** _InstanceFrom_

        Specifies a XPath expression to use for determining the _type instance_. The
        XPath expression must return exactly one element. The element's value is then
        used as _type instance_, possibly prefixed with _InstancePrefix_ (see above).

    - **PluginInstanceFrom** _PluginInstanceFrom_

        Specifies a XPath expression to use for determining the _plugin instance_. The
        XPath expression must return exactly one element. The element's value is then
        used as _plugin instance_.

    If the "base XPath expression" (the argument to the **XPath** block) returns
    exactly one argument, then _InstanceFrom_ and _PluginInstanceFrom_ may be omitted.
    Otherwise, at least one of _InstanceFrom_ or _PluginInstanceFrom_ is required.

    - **ValuesFrom** _ValuesFrom_ \[_ValuesFrom_ ...\]

        Specifies one or more XPath expression to use for reading the values. The
        number of XPath expressions must match the number of data sources in the
        _type_ specified with **Type** (see above). Each XPath expression must return
        exactly one element. The element's value is then parsed as a number and used as
        value for the appropriate value in the value list dispatched to the daemon.
        This option is required.

## Plugin `dbi`

This plugin uses the **dbi** library ([http://libdbi.sourceforge.net/](http://libdbi.sourceforge.net/)) to
connect to various databases, execute _SQL_ statements and read back the
results. _dbi_ is an acronym for "database interface" in case you were
wondering about the name. You can configure how each column is to be
interpreted and the plugin will generate one or more data sets from each row
returned according to these rules.

Because the plugin is very generic, the configuration is a little more complex
than those of other plugins. It usually looks something like this:

    <Plugin dbi>
      <Query "out_of_stock">
        Statement "SELECT category, COUNT(*) AS value FROM products WHERE in_stock = 0 GROUP BY category"
        # Use with MySQL 5.0.0 or later
        MinVersion 50000
        <Result>
          Type "gauge"
          InstancePrefix "out_of_stock"
          InstancesFrom "category"
          ValuesFrom "value"
        </Result>
      </Query>
      <Database "product_information">
        #Plugin "warehouse"
        Driver "mysql"
        Interval 120
        DriverOption "host" "localhost"
        DriverOption "username" "collectd"
        DriverOption "password" "aZo6daiw"
        DriverOption "dbname" "prod_info"
        SelectDB "prod_info"
        Query "out_of_stock"
      </Database>
    </Plugin>

The configuration above defines one query with one result and one database. The
query is then linked to the database with the **Query** option _within_ the
**<Database>** block. You can have any number of queries and databases
and you can also use the **Include** statement to split up the configuration
file in multiple, smaller files. However, the **<Query>** block _must_
precede the **<Database>** blocks, because the file is interpreted from
top to bottom!

The following is a complete list of options:

### **Query** blocks

Query blocks define _SQL_ statements and how the returned data should be
interpreted. They are identified by the name that is given in the opening line
of the block. Thus the name needs to be unique. Other than that, the name is
not used in collectd.

In each **Query** block, there is one or more **Result** blocks. **Result** blocks
define which column holds which value or instance information. You can use
multiple **Result** blocks to create multiple values from one returned row. This
is especially useful, when queries take a long time and sending almost the same
query again and again is not desirable.

Example:

    <Query "environment">
      Statement "select station, temperature, humidity from environment"
      <Result>
        Type "temperature"
        # InstancePrefix "foo"
        InstancesFrom "station"
        ValuesFrom "temperature"
      </Result>
      <Result>
        Type "humidity"
        InstancesFrom "station"
        ValuesFrom "humidity"
      </Result>
    </Query>

The following options are accepted:

- **Statement** _SQL_

    Sets the statement that should be executed on the server. This is **not**
    interpreted by collectd, but simply passed to the database server. Therefore,
    the SQL dialect that's used depends on the server collectd is connected to.

    The query has to return at least two columns, one for the instance and one
    value. You cannot omit the instance, even if the statement is guaranteed to
    always return exactly one line. In that case, you can usually specify something
    like this:

        Statement "SELECT \"instance\", COUNT(*) AS value FROM table"

    (That works with MySQL but may not be valid SQL according to the spec. If you
    use a more strict database server, you may have to select from a dummy table or
    something.)

    Please note that some databases, for example **Oracle**, will fail if you
    include a semicolon at the end of the statement.

- **MinVersion** _Version_
- **MaxVersion** _Value_

    Only use this query for the specified database version. You can use these
    options to provide multiple queries with the same name but with a slightly
    different syntax. The plugin will use only those queries, where the specified
    minimum and maximum versions fit the version of the database in use.

    The database version is determined by `dbi_conn_get_engine_version`, see the
    [libdbi documentation](http://libdbi.sourceforge.net/docs/programmers-guide/reference-conn.html#DBI-CONN-GET-ENGINE-VERSION)
    for details. Basically, each part of the version is assumed to be in the range
    from **00** to **99** and all dots are removed. So version "4.1.2" becomes
    "40102", version "5.0.42" becomes "50042".

    **Warning:** The plugin will use **all** matching queries, so if you specify
    multiple queries with the same name and **overlapping** ranges, weird stuff will
    happen. Don't to it! A valid example would be something along these lines:

        MinVersion 40000
        MaxVersion 49999
        ...
        MinVersion 50000
        MaxVersion 50099
        ...
        MinVersion 50100
        # No maximum

    In the above example, there are three ranges that don't overlap. The last one
    goes from version "5.1.0" to infinity, meaning "all later versions". Versions
    before "4.0.0" are not specified.

- **Type** _Type_

    The **type** that's used for each line returned. See [types.db(5)](http://man.he.net/man5/types.db) for more
    details on how types are defined. In short: A type is a predefined layout of
    data and the number of values and type of values has to match the type
    definition.

    If you specify "temperature" here, you need exactly one gauge column. If you
    specify "if\_octets", you will need two counter columns. See the **ValuesFrom**
    setting below.

    There must be exactly one **Type** option inside each **Result** block.

- **InstancePrefix** _prefix_

    Prepends _prefix_ to the type instance. If **InstancesFrom** (see below) is not
    given, the string is simply copied. If **InstancesFrom** is given, _prefix_ and
    all strings returned in the appropriate columns are concatenated together,
    separated by dashes _("-")_.

- **InstancesFrom** _column0_ \[_column1_ ...\]

    Specifies the columns whose values will be used to create the "type-instance"
    for each row. If you specify more than one column, the value of all columns
    will be joined together with dashes _("-")_ as separation characters.

    The plugin itself does not check whether or not all built instances are
    different. It's your responsibility to assure that each is unique. This is
    especially true, if you do not specify **InstancesFrom**: **You** have to make
    sure that only one row is returned in this case.

    If neither **InstancePrefix** nor **InstancesFrom** is given, the type-instance
    will be empty.

- **ValuesFrom** _column0_ \[_column1_ ...\]

    Names the columns whose content is used as the actual data for the data sets
    that are dispatched to the daemon. How many such columns you need is determined
    by the **Type** setting above. If you specify too many or not enough columns,
    the plugin will complain about that and no data will be submitted to the
    daemon.

    The actual data type in the columns is not that important. The plugin will
    automatically cast the values to the right type if it know how to do that. So
    it should be able to handle integer an floating point types, as well as strings
    (if they include a number at the beginning).

    There must be at least one **ValuesFrom** option inside each **Result** block.

- **MetadataFrom** \[_column0_ _column1_ ...\]

    Names the columns whose content is used as metadata for the data sets
    that are dispatched to the daemon.

    The actual data type in the columns is not that important. The plugin will
    automatically cast the values to the right type if it know how to do that. So
    it should be able to handle integer an floating point types, as well as strings
    (if they include a number at the beginning).

### **Database** blocks

Database blocks define a connection to a database and which queries should be
sent to that database. Since the used "dbi" library can handle a wide variety
of databases, the configuration is very generic. If in doubt, refer to libdbi's
documentation - we stick as close to the terminology used there.

Each database needs a "name" as string argument in the starting tag of the
block. This name will be used as "PluginInstance" in the values submitted to
the daemon. Other than that, that name is not used.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting query results from
    this **Database**. Defaults to `dbi`.

- **Interval** _Interval_

    Sets the interval (in seconds) in which the values will be collected from this
    database. By default the global **Interval** setting will be used.

- **Driver** _Driver_

    Specifies the driver to use to connect to the database. In many cases those
    drivers are named after the database they can connect to, but this is not a
    technical necessity. These drivers are sometimes referred to as "DBD",
    **D**ata**B**ase **D**river, and some distributions ship them in separate
    packages. Drivers for the "dbi" library are developed by the **libdbi-drivers**
    project at [http://libdbi-drivers.sourceforge.net/](http://libdbi-drivers.sourceforge.net/).

    You need to give the driver name as expected by the "dbi" library here. You
    should be able to find that in the documentation for each driver. If you
    mistype the driver name, the plugin will dump a list of all known driver names
    to the log.

- **DriverOption** _Key_ _Value_

    Sets driver-specific options. What option a driver supports can be found in the
    documentation for each driver, somewhere at
    [http://libdbi-drivers.sourceforge.net/](http://libdbi-drivers.sourceforge.net/). However, the options "host",
    "username", "password", and "dbname" seem to be de facto standards.

    DBDs can register two types of options: String options and numeric options. The
    plugin will use the `dbi_conn_set_option` function when the configuration
    provides a string and the `dbi_conn_require_option_numeric` function when the
    configuration provides a number. So these two lines will actually result in
    different calls being used:

        DriverOption "Port" 1234      # numeric
        DriverOption "Port" "1234"    # string

    Unfortunately, drivers are not too keen to report errors when an unknown option
    is passed to them, so invalid settings here may go unnoticed. This is not the
    plugin's fault, it will report errors if it gets them from the library /
    the driver. If a driver complains about an option, the plugin will dump a
    complete list of all options understood by that driver to the log. There is no
    way to programmatically find out if an option expects a string or a numeric
    argument, so you will have to refer to the appropriate DBD's documentation to
    find this out. Sorry.

- **SelectDB** _Database_

    In some cases, the database name you connect with is not the database name you
    want to use for querying data. If this option is set, the plugin will "select"
    (switch to) that database after the connection is established.

- **Query** _QueryName_

    Associates the query named _QueryName_ with this database connection. The
    query needs to be defined _before_ this statement, i. e. all query
    blocks you want to refer to must be placed above the database block you want to
    refer to them from.

- **Host** _Hostname_

    Sets the **host** field of _value lists_ to _Hostname_ when dispatching
    values. Defaults to the global hostname setting.

## Plugin `dcpmm`

The _dcpmm plugin_ will collect Intel(R) Optane(TM) DC Persistent Memory related performance statistics.
The plugin requires root privileges to perform the statistics collection.

**Synopsis:**

    <Plugin "dcpmm">
      Interval 10.0
      CollectHealth false
      CollectPerfMetrics true
      EnableDispatchAll false
    </Plugin>

- **Interval** _time in seconds_

    Sets the _Interval (in seconds)_ in which the values will be collected. Defaults to `global Interval` value.
    This will override the _global Interval_ for _dcpmm_ plugin. None of the other plugins will be affected.

- **CollectHealth** _true_|_false_

    Collects health information. _CollectHealth and CollectPerfMetrics cannot be true at the same time_. Defaults to `false`.

    The health information metrics are the following:
      health\_status              Overall health summary (0: normal | 1: non-critical | 2: critical | 3: fatal).
      lifespan\_remaining         The module’s remaining life as a percentage value of factory expected life span.
      lifespan\_used              The module’s used life as a percentage value of factory expected life span.
      power\_on\_time              The lifetime the DIMM has been powered on in seconds.
      uptime                     The current uptime of the DIMM for the current power cycle in seconds.
      last\_shutdown\_time         The time the system was last shutdown. The time is represented in epoch (seconds).
      media\_temperature          The media’s current temperature in degree Celsius.
      controller\_temperature     The controller’s current temperature in degree Celsius.
      max\_media\_temperature      The media’s the highest temperature reported in degree Celsius.
      max\_controller\_temperature The controller’s highest temperature reported in degree Celsius.
      tsc\_cycles                 The number of tsc cycles during each interval.
      epoch                      The timestamp in seconds at which the metrics are collected from DCPMM DIMMs.

- **CollectPerfMetrics** _true_|_false_

    Collects memory performance metrics. _CollectHealth and CollectPerfMetrics cannot be true at the same time_. Defaults to `true`.

    The memory performance metrics are the following:
      total\_bytes\_read    Number of bytes transacted by the read operations.
      total\_bytes\_written Number of bytes transacted by the write operations.
      read\_64B\_ops\_rcvd   Number of read operations performed to the physical media in 64 bytes granularity.
      write\_64B\_ops\_rcvd  Number of write operations performed to the physical media in 64 bytes granularity.
      media\_read\_ops      Number of read operations performed to the physical media.
      media\_write\_ops     Number of write operations performed to the physical media.
      host\_reads          Number of read operations received from the CPU (memory controller).
      host\_writes         Number of write operations received from the CPU (memory controller).
      read\_hit\_ratio      Measures the efficiency of the buffer in the read path. Range of 0.0 - 1.0.
      write\_hit\_ratio     Measures the efficiency of the buffer in the write path. Range of 0.0 - 1.0.
      tsc\_cycles          The number of tsc cycles during each interval.
      epoch               The timestamp in seconds at which the metrics are collected from DCPMM DIMMs.

- **EnableDispatchAll** _false_

    This parameter helps to seamlessly enable simultaneous health and memory perf metrics collection in future.
    This is unused at the moment and _must_ always be _false_.

## Plugin `df`

- **Device** _Device_

    Select partitions based on the devicename.

    See `/"IGNORELISTS"` for details.

- **MountPoint** _Directory_

    Select partitions based on the mountpoint.

    See `/"IGNORELISTS"` for details.

- **FSType** _FSType_

    Select partitions based on the filesystem type.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Invert the selection: If set to true, all partitions **except** the ones that
    match any one of the criteria are collected. By default only selected
    partitions are collected if a selection is made. If no selection is configured
    at all, **all** partitions are selected.

- **LogOnce** **false**|**false**

    Only log stat() errors once.

- **ReportByDevice** **true**|**false**

    Report using the device name rather than the mountpoint. i.e. with this _false_,
    (the default), it will report a disk as "root", but with it _true_, it will be
    "sda1" (or whichever).

- **ReportInodes** **true**|**false**

    Enables or disables reporting of free, reserved and used inodes. Defaults to
    inode collection being disabled.

    Enable this option if inodes are a scarce resource for you, usually because
    many small files are stored on the disk. This is a usual scenario for mail
    transfer agents and web caches.

- **ValuesAbsolute** **true**|**false**

    Enables or disables reporting of free and used disk space in 1K-blocks.
    Defaults to **true**.

- **ValuesPercentage** **false**|**true**

    Enables or disables reporting of free and used disk space in percentage.
    Defaults to **false**.

    This is useful for deploying _collectd_ on the cloud, where machines with
    different disk size may exist. Then it is more practical to configure
    thresholds based on relative disk size.

## Plugin `disk`

The `disk` plugin collects information about the usage of physical disks and
logical disks (partitions). Values collected are the number of octets written
to and read from a disk or partition, the number of read/write operations
issued to the disk and a rather complex "time" it took for these commands to be
issued.

Using the following two options you can ignore some disks or configure the
collection only of specific disks.

- **Disk** _Name_

    Select the disk _Name_. Whether it is collected or ignored depends on the
    **IgnoreSelected** setting, see below. As with other plugins that use the
    daemon's ignorelist functionality, a string that starts and ends with a slash
    is interpreted as a regular expression. Examples:

        Disk "sdd"
        Disk "/hda[34]/"

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Sets whether selected disks, i. e. the ones matches by any of the **Disk**
    statements, are ignored or if all other disks are ignored. The behavior
    (hopefully) is intuitive: If no **Disk** option is configured, all disks are
    collected. If at least one **Disk** option is given and no **IgnoreSelected** or
    set to **false**, **only** matching disks will be collected. If **IgnoreSelected**
    is set to **true**, all disks are collected **except** the ones matched.

- **UseBSDName** **true**|**false**

    Whether to use the device's "BSD Name", on Mac OS X, instead of the
    default major/minor numbers. Requires collectd to be built with Apple's
    IOKitLib support.

- **UdevNameAttr** _Attribute_

    Attempt to override disk instance name with the value of a specified udev
    attribute when built with **libudev**.  If the attribute is not defined for the
    given device, the default name is used. Example:

        UdevNameAttr "DM_NAME"

    Please note that using an attribute that does not differentiate between the
    whole disk and its particular partitions (like **ID\_SERIAL**) will result in
    data about the whole disk and each partition being mixed together incorrectly.
    In this case, you can use **ID\_COLLECTD** attribute that is provided by
    _contrib/99-storage-collectd.rules_ udev rule file instead.

## Plugin `dns`

- **Interface** _Interface_

    The dns plugin uses **libpcap** to capture dns traffic and analyzes it. This
    option sets the interface that should be used. If this option is not set, or
    set to "any", the plugin will try to get packets from **all** interfaces. This
    may not work on certain platforms, such as Mac OS X.

- **IgnoreSource** _IP-address_

    Ignore packets that originate from this address.

- **SelectNumericQueryTypes** **true**|**false**

    Enabled by default, collects unknown (and thus presented as numeric only) query types.

## Plugin `dpdkevents`

The _dpdkevents plugin_ collects events from DPDK such as link status of
network ports and Keep Alive status of DPDK logical cores.
In order to get Keep Alive events following requirements must be met:
\- DPDK >= 16.07
\- support for Keep Alive implemented in DPDK application. More details can
be found here: http://dpdk.org/doc/guides/sample\_app\_ug/keep\_alive.html

**Synopsis:**

    <Plugin "dpdkevents">
      <EAL>
        Coremask "0x1"
        MemoryChannels "4"
        FilePrefix "rte"
      </EAL>
      <Event "link_status">
        SendEventsOnUpdate true
        EnabledPortMask 0xffff
        PortName "interface1"
        PortName "interface2"
        SendNotification false
      </Event>
      <Event "keep_alive">
        SendEventsOnUpdate true
        LCoreMask "0xf"
        KeepAliveShmName "/dpdk_keepalive_shm_name"
        SendNotification false
      </Event>
    </Plugin>

**Options:**

### The EAL block

- **Coremask** _Mask_
- **Memorychannels** _Channels_

    Number of memory channels per processor socket.

- **FilePrefix** _File_

    The prefix text used for hugepage filenames. The filename will be set to
    /var/run/.&lt;prefix>\_config where prefix is what is passed in by the user.

### The Event block

The **Event** block defines configuration for specific event. It accepts a
single argument which specifies the name of the event.

#### Link Status event

- **SendEventOnUpdate** _true|false_

    If set to true link status value will be dispatched only when it is
    different from previously read value. This is an optional argument - default
    value is true.

- **EnabledPortMask** _Mask_

    A hexidecimal bit mask of the DPDK ports which should be enabled. A mask
    of 0x0 means that all ports will be disabled. A bitmask of all F's means
    that all ports will be enabled. This is an optional argument - by default
    all ports are enabled.

- **PortName** _Name_

    A string containing an optional name for the enabled DPDK ports. Each PortName
    option should contain only one port name; specify as many PortName options as
    desired. Default naming convention will be used if PortName is blank. If there
    are less PortName options than there are enabled ports, the default naming
    convention will be used for the additional ports.

- **SendNotification** _true|false_

    If set to true, link status notifications are sent, instead of link status
    being collected as a statistic. This is an optional argument - default
    value is false.

#### Keep Alive event

- **SendEventOnUpdate** _true|false_

    If set to true keep alive value will be dispatched only when it is
    different from previously read value. This is an optional argument - default
    value is true.

- **LCoreMask** _Mask_

    An hexadecimal bit mask of the logical cores to monitor keep alive state.

- **KeepAliveShmName** _Name_

    Shared memory name identifier that is used by secondary process to monitor
    the keep alive cores state.

- **SendNotification** _true|false_

    If set to true, keep alive notifications are sent, instead of keep alive
    information being collected as a statistic. This is an optional
    argument - default value is false.

## Plugin `dpdkstat`

The _dpdkstat plugin_ collects information about DPDK interfaces using the
extended NIC stats API in DPDK.

**Synopsis:**

    <Plugin "dpdkstat">
      <EAL>
        Coremask "0x4"
        MemoryChannels "4"
        FilePrefix "rte"
        SocketMemory "1024"
        LogLevel "7"
        RteDriverLibPath "/usr/lib/dpdk-pmd"
      </EAL>
      SharedMemObj "dpdk_collectd_stats_0"
      EnabledPortMask 0xffff
      PortName "interface1"
      PortName "interface2"
    </Plugin>

**Options:**

### The EAL block

- **Coremask** _Mask_

    A string containing an hexadecimal bit mask of the cores to run on. Note that
    core numbering can change between platforms and should be determined beforehand.

- **Memorychannels** _Channels_

    A string containing a number of memory channels per processor socket.

- **FilePrefix** _File_

    The prefix text used for hugepage filenames. The filename will be set to
    /var/run/.&lt;prefix>\_config where prefix is what is passed in by the user.

- **SocketMemory** _MB_

    A string containing amount of Memory to allocate from hugepages on specific
    sockets in MB. This is an optional value.

- **LogLevel** _LogLevel\_number_

    A string containing log level number. This parameter is optional.
    If parameter is not present then default value "7" - (INFO) is used.
    Value "8" - (DEBUG) can be set to enable debug traces.

- **RteDriverLibPath** _Path_

    A string containing path to shared pmd driver lib or path to directory,
    where shared pmd driver libs are available. This parameter is optional.
    This parameter enable loading of shared pmd driver libs from defined path.
    E.g.: "/usr/lib/dpdk-pmd/librte\_pmd\_i40e.so"
    or    "/usr/lib/dpdk-pmd"

- **SharedMemObj** _Mask_

    A string containing the name of the shared memory object that should be used to
    share stats from the DPDK secondary process to the collectd dpdkstat plugin.
    Defaults to dpdk\_collectd\_stats if no other value is configured.

- **EnabledPortMask** _Mask_

    A hexidecimal bit mask of the DPDK ports which should be enabled. A mask
    of 0x0 means that all ports will be disabled. A bitmask of all Fs means
    that all ports will be enabled. This is an optional argument - default
    is all ports enabled.

- **PortName** _Name_

    A string containing an optional name for the enabled DPDK ports. Each PortName
    option should contain only one port name; specify as many PortName options as
    desired. Default naming convention will be used if PortName is blank. If there
    are less PortName options than there are enabled ports, the default naming
    convention will be used for the additional ports.

## Plugin `dpdk_telemetry`

The _ dpdk\_telemetry _ plugin collects DPDK ethernet device metrics via
dpdk\_telemetry library.

The plugin retrieves metrics from a DPDK packet forwarding application
by sending the JSON formatted message via a UNIX domain socket.
The DPDK telemetry component will respond with a JSON formatted reply,
delivering the requested metrics. The plugin parses the JSON data,
and publishes the metric values to collectd for further use.

**Synopsis:**

    <Plugin dpdk_telemetry>
      ClientSocketPath "/var/run/.client"
      DpdkSocketPath "/var/run/dpdk/rte/telemetry"
    </Plugin>

**Options:**

- **ClientSocketPath** _Client\_Path_

    The UNIX domain client socket at _Client\_Path_ to receive messages from DPDK
    telemetry library. Defaults to **"/var/run/.client"**.

- **DpdkSocketPath** _Dpdk\_Path_

    The UNIX domain DPDK telemetry socket to be connected at _Dpdk\_Path_ to send
    messages. Defaults to **"/var/run/dpdk/rte/telemetry"**.

## Plugin `email`

- **SocketFile** _Path_

    Sets the socket-file which is to be created.

- **SocketGroup** _Group_

    If running as root change the group of the UNIX-socket after it has been
    created. Defaults to **collectd**.

- **SocketPerms** _Permissions_

    Change the file permissions of the UNIX-socket after it has been created. The
    permissions must be given as a numeric, octal value as you would pass to
    [chmod(1)](http://man.he.net/man1/chmod). Defaults to **0770**.

- **MaxConns** _Number_

    Sets the maximum number of connections that can be handled in parallel. Since
    this many threads will be started immediately setting this to a very high
    value will waste valuable resources. Defaults to **5** and will be forced to be
    at most **16384** to prevent typos and dumb mistakes.

## Plugin `ethstat`

The _ethstat plugin_ collects information about network interface cards (NICs)
by talking directly with the underlying kernel driver using [ioctl(2)](http://man.he.net/man2/ioctl).

**Synopsis:**

    <Plugin "ethstat">
      Interface "eth0"
      Map "rx_csum_offload_errors" "if_rx_errors" "checksum_offload"
      Map "multicast" "if_multicast"
    </Plugin>

**Options:**

- **Interface** _Name_

    Collect statistical information about interface _Name_.

- **Map** _Name_ _Type_ \[_TypeInstance_\]

    By default, the plugin will submit values as type `derive` and _type
    instance_ set to _Name_, the name of the metric as reported by the driver. If
    an appropriate **Map** option exists, the given _Type_ and, optionally,
    _TypeInstance_ will be used.

- **MappedOnly** **true**|**false**

    When set to **true**, only metrics that can be mapped to a _type_ will be
    collected, all other metrics will be ignored. Defaults to **false**.

## Plugin `exec`

Please make sure to read [collectd-exec(5)](http://man.he.net/man5/collectd-exec) before using this plugin. It
contains valuable information on when the executable is executed and the
output that is expected from it.

- **Exec** _User_\[:\[_Group_\]\] _Executable_ \[_&lt;arg>_ \[_&lt;arg>_ ...\]\]
- **NotificationExec** _User_\[:\[_Group_\]\] _Executable_ \[_&lt;arg>_ \[_&lt;arg>_ ...\]\]

    Execute the executable _Executable_ as user _User_. If the user name is
    followed by a colon and a group name, the effective group is set to that group.
    The real group and saved-set group will be set to the default group of that
    user. If no group is given the effective group ID will be the same as the real
    group ID.

    Please note that in order to change the user and/or group the daemon needs
    superuser privileges. If the daemon is run as an unprivileged user you must
    specify the same user/group here. If the daemon is run with superuser
    privileges, you must supply a non-root user here.

    The executable may be followed by optional arguments that are passed to the
    program. Please note that due to the configuration parsing numbers and boolean
    values may be changed. If you want to be absolutely sure that something is
    passed as-is please enclose it in quotes.

    The **Exec** and **NotificationExec** statements change the semantics of the
    programs executed, i. e. the data passed to them and the response
    expected from them. This is documented in great detail in [collectd-exec(5)](http://man.he.net/man5/collectd-exec).

## Plugin `fhcount`

The `fhcount` plugin provides statistics about used, unused and total number of
file handles on Linux.

The _fhcount plugin_ provides the following configuration options:

- **ValuesAbsolute** **true**|**false**

    Enables or disables reporting of file handles usage in absolute numbers,
    e.g. file handles used. Defaults to **true**.

- **ValuesPercentage** **false**|**true**

    Enables or disables reporting of file handles usage in percentages, e.g.
    percent of file handles used. Defaults to **false**.

## Plugin `filecount`

The `filecount` plugin counts the number of files in a certain directory (and
its subdirectories) and their combined size. The configuration is very straight
forward:

    <Plugin "filecount">
      <Directory "/var/qmail/queue/mess">
        Instance "qmail-message"
      </Directory>
      <Directory "/var/qmail/queue/todo">
        Instance "qmail-todo"
      </Directory>
      <Directory "/var/lib/php5">
        Instance "php5-sessions"
        Name "sess_*"
      </Directory>
    </Plugin>

The example above counts the number of files in QMail's queue directories and
the number of PHP5 sessions. Jfiy: The "todo" queue holds the messages that
QMail has not yet looked at, the "message" queue holds the messages that were
classified into "local" and "remote".

As you can see, the configuration consists of one or more `Directory` blocks,
each of which specifies a directory in which to count the files. Within those
blocks, the following options are recognized:

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to **filecount**.

- **Instance** _Instance_

    Sets the plugin instance to _Instance_. If not given, the instance is set to
    the directory name with all slashes replaced by underscores and all leading
    underscores removed. Empty value is allowed.

- **Name** _Pattern_

    Only count files that match _Pattern_, where _Pattern_ is a shell-like
    wildcard as understood by [fnmatch(3)](http://man.he.net/man3/fnmatch). Only the **filename** is checked
    against the pattern, not the entire path. In case this makes it easier for you:
    This option has been named after the **-name** parameter to [find(1)](http://man.he.net/man1/find).

- **MTime** _Age_

    Count only files of a specific age: If _Age_ is greater than zero, only files
    that haven't been touched in the last _Age_ seconds are counted. If _Age_ is
    a negative number, this is inversed. For example, if **-60** is specified, only
    files that have been modified in the last minute will be counted.

    The number can also be followed by a "multiplier" to easily specify a larger
    timespan. When given in this notation, the argument must in quoted, i. e.
    must be passed as string. So the **-60** could also be written as **"-1m"** (one
    minute). Valid multipliers are `s` (second), `m` (minute), `h` (hour), `d`
    (day), `w` (week), and `y` (year). There is no "month" multiplier. You can
    also specify fractional numbers, e. g. **"0.5d"** is identical to
    **"12h"**.

- **Size** _Size_

    Count only files of a specific size. When _Size_ is a positive number, only
    files that are at least this big are counted. If _Size_ is a negative number,
    this is inversed, i. e. only files smaller than the absolute value of
    _Size_ are counted.

    As with the **MTime** option, a "multiplier" may be added. For a detailed
    description see above. Valid multipliers here are `b` (byte), `k` (kilobyte),
    `m` (megabyte), `g` (gigabyte), `t` (terabyte), and `p` (petabyte). Please
    note that there are 1000 bytes in a kilobyte, not 1024.

- **Recursive** _true_|_false_

    Controls whether or not to recurse into subdirectories. Enabled by default.

- **IncludeHidden** _true_|_false_

    Controls whether or not to include "hidden" files and directories in the count.
    "Hidden" files and directories are those, whose name begins with a dot.
    Defaults to _false_, i.e. by default hidden files and directories are ignored.

- **RegularOnly** _true_|_false_

    Controls whether or not to include only regular files in the count.
    Defaults to _true_, i.e. by default non regular files are ignored.

- **FilesSizeType** _Type_

    Sets the type used to dispatch files combined size. Empty value ("") disables
    reporting. Defaults to **bytes**.

- **FilesCountType** _Type_

    Sets the type used to dispatch number of files. Empty value ("") disables
    reporting. Defaults to **files**.

- **TypeInstance** _Instance_

    Sets the _type instance_ used to dispatch values. Defaults to an empty string
    (no plugin instance).

## Plugin `GenericJMX`

The _GenericJMX plugin_ is written in _Java_ and therefore documented in
[collectd-java(5)](http://man.he.net/man5/collectd-java).

## Plugin `gmond`

The _gmond_ plugin received the multicast traffic sent by **gmond**, the
statistics collection daemon of Ganglia. Mappings for the standard "metrics"
are built-in, custom mappings may be added via **Metric** blocks, see below.

Synopsis:

    <Plugin "gmond">
      MCReceiveFrom "239.2.11.71" "8649"
      <Metric "swap_total">
        Type "swap"
        TypeInstance "total"
        DataSource "value"
      </Metric>
      <Metric "swap_free">
        Type "swap"
        TypeInstance "free"
        DataSource "value"
      </Metric>
    </Plugin>

The following metrics are built-in:

- load\_one, load\_five, load\_fifteen
- cpu\_user, cpu\_system, cpu\_idle, cpu\_nice, cpu\_wio
- mem\_free, mem\_shared, mem\_buffers, mem\_cached, mem\_total
- bytes\_in, bytes\_out
- pkts\_in, pkts\_out

Available configuration options:

- **MCReceiveFrom** _MCGroup_ \[_Port_\]

    Sets sets the multicast group and UDP port to which to subscribe.

    Default: **239.2.11.71** / **8649**

- <**Metric** _Name_>

    These blocks add a new metric conversion to the internal table. _Name_, the
    string argument to the **Metric** block, is the metric name as used by Ganglia.

    - **Type** _Type_

        Type to map this metric to. Required.

    - **TypeInstance** _Instance_

        Type-instance to use. Optional.

    - **DataSource** _Name_

        Data source to map this metric to. If the configured type has exactly one data
        source, this is optional. Otherwise the option is required.

## Plugin `gps`

The `gps plugin` connects to gpsd on the host machine.
The host, port, timeout and pause are configurable.

This is useful if you run an NTP server using a GPS for source and you want to
monitor it.

Mind your GPS must send $--GSA for having the data reported!

The following elements are collected:

- **satellites**

    Number of satellites used for fix (type instance "used") and in view (type
    instance "visible"). 0 means no GPS satellites are visible.

- **dilution\_of\_precision**

    Vertical and horizontal dilution (type instance "horizontal" or "vertical").
    It should be between 0 and 3.
    Look at the documentation of your GPS to know more.

Synopsis:

    LoadPlugin gps
    <Plugin "gps">
      # Connect to localhost on gpsd regular port:
      Host "127.0.0.1"
      Port "2947"
      # 15 ms timeout
      Timeout 0.015
      # PauseConnect of 5 sec. between connection attempts.
      PauseConnect 5
    </Plugin>

Available configuration options:

- **Host** _Host_

    The host on which gpsd daemon runs. Defaults to **localhost**.

- **Port** _Port_

    Port to connect to gpsd on the host machine. Defaults to **2947**.

- **Timeout** _Seconds_

    Timeout in seconds (default 0.015 sec).

    The GPS data stream is fetch by the plugin form the daemon.
    It waits for data to be available, if none arrives it times out
    and loop for another reading.
    Mind to put a low value gpsd expects value in the micro-seconds area
    (recommended is 500 us) since the waiting function is blocking.
    Value must be between 500 us and 5 sec., if outside that range the
    default value is applied.

    This only applies from gpsd release-2.95.

- **PauseConnect** _Seconds_

    Pause to apply between attempts of connection to gpsd in seconds (default 5 sec).

## Plugin `gpu_nvidia`

Efficiently collects various statistics from the system's NVIDIA GPUs using the
NVML library. Currently collected are fan speed, core temperature, percent
load, percent memory used, compute and memory frequencies, and power
consumption.

- **GPUIndex**

    If one or more of these options is specified, only GPUs at that index (as
    determined by nvidia-utils through _nvidia-smi_) have statistics collected.
    If no instance of this option is specified, all GPUs are monitored.

- **IgnoreSelected**

    If set to true, all detected GPUs **except** the ones at indices specified by
    **GPUIndex** entries are collected. For greater clarity, setting IgnoreSelected
    without any GPUIndex directives will result in **no** statistics being
    collected.

- **InstanceByGPUIndex**

    If set to false, the GPU ID will not be part of the plugin instance. The default
    is 'GPU ID'-'GPU name'

- **InstanceByGPUName**

    If set to false, the GPU name will not be part of the plugin instance. The 
    default is 'GPU ID'-'GPU name'

## Plugin `grpc`

The _grpc_ plugin provides an RPC interface to submit values to or query
values from collectd based on the open source gRPC framework. It exposes an
end-point for dispatching values to the daemon.

The **gRPC** homepage can be found at [https://grpc.io/](https://grpc.io/).

- **Server** _Host_ _Port_

    The **Server** statement sets the address of a server to which to send metrics
    via the `DispatchValues` function.

    The argument _Host_ may be a hostname, an IPv4 address, or an IPv6 address.

    Optionally, **Server** may be specified as a configuration block which supports
    the following options:

    - **EnableSSL** **false**|**true**

        Whether to require SSL for outgoing connections. Default: false.

    - **SSLCACertificateFile** _Filename_
    - **SSLCertificateFile** _Filename_
    - **SSLCertificateKeyFile** _Filename_

        Filenames specifying SSL certificate and key material to be used with SSL
        connections.

- **Listen** _Host_ _Port_

    The **Listen** statement sets the network address to bind to. When multiple
    statements are specified, the daemon will bind to all of them. If none are
    specified, it defaults to **0.0.0.0:50051**.

    The argument _Host_ may be a hostname, an IPv4 address, or an IPv6 address.

    Optionally, **Listen** may be specified as a configuration block which
    supports the following options:

    - **EnableSSL** _true_|_false_

        Whether to enable SSL for incoming connections. Default: false.

    - **SSLCACertificateFile** _Filename_
    - **SSLCertificateFile** _Filename_
    - **SSLCertificateKeyFile** _Filename_

        Filenames specifying SSL certificate and key material to be used with SSL
        connections.

    - **VerifyPeer** **true**|**false**

        When enabled, a valid client certificate is required to connect to the server.
        When disabled, a client certifiacte is not requested and any unsolicited client
        certificate is accepted.
        Enabled by default.

## Plugin `hddtemp`

To get values from **hddtemp** collectd connects to **localhost** (127.0.0.1),
port **7634/tcp**. The **Host** and **Port** options can be used to change these
default values, see below. `hddtemp` has to be running to work correctly. If
`hddtemp` is not running timeouts may appear which may interfere with other
statistics..

The **hddtemp** homepage can be found at
[http://www.guzu.net/linux/hddtemp.php](http://www.guzu.net/linux/hddtemp.php).

- **Host** _Hostname_

    Hostname to connect to. Defaults to **127.0.0.1**.

- **Port** _Port_

    TCP-Port to connect to. Defaults to **7634**.

## Plugin `hugepages`

To collect **hugepages** information, collectd reads directories
"/sys/devices/system/node/\*/hugepages" and
"/sys/kernel/mm/hugepages".
Reading of these directories can be disabled by the following
options (default is enabled).

- **ReportPerNodeHP** **true**|**false**

    If enabled, information will be collected from the hugepage
    counters in "/sys/devices/system/node/\*/hugepages".
    This is used to check the per-node hugepage statistics on
    a NUMA system.

- **ReportRootHP** **true**|**false**

    If enabled, information will be collected from the hugepage
    counters in "/sys/kernel/mm/hugepages".
    This can be used on both NUMA and non-NUMA systems to check
    the overall hugepage statistics.

- **ValuesPages** **true**|**false**

    Whether to report hugepages metrics in number of pages.
    Defaults to **true**.

- **ValuesBytes** **false**|**true**

    Whether to report hugepages metrics in bytes.
    Defaults to **false**.

- **ValuesPercentage** **false**|**true**

    Whether to report hugepages metrics as percentage.
    Defaults to **false**.

## Plugin `infiniband`

The `infiniband` plugin collects information about IB ports. Metrics are
gathered from `/sys/class/infiniband/DEVICE/port/PORTNUM/*`, and _Port_ names
are formatted like `DEVICE:PORTNUM` (see examples below).

**Options:**

- **Port** _Port_

    Select the port _Port_. Whether it is collected or ignored depends on the
    **IgnoreSelected** setting, see below. As with other plugins that use the
    daemon's ignorelist functionality, a string that starts and ends with a slash
    is interpreted as a regular expression. Examples:

        Port "mlx5_0:1"
        Port "/mthca0:[0-9]/"

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    Sets whether selected ports are ignored or if all other ports are ignored. The
    behavior (hopefully) is intuitive: If no **Port** option is configured, all
    ports are collected. If at least one **Port** option is given and
    **IgnoreSelected** is not given or set to _false_, **only** matching ports will
    be collected. If **IgnoreSelected** is set to **true**, all ports are collected
    **except** the ones matched.

## Plugin `intel_pmu`

The _intel\_pmu_ plugin collects performance counters data on Intel CPUs using
Linux perf interface. All events are reported on a per core basis.

**Note:** When using intel\_pmu plugin number of reading threads in collectd
should be adjusted accordingly. The value should be more than a half of
configured cores, so for 60 monitored cores the recommendation is to set
**ReadThreads** > 30. The optimal number of **WriteThreads** depends on volume
of metrics from read plugins, interval and number of enabled write plugins.
The above adjustments can help with performance scaling when monitoring a high
number of events on many cores.

**Synopsis:**

    <Plugin intel_pmu>
      EventList "/var/cache/pmu/GenuineIntel-6-55-4-core.json"
      HardwareEvents "L2_RQSTS.CODE_RD_HIT,L2_RQSTS.CODE_RD_MISS" "L2_RQSTS.ALL_CODE_RD"
      Cores "0-3" "4,6" "[12-15]"
      HardwareEvents "L2_RQSTS.PF_MISS"
      Cores "[1,2]"
      HardwareEvents "INST_RETIRED.ANY" "CPU_CLK_UNHALTED.THREAD"
      Cores ""
      AggregateUncorePMUs true
    </Plugin>

**Options:**

- **EventList** _filename_

    JSON performance counter event list file name. To be able to monitor all Intel
    CPU specific events JSON event list file should be downloaded. Use the pmu-tools
    event\_download.py script to download event list for current CPU.

- **HardwareEvents** _events_

    This field is a list of event names or groups of comma separated event names.
    This option requires **EventList** option to be configured. If "All" is
    provided, all events from **EventList** are going to be loaded. This option
    can be used multiple times in pair with **Cores** option, as shown in example
    above.

- **Cores** _cores groups_

    All events are reported on a per core basis. Monitoring of the events can be
    configured for a group of cores (aggregated statistics). This field defines
    groups of cores on which to monitor supported events. The field is represented
    as list of strings with core group values. Each string represents a list of
    cores in a group. If a group is enclosed in square brackets each core is added
    individually to a separate group (that is statistics are not aggregated).
    Allowed formats are:
        0,1,2,3
        0-10,20-18
        1,3,5-8,10,0x10-12
        \[4-15,32-63\]

    If an empty string is provided as value for this field default cores
    configuration is applied - that is separate group is created for each core.
    This option can be used once for every **HardwareEvents** set.

- **AggregateUncorePMUs** **false**|**true**

    This option toggles the event value reporting from all the uncore PMUs to either
    dispatch as aggregated value in a single metric or dispatch as individual
    values. If **AggregateUncorePMUs** is set to 'true', uncore events from the
    various PMU subsystems across uncore are reported as a single metric, usually
    reported as single 'Core0' events. The total value is obtained by summing all
    counters across all the units (e.g. CHAs). If **AggregateUncorePMUs** is set to
    'false', values from the individual PMU subsystems across uncore are dispatched
    separately with PMU name/number added to Collectd's _plugin\_instance_.

## Plugin `intel_rdt`

The _intel\_rdt_ plugin collects information provided by monitoring features of
Intel Resource Director Technology (Intel(R) RDT) like Cache Monitoring
Technology (CMT), Memory Bandwidth Monitoring (MBM). These features provide
information about utilization of shared resources. CMT monitors last level cache
occupancy (LLC). MBM supports two types of events reporting local and remote
memory bandwidth. Local memory bandwidth (MBL) reports the bandwidth of
accessing memory associated with the local socket. Remote memory bandwidth (MBR)
reports the bandwidth of accessing the remote socket. Also this technology
allows to monitor instructions per clock (IPC).
Monitor events are hardware dependant. Monitoring capabilities are detected on
plugin initialization and only supported events are monitored.

**Note:** _intel\_rdt_ plugin is using model-specific registers (MSRs), which
require an additional capability to be enabled if collectd is run as a service.
Please refer to _contrib/systemd.collectd.service_ file for more details.

**Synopsis:**

    <Plugin "intel_rdt">
      MonIPCEnabled true
      MonLLCRefEnabled false
      Cores "0-2" "3,4,6" "8-10,15"
      Processes "sshd,qemu-system-x86" "bash"
    </Plugin>

**Options:**

- **Interval** _seconds_

    The interval within which to retrieve statistics on monitored events in seconds.
    For milliseconds divide the time by 1000 for example if the desired interval
    is 50ms, set interval to 0.05. Due to limited capacity of counters it is not
    recommended to set interval higher than 1 sec.

- **MonIPCEnabled** **true**|**false**

    Determines whether or not to enable IPC monitoring. If set to **true** (the
    default), IPC monitoring statistics will be collected by intel\_rdt plugin.

- **MonLLCRefEnabled** **true**|**false**

    Determines whether or not to enable LLC references monitoring. If set to
    **false** (the default), LLC references monitoring statistics will not be
    collected by intel\_rdt plugin.

- **Cores** _cores groups_

    Monitoring of the events can be configured for group of cores
    (aggregated statistics). This field defines groups of cores on which to monitor
    supported events. The field is represented as list of strings with core group
    values. Each string represents a list of cores in a group. Allowed formats are:
        0,1,2,3
        0-10,20-18
        1,3,5-8,10,0x10-12

    If an empty string is provided as value for this field default cores
    configuration is applied - a separate group is created for each core.

- **Processes** _process names groups_

    Monitoring of the events can be configured for group of processes
    (aggregated statistics). This field defines groups of processes on which to
    monitor supported events. The field is represented as list of strings with
    process names group values. Each string represents a list of processes in a
    group. Allowed format is:
        sshd,bash,qemu

**Note:** By default global interval is used to retrieve statistics on monitored
events. To configure a plugin specific interval use **Interval** option of the
intel\_rdt <LoadPlugin> block. For milliseconds divide the time by 1000 for
example if the desired interval is 50ms, set interval to 0.05.
Due to limited capacity of counters it is not recommended to set interval higher
than 1 sec.

## Plugin `interface`

- **Interface** _Interface_

    Select this interface. By default these interfaces will then be collected. For
    a more detailed description see **IgnoreSelected** below.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    If no configuration is given, the **interface**-plugin will collect data from
    all interfaces. This may not be practical, especially for loopback- and
    similar interfaces. Thus, you can use the **Interface**-option to pick the
    interfaces you're interested in. Sometimes, however, it's easier/preferred
    to collect all interfaces _except_ a few ones. This option enables you to
    do that: By setting **IgnoreSelected** to _true_ the effect of
    **Interface** is inverted: All selected interfaces are ignored and all
    other interfaces are collected.

    It is possible to use regular expressions to match interface names, if the
    name is surrounded by _/.../_ and collectd was compiled with support for
    regexps. This is useful if there's a need to collect (or ignore) data
    for a group of interfaces that are similarly named, without the need to
    explicitly list all of them (especially useful if the list is dynamic).
    Example:

        Interface "lo"
        Interface "/^veth/"
        Interface "/^tun[0-9]+/"
        IgnoreSelected "true"

    This will ignore the loopback interface, all interfaces with names starting
    with _veth_ and all interfaces with names starting with _tun_ followed by
    at least one digit.

- **ReportInactive** _true_|_false_

    When set to _false_, only interfaces with non-zero traffic will be
    reported. Note that the check is done by looking into whether a
    package was sent at any time from boot and the corresponding counter
    is non-zero. So, if the interface has been sending data in the past
    since boot, but not during the reported time-interval, it will still
    be reported.

    The default value is _true_ and results in collection of the data
    from all interfaces that are selected by **Interface** and
    **IgnoreSelected** options.

- **UniqueName** _true_|_false_

    Interface name is not unique on Solaris (KSTAT), interface name is unique
    only within a module/instance. Following tuple is considered unique:
       (ks\_module, ks\_instance, ks\_name)
    If this option is set to true, interface name contains above three fields
    separated by an underscore. For more info on KSTAT, visit
    [http://docs.oracle.com/cd/E23824\_01/html/821-1468/kstat-3kstat.html#REFMAN3Ekstat-3kstat](http://docs.oracle.com/cd/E23824_01/html/821-1468/kstat-3kstat.html#REFMAN3Ekstat-3kstat)

    This option is only available on Solaris.

## Plugin `ipmi`

The **ipmi plugin** allows to monitor server platform status using the Intelligent
Platform Management Interface (IPMI). Local and remote interfaces are supported.

The plugin configuration consists of one or more **Instance** blocks which
specify one _ipmi_ connection each. Each block requires one unique string
argument as the instance name. If instances are not configured, an instance with
the default option values will be created.

For backwards compatibility, any option other than **Instance** block will trigger
legacy config handling and it will be treated as an option within **Instance**
block. This support will go away in the next major version of Collectd.

Within the **Instance** blocks, the following options are allowed:

- **Address** _Address_

    Hostname or IP to connect to. If not specified, plugin will try to connect to
    local management controller (BMC).

- **Username** _Username_
- **Password** _Password_

    The username and the password to use for the connection to remote BMC.

- **AuthType** _MD5_|_rmcp+_

    Forces the authentication type to use for the connection to remote BMC.
    By default most secure type is seleted.

- **Host** _Hostname_

    Sets the **host** field of dispatched values. Defaults to the global hostname
    setting.

- **Sensor** _Sensor_

    Selects sensors to collect or to ignore, depending on **IgnoreSelected**.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    If no configuration if given, the **ipmi** plugin will collect data from all
    sensors found of type "temperature", "voltage", "current" and "fanspeed".
    This option enables you to do that: By setting **IgnoreSelected** to _true_
    the effect of **Sensor** is inverted: All selected sensors are ignored and
    all other sensors are collected.

- **NotifySensorAdd** _true_|_false_

    If a sensor appears after initialization time of a minute a notification
    is sent.

- **NotifySensorRemove** _true_|_false_

    If a sensor disappears a notification is sent.

- **NotifySensorNotPresent** _true_|_false_

    If you have for example dual power supply and one of them is (un)plugged then
    a notification is sent.

- **NotifyIPMIConnectionState** _true_|_false_

    If a IPMI connection state changes after initialization time of a minute
    a notification is sent. Defaults to **false**.

- **SELEnabled** _true_|_false_

    If system event log (SEL) is enabled, plugin will listen for sensor threshold
    and discrete events. When event is received the notification is sent.
    SEL event filtering can be configured using **SELSensor** and **SELIgnoreSelected**
    config options.
    Defaults to **false**.

- **SELSensor** _SELSensor_

    Selects sensors to get events from or to ignore, depending on **SELIgnoreSelected**.

    See `/"IGNORELISTS"` for details.

- **SELIgnoreSelected** _true_|_false_

    If no configuration is given, the **ipmi** plugin will pass events from all
    sensors. This option enables you to do that: By setting **SELIgnoreSelected**
    to _true_ the effect of **SELSensor** is inverted: All events from selected
    sensors are ignored and all events from other sensors are passed.

- **SELClearEvent** _true_|_false_

    If SEL clear event is enabled, plugin will delete event from SEL list after
    it is received and successfully handled. In this case other tools that are
    subscribed for SEL events will receive an empty event.
    Defaults to **false**.

## Plugin `ipstats`

This plugin collects counts for ipv4 and ipv6 various types of packets passing
through the system in total.  At the moment it's only supported on FreeBSD.

The full list of options available to include in the counted statistics is:
  ip4receive         IPv4 total packets received
  ip4badsum          IPv4 checksum bad
  ip4tooshort        IPv4 packet too short
  ip4toosmall        IPv4 not enough data
  ip4badhlen         IPv4 ip header length < data size
  ip4badlen          IPv4 ip length < ip header length
  ip4fragment        IPv4 fragments received
  ip4fragdrop        IPv4 frags dropped (dups, out of space)
  ip4fragtimeout     IPv4 fragments timed out
  ip4forward         IPv4 packets forwarded
  ip4fastforward     IPv4 packets fast forwarded
  ip4cantforward     IPv4 packets rcvd for unreachable dest
  ip4redirectsent    IPv4 packets forwarded on same net
  ip4noproto         IPv4 unknown or unsupported protocol
  ip4deliver         IPv4 datagrams delivered to upper level
  ip4transmit        IPv4 total ip packets generated here
  ip4odrop           IPv4 lost packets due to nobufs, etc.
  ip4reassemble      IPv4 total packets reassembled ok
  ip4fragmented      IPv4 datagrams successfully fragmented
  ip4ofragment       IPv4 output fragments created
  ip4cantfrag        IPv4 don't fragment flag was set, etc.
  ip4badoptions      IPv4 error in option processing
  ip4noroute         IPv4 packets discarded due to no route
  ip4badvers         IPv4 ip version != 4
  ip4rawout          IPv4 total raw ip packets generated
  ip4toolong         IPv4 ip length > max ip packet size
  ip4notmember       IPv4 multicasts for unregistered grps
  ip4nogif           IPv4 no match gif found
  ip4badaddr         IPv4 invalid address on header

    ip6receive         IPv6 total packets received
    ip6tooshort        IPv6 packet too short
    ip6toosmall        IPv6 not enough data
    ip6fragment        IPv6 fragments received
    ip6fragdrop        IPv6 frags dropped(dups, out of space)
    ip6fragtimeout     IPv6 fragments timed out
    ip6fragoverflow    IPv6 fragments that exceeded limit
    ip6forward         IPv6 packets forwarded
    ip6cantforward     IPv6 packets rcvd for unreachable dest
    ip6redirectsent    IPv6 packets forwarded on same net
    ip6deliver         IPv6 datagrams delivered to upper level
    ip6transmit        IPv6 total ip packets generated here
    ip6odrop           IPv6 lost packets due to nobufs, etc.
    ip6reassemble      IPv6 total packets reassembled ok
    ip6fragmented      IPv6 datagrams successfully fragmented
    ip6ofragment       IPv6 output fragments created
    ip6cantfrag        IPv6 don't fragment flag was set, etc.
    ip6badoptions      IPv6 error in option processing
    ip6noroute         IPv6 packets discarded due to no route
    ip6badvers         IPv6 ip6 version != 6
    ip6rawout          IPv6 total raw ip packets generated
    ip6badscope        IPv6 scope error
    ip6notmember       IPv6 don't join this multicast group
    ip6nogif           IPv6 no match gif found
    ip6toomanyhdr      IPv6 discarded due to too many headers

By default the following options are included in the counted packets:

\- ip4receive
\- ip4forward
\- ip4transmit

\- ip6receive
\- ip6forward
\- ip6transmit

For example to also count IPv4 and IPv6 fragments received, include the
following configuration:

    <Plugin ipstats>
      ip4fragment true
      ip6fragment true
    </Plugin>

## Plugin `iptables`

- **Chain** _Table_ _Chain_ \[_Comment|Number_ \[_Name_\]\]
- **Chain6** _Table_ _Chain_ \[_Comment|Number_ \[_Name_\]\]

    Select the iptables/ip6tables filter rules to count packets and bytes from.

    If only _Table_ and _Chain_ are given, this plugin will collect the counters
    of all rules which have a comment-match. The comment is then used as
    type-instance.

    If _Comment_ or _Number_ is given, only the rule with the matching comment or
    the _n_th rule will be collected. Again, the comment (or the number) will be
    used as the type-instance.

    If _Name_ is supplied, it will be used as the type-instance instead of the
    comment or the number.

## Plugin `irq`

- **Irq** _Irq_

    Select this irq. By default these irqs will then be collected. For a more
    detailed description see **IgnoreSelected** below.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    If no configuration if given, the **irq**-plugin will collect data from all
    irqs. This may not be practical, especially if no interrupts happen. Thus, you
    can use the **Irq**-option to pick the interrupt you're interested in.
    Sometimes, however, it's easier/preferred to collect all interrupts _except_ a
    few ones. This option enables you to do that: By setting **IgnoreSelected** to
    _true_ the effect of **Irq** is inverted: All selected interrupts are ignored
    and all other interrupts are collected.

## Plugin `java`

The _Java_ plugin makes it possible to write extensions for collectd in Java.
This section only discusses the syntax and semantic of the configuration
options. For more in-depth information on the _Java_ plugin, please read
[collectd-java(5)](http://man.he.net/man5/collectd-java).

Synopsis:

    <Plugin "java">
      JVMArg "-verbose:jni"
      JVMArg "-Djava.class.path=/opt/collectd/lib/collectd/bindings/java"
      LoadPlugin "org.collectd.java.Foobar"
      <Plugin "org.collectd.java.Foobar">
        # To be parsed by the plugin
      </Plugin>
    </Plugin>

Available configuration options:

- **JVMArg** _Argument_

    Argument that is to be passed to the _Java Virtual Machine_ (JVM). This works
    exactly the way the arguments to the _java_ binary on the command line work.
    Execute `java --help` for details.

    Please note that **all** these options must appear **before** (i. e. above)
    any other options! When another option is found, the JVM will be started and
    later options will have to be ignored!

- **LoadPlugin** _JavaClass_

    Instantiates a new _JavaClass_ object. The constructor of this object very
    likely then registers one or more callback methods with the server.

    See [collectd-java(5)](http://man.he.net/man5/collectd-java) for details.

    When the first such option is found, the virtual machine (JVM) is created. This
    means that all **JVMArg** options must appear before (i. e. above) all
    **LoadPlugin** options!

- **Plugin** _Name_

    The entire block is passed to the Java plugin as an
    _org.collectd.api.OConfigItem_ object.

    For this to work, the plugin has to register a configuration callback first,
    see ["config callback" in collectd-java(5)](http://man.he.net/man5/collectd-java). This means, that the **Plugin** block
    must appear after the appropriate **LoadPlugin** block. Also note, that _Name_
    depends on the (Java) plugin registering the callback and is completely
    independent from the _JavaClass_ argument passed to **LoadPlugin**.

## Plugin `load`

The _Load plugin_ collects the system load. These numbers give a rough overview
over the utilization of a machine. The system load is defined as the number of
runnable tasks in the run-queue and is provided by many operating systems as a
one, five or fifteen minute average.

The following configuration options are available:

- **ReportRelative** **false**|**true**

    When enabled, system load divided by number of available CPU cores is reported
    for intervals 1 min, 5 min and 15 min. Defaults to false.

## Plugin `logfile`

- **LogLevel** **debug|info|notice|warning|err**

    Sets the log-level. If, for example, set to **notice**, then all events with
    severity **notice**, **warning**, or **err** will be written to the logfile.

    Please note that **debug** is only available if collectd has been compiled with
    debugging support.

- **File** _File_

    Sets the file to write log messages to. The special strings **stdout** and
    **stderr** can be used to write to the standard output and standard error
    channels, respectively. This, of course, only makes much sense when _collectd_
    is running in foreground- or non-daemon-mode.

- **Timestamp** **true**|**false**

    Prefix all lines printed by the current time. Defaults to **true**.

- **PrintSeverity** **true**|**false**

    When enabled, all lines are prefixed by the severity of the log message, for
    example "warning". Defaults to **false**.

**Note**: There is no need to notify the daemon after moving or removing the
log file (e. g. when rotating the logs). The plugin reopens the file
for each line it writes.

## Plugin `logparser`

The _logparser_ plugin is used to parse different kinds of logs. Setting proper
options you can choose strings to collect. Plugin searches the log file for
messages which contain several matches (two or more). When all mandatory matches
are found then it sends proper notification containing all fetched values.

**Synopsis:**

    <Plugin logparser>
      <Logfile "/var/log/syslog">
        FirstFullRead false
        <Message "pcie_errors">
          DefaultType "pcie_error"
          DefaultSeverity "warning"
          <Match "aer error">
            Regex "AER:.*error received"
            SubmatchIdx -1
          </Match>
          <Match "incident time">
            Regex "(... .. ..:..:..) .* pcieport.*AER"
            SubmatchIdx 1
            IsMandatory false
          </Match>
          <Match "root port">
            Regex "pcieport (.*): AER:"
            SubmatchIdx 1
            IsMandatory true
          </Match>
          <Match "device">
            PluginInstance true
            Regex " ([0-9a-fA-F:\\.]*): PCIe Bus Error"
            SubmatchIdx 1
            IsMandatory false
          </Match>
          <Match "severity_mandatory">
            Regex "severity="
            SubMatchIdx -1
          </Match>
          <Match "nonfatal">
            Regex "severity=.*\\([nN]on-[fF]atal"
            TypeInstance "non_fatal"
            IsMandatory false
          </Match>
          <Match "fatal">
            Regex "severity=.*\\([fF]atal"
            Severity "failure"
            TypeInstance "fatal"
            IsMandatory false
          </Match>
          <Match "corrected">
            Regex "severity=Corrected"
            TypeInstance "correctable"
            IsMandatory false
          </Match>
          <Match "error type">
            Regex "type=(.*),"
            SubmatchIdx 1
            IsMandatory false
          </Match>
         <Match "id">
            Regex ", id=(.*)"
            SubmatchIdx 1
          </Match>
        </Message>
      </Logfile>
    </Plugin>

**Options:**

- **Logfile** _File_

    The **Logfile** block defines file to search. It may contain one or more
    **Message** blocks which are defined below.

- **FirstFullRead** _true_|_false_

    Set to true if the file has to be parsed from the beginning on the first read.
    If false only subsequent writes to log file will be parsed.

- **Message** _Name_

    **Message** block contains matches to search the log file for. Each **Message**
    block builds a notification message using matched elements if its mandatory
    **Match** blocks are matched.

- **DefaultPluginInstance** _String_

    Sets the default value for the plugin instance of the notification.

- **DefaultType** _String_

    Sets the default value for the type of the notification.

- **DefaultTypeInstance** _String_

    Sets the default value for the type instance of the notification.

- **DefaultSeverity** _String_

    Sets the default severity. Must be set to "OK", "WARNING" or "FAILURE".
    Default value is "OK".

- **Match** _Name_

    Multiple _Match_ blocks define regular expression patterns for extracting or
    excluding specific string patterns from parsing. First and last _Match_ items
    in the same _Message_ set boundaries of multiline message and are mandatory.
    If these matches are not found then the whole message is discarded.

- **Regex** _Regex_

    Regular expression with pattern matching string. It may contain subexpressions,
    so next option **SubmatchIdx** specifies which subexpression should be stored.

- **SubmatchIdx** _Integer_

    Index of subexpression to be used for notification. Multiple subexpressions are
    allowed. Index value 0 takes whole regular expression match as a result.
    Index value -1 does not add result to message item. Can be omitted, default
    value is 0.

- **Excluderegex** _Regex_

    Regular expression for excluding lines containing specific matching strings.
    This is processed before checking _Regex_ pattern. It is optional and can
    be omitted.

- **IsMandatory**  _true_|_false_

    Flag indicating if _Match_ item is mandatory for message validation. If set to
    true, whole message is discarded if it's missing. For false its presence is
    optional. Default value is set to true.

- **PluginInstance** _true_|_String_

    If set to true, it sets plugin instance to string returned by regex. It can be
    overridden by user string.

- **Type** _true_|_String_

    Sets notification type using rules like **PluginInstance**.

- **TypeInstance** _true_|_String_

    Sets notification type instance using rules like above.

- **Severity** _String_

    Sets notification severity to one of the options: "OK", "WARNING", "FAILURE".

## Plugin `log_logstash`

The _log logstash plugin_ behaves like the logfile plugin but formats
messages as JSON events for logstash to parse and input.

- **LogLevel** **debug|info|notice|warning|err**

    Sets the log-level. If, for example, set to **notice**, then all events with
    severity **notice**, **warning**, or **err** will be written to the logfile.

    Please note that **debug** is only available if collectd has been compiled with
    debugging support.

- **File** _File_

    Sets the file to write log messages to. The special strings **stdout** and
    **stderr** can be used to write to the standard output and standard error
    channels, respectively. This, of course, only makes much sense when _collectd_
    is running in foreground- or non-daemon-mode.

**Note**: There is no need to notify the daemon after moving or removing the
log file (e. g. when rotating the logs). The plugin reopens the file
for each line it writes.

## Plugin `lpar`

The _LPAR plugin_ reads CPU statistics of _Logical Partitions_, a
virtualization technique for IBM POWER processors. It takes into account CPU
time stolen from or donated to a partition, in addition to the usual user,
system, I/O statistics.

The following configuration options are available:

- **CpuPoolStats** **false**|**true**

    When enabled, statistics about the processor pool are read, too. The partition
    needs to have pool authority in order to be able to acquire this information.
    Defaults to false.

- **ReportBySerial** **false**|**true**

    If enabled, the serial of the physical machine the partition is currently
    running on is reported as _hostname_ and the logical hostname of the machine
    is reported in the _plugin instance_. Otherwise, the logical hostname will be
    used (just like other plugins) and the _plugin instance_ will be empty.
    Defaults to false.

## Plugin `lua`

This plugin embeds a Lua interpreter into collectd and provides an interface
to collectd's plugin system. See [collectd-lua(5)](http://man.he.net/man5/collectd-lua) for its documentation.

## Plugin `mbmon`

The `mbmon plugin` uses mbmon to retrieve temperature, voltage, etc.

Be default collectd connects to **localhost** (127.0.0.1), port **411/tcp**. The
**Host** and **Port** options can be used to change these values, see below.
`mbmon` has to be running to work correctly. If `mbmon` is not running
timeouts may appear which may interfere with other statistics..

`mbmon` must be run with the -r option ("print TAG and Value format");
Debian's `/etc/init.d/mbmon` script already does this, other people
will need to ensure that this is the case.

- **Host** _Hostname_

    Hostname to connect to. Defaults to **127.0.0.1**.

- **Port** _Port_

    TCP-Port to connect to. Defaults to **411**.

## Plugin `mdevents `

The _ mdevents _ plugin collects status changes from md (Linux software RAID) devices.

RAID arrays are meant to allow users/administrators to keep systems up and
running, in case of common hardware problems (disk failure). Mdadm is the
standard software RAID management tool for Linux. It provides the ability to 
monitor "metadata event" occurring such as disk failures, clean-to-dirty 
transitions, and etc. The kernel provides the ability to report such actions to 
the userspace via sysfs, and mdadm takes action accordingly with the monitoring 
capability. The mdmon polls the /sys looking for changes in the entries 
array\_state, sync\_action, and per disk state attribute files. This is meaningful
for RAID1, 5 and 10 only.

Mdevents plugin is based on gathering RAID array events that are
written to syslog by mdadm. After registering an event, it can send a collectd
notification that contains mdadm event's data. Event consists of event type,
raid array name and, for particular events, name of component device.

Example message:

`Jan 17 05:24:27 pc1 mdadm[188]: NewArray event detected on md device /dev/md0`

Plugin also classifies gathered event. This means that a notification will have
a different severity {OKAY, WARNING, FAILURE} for particular mdadm event.

For proper work, mdevents plugin needs syslog and mdadm utilities to be present on
the running system. Otherwise it will not be compiled as a part of collectd.

**Synopsis:**

    <Plugin mdevents>
      Event ""
      IgnoreEvent False
      Array ""
      IgnoreArray False
    </Plugin>

**Plugin configuration:**

Mdevents plugin's configuration is mostly based on IgnoreList, which is a collectd's
utility. User can specify what particular events/RAID arrays lie in his interest.
Setting of IgnoreEvent/IgnoreArray booleans won't take effect if Event/Array config
lists are empty - plugin will accept entry anyway.

**Options:**

- **Event** _"EventName"_

    Names of events to be monitored, separated by spaces. Possible events include:

        Event Name        | Class of event
        ------------------+---------------
        DeviceDisappeared | FAILURE
        RebuildStarted    | OKAY
        RebuildNN         | OKAY
        RebuildFinished   | WARNING
        Fail              | FAILURE
        FailSpare         | WARNING
        SpareActive       | OKAY
        NewArray          | OKAY
        DegradedArray     | FAILURE
        MoveSpare         | WARNING
        SparesMissing     | WARNING
        TestMessage       | OKAY

    User should set the events that should be monitored as a strings separated by spaces,
    for example Events "DeviceDisappeared Fail DegradedArray".

- **IgnoreEvent** _false_|_true_

    If _IgnoreEvent_ is set to true, events specified in _Events_ will be ignored.
    If it's false, only specified events will be monitored.

- **Array** _arrays_

    User can specify an array or a group of arrays using regexp. Plugin will accept
    only RAID arrays names that start with "/dev/md".

- **IgnoreArray** _false_|_true_

    If _IgnoreArray_ is set to true, arrays specified in _Array_ will be ignored.
    If it's false, only specified events will be monitored.

## Plugin `mcelog`

The `mcelog plugin` uses mcelog to retrieve machine check exceptions.

By default the plugin connects to **"/var/run/mcelog-client"** to check if the
mcelog server is running. When the server is running, the plugin will tail the
specified logfile to retrieve machine check exception information and send a
notification with the details from the logfile. The plugin will use the mcelog
client protocol to retrieve memory related machine check exceptions. Note that
for memory exceptions, notifications are only sent when there is a change in
the number of corrected/uncorrected memory errors.

### The Memory block

Note: these options cannot be used in conjunction with the logfile options, they are mutually
exclusive.

- **McelogClientSocket** _Path_
Connect to the mcelog client socket using the UNIX domain socket at _Path_.
Defaults to **"/var/run/mcelog-client"**.
- **PersistentNotification** **true**|**false**
Override default configuration to only send notifications when sent when there
is a change in the number of corrected/uncorrected memory errors. When set to
true notifications will be sent for every read cycle. Default is false. Does
not affect the stats being dispatched.

- **McelogLogfile** _Path_

    The mcelog file to parse. Defaults to **"/var/log/mcelog"**. Note: this option
    cannot be used in conjunction with the memory block options, they are mutually
    exclusive.

## Plugin `md`

The `md plugin` collects information from Linux Software-RAID devices (md).

All reported values are of the type `md_disks`. Reported type instances are
_active_, _failed_ (present but not operational), _spare_ (hot stand-by) and
_missing_ (physically absent) disks.

- **Device** _Device_

    Select md devices based on device name. The _device name_ is the basename of
    the device, i.e. the name of the block device without the leading `/dev/`.
    See **IgnoreSelected** for more details.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Invert device selection: If set to **true**, all md devices **except** those
    listed using **Device** are collected. If **false** (the default), only those
    listed are collected. If no configuration is given, the **md** plugin will
    collect data from all md devices.

## Plugin `memcachec`

The `memcachec plugin` connects to a memcached server, queries one or more
given _pages_ and parses the returned data according to user specification.
The _matches_ used are the same as the matches used in the `curl` and `tail`
plugins.

In order to talk to the memcached server, this plugin uses the _libmemcached_
library. Please note that there is another library with a very similar name,
libmemcache (notice the missing \`d'), which is not applicable.

Synopsis of the configuration:

    <Plugin "memcachec">
      <Page "plugin_instance">
        Server "localhost"
        Key "page_key"
        Plugin "plugin_name"
        <Match>
          Regex "(\\d+) bytes sent"
          DSType CounterAdd
          Type "ipt_octets"
          Instance "type_instance"
        </Match>
      </Page>
    </Plugin>

The configuration options are:

- <**Page** _Name_>

    Each **Page** block defines one _page_ to be queried from the memcached server.
    The block requires one string argument which is used as _plugin instance_.

- **Server** _Address_

    Sets the server address to connect to when querying the page. Must be inside a
    **Page** block.

- **Key** _Key_

    When connected to the memcached server, asks for the page _Key_.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting values.
    Defaults to `memcachec`.

- <**Match**>

    Match blocks define which strings to look for and how matches substrings are
    interpreted. For a description of match blocks, please see ["Plugin tail"](#plugin-tail).

## Plugin `memcached`

The **memcached plugin** connects to a memcached server and queries statistics
about cache utilization, memory and bandwidth used.
[http://memcached.org/](http://memcached.org/)

    <Plugin "memcached">
      <Instance "name">
        #Host "memcache.example.com"
        Address "127.0.0.1"
        Port 11211
      </Instance>
    </Plugin>

The plugin configuration consists of one or more **Instance** blocks which
specify one _memcached_ connection each. Within the **Instance** blocks, the
following options are allowed:

- **Host** _Hostname_

    Sets the **host** field of dispatched values. Defaults to the global hostname
    setting.
    For backwards compatibility, values are also dispatched with the global
    hostname when **Host** is set to **127.0.0.1** or **localhost** and **Address** is
    not set.

- **Address** _Address_

    Hostname or IP to connect to. For backwards compatibility, defaults to the
    value of **Host** or **127.0.0.1** if **Host** is unset.

- **Port** _Port_

    TCP port to connect to. Defaults to **11211**.

- **Socket** _Path_

    Connect to _memcached_ using the UNIX domain socket at _Path_. If this
    setting is given, the **Address** and **Port** settings are ignored.

## Plugin `mic`

The **mic plugin** gathers CPU statistics, memory usage and temperatures from
Intel's Many Integrated Core (MIC) systems.

**Synopsis:**

    <Plugin mic>
      ShowCPU true
      ShowCPUCores true
      ShowMemory true

      ShowTemperatures true
      Temperature vddg
      Temperature vddq
      IgnoreSelectedTemperature true

      ShowPower true
      Power total0
      Power total1
      IgnoreSelectedPower true
    </Plugin>

The following options are valid inside the **Plugin mic** block:

- **ShowCPU** **true**|**false**

    If enabled (the default) a sum of the CPU usage across all cores is reported.

- **ShowCPUCores** **true**|**false**

    If enabled (the default) per-core CPU usage is reported.

- **ShowMemory** **true**|**false**

    If enabled (the default) the physical memory usage of the MIC system is
    reported.

- **ShowTemperatures** **true**|**false**

    If enabled (the default) various temperatures of the MIC system are reported.

- **Temperature** _Name_

    This option controls which temperatures are being reported. Whether matching
    temperatures are being ignored or _only_ matching temperatures are reported
    depends on the **IgnoreSelectedTemperature** setting below. By default _all_
    temperatures are reported.

- **IgnoreSelectedTemperature** **false**|**true**

    Controls the behavior of the **Temperature** setting above. If set to **false**
    (the default) only temperatures matching a **Temperature** option are reported
    or, if no **Temperature** option is specified, all temperatures are reported. If
    set to **true**, matching temperatures are _ignored_ and all other temperatures
    are reported.

    Known temperature names are:

    - die

        Die of the CPU

    - devmem

        Device Memory

    - fin

        Fan In

    - fout

        Fan Out

    - vccp

        Voltage ccp

    - vddg

        Voltage ddg

    - vddq

        Voltage ddq

- **ShowPower** **true**|**false**

    If enabled (the default) various temperatures of the MIC system are reported.

- **Power** _Name_

    This option controls which power readings are being reported. Whether matching
    power readings are being ignored or _only_ matching power readings are reported
    depends on the **IgnoreSelectedPower** setting below. By default _all_
    power readings are reported.

- **IgnoreSelectedPower** **false**|**true**

    Controls the behavior of the **Power** setting above. If set to **false**
    (the default) only power readings matching a **Power** option are reported
    or, if no **Power** option is specified, all power readings are reported. If
    set to **true**, matching power readings are _ignored_ and all other power readings
    are reported.

    Known power names are:

    - total0

        Total power utilization averaged over Time Window 0 (uWatts).

    - total1

        Total power utilization averaged over Time Window 0 (uWatts).

    - inst

        Instantaneous power (uWatts).

    - imax

        Max instantaneous power (uWatts).

    - pcie

        PCI-E connector power (uWatts).

    - c2x3

        2x3 connector power (uWatts).

    - c2x4

        2x4 connector power (uWatts).

    - vccp

        Core rail (uVolts).

    - vddg

        Uncore rail (uVolts).

    - vddq

        Memory subsystem rail (uVolts).

## Plugin `memory`

The _memory plugin_ provides the following configuration options:

- **ValuesAbsolute** **true**|**false**

    Enables or disables reporting of physical memory usage in absolute numbers,
    i.e. bytes. Defaults to **true**.

- **ValuesPercentage** **false**|**true**

    Enables or disables reporting of physical memory usage in percentages, e.g.
    percent of physical memory used. Defaults to **false**.

    This is useful for deploying _collectd_ in a heterogeneous environment in
    which the sizes of physical memory vary.

## Plugin `modbus`

The **modbus plugin** connects to a Modbus "slave" via Modbus/TCP or Modbus/RTU and
reads register values. It supports reading single registers (unsigned 16 bit
values), large integer values (unsigned 32 bit and 64 bit values) and
floating point values (two registers interpreted as IEEE floats in big endian
notation).

**Synopsis:**

    <Data "voltage-input-1">
      RegisterBase 0
      RegisterType float
      RegisterCmd ReadHolding
      Type voltage
      Instance "input-1"
      #Scale 1.0
      #Shift 0.0
    </Data>

    <Data "voltage-input-2">
      RegisterBase 2
      RegisterType float
      RegisterCmd ReadHolding
      Type voltage
      Instance "input-2"
    </Data>

    <Data "supply-temperature-1">
      RegisterBase 0
      RegisterType Int16
      RegisterCmd ReadHolding
      Type temperature
      Instance "temp-1"
    </Data>

    <Host "modbus.example.com">
      Address "192.168.0.42"
      Port    "502"
      Interval 60

      <Slave 1>
        Instance "power-supply"
        Collect  "voltage-input-1"
        Collect  "voltage-input-2"
      </Slave>
    </Host>

    <Host "localhost">
      Device "/dev/ttyUSB0"
      Baudrate 38400
      Interval 20

      <Slave 1>
        Instance "temperature"
        Collect  "supply-temperature-1"
      </Slave>
    </Host>

- <**Data** _Name_> blocks

    Data blocks define a mapping between register numbers and the "types" used by
    _collectd_.

    Within <Data /> blocks, the following options are allowed:

    - **RegisterBase** _Number_

        Configures the base register to read from the device. If the option
        **RegisterType** has been set to **Uint32** or **Float**, this and the next
        register will be read (the register number is increased by one).

    - **RegisterType** **Int16**|**Int32**|**Int64**|**Uint16**|**Uint32**|**UInt64**|**Float**|**Int32LE**|**Uint32LE**|**FloatLE**|**Double**

        Specifies what kind of data is returned by the device. This defaults to
        **Uint16**.  If the type is **Int32**, **Int32LE**, **Uint32**, **Uint32LE**,
        **Float** or **FloatLE**, two 16 bit registers at **RegisterBase**
        and **RegisterBase+1** will be read and the data is combined into one
        32 value. For **Int32**, **Uint32** and **Float** the most significant
        16 bits are in the register at **RegisterBase** and the least
        significant 16 bits are in the register at **RegisterBase+1**.
        For **Int32LE**, **Uint32LE**, or **Float32LE**, the high and low order
        registers are swapped with the most significant 16 bits in
        the **RegisterBase+1** and the least significant 16 bits in
        **RegisterBase**. If the type is **Int64**, **UInt64** or **Double**, four
        16 bit registers at **RegisterBase**, **RegisterBase+1**, **RegisterBase+2**
        and **RegisterBase+3** will be read and the data combined into one 64 bit
        value.

    - **RegisterCmd** **ReadHolding**|**ReadInput**

        Specifies register type to be collected from device. Works only with libmodbus
        2.9.2 or higher. Defaults to **ReadHolding**.

    - **Type** _Type_

        Specifies the "type" (data set) to use when dispatching the value to
        _collectd_. Currently, only data sets with exactly one data source are
        supported.

    - **Instance** _Instance_

        Sets the type instance to use when dispatching the value to _Instance_. If
        unset, an empty string (no type instance) is used.

    - **Scale** _Value_

        The values taken from device are multiplied by _Value_. The field is optional
        and the default is **1.0**.

    - **Shift** _Value_

        _Value_ is added to values from device after they have been multiplied by
        **Scale** value. The field is optional and the default value is **0.0**.

- <**Host** _Name_> blocks

    Host blocks are used to specify to which hosts to connect and what data to read
    from their "slaves". The string argument _Name_ is used as hostname when
    dispatching the values to _collectd_.

    Within <Host /> blocks, the following options are allowed:

    - **Address** _Hostname_

        For Modbus/TCP, specifies the node name (the actual network address) used to
        connect to the host. This may be an IP address or a hostname. Please note that
        the used _libmodbus_ library only supports IPv4 at the moment.

    - **Port** _Service_

        for Modbus/TCP, specifies the port used to connect to the host. The port can
        either be given as a number or as a service name. Please note that the
        _Service_ argument must be a string, even if ports are given in their numerical
        form. Defaults to "502".

    - **Device** _Devicenode_

        For Modbus/RTU, specifies the path to the serial device being used.

    - **Baudrate** _Baudrate_

        For Modbus/RTU, specifies the baud rate of the serial device.
        Note, connections currently support only 8/N/1.

    - **UARTType** _UARTType_

        For Modbus/RTU, specifies the type of the serial device.
        RS232, RS422 and RS485 are supported. Defaults to RS232.
        Available only on Linux systems with libmodbus>=2.9.4.

    - **Interval** _Interval_

        Sets the interval (in seconds) in which the values will be collected from this
        host. By default the global **Interval** setting will be used.

    - <**Slave** _ID_>

        Over each connection, multiple Modbus devices may be reached. The slave ID
        is used to specify which device should be addressed. For each device you want
        to query, one **Slave** block must be given.

        Within <Slave /> blocks, the following options are allowed:

        - **Instance** _Instance_

            Specify the plugin instance to use when dispatching the values to _collectd_.
            By default "slave\__ID_" is used.

        - **Collect** _DataName_

            Specifies which data to retrieve from the device. _DataName_ must be the same
            string as the _Name_ argument passed to a **Data** block. You can specify this
            option multiple times to collect more than one value from a slave. At least one
            **Collect** option is mandatory.

## Plugin `mqtt`

The _MQTT plugin_ can send metrics to MQTT (**Publish** blocks) and receive
values from MQTT (**Subscribe** blocks).

**Synopsis:**

    <Plugin mqtt>
      <Publish "name">
        Host "mqtt.example.com"
        Prefix "collectd"
      </Publish>
      <Subscribe "name">
        Host "mqtt.example.com"
        Topic "collectd/#"
      </Subscribe>
    </Plugin>

The plugin's configuration is in **Publish** and/or **Subscribe** blocks,
configuring the sending and receiving direction respectively. The plugin will
register a write callback named `mqtt/_name_` where _name_ is the string
argument given to the **Publish** block. Both types of blocks share many but not
all of the following options. If an option is valid in only one of the blocks,
it will be mentioned explicitly.

**Options:**

- **Host** _Hostname_

    Hostname of the MQTT broker to connect to.

- **Port** _Service_

    Port number or service name of the MQTT broker to connect to.

- **User** _UserName_

    Username used when authenticating to the MQTT broker.

- **Password** _Password_

    Password used when authenticating to the MQTT broker.

- **ClientId** _ClientId_

    MQTT client ID to use. Defaults to the hostname used by _collectd_.

- **QoS** \[**0**-**2**\]

    Sets the _Quality of Service_, with the values `0`, `1` and `2` meaning:

    - **0**

        At most once

    - **1**

        At least once

    - **2**

        Exactly once

    In **Publish** blocks, this option determines the QoS flag set on outgoing
    messages and defaults to **0**. In **Subscribe** blocks, determines the maximum
    QoS setting the client is going to accept and defaults to **2**. If the QoS flag
    on a message is larger than the maximum accepted QoS of a subscriber, the
    message's QoS will be downgraded.

- **Prefix** _Prefix_ (Publish only)

    This plugin will use one topic per _value list_ which will looks like a path.
    _Prefix_ is used as the first path element and defaults to **collectd**.

    An example topic name would be:

        collectd/cpu-0/cpu-user

- **Retain** **false**|**true** (Publish only)

    Controls whether the MQTT broker will retain (keep a copy of) the last message
    sent to each topic and deliver it to new subscribers. Defaults to **false**.

- **StoreRates** **true**|**false** (Publish only)

    Controls whether `DERIVE` and `COUNTER` metrics are converted to a _rate_
    before sending. Defaults to **true**.

- **CleanSession** **true**|**false** (Subscribe only)

    Controls whether the MQTT "cleans" the session up after the subscriber
    disconnects or if it maintains the subscriber's subscriptions and all messages
    that arrive while the subscriber is disconnected. Defaults to **true**.

- **Topic** _TopicName_ (Subscribe only)

    Configures the topic(s) to subscribe to. You can use the single level `+` and
    multi level `#` wildcards. Defaults to **collectd/#**, i.e. all topics beneath
    the **collectd** branch.

- **CACert** _file_

    Path to the PEM-encoded CA certificate file. Setting this option enables TLS
    communication with the MQTT broker, and as such, **Port** should be the TLS-enabled
    port of the MQTT broker.
    This option enables the use of TLS.

- **CertificateFile** _file_

    Path to the PEM-encoded certificate file to use as client certificate when
    connecting to the MQTT broker.
    Only valid if **CACert** and **CertificateKeyFile** are also set.

- **CertificateKeyFile** _file_

    Path to the unencrypted PEM-encoded key file corresponding to **CertificateFile**.
    Only valid if **CACert** and **CertificateFile** are also set.

- **TLSProtocol** _protocol_

    If configured, this specifies the string protocol version (e.g. `tlsv1`,
    `tlsv1.2`) to use for the TLS connection to the broker. If not set a default
    version is used which depends on the version of OpenSSL the Mosquitto library
    was linked against.
    Only valid if **CACert** is set.

- **CipherSuite** _ciphersuite_

    A string describing the ciphers available for use. See [ciphers(1)](http://man.he.net/man1/ciphers) and the
    `openssl ciphers` utility for more information. If unset, the default ciphers
    will be used.
    Only valid if **CACert** is set.

## Plugin `mysql`

The `mysql plugin` requires **mysqlclient** to be installed. It connects to
one or more databases when started and keeps the connection up as long as
possible. When the connection is interrupted for whatever reason it will try
to re-connect. The plugin will complain loudly in case anything goes wrong.

This plugin issues the MySQL `SHOW STATUS` / `SHOW GLOBAL STATUS` command
and collects information about MySQL network traffic, executed statements,
requests, the query cache and threads by evaluating the
`Bytes_{received,sent}`, `Com_*`, `Handler_*`, `Qcache_*` and `Threads_*`
return values. Please refer to the **MySQL reference manual**, _5.1.6. Server
Status Variables_ for an explanation of these values.

Optionally, primary and replica statistics may be collected in a MySQL
replication setup. In that case, information about the synchronization state
of the nodes are collected by evaluating the `Position` return value of the
`SHOW MASTER STATUS` command and the `Seconds_Behind_Master`,
`Read_Master_Log_Pos` and `Exec_Master_Log_Pos` return values of the
`SHOW SLAVE STATUS` command. See the **MySQL reference manual**,
_12.5.5.21 SHOW MASTER STATUS Syntax_ and
_12.5.5.31 SHOW SLAVE STATUS Syntax_ for details.

Synopsis:

    <Plugin mysql>
      <Database foo>
        Host "hostname"
        User "username"
        Password "password"
        Port "3306"
        MasterStats true
        ConnectTimeout 10
        SSLKey "/path/to/key.pem"
        SSLCert "/path/to/cert.pem"
        SSLCA "/path/to/ca.pem"
        SSLCAPath "/path/to/cas/"
        SSLCipher "DHE-RSA-AES256-SHA"
      </Database>

      <Database bar>
        Alias "squeeze"
        Host "localhost"
        Socket "/var/run/mysql/mysqld.sock"
        SlaveStats true
        SlaveNotifications true
      </Database>

     <Database galera>
        Alias "galera"
        Host "localhost"
        Socket "/var/run/mysql/mysqld.sock"
        WsrepStats true
     </Database>
    </Plugin>

A **Database** block defines one connection to a MySQL database. It accepts a
single argument which specifies the name of the database. None of the other
options are required. MySQL will use default values as documented in the
"mysql\_real\_connect()" and "mysql\_ssl\_set()" sections in the
**MySQL reference manual**.

- **Alias** _Alias_

    Alias to use as sender instead of hostname when reporting. This may be useful
    when having cryptic hostnames.

- **Host** _Hostname_

    Hostname of the database server. Defaults to **localhost**.

- **User** _Username_

    Username to use when connecting to the database. The user does not have to be
    granted any privileges (which is synonym to granting the `USAGE` privilege),
    unless you want to collect replication statistics (see **MasterStats** and
    **SlaveStats** below). In this case, the user needs the `REPLICATION CLIENT`
    (or `SUPER`) privileges. Else, any existing MySQL user will do.

- **Password** _Password_

    Password needed to log into the database.

- **Database** _Database_

    Select this database. Defaults to _no database_ which is a perfectly reasonable
    option for what this plugin does.

- **Port** _Port_

    TCP-port to connect to. The port must be specified in its numeric form, but it
    must be passed as a string nonetheless. For example:

        Port "3306"

    If **Host** is set to **localhost** (the default), this setting has no effect.
    See the documentation for the `mysql_real_connect` function for details.

- **Socket** _Socket_

    Specifies the path to the UNIX domain socket of the MySQL server. This option
    only has any effect, if **Host** is set to **localhost** (the default).
    Otherwise, use the **Port** option above. See the documentation for the
    `mysql_real_connect` function for details.

- **InnodbStats** _true|false_

    If enabled, metrics about the InnoDB storage engine are collected.
    Disabled by default.

- **MasterStats** _true|false_
- **SlaveStats** _true|false_

    Enable the collection of primary / replica statistics in a replication setup. In
    order to be able to get access to these statistics, the user needs special
    privileges. See the **User** documentation above. Defaults to **false**.

- **SlaveNotifications** _true|false_

    If enabled, the plugin sends a notification if the replication slave I/O and /
    or SQL threads are not running. Defaults to **false**.

- **WsrepStats** _true|false_

    Enable the collection of wsrep plugin statistics, used in Master-Master
    replication setups like in MySQL Galera/Percona XtraDB Cluster.
    User needs only privileges to execute 'SHOW GLOBAL STATUS'.
    Defaults to **false**.

- **ConnectTimeout** _Seconds_

    Sets the connect timeout for the MySQL client.

- **SSLKey** _Path_

    If provided, the X509 key in PEM format.

- **SSLCert** _Path_

    If provided, the X509 cert in PEM format.

- **SSLCA** _Path_

    If provided, the CA file in PEM format (check OpenSSL docs).

- **SSLCAPath** _Path_

    If provided, the CA directory (check OpenSSL docs).

- **SSLCipher** _String_

    If provided, the SSL cipher to use.

## Plugin `netapp`

The netapp plugin can collect various performance and capacity information
from a NetApp filer using the NetApp API.

Please note that NetApp has a wide line of products and a lot of different
software versions for each of these products. This plugin was developed for a
NetApp FAS3040 running OnTap 7.2.3P8 and tested on FAS2050 7.3.1.1L1,
FAS3140 7.2.5.1 and FAS3020 7.2.4P9. It _should_ work for most combinations of
model and software version but it is very hard to test this.
If you have used this plugin with other models and/or software version, feel
free to send us a mail to tell us about the results, even if it's just a short
"It works".

To collect these data collectd will log in to the NetApp via HTTP(S) and HTTP
basic authentication.

**Do not use a regular user for this!** Create a special collectd user with just
the minimum of capabilities needed. The user only needs the "login-http-admin"
capability as well as a few more depending on which data will be collected.
Required capabilities are documented below.

### Synopsis

    <Plugin "netapp">
      <Host "netapp1.example.com">
       Protocol      "https"
       Address       "10.0.0.1"
       Port          443
       User          "username"
       Password      "aef4Aebe"
       Interval      30

       <WAFL>
         Interval 30
         GetNameCache   true
         GetDirCache    true
         GetBufferCache true
         GetInodeCache  true
       </WAFL>

       <Disks>
         Interval 30
         GetBusy true
       </Disks>

       <VolumePerf>
         Interval 30
         GetIO      "volume0"
         IgnoreSelectedIO      false
         GetOps     "volume0"
         IgnoreSelectedOps     false
         GetLatency "volume0"
         IgnoreSelectedLatency false
       </VolumePerf>

       <VolumeUsage>
         Interval 30
         GetCapacity "vol0"
         GetCapacity "vol1"
         IgnoreSelectedCapacity false
         GetSnapshot "vol1"
         GetSnapshot "vol3"
         IgnoreSelectedSnapshot false
       </VolumeUsage>

       <Quota>
         Interval 60
       </Quota>

       <Snapvault>
         Interval 30
       </Snapvault>

       <System>
         Interval 30
         GetCPULoad     true
         GetInterfaces  true
         GetDiskOps     true
         GetDiskIO      true
       </System>

       <VFiler vfilerA>
         Interval 60

         SnapVault true
         # ...
       </VFiler>
      </Host>
    </Plugin>

The netapp plugin accepts the following configuration options:

- **Host** _Name_

    A host block defines one NetApp filer. It will appear in collectd with the name
    you specify here which does not have to be its real name nor its hostname (see
    the **Address** option below).

- **VFiler** _Name_

    A **VFiler** block may only be used inside a host block. It accepts all the
    same options as the **Host** block (except for cascaded **VFiler** blocks) and
    will execute all NetApp API commands in the context of the specified
    VFiler(R). It will appear in collectd with the name you specify here which
    does not have to be its real name. The VFiler name may be specified using the
    **VFilerName** option. If this is not specified, it will default to the name
    you specify here.

    The VFiler block inherits all connection related settings from the surrounding
    **Host** block (which appear before the **VFiler** block) but they may be
    overwritten inside the **VFiler** block.

    This feature is useful, for example, when using a VFiler as SnapVault target
    (supported since OnTap 8.1). In that case, the SnapVault statistics are not
    available in the host filer (vfiler0) but only in the respective VFiler
    context.

- **Protocol** **httpd**|**http**

    The protocol collectd will use to query this host.

    Optional

    Type: string

    Default: https

    Valid options: http, https

- **Address** _Address_

    The hostname or IP address of the host.

    Optional

    Type: string

    Default: The "host" block's name.

- **Port** _Port_

    The TCP port to connect to on the host.

    Optional

    Type: integer

    Default: 80 for protocol "http", 443 for protocol "https"

- **User** _User_
- **Password** _Password_

    The username and password to use to login to the NetApp.

    Mandatory

    Type: string

- **VFilerName** _Name_

    The name of the VFiler in which context to execute API commands. If not
    specified, the name provided to the **VFiler** block will be used instead.

    Optional

    Type: string

    Default: name of the **VFiler** block

    **Note:** This option may only be used inside **VFiler** blocks.

- **Interval** _Interval_

    **TODO**

The following options decide what kind of data will be collected. You can
either use them as a block and fine tune various parameters inside this block,
use them as a single statement to just accept all default values, or omit it to
not collect any data.

The following options are valid inside all blocks:

- **Interval** _Seconds_

    Collect the respective statistics every _Seconds_ seconds. Defaults to the
    host specific setting.

### The System block

This will collect various performance data about the whole system.

**Note:** To get this data the collectd user needs the
"api-perf-object-get-instances" capability.

- **Interval** _Seconds_

    Collect disk statistics every _Seconds_ seconds.

- **GetCPULoad** **true**|**false**

    If you set this option to true the current CPU usage will be read. This will be
    the average usage between all CPUs in your NetApp without any information about
    individual CPUs.

    **Note:** These are the same values that the NetApp CLI command "sysstat"
    returns in the "CPU" field.

    Optional

    Type: boolean

    Default: true

    Result: Two value lists of type "cpu", and type instances "idle" and "system".

- **GetInterfaces** **true**|**false**

    If you set this option to true the current traffic of the network interfaces
    will be read. This will be the total traffic over all interfaces of your NetApp
    without any information about individual interfaces.

    **Note:** This is the same values that the NetApp CLI command "sysstat" returns
    in the "Net kB/s" field.

    **Or is it?**

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "if\_octects".

- **GetDiskIO** **true**|**false**

    If you set this option to true the current IO throughput will be read. This
    will be the total IO of your NetApp without any information about individual
    disks, volumes or aggregates.

    **Note:** This is the same values that the NetApp CLI command "sysstat" returns
    in the "Disk kB/s" field.

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "disk\_octets".

- **GetDiskOps** **true**|**false**

    If you set this option to true the current number of HTTP, NFS, CIFS, FCP,
    iSCSI, etc. operations will be read. This will be the total number of
    operations on your NetApp without any information about individual volumes or
    aggregates.

    **Note:** These are the same values that the NetApp CLI command "sysstat"
    returns in the "NFS", "CIFS", "HTTP", "FCP" and "iSCSI" fields.

    Optional

    Type: boolean

    Default: true

    Result: A variable number of value lists of type "disk\_ops\_complex". Each type
    of operation will result in one value list with the name of the operation as
    type instance.

### The WAFL block

This will collect various performance data about the WAFL file system. At the
moment this just means cache performance.

**Note:** To get this data the collectd user needs the
"api-perf-object-get-instances" capability.

**Note:** The interface to get these values is classified as "Diagnostics" by
NetApp. This means that it is not guaranteed to be stable even between minor
releases.

- **Interval** _Seconds_

    Collect disk statistics every _Seconds_ seconds.

- **GetNameCache** **true**|**false**

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "cache\_ratio" and type instance
    "name\_cache\_hit".

- **GetDirCache** **true**|**false**

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "cache\_ratio" and type instance "find\_dir\_hit".

- **GetInodeCache** **true**|**false**

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "cache\_ratio" and type instance
    "inode\_cache\_hit".

- **GetBufferCache** **true**|**false**

    **Note:** This is the same value that the NetApp CLI command "sysstat" returns
    in the "Cache hit" field.

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "cache\_ratio" and type instance "buf\_hash\_hit".

### The Disks block

This will collect performance data about the individual disks in the NetApp.

**Note:** To get this data the collectd user needs the
"api-perf-object-get-instances" capability.

- **Interval** _Seconds_

    Collect disk statistics every _Seconds_ seconds.

- **GetBusy** **true**|**false**

    If you set this option to true the busy time of all disks will be calculated
    and the value of the busiest disk in the system will be written.

    **Note:** This is the same values that the NetApp CLI command "sysstat" returns
    in the "Disk util" field. Probably.

    Optional

    Type: boolean

    Default: true

    Result: One value list of type "percent" and type instance "disk\_busy".

### The VolumePerf block

This will collect various performance data about the individual volumes.

You can select which data to collect about which volume using the following
options. They follow the standard ignorelist semantic.

**Note:** To get this data the collectd user needs the
_api-perf-object-get-instances_ capability.

- **Interval** _Seconds_

    Collect volume performance data every _Seconds_ seconds.

- **GetIO** _Volume_
- **GetOps** _Volume_
- **GetLatency** _Volume_

    Select the given volume for IO, operations or latency statistics collection.
    The argument is the name of the volume without the `/vol/` prefix.

    Since the standard ignorelist functionality is used here, you can use a string
    starting and ending with a slash to specify regular expression matching: To
    match the volumes "vol0", "vol2" and "vol7", you can use this regular
    expression:

        GetIO "/^vol[027]$/"

    If no regular expression is specified, an exact match is required. Both,
    regular and exact matching are case sensitive.

    If no volume was specified at all for either of the three options, that data
    will be collected for all available volumes.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelectedIO** **true**|**false**
- **IgnoreSelectedOps** **true**|**false**
- **IgnoreSelectedLatency** **true**|**false**

    When set to **true**, the volumes selected for IO, operations or latency
    statistics collection will be ignored and the data will be collected for all
    other volumes.

    When set to **false**, data will only be collected for the specified volumes and
    all other volumes will be ignored.

    If no volumes have been specified with the above **Get\*** options, all volumes
    will be collected regardless of the **IgnoreSelected\*** option.

    Defaults to **false**

### The VolumeUsage block

This will collect capacity data about the individual volumes.

**Note:** To get this data the collectd user needs the _api-volume-list-info_
capability.

- **Interval** _Seconds_

    Collect volume usage statistics every _Seconds_ seconds.

- **GetCapacity** _VolumeName_

    The current capacity of the volume will be collected. This will result in two
    to four value lists, depending on the configuration of the volume. All data
    sources are of type "df\_complex" with the name of the volume as
    plugin\_instance.

    There will be type\_instances "used" and "free" for the number of used and
    available bytes on the volume.  If the volume has some space reserved for
    snapshots, a type\_instance "snap\_reserved" will be available.  If the volume
    has SIS enabled, a type\_instance "sis\_saved" will be available. This is the
    number of bytes saved by the SIS feature.

    **Note:** The current NetApp API has a bug that results in this value being
    reported as a 32 bit number. This plugin tries to guess the correct
    number which works most of the time.  If you see strange values here, bug
    NetApp support to fix this.

    Repeat this option to specify multiple volumes.

- **IgnoreSelectedCapacity** **true**|**false**

    Specify whether to collect only the volumes selected by the **GetCapacity**
    option or to ignore those volumes. **IgnoreSelectedCapacity** defaults to
    **false**. However, if no **GetCapacity** option is specified at all, all
    capacities will be selected anyway.

- **GetSnapshot** _VolumeName_

    Select volumes from which to collect snapshot information.

    Usually, the space used for snapshots is included in the space reported as
    "used". If snapshot information is collected as well, the space used for
    snapshots is subtracted from the used space.

    To make things even more interesting, it is possible to reserve space to be
    used for snapshots. If the space required for snapshots is less than that
    reserved space, there is "reserved free" and "reserved used" space in addition
    to "free" and "used". If the space required for snapshots exceeds the reserved
    space, that part allocated in the normal space is subtracted from the "used"
    space again.

    Repeat this option to specify multiple volumes.

- **IgnoreSelectedSnapshot**

    Specify whether to collect only the volumes selected by the **GetSnapshot**
    option or to ignore those volumes. **IgnoreSelectedSnapshot** defaults to
    **false**. However, if no **GetSnapshot** option is specified at all, all
    capacities will be selected anyway.

### The Quota block

This will collect (tree) quota statistics (used disk space and number of used
files). This mechanism is useful to get usage information for single qtrees.
In case the quotas are not used for any other purpose, an entry similar to the
following in `/etc/quotas` would be sufficient:

    /vol/volA/some_qtree tree - - - - -

After adding the entry, issue `quota on -w volA` on the NetApp filer.

- **Interval** _Seconds_

    Collect SnapVault(R) statistics every _Seconds_ seconds.

### The SnapVault block

This will collect statistics about the time and traffic of SnapVault(R)
transfers.

- **Interval** _Seconds_

    Collect SnapVault(R) statistics every _Seconds_ seconds.

## Plugin `netlink`

The `netlink` plugin uses a netlink socket to query the Linux kernel about
statistics of various interface and routing aspects.

- **Interface** _Interface_
- **VerboseInterface** _Interface_

    Instruct the plugin to collect interface statistics. This is basically the same
    as the statistics provided by the `interface` plugin (see above) but
    potentially much more detailed.

    When configuring with **Interface** only the basic statistics will be collected,
    namely octets, packets, and errors. These statistics are collected by
    the `interface` plugin, too, so using both at the same time is no benefit.

    When configured with **VerboseInterface** all counters **except** the basic ones
    will be collected, so that no data needs to be collected twice if you use the
    `interface` plugin.
    This includes dropped packets, received multicast packets, collisions and a
    whole zoo of differentiated RX and TX errors. You can try the following command
    to get an idea of what awaits you:

        ip -s -s link list

    If _Interface_ is **All**, all interfaces will be selected.

    It is possible to use regular expressions to match interface names, if the
    name is surrounded by _/.../_ and collectd was compiled with support for
    regexps. This is useful if there's a need to collect (or ignore) data
    for a group of interfaces that are similarly named, without the need to
    explicitly list all of them (especially useful if the list is dynamic).
    Examples:

        Interface "/^eth/"
        Interface "/^ens[1-4]$|^enp[0-3]$/"
        VerboseInterface "/^eno[0-9]+/"

    This will match all interfaces with names starting with _eth_, all interfaces
    in range _ens1 - ens4_ and _enp0 - enp3_, and for verbose metrics all
    interfaces with names starting with _eno_ followed by at least one digit.

- **QDisc** _Interface_ \[_QDisc_\]
- **Class** _Interface_ \[_Class_\]
- **Filter** _Interface_ \[_Filter_\]

    Collect the octets and packets that pass a certain qdisc, class or filter.

    QDiscs and classes are identified by their type and handle (or classid).
    Filters don't necessarily have a handle, therefore the parent's handle is used.
    The notation used in collectd differs from that used in tc(1) in that it
    doesn't skip the major or minor number if it's zero and doesn't print special
    ids by their name. So, for example, a qdisc may be identified by
    `pfifo_fast-1:0` even though the minor number of **all** qdiscs is zero and
    thus not displayed by tc(1).

    If **QDisc**, **Class**, or **Filter** is given without the second argument,
    i. .e. without an identifier, all qdiscs, classes, or filters that are
    associated with that interface will be collected.

    Since a filter itself doesn't necessarily have a handle, the parent's handle is
    used. This may lead to problems when more than one filter is attached to a
    qdisc or class. This isn't nice, but we don't know how this could be done any
    better. If you have a idea, please don't hesitate to tell us.

    As with the **Interface** option you can specify **All** as the interface,
    meaning all interfaces.

    Here are some examples to help you understand the above text more easily:

        <Plugin netlink>
          VerboseInterface "All"
          QDisc "eth0" "pfifo_fast-1:0"
          QDisc "ppp0"
          Class "ppp0" "htb-1:10"
          Filter "ppp0" "u32-1:0"
        </Plugin>

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected**

    The behavior is the same as with all other similar plugins: If nothing is
    selected at all, everything is collected. If some things are selected using the
    options described above, only these statistics are collected. If you set
    **IgnoreSelected** to **true**, this behavior is inverted, i. e. the
    specified statistics will not be collected.

- **CollectVFStats** **true|false**

    Allow plugin to collect VF's statistics if there are Virtual Functions
    available for interfaces specified in **Interface** or **VerboseInterface**.
    All available stats are collected no matter if parent interface is set
    by **Interface** or **VerboseInterface**.

## Plugin `network`

The Network plugin sends data to a remote instance of collectd, receives data
from a remote instance, or both at the same time. Data which has been received
from the network is usually not transmitted again, but this can be activated, see
the **Forward** option below.

The default IPv6 multicast group is `ff18::efc0:4a42`. The default IPv4
multicast group is `239.192.74.66`. The default _UDP_ port is **25826**.

Both, **Server** and **Listen** can be used as single option or as block. When
used as block, given options are valid for this socket only. The following
example will export the metrics twice: Once to an "internal" server (without
encryption and signing) and one to an external server (with cryptographic
signature):

    <Plugin "network">
      # Export to an internal server
      # (demonstrates usage without additional options)
      Server "collectd.internal.tld"

      # Export to an external server
      # (demonstrates usage with signature options)
      <Server "collectd.external.tld">
        SecurityLevel "sign"
        Username "myhostname"
        Password "ohl0eQue"
      </Server>
    </Plugin>

- **<Server** _Host_ \[_Port_\]**>**

    The **Server** statement/block sets the server to send datagrams to. The
    statement may occur multiple times to send each datagram to multiple
    destinations.

    The argument _Host_ may be a hostname, an IPv4 address or an IPv6 address. The
    optional second argument specifies a port number or a service name. If not
    given, the default, **25826**, is used.

    The following options are recognized within **Server** blocks:

    - **SecurityLevel** **Encrypt**|**Sign**|**None**

        Set the security you require for network communication. When the security level
        has been set to **Encrypt**, data sent over the network will be encrypted using
        _AES-256_. The integrity of encrypted packets is ensured using _SHA-1_. When
        set to **Sign**, transmitted data is signed using the _HMAC-SHA-256_ message
        authentication code. When set to **None**, data is sent without any security.

        This feature is only available if the _network_ plugin was linked with
        _libgcrypt_.

    - **Username** _Username_

        Sets the username to transmit. This is used by the server to lookup the
        password. See **AuthFile** below. All security levels except **None** require
        this setting.

        This feature is only available if the _network_ plugin was linked with
        _libgcrypt_.

    - **Password** _Password_

        Sets a password (shared secret) for this socket. All security levels except
        **None** require this setting.

        This feature is only available if the _network_ plugin was linked with
        _libgcrypt_.

    - **Interface** _Interface name_

        Set the outgoing interface for IP packets. This applies at least
        to IPv6 packets and if possible to IPv4. If this option is not applicable,
        undefined or a non-existent interface name is specified, the default
        behavior is to let the kernel choose the appropriate interface. Be warned
        that the manual selection of an interface for unicast traffic is only
        necessary in rare cases.

    - **BindAddress** _IP Address_

        Set the outgoing IP address for IP packets. This option can be used instead of
        the _Interface_ option to explicitly define the IP address which will be used
        to send Packets to the remote server.

    - **ResolveInterval** _Seconds_

        Sets the interval at which to re-resolve the DNS for the _Host_. This is
        useful to force a regular DNS lookup to support a high availability setup. If
        not specified, re-resolves are never attempted.

- **<Listen** _Host_ \[_Port_\]**>**

    The **Listen** statement sets the interfaces to bind to. When multiple
    statements are found the daemon will bind to multiple interfaces.

    The argument _Host_ may be a hostname, an IPv4 address or an IPv6 address. If
    the argument is a multicast address the daemon will join that multicast group.
    The optional second argument specifies a port number or a service name. If not
    given, the default, **25826**, is used.

    The following options are recognized within `<Listen>` blocks:

    - **SecurityLevel** **Encrypt**|**Sign**|**None**

        Set the security you require for network communication. When the security level
        has been set to **Encrypt**, only encrypted data will be accepted. The integrity
        of encrypted packets is ensured using _SHA-1_. When set to **Sign**, only
        signed and encrypted data is accepted. When set to **None**, all data will be
        accepted. If an **AuthFile** option was given (see below), encrypted data is
        decrypted if possible.

        This feature is only available if the _network_ plugin was linked with
        _libgcrypt_.

    - **AuthFile** _Filename_

        Sets a file in which usernames are mapped to passwords. These passwords are
        used to verify signatures and to decrypt encrypted network packets. If
        **SecurityLevel** is set to **None**, this is optional. If given, signed data is
        verified and encrypted packets are decrypted. Otherwise, signed data is
        accepted without checking the signature and encrypted data cannot be decrypted.
        For the other security levels this option is mandatory.

        The file format is very simple: Each line consists of a username followed by a
        colon and any number of spaces followed by the password. To demonstrate, an
        example file could look like this:

            user0: foo
            user1: bar

        Each time a packet is received, the modification time of the file is checked
        using [stat(2)](http://man.he.net/man2/stat). If the file has been changed, the contents is re-read. While
        the file is being read, it is locked using [fcntl(2)](http://man.he.net/man2/fcntl).

    - **Interface** _Interface name_

        Set the incoming interface for IP packets explicitly. This applies at least
        to IPv6 packets and if possible to IPv4. If this option is not applicable,
        undefined or a non-existent interface name is specified, the default
        behavior is, to let the kernel choose the appropriate interface. Thus incoming
        traffic gets only accepted, if it arrives on the given interface.

- **TimeToLive** _1-255_

    Set the time-to-live of sent packets. This applies to all, unicast and
    multicast, and IPv4 and IPv6 packets. The default is to not change this value.
    That means that multicast packets will be sent with a TTL of `1` (one) on most
    operating systems.

- **MaxPacketSize** _1024-65535_

    Set the maximum size for datagrams received over the network. Packets larger
    than this will be truncated. Defaults to 1452 bytes, which is the maximum
    payload size that can be transmitted in one Ethernet frame using IPv6 /
    UDP.

    On the server side, this limit should be set to the largest value used on
    _any_ client. Likewise, the value on the client must not be larger than the
    value on the server, or data will be lost.

    **Compatibility:** Versions prior to _version 4.8_ used a fixed sized
    buffer of 1024 bytes. Versions _4.8_, _4.9_ and _4.10_ used a default
    value of 1024 bytes to avoid problems when sending data to an older
    server.

- **Forward** _true|false_

    If set to _true_, write packets that were received via the network plugin to
    the sending sockets. This should only be activated when the **Listen**- and
    **Server**-statements differ. Otherwise packets may be send multiple times to
    the same multicast group. While this results in more network traffic than
    necessary it's not a huge problem since the plugin has a duplicate detection,
    so the values will not loop.

- **ReportStats** **true**|**false**

    The network plugin cannot only receive and send statistics, it can also create
    statistics about itself. Collectd data included the number of received and
    sent octets and packets, the length of the receive queue and the number of
    values handled. When set to **true**, the _Network plugin_ will make these
    statistics available. Defaults to **false**.

## Plugin `nfs`

The _nfs plugin_ collects information about the usage of the Network File
System (NFS). It counts the number of procedure calls for each procedure,
grouped by version and whether the system runs as server or client.

It is possibly to omit metrics for a specific NFS version by setting one or
more of the following options to **false** (all of them default to **true**).

- **ReportV2** **true**|**false**
- **ReportV3** **true**|**false**
- **ReportV4** **true**|**false**

## Plugin `nginx`

This plugin collects the number of connections and requests handled by the
`nginx daemon` (speak: engine X), a HTTP and mail server/proxy. It
queries the page provided by the `ngx_http_stub_status_module` module, which
isn't compiled by default. Please refer to
[http://wiki.codemongers.com/NginxStubStatusModule](http://wiki.codemongers.com/NginxStubStatusModule) for more information on
how to compile and configure nginx and this module.

The following options are accepted by the `nginx plugin`:

- **URL** _http://host/nginx\_status_

    Sets the URL of the `ngx_http_stub_status_module` output.

- **User** _Username_

    Optional user name needed for authentication.

- **Password** _Password_

    Optional password needed for authentication.

- **VerifyPeer** **true|false**

    Enable or disable peer SSL certificate verification. See
    [http://curl.haxx.se/docs/sslcerts.html](http://curl.haxx.se/docs/sslcerts.html) for details. Enabled by default.

- **VerifyHost** **true|false**

    Enable or disable peer host name verification. If enabled, the plugin checks
    if the `Common Name` or a `Subject Alternate Name` field of the SSL
    certificate matches the host name provided by the **URL** option. If this
    identity check fails, the connection is aborted. Obviously, only works when
    connecting to a SSL enabled server. Enabled by default.

- **CACert** _File_

    File that holds one or more SSL certificates. If you want to use HTTPS you will
    possibly need this option. What CA certificates come bundled with `libcurl`
    and are checked by default depends on the distribution you use.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the overall timeout for HTTP requests to **URL**, in
    milliseconds. By default, the configured **Interval** is used to set the
    timeout.

- **Socket** _Path_

    The **Socket** option sets the UNIX domain socket to use, if the NGINX listens
    on a UNIX domain socket instead. Note that you still need to provide the
    **URL** option.

## Plugin `notify_desktop`

This plugin sends a desktop notification to a notification daemon, as defined
in the Desktop Notification Specification. To actually display the
notifications, **notification-daemon** is required and **collectd** has to be
able to access the X server (i. e., the `DISPLAY` and `XAUTHORITY`
environment variables have to be set correctly) and the D-Bus message bus.

The Desktop Notification Specification can be found at
[http://www.galago-project.org/specs/notification/](http://www.galago-project.org/specs/notification/).

- **OkayTimeout** _timeout_
- **WarningTimeout** _timeout_
- **FailureTimeout** _timeout_

    Set the _timeout_, in milliseconds, after which to expire the notification
    for `OKAY`, `WARNING` and `FAILURE` severities respectively. If zero has
    been specified, the displayed notification will not be closed at all - the
    user has to do so herself. These options default to 5000. If a negative number
    has been specified, the default is used as well.

## Plugin `notify_email`

The _notify\_email_ plugin uses the _ESMTP_ library to send notifications to a
configured email address.

_libESMTP_ is available from [http://www.stafford.uklinux.net/libesmtp/](http://www.stafford.uklinux.net/libesmtp/).

Available configuration options:

- **From** _Address_

    Email address from which the emails should appear to come from.

    Default: `root@localhost`

- **Recipient** _Address_

    Configures the email address(es) to which the notifications should be mailed.
    May be repeated to send notifications to multiple addresses.

    At least one **Recipient** must be present for the plugin to work correctly.

- **SMTPServer** _Hostname_

    Hostname of the SMTP server to connect to.

    Default: `localhost`

- **SMTPPort** _Port_

    TCP port to connect to.

    Default: `25`

- **SMTPUser** _Username_

    Username for ASMTP authentication. Optional.

- **SMTPPassword** _Password_

    Password for ASMTP authentication. Optional.

- **Subject** _Subject_

    Subject-template to use when sending emails. There must be exactly two
    string-placeholders in the subject, given in the standard _printf(3)_ syntax,
    i. e. `%s`. The first will be replaced with the severity, the second
    with the hostname.

    Default: `Collectd notify: %s@%s`

## Plugin `notify_nagios`

The _notify\_nagios_ plugin writes notifications to Nagios' _command file_ as
a _passive service check result_.

Available configuration options:

- **CommandFile** _Path_

    Sets the _command file_ to write to. Defaults to `/usr/local/nagios/var/rw/nagios.cmd`.

## Plugin `ntpd`

The `ntpd` plugin collects per-peer ntp data such as time offset and time
dispersion.

For talking to **ntpd**, it mimics what the **ntpdc** control program does on
the wire - using **mode 7** specific requests. This mode is deprecated with
newer **ntpd** releases (4.2.7p230 and later). For the `ntpd` plugin to work
correctly with them, the ntp daemon must be explicitly configured to
enable **mode 7** (which is disabled by default). Refer to the _ntp.conf(5)_
manual page for details.

Available configuration options for the `ntpd` plugin:

- **Host** _Hostname_

    Hostname of the host running **ntpd**. Defaults to **localhost**.

- **Port** _Port_

    UDP-Port to connect to. Defaults to **123**.

- **ReverseLookups** **true**|**false**

    Sets whether or not to perform reverse lookups on peers. Since the name or
    IP-address may be used in a filename it is recommended to disable reverse
    lookups. The default is to do reverse lookups to preserve backwards
    compatibility, though.

- **IncludeUnitID** **true**|**false**

    When a peer is a refclock, include the unit ID in the _type instance_.
    Defaults to **false** for backward compatibility.

    If two refclock peers use the same driver and this is **false**, the plugin will
    try to write simultaneous measurements from both to the same type instance.
    This will result in error messages in the log and only one set of measurements
    making it through.

## Plugin `nut`

- **UPS** _upsname_**@**_hostname_\[**:**_port_\]

    Add a UPS to collect data from. The format is identical to the one accepted by
    [upsc(8)](http://man.he.net/man8/upsc).

- **ForceSSL** **true**|**false**

    Stops connections from falling back to unsecured if an SSL connection
    cannot be established. Defaults to false if undeclared.

- **VerifyPeer** _true_|_false_

    If set to true, requires a CAPath be provided. Will use the CAPath to find
    certificates to use as Trusted Certificates to validate a upsd server certificate.
    If validation of the upsd server certificate fails, the connection will not be
    established. If ForceSSL is undeclared or set to false, setting VerifyPeer to true
    will override and set ForceSSL to true.

- **CAPath** I/path/to/certs/folder

    If VerifyPeer is set to true, this is required. Otherwise this is ignored.
    The folder pointed at must contain certificate(s) named according to their hash.
    Ex: XXXXXXXX.Y where X is the hash value of a cert and Y is 0. If name collisions
    occur because two different certs have the same hash value, Y can be  incremented
    in order to avoid conflict. To create a symbolic link to a certificate the following
    command can be used from within the directory where the cert resides:

    `ln -s some.crt ./$(openssl x509 -hash -noout -in some.crt).0`

    Alternatively, the package openssl-perl provides a command `c_rehash` that will
    generate links like the one described above for ALL certs in a given folder.
    Example usage:
    `c_rehash /path/to/certs/folder`

- **ConnectTimeout** _Milliseconds_

    The **ConnectTimeout** option sets the connect timeout, in milliseconds.
    By default, the configured **Interval** is used to set the timeout.

## Plugin `olsrd`

The _olsrd_ plugin connects to the TCP port opened by the _txtinfo_ plugin of
the Optimized Link State Routing daemon and reads information about the current
state of the meshed network.

The following configuration options are understood:

- **Host** _Host_

    Connect to _Host_. Defaults to **"localhost"**.

- **Port** _Port_

    Specifies the port to connect to. This must be a string, even if you give the
    port as a number rather than a service name. Defaults to **"2006"**.

- **CollectLinks** **No**|**Summary**|**Detail**

    Specifies what information to collect about links, i. e. direct
    connections of the daemon queried. If set to **No**, no information is
    collected. If set to **Summary**, the number of links and the average of all
    _link quality_ (LQ) and _neighbor link quality_ (NLQ) values is calculated.
    If set to **Detail** LQ and NLQ are collected per link.

    Defaults to **Detail**.

- **CollectRoutes** **No**|**Summary**|**Detail**

    Specifies what information to collect about routes of the daemon queried. If
    set to **No**, no information is collected. If set to **Summary**, the number of
    routes and the average _metric_ and _ETX_ is calculated. If set to **Detail**
    metric and ETX are collected per route.

    Defaults to **Summary**.

- **CollectTopology** **No**|**Summary**|**Detail**

    Specifies what information to collect about the global topology. If set to
    **No**, no information is collected. If set to **Summary**, the number of links
    in the entire topology and the average _link quality_ (LQ) is calculated.
    If set to **Detail** LQ and NLQ are collected for each link in the entire topology.

    Defaults to **Summary**.

## Plugin `onewire`

**EXPERIMENTAL!** See notes below.

The `onewire` plugin uses the **owcapi** library from the **owfs** project
[http://owfs.org/](http://owfs.org/) to read sensors connected via the onewire bus.

It can be used in two possible modes - standard or advanced.

In the standard mode only temperature sensors (sensors with the family code
`10`, `22` and `28` - e.g. DS1820, DS18S20, DS1920) can be read. If you have
other sensors you would like to have included, please send a sort request to
the mailing list. You can select sensors to be read or to be ignored depending
on the option **IgnoreSelected**). When no list is provided the whole bus is
walked and all sensors are read.

Hubs (the DS2409 chips) are working, but read the note, why this plugin is
experimental, below.

In the advanced mode you can configure any sensor to be read (only numerical
value) using full OWFS path (e.g. "/uncached/10.F10FCA000800/temperature").
In this mode you have to list all the sensors. Neither default bus walk nor
**IgnoreSelected** are used here. Address and type (file) is extracted from
the path automatically and should produce compatible structure with the "standard"
mode (basically the path is expected as for example
"/uncached/10.F10FCA000800/temperature" where it would extract address part
"F10FCA000800" and the rest after the slash is considered the type - here
"temperature").
There are two advantages to this mode - you can access virtually any sensor
(not just temperature), select whether to use cached or directly read values
and it is slighlty faster. The downside is more complex configuration.

The two modes are distinguished automatically by the format of the address.
It is not possible to mix the two modes. Once a full path is detected in any
**Sensor** then the whole addressing (all sensors) is considered to be this way
(and as standard addresses will fail parsing they will be ignored).

- **Device** _Device_

    Sets the device to read the values from. This can either be a "real" hardware
    device, such as a serial port or an USB port, or the address of the
    [owserver(1)](http://man.he.net/man1/owserver) socket, usually **localhost:4304**.

    Though the documentation claims to automatically recognize the given address
    format, with version 2.7p4 we had to specify the type explicitly. So
    with that version, the following configuration worked for us:

        <Plugin onewire>
          Device "-s localhost:4304"
        </Plugin>

    This directive is **required** and does not have a default value.

- **Sensor** _Sensor_

    In the standard mode selects sensors to collect or to ignore
    (depending on **IgnoreSelected**, see below). Sensors are specified without
    the family byte at the beginning, so you have to use for example `F10FCA000800`,
    and **not** include the leading `10.` family byte and point.
    When no **Sensor** is configured the whole Onewire bus is walked and all supported
    sensors (see above) are read.

    In the advanced mode the **Sensor** specifies full OWFS path - e.g.
    `/uncached/10.F10FCA000800/temperature` (or when cached values are OK
    `/10.F10FCA000800/temperature`). **IgnoreSelected** is not used.

    As there can be multiple devices on the bus you can list multiple sensor (use
    multiple **Sensor** elements).

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    If no configuration is given, the **onewire** plugin will collect data from all
    sensors found. This may not be practical, especially if sensors are added and
    removed regularly. Sometimes, however, it's easier/preferred to collect only
    specific sensors or all sensors _except_ a few specified ones. This option
    enables you to do that: By setting **IgnoreSelected** to _true_ the effect of
    **Sensor** is inverted: All selected interfaces are ignored and all other
    interfaces are collected.

    Used only in the standard mode - see above.

- **Interval** _Seconds_

    Sets the interval in which all sensors should be read. If not specified, the
    global **Interval** setting is used.

**EXPERIMENTAL!** The `onewire` plugin is experimental, because it doesn't yet
work with big setups. It works with one sensor being attached to one
controller, but as soon as you throw in a couple more senors and maybe a hub
or two, reading all values will take more than ten seconds (the default
interval). We will probably add some separate thread for reading the sensors
and some cache or something like that, but it's not done yet. We will try to
maintain backwards compatibility in the future, but we can't promise. So in
short: If it works for you: Great! But keep in mind that the config _might_
change, though this is unlikely. Oh, and if you want to help improving this
plugin, just send a short notice to the mailing list. Thanks :)

## Plugin `openldap`

To use the `openldap` plugin you first need to configure the _OpenLDAP_
server correctly. The backend database `monitor` needs to be loaded and
working. See slapd-monitor(5) for the details.

The configuration of the `openldap` plugin consists of one or more **Instance**
blocks. Each block requires one string argument as the instance name. For
example:

    <Plugin "openldap">
      <Instance "foo">
        URL "ldap://localhost/"
      </Instance>
      <Instance "bar">
        URL "ldaps://localhost/"
      </Instance>
    </Plugin>

The instance name will be used as the _plugin instance_. To emulate the old
(version 4) behavior, you can use an empty string (""). In order for the
plugin to work correctly, each instance name must be unique. This is not
enforced by the plugin and it is your responsibility to ensure it is.

The following options are accepted within each **Instance** block:

- **URL** _ldap://host/binddn_

    Sets the URL to use to connect to the _OpenLDAP_ server. This option is
    _mandatory_.

- **BindDN** _BindDN_

    Name in the form of an LDAP distinguished name intended to be used for
    authentication. Defaults to empty string to establish an anonymous authorization.

- **Password** _Password_

    Password for simple bind authentication. If this option is not set,
    unauthenticated bind operation is used.

- **StartTLS** **true|false**

    Defines whether TLS must be used when connecting to the _OpenLDAP_ server.
    Disabled by default.

- **VerifyHost** **true|false**

    Enables or disables peer host name verification. If enabled, the plugin checks
    if the `Common Name` or a `Subject Alternate Name` field of the SSL
    certificate matches the host name provided by the **URL** option. If this
    identity check fails, the connection is aborted. Enabled by default.

- **CACert** _File_

    File that holds one or more SSL certificates. If you want to use TLS/SSL you
    may possibly need this option. What CA certificates are checked by default
    depends on the distribution you use and can be changed with the usual ldap
    client configuration mechanisms. See ldap.conf(5) for the details.

- **Timeout** _Seconds_

    Sets the timeout value for ldap operations, in seconds. By default, the
    configured **Interval** is used to set the timeout. Use **-1** to disable
    (infinite timeout).

- **Version** _Version_

    An integer which sets the LDAP protocol version number to use when connecting
    to the _OpenLDAP_ server. Defaults to **3** for using _LDAPv3_.

## Plugin `openvpn`

The OpenVPN plugin reads a status file maintained by OpenVPN and gathers
traffic statistics about connected clients.

To set up OpenVPN to write to the status file periodically, use the
**--status** option of OpenVPN.

So, in a nutshell you need:

    openvpn $OTHER_OPTIONS \
      --status "/var/run/openvpn-status" 10

Available options:

- **StatusFile** _File_

    Specifies the location of the status file.

- **ImprovedNamingSchema** **true**|**false**

    When enabled, the filename of the status file will be used as plugin instance
    and the client's "common name" will be used as type instance. This is required
    when reading multiple status files. Enabling this option is recommended, but to
    maintain backwards compatibility this option is disabled by default.

- **CollectCompression** **true**|**false**

    Sets whether or not statistics about the compression used by OpenVPN should be
    collected. This information is only available in _single_ mode. Enabled by
    default.

- **CollectIndividualUsers** **true**|**false**

    Sets whether or not traffic information is collected for each connected client
    individually. If set to false, currently no traffic data is collected at all
    because aggregating this data in a save manner is tricky. Defaults to **true**.

- **CollectUserCount** **true**|**false**

    When enabled, the number of currently connected clients or users is collected.
    This is especially interesting when **CollectIndividualUsers** is disabled, but
    can be configured independently from that option. Defaults to **false**.

## Plugin `oracle`

The "oracle" plugin uses the Oracle® Call Interface _(OCI)_ to connect to an
Oracle® Database and lets you execute SQL statements there. It is very similar
to the "dbi" plugin, because it was written around the same time. See the "dbi"
plugin's documentation above for details.

    <Plugin oracle>
      <Query "out_of_stock">
        Statement "SELECT category, COUNT(*) AS value FROM products WHERE in_stock = 0 GROUP BY category"
        <Result>
          Type "gauge"
          # InstancePrefix "foo"
          InstancesFrom "category"
          ValuesFrom "value"
        </Result>
      </Query>
      <Database "product_information">
        #Plugin "warehouse"
        ConnectID "db01"
        Username "oracle"
        Password "secret"
        Query "out_of_stock"
      </Database>
    </Plugin>

### **Query** blocks

The Query blocks are handled identically to the Query blocks of the "dbi"
plugin. Please see its documentation above for details on how to specify
queries.

### **Database** blocks

Database blocks define a connection to a database and which queries should be
sent to that database. Each database needs a "name" as string argument in the
starting tag of the block. This name will be used as "PluginInstance" in the
values submitted to the daemon. Other than that, that name is not used.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting query results from
    this **Database**. Defaults to `oracle`.

- **ConnectID** _ID_

    Defines the "database alias" or "service name" to connect to. Usually, these
    names are defined in the file named `$ORACLE_HOME/network/admin/tnsnames.ora`.

- **Host** _Host_

    Hostname to use when dispatching values for this database. Defaults to using
    the global hostname of the _collectd_ instance.

- **Username** _Username_

    Username used for authentication.

- **Password** _Password_

    Password used for authentication.

- **Query** _QueryName_

    Associates the query named _QueryName_ with this database connection. The
    query needs to be defined _before_ this statement, i. e. all query
    blocks you want to refer to must be placed above the database block you want to
    refer to them from.

## Plugin `ovs_events`

The _ovs\_events_ plugin monitors the link status of _Open vSwitch_ (OVS)
connected interfaces, dispatches the values to collectd and sends the
notification whenever the link state change occurs. This plugin uses OVS
database to get a link state change notification.

**Synopsis:**

    <Plugin "ovs_events">
      Port 6640
      Address "127.0.0.1"
      Socket "/var/run/openvswitch/db.sock"
      Interfaces "br0" "veth0"
      SendNotification true
      DispatchValues false
    </Plugin>

The plugin provides the following configuration options:

- **Address** _node_

    The address of the OVS DB server JSON-RPC interface used by the plugin. To
    enable the interface, OVS DB daemon should be running with `--remote=ptcp:`
    option. See [ovsdb-server(1)](http://man.he.net/man1/ovsdb-server) for more details. The option may be either
    network hostname, IPv4 numbers-and-dots notation or IPv6 hexadecimal string
    format. Defaults to `localhost`.

- **Port** _service_

    TCP-port to connect to. Either a service name or a port number may be given.
    Defaults to **6640**.

- **Socket** _path_

    The UNIX domain socket path of OVS DB server JSON-RPC interface used by the
    plugin. To enable the interface, the OVS DB daemon should be running with
    `--remote=punix:` option. See [ovsdb-server(1)](http://man.he.net/man1/ovsdb-server) for more details. If this
    option is set, **Address** and **Port** options are ignored.

- **Interfaces** \[_ifname_ ...\]

    List of interface names to be monitored by this plugin. If this option is not
    specified or is empty then all OVS connected interfaces on all bridges are
    monitored.

    Default: empty (all interfaces on all bridges are monitored)

- **SendNotification** _true|false_

    If set to true, OVS link notifications (interface status and OVS DB connection
    terminate) are sent to collectd. Default value is true.

- **DispatchValues** _true|false_

    Dispatch the OVS DB interface link status value with configured plugin interval.
    Defaults to false. Please note, if **SendNotification** and **DispatchValues**
    options are false, no OVS information will be provided by the plugin.

**Note:** By default, the global interval setting is used within which to
retrieve the OVS link status. To configure a plugin-specific interval, please
use **Interval** option of the OVS **LoadPlugin** block settings. For milliseconds
simple divide the time by 1000 for example if the desired interval is 50ms, set
interval to 0.05.

## Plugin `ovs_stats`

The _ovs\_stats_ plugin collects statistics of OVS connected interfaces.
This plugin uses OVSDB management protocol (RFC7047) monitor mechanism to get
statistics from OVSDB

**Synopsis:**

    <Plugin "ovs_stats">
      Port 6640
      Address "127.0.0.1"
      Socket "/var/run/openvswitch/db.sock"
      Bridges "br0" "br_ext"
      InterfaceStats false
    </Plugin>

The plugin provides the following configuration options:

- **Address** _node_

    The address of the OVS DB server JSON-RPC interface used by the plugin. To
    enable the interface, OVS DB daemon should be running with `--remote=ptcp:`
    option. See [ovsdb-server(1)](http://man.he.net/man1/ovsdb-server) for more details. The option may be either
    network hostname, IPv4 numbers-and-dots notation or IPv6 hexadecimal string
    format. Defaults to `localhost`.

- **Port** _service_

    TCP-port to connect to. Either a service name or a port number may be given.
    Defaults to **6640**.

- **Socket** _path_

    The UNIX domain socket path of OVS DB server JSON-RPC interface used by the
    plugin. To enable the interface, the OVS DB daemon should be running with
    `--remote=punix:` option. See [ovsdb-server(1)](http://man.he.net/man1/ovsdb-server) for more details. If this
    option is set, **Address** and **Port** options are ignored.

- **Bridges** \[_brname_ ...\]

    List of OVS bridge names to be monitored by this plugin. If this option is
    omitted or is empty then all OVS bridges will be monitored.

    Default: empty (monitor all bridges)

- **InterfaceStats** **false**|**true**

    Indicates that the plugin should gather statistics for individual interfaces
    in addition to ports.  This can be useful when monitoring an OVS setup with
    bond ports, where you might wish to know individual statistics for the
    interfaces included in the bonds.  Defaults to **false**.

## Plugin `pcie_errors`

The _pcie\_errors_ plugin collects PCI Express errors from Device Status in Capability
structure and from Advanced Error Reporting Extended Capability where available.
At every read it polls config space of PCI Express devices and dispatches
notification for every error that is set. It checks for new errors at every read.
The device is indicated in plugin\_instance according to format "domain:bus:dev.fn".
Errors are divided into categories indicated by type\_instance: "correctable", and
for uncorrectable errors "non\_fatal" or "fatal".
Fatal errors are reported as _NOTIF\_FAILURE_ and all others as _NOTIF\_WARNING_.

**Synopsis:**

    <Plugin "pcie_errors">
      Source "sysfs"
      AccessDir "/sys/bus/pci"
      ReportMasked false
      PersistentNotifications false
    </Plugin>

**Options:**

- **Source** **sysfs**|**proc**

    Use **sysfs** or **proc** to read data from /sysfs or /proc.
    The default value is **sysfs**.

- **AccessDir** _dir_

    Directory used to access device config space. It is optional and defaults to
    /sys/bus/pci for **sysfs** and to /proc/bus/pci for **proc**.

- **ReportMasked** **false**|**true**

    If true plugin will notify about errors that are set to masked in Error Mask register.
    Such errors are not reported to the PCI Express Root Complex. Defaults to **false**.

- **PersistentNotifications** **false**|**true**

    If false plugin will dispatch notification only on set/clear of error.
    The ones already reported will be ignored. Defaults to **false**.

## Plugin `perl`

This plugin embeds a Perl-interpreter into collectd and provides an interface
to collectd's plugin system. See [collectd-perl(5)](http://man.he.net/man5/collectd-perl) for its documentation.

## Plugin `pinba`

The _Pinba plugin_ receives profiling information from _Pinba_, an extension
for the _PHP_ interpreter. At the end of executing a script, i.e. after a
PHP-based webpage has been delivered, the extension will send a UDP packet
containing timing information, peak memory usage and so on. The plugin will
wait for such packets, parse them and account the provided information, which
is then dispatched to the daemon once per interval.

Synopsis:

    <Plugin pinba>
      Address "::0"
      Port "30002"
      # Overall statistics for the website.
      <View "www-total">
        Server "www.example.com"
      </View>
      # Statistics for www-a only
      <View "www-a">
        Host "www-a.example.com"
        Server "www.example.com"
      </View>
      # Statistics for www-b only
      <View "www-b">
        Host "www-b.example.com"
        Server "www.example.com"
      </View>
    </Plugin>

The plugin provides the following configuration options:

- **Address** _Node_

    Configures the address used to open a listening socket. By default, plugin will
    bind to the _any_ address `::0`.

- **Port** _Service_

    Configures the port (service) to bind to. By default the default Pinba port
    "30002" will be used. The option accepts service names in addition to port
    numbers and thus requires a _string_ argument.

- <**View** _Name_> block

    The packets sent by the Pinba extension include the hostname of the server, the
    server name (the name of the virtual host) and the script that was executed.
    Using **View** blocks it is possible to separate the data into multiple groups
    to get more meaningful statistics. Each packet is added to all matching groups,
    so that a packet may be accounted for more than once.

    - **Host** _Host_

        Matches the hostname of the system the webserver / script is running on. This
        will contain the result of the [gethostname(2)](http://man.he.net/man2/gethostname) system call. If not
        configured, all hostnames will be accepted.

    - **Server** _Server_

        Matches the name of the _virtual host_, i.e. the contents of the
        `$_SERVER["SERVER_NAME"]` variable when within PHP. If not configured, all
        server names will be accepted.

    - **Script** _Script_

        Matches the name of the _script name_, i.e. the contents of the
        `$_SERVER["SCRIPT_NAME"]` variable when within PHP. If not configured, all
        script names will be accepted.

## Plugin `ping`

The _Ping_ plugin starts a new thread which sends ICMP "ping" packets to the
configured hosts periodically and measures the network latency. Whenever the
`read` function of the plugin is called, it submits the average latency, the
standard deviation and the drop rate for each host.

Available configuration options:

- **Host** _IP-address_

    Host to ping periodically. This option may be repeated several times to ping
    multiple hosts.

- **Interval** _Seconds_

    Sets the interval in which to send ICMP echo packets to the configured hosts.
    This is **not** the interval in which metrics are read from the plugin but the
    interval in which the hosts are "pinged". Therefore, the setting here should be
    smaller than or equal to the global **Interval** setting. Fractional times, such
    as "1.24" are allowed.

    Default: **1.0**

- **Timeout** _Seconds_

    Time to wait for a response from the host to which an ICMP packet had been
    sent. If a reply was not received after _Seconds_ seconds, the host is assumed
    to be down or the packet to be dropped. This setting must be smaller than the
    **Interval** setting above for the plugin to work correctly. Fractional
    arguments are accepted.

    Default: **0.9**

- **TTL** _0-255_

    Sets the Time-To-Live of generated ICMP packets.

- **Size** _size_

    Sets the size of the data payload in ICMP packet to specified _size_ (it
    will be filled with regular ASCII pattern). If not set, default 56 byte
    long string is used so that the packet size of an ICMPv4 packet is exactly
    64 bytes, similar to the behaviour of normal ping(1) command.

- **SourceAddress** _host_

    Sets the source address to use. _host_ may either be a numerical network
    address or a network hostname.

- **AddressFamily** _af_

    Sets the address family to use. _af_ may be "any", "ipv4" or "ipv6". This
    option will be ignored if you set a **SourceAddress**.

- **Device** _name_

    Sets the outgoing network device to be used. _name_ has to specify an
    interface name (e. g. `eth0`). This might not be supported by all
    operating systems.

- **MaxMissed** _Packets_

    Trigger a DNS resolve after the host has not replied to _Packets_ packets. This
    enables the use of dynamic DNS services (like dyndns.org) with the ping plugin.

    Default: **-1** (disabled)

## Plugin `postgresql`

The `postgresql` plugin queries statistics from PostgreSQL databases. It
keeps a persistent connection to all configured databases and tries to
reconnect if the connection has been interrupted. A database is configured by
specifying a **Database** block as described below. The default statistics are
collected from PostgreSQL's **statistics collector** which thus has to be
enabled for this plugin to work correctly. This should usually be the case by
default. See the section "The Statistics Collector" of the **PostgreSQL
Documentation** for details.

By specifying custom database queries using a **Query** block as described
below, you may collect any data that is available from some PostgreSQL
database. This way, you are able to access statistics of external daemons
which are available in a PostgreSQL database or use future or special
statistics provided by PostgreSQL without the need to upgrade your collectd
installation.

Starting with version 5.2, the `postgresql` plugin supports writing data to
PostgreSQL databases as well. This has been implemented in a generic way. You
need to specify an SQL statement which will then be executed by collectd in
order to write the data (see below for details). The benefit of that approach
is that there is no fixed database layout. Rather, the layout may be optimized
for the current setup.

The **PostgreSQL Documentation** manual can be found at
[http://www.postgresql.org/docs/manuals/](http://www.postgresql.org/docs/manuals/).

    <Plugin postgresql>
      <Query magic>
        Statement "SELECT magic FROM wizard WHERE host = $1;"
        Param hostname
        <Result>
          Type gauge
          InstancePrefix "magic"
          ValuesFrom magic
        </Result>
      </Query>

      <Query rt36_tickets>
        Statement "SELECT COUNT(type) AS count, type \
                          FROM (SELECT CASE \
                                       WHEN resolved = 'epoch' THEN 'open' \
                                       ELSE 'resolved' END AS type \
                                       FROM tickets) type \
                          GROUP BY type;"
        <Result>
          Type counter
          InstancePrefix "rt36_tickets"
          InstancesFrom "type"
          ValuesFrom "count"
        </Result>
      </Query>

      <Writer sqlstore>
        Statement "SELECT collectd_insert($1, $2, $3, $4, $5, $6, $7, $8, $9);"
        StoreRates true
      </Writer>

      <Database foo>
        Plugin "kingdom"
        Host "hostname"
        Port "5432"
        User "username"
        Password "secret"
        SSLMode "prefer"
        KRBSrvName "kerberos_service_name"
        Query magic
      </Database>

      <Database bar>
        Interval 300
        Service "service_name"
        Query backends # predefined
        Query rt36_tickets
      </Database>

      <Database qux>
        # ...
        Writer sqlstore
        CommitInterval 10
      </Database>
    </Plugin>

The **Query** block defines one database query which may later be used by a
database definition. It accepts a single mandatory argument which specifies
the name of the query. The names of all queries have to be unique (see the
**MinVersion** and **MaxVersion** options below for an exception to this
rule).

In each **Query** block, there is one or more **Result** blocks. Multiple
**Result** blocks may be used to extract multiple values from a single query.

The following configuration options are available to define the query:

- **Statement** _sql query statement_

    Specify the _sql query statement_ which the plugin should execute. The string
    may contain the tokens **$1**, **$2**, etc. which are used to reference the
    first, second, etc. parameter. The value of the parameters is specified by the
    **Param** configuration option - see below for details. To include a literal
    **$** character followed by a number, surround it with single quotes (**'**).

    Any SQL command which may return data (such as `SELECT` or `SHOW`) is
    allowed. Note, however, that only a single command may be used. Semicolons are
    allowed as long as a single non-empty command has been specified only.

    The returned lines will be handled separately one after another.

- **Param** _hostname_|_database_|_instance_|_username_|_interval_

    Specify the parameters which should be passed to the SQL query. The parameters
    are referred to in the SQL query as **$1**, **$2**, etc. in the same order as
    they appear in the configuration file. The value of the parameter is
    determined depending on the value of the **Param** option as follows:

    - _hostname_

        The configured hostname of the database connection. If a UNIX domain socket is
        used, the parameter expands to "localhost".

    - _database_

        The name of the database of the current connection.

    - _instance_

        The name of the database plugin instance. See the **Instance** option of the
        database specification below for details.

    - _username_

        The username used to connect to the database.

    - _interval_

        The interval with which this database is queried (as specified by the database
        specific or global **Interval** options).

    Please note that parameters are only supported by PostgreSQL's protocol
    version 3 and above which was introduced in version 7.4 of PostgreSQL.

- **PluginInstanceFrom** _column_

    Specify how to create the "PluginInstance" for reporting this query results.
    Only one column is supported. You may concatenate fields and string values in
    the query statement to get the required results.

- **MinVersion** _version_
- **MaxVersion** _version_

    Specify the minimum or maximum version of PostgreSQL that this query should be
    used with. Some statistics might only be available with certain versions of
    PostgreSQL. This allows you to specify multiple queries with the same name but
    which apply to different versions, thus allowing you to use the same
    configuration in a heterogeneous environment.

    The _version_ has to be specified as the concatenation of the major, minor
    and patch-level versions, each represented as two-decimal-digit numbers. For
    example, version 8.2.3 will become 80203.

The **Result** block defines how to handle the values returned from the query.
It defines which column holds which value and how to dispatch that value to
the daemon.

- **Type** _type_

    The _type_ name to be used when dispatching the values. The type describes
    how to handle the data and where to store it. See [types.db(5)](http://man.he.net/man5/types.db) for more
    details on types and their configuration. The number and type of values (as
    selected by the **ValuesFrom** option) has to match the type of the given name.

    This option is mandatory.

- **InstancePrefix** _prefix_
- **InstancesFrom** _column0_ \[_column1_ ...\]

    Specify how to create the "TypeInstance" for each data set (i. e. line).
    **InstancePrefix** defines a static prefix that will be prepended to all type
    instances. **InstancesFrom** defines the column names whose values will be used
    to create the type instance. Multiple values will be joined together using the
    hyphen (`-`) as separation character.

    The plugin itself does not check whether or not all built instances are
    different. It is your responsibility to assure that each is unique.

    Both options are optional. If none is specified, the type instance will be
    empty.

- **ValuesFrom** _column0_ \[_column1_ ...\]

    Names the columns whose content is used as the actual data for the data sets
    that are dispatched to the daemon. How many such columns you need is
    determined by the **Type** setting as explained above. If you specify too many
    or not enough columns, the plugin will complain about that and no data will be
    submitted to the daemon.

    The actual data type, as seen by PostgreSQL, is not that important as long as
    it represents numbers. The plugin will automatically cast the values to the
    right type if it know how to do that. For that, it uses the [strtoll(3)](http://man.he.net/man3/strtoll) and
    [strtod(3)](http://man.he.net/man3/strtod) functions, so anything supported by those functions is supported
    by the plugin as well.

    This option is required inside a **Result** block and may be specified multiple
    times. If multiple **ValuesFrom** options are specified, the columns are read
    in the given order.

The following predefined queries are available (the definitions can be found
in the `postgresql_default.conf` file which, by default, is available at
`_prefix_/share/collectd/`):

- **backends**

    This query collects the number of backends, i. e. the number of
    connected clients.

- **transactions**

    This query collects the numbers of committed and rolled-back transactions of
    the user tables.

- **queries**

    This query collects the numbers of various table modifications (i. e.
    insertions, updates, deletions) of the user tables.

- **query\_plans**

    This query collects the numbers of various table scans and returned tuples of
    the user tables.

- **table\_states**

    This query collects the numbers of live and dead rows in the user tables.

- **disk\_io**

    This query collects disk block access counts for user tables.

- **disk\_usage**

    This query collects the on-disk size of the database in bytes.

In addition, the following detailed queries are available by default. Please
note that each of those queries collects information **by table**, thus,
potentially producing **a lot** of data. For details see the description of the
non-by\_table queries above.

- **queries\_by\_table**
- **query\_plans\_by\_table**
- **table\_states\_by\_table**
- **disk\_io\_by\_table**

The **Writer** block defines a PostgreSQL writer backend. It accepts a single
mandatory argument specifying the name of the writer. This will then be used
in the **Database** specification in order to activate the writer instance. The
names of all writers have to be unique. The following options may be
specified:

- **Statement** _sql statement_

    This mandatory option specifies the SQL statement that will be executed for
    each submitted value. A single SQL statement is allowed only. Anything after
    the first semicolon will be ignored.

    Nine parameters will be passed to the statement and should be specified as
    tokens **$1**, **$2**, through **$9** in the statement string. The following
    values are made available through those parameters:

    - **$1**

        The timestamp of the queried value as an RFC 3339-formatted local time.

    - **$2**

        The hostname of the queried value.

    - **$3**

        The plugin name of the queried value.

    - **$4**

        The plugin instance of the queried value. This value may be **NULL** if there
        is no plugin instance.

    - **$5**

        The type of the queried value (cf. [types.db(5)](http://man.he.net/man5/types.db)).

    - **$6**

        The type instance of the queried value. This value may be **NULL** if there is
        no type instance.

    - **$7**

        An array of names for the submitted values (i. e., the name of the data
        sources of the submitted value-list).

    - **$8**

        An array of types for the submitted values (i. e., the type of the data
        sources of the submitted value-list; `counter`, `gauge`, ...). Note, that if
        **StoreRates** is enabled (which is the default, see below), all types will be
        `gauge`.

    - **$9**

        An array of the submitted values. The dimensions of the value name and value
        arrays match.

    In general, it is advisable to create and call a custom function in the
    PostgreSQL database for this purpose. Any procedural language supported by
    PostgreSQL will do (see chapter "Server Programming" in the PostgreSQL manual
    for details).

- **StoreRates** **false**|**true**

    If set to **true** (the default), convert counter values to rates. If set to
    **false** counter values are stored as is, i. e. as an increasing integer
    number.

The **Database** block defines one PostgreSQL database for which to collect
statistics. It accepts a single mandatory argument which specifies the
database name. None of the other options are required. PostgreSQL will use
default values as documented in the section "CONNECTING TO A DATABASE" in the
[psql(1)](http://man.he.net/man1/psql) manpage. However, be aware that those defaults may be influenced by
the user collectd is run as and special environment variables. See the manpage
for details.

- **Interval** _seconds_

    Specify the interval with which the database should be queried. The default is
    to use the global **Interval** setting.

- **CommitInterval** _seconds_

    This option may be used for database connections which have "writers" assigned
    (see above). If specified, it causes a writer to put several updates into a
    single transaction. This transaction will last for the specified amount of
    time. By default, each update will be executed in a separate transaction. Each
    transaction generates a fair amount of overhead which can, thus, be reduced by
    activating this option. The draw-back is, that data covering the specified
    amount of time will be lost, for example, if a single statement within the
    transaction fails or if the database server crashes.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name when submitting query results from
    this **Database**. Defaults to `postgresql`.

- **Instance** _name_

    Specify the plugin instance name that should be used instead of the database
    name (which is the default, if this option has not been specified). This
    allows one to query multiple databases of the same name on the same host (e.g.
    when running multiple database server versions in parallel).
    The plugin instance name can also be set from the query result using
    the **PluginInstanceFrom** option in **Query** block.

- **Host** _hostname_

    Specify the hostname or IP of the PostgreSQL server to connect to. If the
    value begins with a slash, it is interpreted as the directory name in which to
    look for the UNIX domain socket.

    This option is also used to determine the hostname that is associated with a
    collected data set. If it has been omitted or either begins with with a slash
    or equals **localhost** it will be replaced with the global hostname definition
    of collectd. Any other value will be passed literally to collectd when
    dispatching values. Also see the global **Hostname** and **FQDNLookup** options.

- **Port** _port_

    Specify the TCP port or the local UNIX domain socket file extension of the
    server.

- **User** _username_

    Specify the username to be used when connecting to the server.

- **Password** _password_

    Specify the password to be used when connecting to the server.

- **ExpireDelay** _delay_

    Skip expired values in query output.

- **SSLMode** _disable_|_allow_|_prefer_|_require_

    Specify whether to use an SSL connection when contacting the server. The
    following modes are supported:

    - _disable_

        Do not use SSL at all.

    - _allow_

        First, try to connect without using SSL. If that fails, try using SSL.

    - _prefer_ (default)

        First, try to connect using SSL. If that fails, try without using SSL.

    - _require_

        Use SSL only.

- **Instance** _name_

    Specify the plugin instance name that should be used instead of the database
    name (which is the default, if this option has not been specified). This
    allows one to query multiple databases of the same name on the same host (e.g.
    when running multiple database server versions in parallel).

- **KRBSrvName** _kerberos\_service\_name_

    Specify the Kerberos service name to use when authenticating with Kerberos 5
    or GSSAPI. See the sections "Kerberos authentication" and "GSSAPI" of the
    **PostgreSQL Documentation** for details.

- **Service** _service\_name_

    Specify the PostgreSQL service name to use for additional parameters. That
    service has to be defined in `pg_service.conf` and holds additional
    connection parameters. See the section "The Connection Service File" in the
    **PostgreSQL Documentation** for details.

- **Query** _query_

    Specifies a _query_ which should be executed in the context of the database
    connection. This may be any of the predefined or user-defined queries. If no
    such option is given, it defaults to "backends", "transactions", "queries",
    "query\_plans", "table\_states", "disk\_io" and "disk\_usage" (unless a **Writer**
    has been specified). Else, the specified queries are used only.

- **Writer** _writer_

    Assigns the specified _writer_ backend to the database connection. This
    causes all collected data to be send to the database using the settings
    defined in the writer configuration (see the section "FILTER CONFIGURATION"
    below for details on how to selectively send data to certain plugins).

    Each writer will register a flush callback which may be used when having long
    transactions enabled (see the **CommitInterval** option above). When issuing
    the **FLUSH** command (see [collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock) for details) the current
    transaction will be committed right away. Two different kinds of flush
    callbacks are available with the `postgresql` plugin:

    - **postgresql**

        Flush all writer backends.

    - **postgresql-**_database_

        Flush all writers of the specified _database_ only.

## Plugin `powerdns`

The `powerdns` plugin queries statistics from an authoritative PowerDNS
nameserver and/or a PowerDNS recursor. Since both offer a wide variety of
values, many of which are probably meaningless to most users, but may be useful
for some. So you may chose which values to collect, but if you don't, some
reasonable defaults will be collected.

    <Plugin "powerdns">
      <Server "server_name">
        Collect "latency"
        Collect "udp-answers" "udp-queries"
        Socket "/var/run/pdns.controlsocket"
      </Server>
      <Recursor "recursor_name">
        Collect "questions"
        Collect "cache-hits" "cache-misses"
        Socket "/var/run/pdns_recursor.controlsocket"
      </Recursor>
      LocalSocket "/opt/collectd/var/run/collectd-powerdns"
    </Plugin>

- **Server** and **Recursor** block

    The **Server** block defines one authoritative server to query, the **Recursor**
    does the same for an recursing server. The possible options in both blocks are
    the same, though. The argument defines a name for the server / recursor
    and is required.

    - **Collect** _Field_

        Using the **Collect** statement you can select which values to collect. Here,
        you specify the name of the values as used by the PowerDNS servers, e. g.
        `dlg-only-drops`, `answers10-100`.

        The method of getting the values differs for **Server** and **Recursor** blocks:
        When querying the server a `SHOW *` command is issued in any case, because
        that's the only way of getting multiple values out of the server at once.
        collectd then picks out the values you have selected. When querying the
        recursor, a command is generated to query exactly these values. So if you
        specify invalid fields when querying the recursor, a syntax error may be
        returned by the daemon and collectd may not collect any values at all.

        If no **Collect** statement is given, the following **Server** values will be
        collected:

        - latency
        - packetcache-hit
        - packetcache-miss
        - packetcache-size
        - query-cache-hit
        - query-cache-miss
        - recursing-answers
        - recursing-questions
        - tcp-answers
        - tcp-queries
        - udp-answers
        - udp-queries

        The following **Recursor** values will be collected by default:

        - noerror-answers
        - nxdomain-answers
        - servfail-answers
        - sys-msec
        - user-msec
        - qa-latency
        - cache-entries
        - cache-hits
        - cache-misses
        - questions

        Please note that up to that point collectd doesn't know what values are
        available on the server and values that are added do not need a change of the
        mechanism so far. However, the values must be mapped to collectd's naming
        scheme, which is done using a lookup table that lists all known values. If
        values are added in the future and collectd does not know about them, you will
        get an error much like this:

            powerdns plugin: submit: Not found in lookup table: foobar = 42

        In this case please file a bug report with the collectd team.

    - **Socket** _Path_

        Configures the path to the UNIX domain socket to be used when connecting to the
        daemon. By default `${localstatedir}/run/pdns.controlsocket` will be used for
        an authoritative server and `${localstatedir}/run/pdns_recursor.controlsocket`
        will be used for the recursor.

- **LocalSocket** _Path_

    Querying the recursor is done using UDP. When using UDP over UNIX domain
    sockets, the client socket needs a name in the file system, too. You can set
    this local name to _Path_ using the **LocalSocket** option. The default is
    `_prefix_/var/run/collectd-powerdns`.

## Plugin `processes`

Collects information about processes of local system.

By default, with no process matches configured, only general statistics is
collected: the number of processes in each state and fork rate.

Process matches can be configured by **Process** and **ProcessMatch** options.
These may also be a block in which further options may be specified.

The statistics collected for matched processes are:
 - size of the resident segment size (RSS)
 - user- and system-time used
 - number of processes
 - number of threads
 - number of open files (under Linux)
 - number of memory mapped files (under Linux)
 - io data (where available)
 - context switches (under Linux)
 - minor and major pagefaults
 - Delay Accounting information (Linux only, requires libmnl)

**Synopsis:**

    <Plugin processes>
      CollectFileDescriptor  true
      CollectContextSwitch   true
      CollectDelayAccounting false
      CollectSystemContextSwitch false
      Process "name"
      ProcessMatch "name" "regex"
      <Process "collectd">
        CollectFileDescriptor  false
        CollectContextSwitch   false
        CollectDelayAccounting true
      </Process>
      <ProcessMatch "name" "regex">
        CollectFileDescriptor false
        CollectContextSwitch true
      </ProcessMatch>
    </Plugin>

- **Process** _Name_

    Select more detailed statistics of processes matching this name.

    Some platforms have a limit on the length of process names.
    _Name_ must stay below this limit.

- **ProcessMatch** _name_ _regex_

    Select more detailed statistics of processes matching the specified _regex_
    (see [regex(7)](http://man.he.net/man7/regex) for details). The statistics of all matching processes are
    summed up and dispatched to the daemon using the specified _name_ as an
    identifier. This allows one to "group" several processes together.
    _name_ must not contain slashes.

- **CollectContextSwitch** _Boolean_

    Collect the number of context switches for matched processes.
    Disabled by default.

- **CollectDelayAccounting** _Boolean_

    If enabled, collect Linux Delay Accounding information for matching processes.
    Delay Accounting provides the time processes wait for the CPU to become
    available, for I/O operations to finish, for pages to be swapped in and for
    freed pages to be reclaimed. The metrics are reported as "seconds per second"
    using the `delay_rate` type, e.g. `delay_rate-delay-cpu`.
    Disabled by default.

    This option is only available on Linux, requires the `libmnl` library and
    requires the `CAP_NET_ADMIN` capability at runtime.

- **CollectFileDescriptor** _Boolean_

    Collect number of file descriptors of matched processes.
    Disabled by default.

- **CollectMemoryMaps** _Boolean_

    Collect the number of memory mapped files of the process.
    The limit for this number is configured via `/proc/sys/vm/max_map_count` in
    the Linux kernel.

- **CollectSystemContextSwitch** _Boolean_

    Collect the number of context switches at the system level.
    Collect ctxt fields from /proc/stat in linux systems.
    Can be configured only outside the **Process** and **ProcessMatch**
    blocks.

The **CollectContextSwitch**, **CollectDelayAccounting**,
**CollectFileDescriptor** and **CollectMemoryMaps** options may be used inside
**Process** and **ProcessMatch** blocks. When used there, these options affect
reporting the corresponding processes only. Outside of **Process** and
**ProcessMatch** blocks these options set the default value for subsequent
matches.

## Plugin `procevent`

The _procevent_ plugin monitors when processes start (EXEC) and stop (EXIT).

**Synopsis:**

    <Plugin procevent>
      BufferLength 10
      Process "name"
      ProcessRegex "regex"
    </Plugin>

**Options:**

- **BufferLength** _length_

    Maximum number of process events that can be stored in plugin's ring buffer.
    By default, this is set to 10.  Once an event has been read, its location
    becomes available for storing a new event.

- **Process** _name_

    Enumerate a process name to monitor.  All processes that match this exact
    name will be monitored for EXECs and EXITs.

- **ProcessRegex** _regex_

    Enumerate a process pattern to monitor.  All processes that match this 
    regular expression will be monitored for EXECs and EXITs.

## Plugin `protocols`

Collects a lot of information about various network protocols, such as _IP_,
_TCP_, _UDP_, etc.

Available configuration options:

- **Value** _Selector_

    Selects whether or not to select a specific value. The string being matched is
    of the form "_Protocol_:_ValueName_", where _Protocol_ will be used as the
    plugin instance and _ValueName_ will be used as type instance. An example of
    the string being used would be `Tcp:RetransSegs`.

    You can use regular expressions to match a large number of values with just one
    configuration option. To select all "extended" _TCP_ values, you could use the
    following statement:

        Value "/^TcpExt:/"

    Whether only matched values are selected or all matched values are ignored
    depends on the **IgnoreSelected**. By default, only matched values are selected.
    If no value is configured at all, all values will be selected.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    If set to **true**, inverts the selection made by **Value**, i. e. all
    matching values will be ignored.

## Plugin `python`

This plugin embeds a Python-interpreter into collectd and provides an interface
to collectd's plugin system. See [collectd-python(5)](http://man.he.net/man5/collectd-python) for its documentation.

## Plugin `ras`

The `ras` plugin gathers and counts errors provided by \[RASDaemon\]
(https://github.com/mchehab/rasdaemon). This plugin requires access to SQLite3
database from \`RASDaemon\`.

Metrics:
  type: ras\_errors
  plugin\_instance: CPU\_(number CPU) for metrics per CPU Core metric. For metrics per Server metrics this value is empty.
  type\_instance:
    per CPU Core:
      - memory\_read\_corrected\_errors
      - memory\_read\_uncorrectable\_errors
      - memory\_write\_corrected\_errors
      - memory\_write\_uncorrectable\_errors
      - cache\_l0\_l1\_errors
      - tlb\_instruction\_errors
      - processor\_base\_errors
      - processor\_bus\_errors
      - internal\_timer\_errors
      - smm\_handler\_code\_access\_violation\_errors
      - internal\_parity\_errors
      - frc\_errors
      - external\_mce\_errors
      - microcode\_rom\_parity\_errors
      - unclassified\_mce\_errors
    per Server:
      - cache\_l2\_errors
      - upi\_errors

Please note that \`processor\_base\_errors\` is aggregate counter measuring the following MCE events:
\- internal\_timer\_errors
\- smm\_handler\_code\_access\_violation\_errors
\- internal\_parity\_errors
\- frc\_errors
\- external\_mce\_errors
\- microcode\_rom\_parity\_errors
\- unclassified\_mce\_errors

In addition \`RASDaemon\` runs, by default, with \`--enable-sqlite3\` flag. In case of
problems with SQLite3 database please verify this is still a default option.

- **DB\_Path** _Path_

    Path to the RASDemon database (sqlite3). Please make sure that user has read
    permissions to this database. Example and default setting:

        DB_Path "/var/lib/rasdaemon/ras-mc_event.db"

## Plugin `redfish`

The `redfish` plugin collects sensor data using REST protocol called
Redfish.

**Sample configuration:**

    <Plugin redfish>
      <Query "fans">
        Endpoint "/redfish/v1/Chassis/Chassis-1/Thermal"
        <Resource "Fans">
          <Property "ReadingRPM">
            PluginInstance "chassis-1"
            Type "rpm"
          </Property>
        </Resource>
      </Query>
      <Query "temperatures">
        Endpoint "/redfish/v1/Chassis/Chassis-1/Thermal"
        <Resource "Temperatures">
          <Property "ReadingCelsius">
            PluginInstance "chassis-1"
            Type "degrees"
          </Property>
        </Resource>
      </Query>
      <Query "voltages">
        Endpoint "/redfish/v1/Chassis/Chassis-1/Power"
        <Resource "Voltages">
          <Property "ReadingVolts">
            PluginInstance "chassis-1"
            Type "volts"
          </Property>
        </Resource>
      </Query>
      <Service "local">
        Host "127.0.0.1:5000"
        User "user"
        Passwd "passwd"
        Queries "fans" "voltages" "temperatures"
      </Service>
    </Plugin>

- **Query**

    Section defining a query performed on Redfish interface

- **Endpoint**

    URI of the REST API Endpoint for accessing the BMC

- **Resource**

    Selects single resource or array to collect data.

- **Property**

    Selects property from which data is gathered

- **PluginInstance**

    Plugin instance of dispatched collectd metric

- **Type**

    Type of dispatched collectd metric

- **TypeInstance**

    Type instance of collectd metric

- **Service**

    Section defining service to be sent requests

- **Username**

    BMC username

- **Password**

    BMC password

- **Queries**

    Queries to run

## Plugin `routeros`

The `routeros` plugin connects to a device running _RouterOS_, the
Linux-based operating system for routers by _MikroTik_. The plugin uses
_librouteros_ to connect and reads information about the interfaces and
wireless connections of the device. The configuration supports querying
multiple routers:

    <Plugin "routeros">
      <Router>
        Host "router0.example.com"
        User "collectd"
        Password "secr3t"
        CollectInterface true
        CollectCPULoad true
        CollectMemory true
      </Router>
      <Router>
        Host "router1.example.com"
        User "collectd"
        Password "5ecret"
        CollectInterface true
        CollectRegistrationTable true
        CollectDF true
        CollectDisk true
        CollectHealth true
      </Router>
    </Plugin>

As you can see above, the configuration of the _routeros_ plugin consists of
one or more **<Router>** blocks. Within each block, the following
options are understood:

- **Host** _Host_

    Hostname or IP-address of the router to connect to.

- **Port** _Port_

    Port name or port number used when connecting. If left unspecified, the default
    will be chosen by _librouteros_, currently "8728". This option expects a
    string argument, even when a numeric port number is given.

- **User** _User_

    Use the user name _User_ to authenticate. Defaults to "admin".

- **Password** _Password_

    Set the password used to authenticate.

- **CollectInterface** **true**|**false**

    When set to **true**, interface statistics will be collected for all interfaces
    present on the device. Defaults to **false**.

- **CollectRegistrationTable** **true**|**false**

    When set to **true**, information about wireless LAN connections will be
    collected. Defaults to **false**.

- **CollectCPULoad** **true**|**false**

    When set to **true**, information about the CPU usage will be collected. The
    number is a dimensionless value where zero indicates no CPU usage at all.
    Defaults to **false**.

- **CollectMemory** **true**|**false**

    When enabled, the amount of used and free memory will be collected. How used
    memory is calculated is unknown, for example whether or not caches are counted
    as used space.
    Defaults to **false**.

- **CollectDF** **true**|**false**

    When enabled, the amount of used and free disk space will be collected.
    Defaults to **false**.

- **CollectDisk** **true**|**false**

    When enabled, the number of sectors written and bad blocks will be collected.
    Defaults to **false**.

- **CollectHealth** **true**|**false**

    When enabled, the health statistics will be collected. This includes the
    voltage and temperature on supported hardware.
    Defaults to **false**.

## Plugin `redis`

The _Redis plugin_ connects to one or more Redis servers, gathers
information about each server's state and executes user-defined queries.
For each server there is a _Node_ block which configures the connection
parameters and set of user-defined queries for this node.

    <Plugin redis>
      <Node "example">
          Host "localhost"
          Port "6379"
          #Socket "/var/run/redis/redis.sock"
          Timeout 2000
          ReportCommandStats false
          ReportCpuUsage true
          <Query "LLEN myqueue">
            #Database 0
            Type "queue_length"
            Instance "myqueue"
          </Query>
      </Node>
    </Plugin>

- **Node** _Nodename_

    The **Node** block identifies a new Redis node, that is a new Redis instance
    running in an specified host and port. The name for node is a canonical
    identifier which is used as _plugin instance_. It is limited to
    128 characters in length.

    When no **Node** is configured explicitly, plugin connects to "localhost:6379".

- **Host** _Hostname_

    The **Host** option is the hostname or IP-address where the Redis instance is
    running on.

- **Port** _Port_

    The **Port** option is the TCP port on which the Redis instance accepts
    connections. Either a service name of a port number may be given. Please note
    that numerical port numbers must be given as a string, too.

- **Socket** _Path_

    Connect to Redis using the UNIX domain socket at _Path_. If this
    setting is given, the **Hostname** and **Port** settings are ignored.

- **Password** _Password_

    Use _Password_ to authenticate when connecting to _Redis_.

- **Timeout** _Milliseconds_

    The **Timeout** option set the socket timeout for node response. Since the Redis
    read function is blocking, you should keep this value as low as possible.
    It is expected what **Timeout** values should be lower than **Interval** defined
    globally.

    Defaults to 2000 (2 seconds).

- **ReportCommandStats** **false**|**true**

    Enables or disables reporting of statistics based on the command type, including
    rate of command calls and average CPU time consumed by command processing.
    Defaults to **false**.

- **ReportCpuUsage** **true**|**false**

    Enables or disables reporting of CPU consumption statistics.
    Defaults to **true**.

- **Query** _Querystring_

    The **Query** block identifies a query to execute against the redis server.
    There may be an arbitrary number of queries to execute. Each query should
    return single string or integer.

- **Type** _Collectd type_

    Within a query definition, a valid _collectd type_ to use as when submitting
    the result of the query. When not supplied, will default to **gauge**.

    Currently only types with one datasource are supported.
    See [types.db(5)](http://man.he.net/man5/types.db) for more details on types and their configuration.

- **Instance** _Type instance_

    Within a query definition, an optional type instance to use when submitting
    the result of the query. When not supplied will default to the escaped
    command, up to 128 chars.

- **Database** _Index_

    This index selects the Redis logical database to use for query. Defaults
    to `0`.

## Plugin `rrdcached`

The `rrdcached` plugin uses the RRDtool accelerator daemon, [rrdcached(1)](http://man.he.net/man1/rrdcached),
to store values to RRD files in an efficient manner. The combination of the
`rrdcached` **plugin** and the `rrdcached` **daemon** is very similar to the
way the `rrdtool` plugin works (see below). The added abstraction layer
provides a number of benefits, though: Because the cache is not within
`collectd` anymore, it does not need to be flushed when `collectd` is to be
restarted. This results in much shorter (if any) gaps in graphs, especially
under heavy load. Also, the `rrdtool` command line utility is aware of the
daemon so that it can flush values to disk automatically when needed. This
allows one to integrate automated flushing of values into graphing solutions
much more easily.

There are disadvantages, though: The daemon may reside on a different host, so
it may not be possible for `collectd` to create the appropriate RRD files
anymore. And even if `rrdcached` runs on the same host, it may run in a
different base directory, so relative paths may do weird stuff if you're not
careful.

So the **recommended configuration** is to let `collectd` and `rrdcached` run
on the same host, communicating via a UNIX domain socket. The **DataDir**
setting should be set to an absolute path, so that a changed base directory
does not result in RRD files being created / expected in the wrong place.

- **DaemonAddress** _Address_

    Address of the daemon as understood by the `rrdc_connect` function of the RRD
    library. See [rrdcached(1)](http://man.he.net/man1/rrdcached) for details. Example:

        <Plugin "rrdcached">
          DaemonAddress "unix:/var/run/rrdcached.sock"
        </Plugin>

- **DataDir** _Directory_

    Set the base directory in which the RRD files reside. If this is a relative
    path, it is relative to the working base directory of the `rrdcached` daemon!
    Use of an absolute path is recommended.

- **CreateFiles** **true**|**false**

    Enables or disables the creation of RRD files. If the daemon is not running
    locally, or **DataDir** is set to a relative path, this will not work as
    expected. Default is **true**.

- **CreateFilesAsync** **false**|**true**

    When enabled, new RRD files are enabled asynchronously, using a separate thread
    that runs in the background. This prevents writes to block, which is a problem
    especially when many hundreds of files need to be created at once. However,
    since the purpose of creating the files asynchronously is _not_ to block until
    the file is available, values before the file is available will be discarded.
    When disabled (the default) files are created synchronously, blocking for a
    short while, while the file is being written.

- **StepSize** _Seconds_

    **Force** the stepsize of newly created RRD-files. Ideally (and per default)
    this setting is unset and the stepsize is set to the interval in which the data
    is collected. Do not use this option unless you absolutely have to for some
    reason. Setting this option may cause problems with the `snmp plugin`, the
    `exec plugin` or when the daemon is set up to receive data from other hosts.

- **HeartBeat** _Seconds_

    **Force** the heartbeat of newly created RRD-files. This setting should be unset
    in which case the heartbeat is set to twice the **StepSize** which should equal
    the interval in which data is collected. Do not set this option unless you have
    a very good reason to do so.

- **RRARows** _NumRows_

    The `rrdtool plugin` calculates the number of PDPs per CDP based on the
    **StepSize**, this setting and a timespan. This plugin creates RRD-files with
    three times five RRAs, i. e. five RRAs with the CFs **MIN**, **AVERAGE**, and
    **MAX**. The five RRAs are optimized for graphs covering one hour, one day, one
    week, one month, and one year.

    So for each timespan, it calculates how many PDPs need to be consolidated into
    one CDP by calculating:
      number of PDPs = timespan / (stepsize \* rrarows)

    Bottom line is, set this no smaller than the width of you graphs in pixels. The
    default is 1200.

- **RRATimespan** _Seconds_

    Adds an RRA-timespan, given in seconds. Use this option multiple times to have
    more then one RRA. If this option is never used, the built-in default of (3600,
    86400, 604800, 2678400, 31622400) is used.

    For more information on how RRA-sizes are calculated see **RRARows** above.

- **XFF** _Factor_

    Set the "XFiles Factor". The default is 0.1. If unsure, don't set this option.
    _Factor_ must be in the range `[0.0-1.0)`, i.e. between zero (inclusive) and
    one (exclusive).

- **CollectStatistics** **false**|**true**

    When set to **true**, various statistics about the _rrdcached_ daemon will be
    collected, with "rrdcached" as the _plugin name_. Defaults to **false**.

    Statistics are read via _rrdcached_s socket using the STATS command.
    See [rrdcached(1)](http://man.he.net/man1/rrdcached) for details.

## Plugin `rrdtool`

You can use the settings **StepSize**, **HeartBeat**, **RRARows**, and **XFF** to
fine-tune your RRD-files. Please read [rrdcreate(1)](http://man.he.net/man1/rrdcreate) if you encounter problems
using these settings. If you don't want to dive into the depths of RRDtool, you
can safely ignore these settings.

- **DataDir** _Directory_

    Set the directory to store RRD files under. By default RRD files are generated
    beneath the daemon's working directory, i.e. the **BaseDir**.

- **CreateFilesAsync** **false**|**true**

    When enabled, new RRD files are enabled asynchronously, using a separate thread
    that runs in the background. This prevents writes to block, which is a problem
    especially when many hundreds of files need to be created at once. However,
    since the purpose of creating the files asynchronously is _not_ to block until
    the file is available, values before the file is available will be discarded.
    When disabled (the default) files are created synchronously, blocking for a
    short while, while the file is being written.

- **StepSize** _Seconds_

    **Force** the stepsize of newly created RRD-files. Ideally (and per default)
    this setting is unset and the stepsize is set to the interval in which the data
    is collected. Do not use this option unless you absolutely have to for some
    reason. Setting this option may cause problems with the `snmp plugin`, the
    `exec plugin` or when the daemon is set up to receive data from other hosts.

- **HeartBeat** _Seconds_

    **Force** the heartbeat of newly created RRD-files. This setting should be unset
    in which case the heartbeat is set to twice the **StepSize** which should equal
    the interval in which data is collected. Do not set this option unless you have
    a very good reason to do so.

- **RRARows** _NumRows_

    The `rrdtool plugin` calculates the number of PDPs per CDP based on the
    **StepSize**, this setting and a timespan. This plugin creates RRD-files with
    three times five RRAs, i.e. five RRAs with the CFs **MIN**, **AVERAGE**, and
    **MAX**. The five RRAs are optimized for graphs covering one hour, one day, one
    week, one month, and one year.

    So for each timespan, it calculates how many PDPs need to be consolidated into
    one CDP by calculating:
      number of PDPs = timespan / (stepsize \* rrarows)

    Bottom line is, set this no smaller than the width of you graphs in pixels. The
    default is 1200.

- **RRATimespan** _Seconds_

    Adds an RRA-timespan, given in seconds. Use this option multiple times to have
    more then one RRA. If this option is never used, the built-in default of (3600,
    86400, 604800, 2678400, 31622400) is used.

    For more information on how RRA-sizes are calculated see **RRARows** above.

- **XFF** _Factor_

    Set the "XFiles Factor". The default is 0.1. If unsure, don't set this option.
    _Factor_ must be in the range `[0.0-1.0)`, i.e. between zero (inclusive) and
    one (exclusive).

- **CacheFlush** _Seconds_

    When the `rrdtool` plugin uses a cache (by setting **CacheTimeout**, see below)
    it writes all values for a certain RRD-file if the oldest value is older than
    (or equal to) the number of seconds specified by **CacheTimeout**.
    That check happens on new values arriwal. If some RRD-file is not updated
    anymore for some reason (the computer was shut down, the network is broken,
    etc.) some values may still be in the cache. If **CacheFlush** is set, then
    every _Seconds_ seconds the entire cache is searched for entries older than
    **CacheTimeout** + **RandomTimeout** seconds. The entries found are written to
    disk. Since scanning the entire cache is kind of expensive and does nothing
    under normal circumstances, this value should not be too small. 900 seconds
    might be a good value, though setting this to 7200 seconds doesn't normally
    do much harm either.

    Defaults to 10x **CacheTimeout**.
    **CacheFlush** must be larger than or equal to **CacheTimeout**, otherwise the
    above default is used.

- **CacheTimeout** _Seconds_

    If this option is set to a value greater than zero, the `rrdtool plugin` will
    save values in a cache, as described above. Writing multiple values at once
    reduces IO-operations and thus lessens the load produced by updating the files.
    The trade off is that the graphs kind of "drag behind" and that more memory is
    used.

- **WritesPerSecond** _Updates_

    When collecting many statistics with collectd and the `rrdtool` plugin, you
    will run serious performance problems. The **CacheFlush** setting and the
    internal update queue assert that collectd continues to work just fine even
    under heavy load, but the system may become very unresponsive and slow. This is
    a problem especially if you create graphs from the RRD files on the same
    machine, for example using the `graph.cgi` script included in the
    `contrib/collection3/` directory.

    This setting is designed for very large setups. Setting this option to a value
    between 25 and 80 updates per second, depending on your hardware, will leave
    the server responsive enough to draw graphs even while all the cached values
    are written to disk. Flushed values, i. e. values that are forced to disk
    by the **FLUSH** command, are **not** effected by this limit. They are still
    written as fast as possible, so that web frontends have up to date data when
    generating graphs.

    For example: If you have 100,000 RRD files and set **WritesPerSecond** to 30
    updates per second, writing all values to disk will take approximately
    56 minutes. Together with the flushing ability that's integrated into
    "collection3" you'll end up with a responsive and fast system, up to date
    graphs and basically a "backup" of your values every hour.

- **RandomTimeout** _Seconds_

    When set, the actual timeout for each value is chosen randomly between
    _CacheTimeout_-_RandomTimeout_ and _CacheTimeout_+_RandomTimeout_. The
    intention is to avoid high load situations that appear when many values timeout
    at the same time. This is especially a problem shortly after the daemon starts,
    because all values were added to the internal cache at roughly the same time.

## Plugin `sensors`

The _Sensors plugin_ uses **lm\_sensors** to retrieve sensor-values. This means
that all the needed modules have to be loaded and lm\_sensors has to be
configured (most likely by editing `/etc/sensors.conf`. Read
[sensors.conf(5)](http://man.he.net/man5/sensors.conf) for details.

The **lm\_sensors** homepage can be found at
[http://secure.netroedge.com/~lm78/](http://secure.netroedge.com/~lm78/).

- **SensorConfigFile** _File_

    Read the _lm\_sensors_ configuration from _File_. When unset (recommended),
    the library's default will be used.

- **Sensor** _chip-bus-address/type-feature_

    Selects the name of the sensor which you want to collect or ignore, depending
    on the **IgnoreSelected** below. For example, the option "**Sensor**
    _it8712-isa-0290/voltage-in1_" will cause collectd to gather data for the
    voltage sensor _in1_ of the _it8712_ on the isa bus at the address 0290.

    The value passed to this option has the format
    "_plugin\_instance_/_type_-_type\_instance_".

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    If no configuration if given, the **sensors**-plugin will collect data from all
    sensors. This may not be practical, especially for uninteresting sensors.
    Thus, you can use the **Sensor**-option to pick the sensors you're interested
    in. Sometimes, however, it's easier/preferred to collect all sensors _except_ a
    few ones. This option enables you to do that: By setting **IgnoreSelected** to
    _true_ the effect of **Sensor** is inverted: All selected sensors are ignored
    and all other sensors are collected.

- **UseLabels** _true_|_false_

    Configures how sensor readings are reported. When set to _true_, sensor
    readings are reported using their descriptive label (e.g. "VCore"). When set to
    _false_ (the default) the sensor name is used ("in0").

## Plugin `sigrok`

The _sigrok plugin_ uses _libsigrok_ to retrieve measurements from any device
supported by the [sigrok](http://sigrok.org/) project.

**Synopsis**

    <Plugin sigrok>
      LogLevel 3
      <Device "AC Voltage">
         Driver "fluke-dmm"
         MinimumInterval 10
         Conn "/dev/ttyUSB2"
      </Device>
      <Device "Sound Level">
         Driver "cem-dt-885x"
         Conn "/dev/ttyUSB1"
      </Device>
    </Plugin>

- **LogLevel** **0-5**

    The _sigrok_ logging level to pass on to the _collectd_ log, as a number
    between **0** and **5** (inclusive). These levels correspond to `None`,
    `Errors`, `Warnings`, `Informational`, `Debug `and `Spew`, respectively.
    The default is **2** (`Warnings`). The _sigrok_ log messages, regardless of
    their level, are always submitted to _collectd_ at its INFO log level.

- <**Device** _Name_>

    A sigrok-supported device, uniquely identified by this section's options. The
    _Name_ is passed to _collectd_ as the _plugin instance_.

- **Driver** _DriverName_

    The sigrok driver to use for this device.

- **Conn** _ConnectionSpec_

    If the device cannot be auto-discovered, or more than one might be discovered
    by the driver, _ConnectionSpec_ specifies the connection string to the device.
    It can be of the form of a device path (e.g. `/dev/ttyUSB2`), or, in
    case of a non-serial USB-connected device, the USB _VendorID_**.**_ProductID_
    separated by a period (e.g. `0403.6001`). A USB device can also be
    specified as _Bus_**.**_Address_ (e.g. `1.41`).

- **SerialComm** _SerialSpec_

    For serial devices with non-standard port settings, this option can be used
    to specify them in a form understood by _sigrok_, e.g. `9600/8n1`.
    This should not be necessary; drivers know how to communicate with devices they
    support.

- **MinimumInterval** _Seconds_

    Specifies the minimum time between measurement dispatches to _collectd_, in
    seconds. Since some _sigrok_ supported devices can acquire measurements many
    times per second, it may be necessary to throttle these. For example, the
    _RRD plugin_ cannot process writes more than once per second.

    The default **MinimumInterval** is **0**, meaning measurements received from the
    device are always dispatched to _collectd_. When throttled, unused
    measurements are discarded.

## Plugin `slurm`

This plugin collects per-partition SLURM node and job state information, as
well as internal health statistics.
It takes no options. It should run on a node that is capable of running the
_sinfo_ and _squeue_ commands, i.e. it has a running slurmd and a valid
slurm.conf.
Note that this plugin needs the **Globals** option set to _true_ in order to
function properly.

## Plugin `smart`

The `smart` plugin collects SMART information from physical
disks. Values collectd include temperature, power cycle count, poweron
time and bad sectors. Also, all SMART attributes are collected along
with the normalized current value, the worst value, the threshold and
a human readable value. The plugin can also collect SMART attributes
for NVMe disks (present in accordance with NVMe 1.4 spec) and Additional
SMART Attributes from Intel® NVMe disks.

Using the following two options you can ignore some disks or configure the
collection only of specific disks.

- **Disk** _Name_

    Select the disk _Name_. Whether it is collected or ignored depends on the
    **IgnoreSelected** setting, see below. As with other plugins that use the
    daemon's ignorelist functionality, a string that starts and ends with a slash
    is interpreted as a regular expression. Examples:

        Disk "sdd"
        Disk "/hda[34]/"
        Disk "nvme0n1"

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Sets whether selected disks, i. e. the ones matches by any of the **Disk**
    statements, are ignored or if all other disks are ignored. The behavior
    (hopefully) is intuitive: If no **Disk** option is configured, all disks are
    collected. If at least one **Disk** option is given and no **IgnoreSelected** or
    set to **false**, **only** matching disks will be collected. If **IgnoreSelected**
    is set to **true**, all disks are collected **except** the ones matched.

- **IgnoreSleepMode** **true**|**false**

    Normally, the `smart` plugin will ignore disks that are reported to be asleep.
    This option disables the sleep mode check and allows the plugin to collect data
    from these disks anyway. This is useful in cases where libatasmart mistakenly
    reports disks as asleep because it has not been updated to incorporate support
    for newer idle states in the ATA spec.

- **UseSerial** **true**|**false**

    A disk's kernel name (e.g., sda) can change from one boot to the next. If this
    option is enabled, the `smart` plugin will use the disk's serial number (e.g.,
    HGST\_HUH728080ALE600\_2EJ8VH8X) instead of the kernel name as the key for
    storing data. This ensures that the data for a given disk will be kept together
    even if the kernel name changes.

## Plugin `snmp`

Since the configuration of the `snmp plugin` is a little more complicated than
other plugins, its documentation has been moved to an own manpage,
[collectd-snmp(5)](http://man.he.net/man5/collectd-snmp). Please see there for details.

## Plugin `snmp_agent`

The _snmp\_agent_ plugin is an AgentX subagent that receives and handles queries
from SNMP master agent and returns the data collected by read plugins.
The _snmp\_agent_ plugin handles requests only for OIDs specified in
configuration file. To handle SNMP queries the plugin gets data from collectd
and translates requested values from collectd's internal format to SNMP format.
This plugin is a generic plugin and cannot work without configuration.
For more details on AgentX subagent see
&lt;http://www.net-snmp.org/tutorial/tutorial-5/toolkit/demon/>

**Synopsis:**

    <Plugin snmp_agent>
      <Data "memAvailReal">
        Plugin "memory"
        #PluginInstance "some"
        Type "memory"
        TypeInstance "free"
        OIDs "1.3.6.1.4.1.2021.4.6.0"
      </Data>
      <Table "ifTable">
        IndexOID "IF-MIB::ifIndex"
        SizeOID "IF-MIB::ifNumber"
        <Data "ifDescr">
          <IndexKey>
            Source "PluginInstance"
          </IndexKey>
          Plugin "interface"
          OIDs "IF-MIB::ifDescr"
        </Data>
        <Data "ifOctets">
          Plugin "interface"
          Type "if_octets"
          TypeInstance ""
          OIDs "IF-MIB::ifInOctets" "IF-MIB::ifOutOctets"
        </Data>
      </Table>
      <Table "CPUAffinityTable">
        <Data "DomainName">
          <IndexKey>
            Source "PluginInstance"
          </IndexKey>
          Plugin "virt"
          OIDs "LIBVIRT-HYPERVISOR-MIB::lvhAffinityDomainName"
        </Data>
        <Data "VCPU">
          Plugin "virt"
          <IndexKey>
            Source "TypeInstance"
            Regex "^vcpu_([0-9]{1,3})-cpu_[0-9]{1,3}$"
            Group 1
          </IndexKey>
          OIDs "LIBVIRT-HYPERVISOR-MIB::lvhVCPUIndex"
        </Data>
        <Data "CPU">
          Plugin "virt"
          <IndexKey>
            Source "TypeInstance"
            Regex "^vcpu_[0-9]{1,3}-cpu_([0-9]{1,3})$"
            Group 1
          </IndexKey>
          OIDs "LIBVIRT-HYPERVISOR-MIB::lvhCPUIndex"
        </Data>
        <Data "CPUAffinity">
          Plugin "virt"
          Type "cpu_affinity"
          OIDs "LIBVIRT-HYPERVISOR-MIB::lvhCPUAffinity"
        </Data>
      </Table>
    </Plugin>

There are two types of blocks that can be contained in the
`<Plugin  snmp_agent>` block: **Data** and **Table**:

### **Data** block

The **Data** block defines a list OIDs that are to be handled. This block can
define scalar or table OIDs. If **Data** block is defined inside of **Table**
block it reperesents table OIDs.
The following options can be set:

- **IndexKey** block

    **IndexKey** block contains all data needed for proper index build of snmp table.
    In case more than
    one table **Data** block has **IndexKey** block present then multiple key index is
    built. If **Data** block defines scalar data type **IndexKey** has no effect and can
    be omitted.

    - **Source** _String_

        **Source** can be set to one of the following values: "Hostname", "Plugin",
        "PluginInstance", "Type", "TypeInstance". This value indicates which field of
        corresponding collectd metric is taken as a SNMP table index.

    - **Regex** _String_

        **Regex** option can also be used to parse strings or numbers out of
        specific field. For example: type-instance field which is "vcpu1-cpu2" can be
        parsed into two numeric fields CPU = 2 and VCPU = 1 and can be later used
        as a table index.

    - **Group** _Number_

        **Group** number can be specified in case groups are used in regex.

- **Plugin** _String_

    Read plugin name whose collected data will be mapped to specified OIDs.

- **PluginInstance** _String_

    Read plugin instance whose collected data will be mapped to specified OIDs.
    The field is optional and by default there is no plugin instance check.
    Allowed only if **Data** block defines scalar data type.

- **Type** _String_

    Collectd's type that is to be used for specified OID, e. g. "if\_octets"
    for example. The types are read from the **TypesDB** (see [collectd.conf(5)](http://man.he.net/man5/collectd.conf)).

- **TypeInstance** _String_

    Collectd's type-instance that is to be used for specified OID.

- **OIDs** _OID_ \[_OID_ ...\]

    Configures the OIDs to be handled by _snmp\_agent_ plugin. Values for these OIDs
    are taken from collectd data type specified by **Plugin**, **PluginInstance**,
    **Type**, **TypeInstance** fields of this **Data** block. Number of the OIDs
    configured should correspond to number of values in specified **Type**.
    For example two OIDs "IF-MIB::ifInOctets" "IF-MIB::ifOutOctets" can be mapped to
    "rx" and "tx" values of "if\_octets" type.

- **Scale** _Value_

    The values taken from collectd are multiplied by _Value_. The field is optional
    and the default is **1.0**.

- **Shift** _Value_

    _Value_ is added to values from collectd after they have been multiplied by
    **Scale** value. The field is optional and the default value is **0.0**.

### The **Table** block

The **Table** block defines a collection of **Data** blocks that belong to one
snmp table. In addition to multiple **Data** blocks the following options can be
set:

- **IndexOID** _OID_

    OID that is handled by the plugin and is mapped to numerical index value that is
    generated by the plugin for each table record.

- **SizeOID** _OID_

    OID that is handled by the plugin. Returned value is the number of records in
    the table. The field is optional.

## Plugin `statsd`

The _statsd plugin_ listens to a UDP socket, reads "events" in the statsd
protocol and dispatches rates or other aggregates of these numbers
periodically.

The plugin implements the _Counter_, _Timer_, _Gauge_ and _Set_ types which
are dispatched as the _collectd_ types `derive`, `latency`, `gauge` and
`objects` respectively.

The following configuration options are valid:

- **Host** _Host_

    Bind to the hostname / address _Host_. By default, the plugin will bind to the
    "any" address, i.e. accept packets sent to any of the hosts addresses.

- **Port** _Port_

    UDP port to listen to. This can be either a service name or a port number.
    Defaults to `8125`.

- **DeleteCounters** **false**|**true**
- **DeleteTimers** **false**|**true**
- **DeleteGauges** **false**|**true**
- **DeleteSets** **false**|**true**

    These options control what happens if metrics are not updated in an interval.
    If set to **False**, the default, metrics are dispatched unchanged, i.e. the
    rate of counters and size of sets will be zero, timers report `NaN` and gauges
    are unchanged. If set to **True**, the such metrics are not dispatched and
    removed from the internal cache.

- **CounterSum** **false**|**true**

    When enabled, creates a `count` metric which reports the change since the last
    read. This option primarily exists for compatibility with the _statsd_
    implementation by Etsy.

- **CounterSum** **false**|**true**

    When enabled, creates a `gauge` metric which reports counters as a "gauge"
    of the differential, resetting the counter between flush intervals.  This
    option primarily exists for compatibility with the _statsd_ implementation
    in GitHub Enterprise Server.

- **TimerPercentile** _Percent_

    Calculate and dispatch the configured percentile, i.e. compute the latency, so
    that _Percent_ of all reported timers are smaller than or equal to the
    computed latency. This is useful for cutting off the long tail latency, as it's
    often done in _Service Level Agreements_ (SLAs).

    Different percentiles can be calculated by setting this option several times.
    If none are specified, no percentiles are calculated / dispatched.

- **TimerLower** **false**|**true**
- **TimerUpper** **false**|**true**
- **TimerSum** **false**|**true**
- **TimerCount** **false**|**true**

    Calculate and dispatch various values out of _Timer_ metrics received during
    an interval. If set to **False**, the default, these values aren't calculated /
    dispatched.

    Please note what reported timer values less than 0.001 are ignored in all **Timer\*** reports.

## Plugin `swap`

The _Swap plugin_ collects information about used and available swap space. On
_Linux_ and _Solaris_, the following options are available:

- **ReportByDevice** **false**|**true**

    Configures how to report physical swap devices. If set to **false** (the
    default), the summary over all swap devices is reported only, i.e. the globally
    used and available space over all devices. If **true** is configured, the used
    and available space of each device will be reported separately.

    This option is only available if the _Swap plugin_ can read `/proc/swaps`
    (under Linux) or use the [swapctl(2)](http://man.he.net/man2/swapctl) mechanism (under _Solaris_).

- **ReportBytes** **false**|**true**

    When enabled, the _swap I/O_ is reported in bytes. When disabled, the default,
    _swap I/O_ is reported in pages. This option is available under Linux only.

- **ValuesAbsolute** **true**|**false**

    Enables or disables reporting of absolute swap metrics, i.e. number of _bytes_
    available and used. Defaults to **true**.

- **ValuesPercentage** **false**|**true**

    Enables or disables reporting of relative swap metrics, i.e. _percent_
    available and free. Defaults to **false**.

    This is useful for deploying _collectd_ in a heterogeneous environment, where
    swap sizes differ and you want to specify generic thresholds or similar.

- **ReportIO** **true**|**false**

    Enables or disables reporting swap IO. Defaults to **true**.

    This is useful for the cases when swap IO is not neccessary, is not available,
    or is not reliable.

## Plugin `sysevent`

The _sysevent_ plugin monitors rsyslog messages.

**Synopsis:**

    <Plugin sysevent>
      Listen "192.168.0.2" "6666"
      BufferSize 1024
      BufferLength 10
      RegexFilter "regex"
    </Plugin>

    rsyslog should be configured such that it sends data to the IP and port you
    include in the plugin configuration.  For example, given the configuration
    above, something like this would be set in /etc/rsyslog.conf:

      if $programname != 'collectd' then
      *.* @192.168.0.2:6666

    This plugin is designed to consume JSON rsyslog data, so a more complete
    rsyslog configuration would look like so (where we define a JSON template
    and use it when sending data to our IP and port):

      $template ls_json,"{%timestamp:::date-rfc3339,jsonf:@timestamp%, \
      %source:::jsonf:@source_host%,\"@source\":\"syslog://%fromhost-ip:::json%\", \
      \"@message\":\"%timestamp% %app-name%:%msg:::json%\",\"@fields\": \
      {%syslogfacility-text:::jsonf:facility%,%syslogseverity:::jsonf:severity-num%, \
      %syslogseverity-text:::jsonf:severity%,%programname:::jsonf:program%, \
      %procid:::jsonf:processid%}}"

      if $programname != 'collectd' then
      *.* @192.168.0.2:6666;ls_json

    Please note that these rsyslog.conf examples are *not* complete, as rsyslog
    requires more than these options in the configuration file.  These examples
    are meant to demonstration the proper remote logging and JSON format syntax.

**Options:**

- **Listen** _host_ _port_

    Listen on this IP on this port for incoming rsyslog messages.

- **BufferSize** _length_

    Maximum allowed size for incoming rsyslog messages.  Messages that exceed 
    this number will be truncated to this size.  Default is 4096 bytes.

- **BufferLength** _length_

    Maximum number of rsyslog events that can be stored in plugin's ring buffer.
    By default, this is set to 10.  Once an event has been read, its location
    becomes available for storing a new event.

- **RegexFilter** _regex_

    Enumerate a regex filter to apply to all incoming rsyslog messages.  If a
    message matches this filter, it will be published.

## Plugin `syslog`

- **LogLevel** **debug|info|notice|warning|err**

    Sets the log-level. If, for example, set to **notice**, then all events with
    severity **notice**, **warning**, or **err** will be submitted to the
    syslog-daemon.

    Please note that **debug** is only available if collectd has been compiled with
    debugging support.

- **NotifyLevel** **OKAY**|**WARNING**|**FAILURE**

    Controls which notifications should be sent to syslog. The default behaviour is
    not to send any. Less severe notifications always imply logging more severe
    notifications: Setting this to **OKAY** means all notifications will be sent to
    syslog, setting this to **WARNING** will send **WARNING** and **FAILURE**
    notifications but will dismiss **OKAY** notifications. Setting this option to
    **FAILURE** will only send failures to syslog.

## Plugin `table`

The `table plugin` provides generic means to parse tabular data and dispatch
user specified values. Values are selected based on column numbers. For
example, this plugin may be used to get values from the Linux [proc(5)](http://man.he.net/man5/proc)
filesystem or CSV (comma separated values) files.

    <Plugin table>
      <Table "/proc/slabinfo">
        #Plugin "slab"
        Instance "slabinfo"
        Separator " "
        <Result>
          Type gauge
          InstancePrefix "active_objs"
          InstancesFrom 0
          ValuesFrom 1
        </Result>
        <Result>
          Type gauge
          InstancePrefix "objperslab"
          InstancesFrom 0
          ValuesFrom 4
        </Result>
      </Table>
    </Plugin>

The configuration consists of one or more **Table** blocks, each of which
configures one file to parse. Within each **Table** block, there are one or
more **Result** blocks, which configure which data to select and how to
interpret it.

The following options are available inside a **Table** block:

- **Plugin** _Plugin_

    If specified, _Plugin_ is used as the plugin name when submitting values.
    Defaults to **table**.

- **Instance** _instance_

    If specified, _instance_ is used as the plugin instance. If omitted, the
    filename of the table is used instead, with all special characters replaced
    with an underscore (`_`).

- **Separator** _string_

    Any character of _string_ is interpreted as a delimiter between the different
    columns of the table. A sequence of two or more contiguous delimiters in the
    table is considered to be a single delimiter, i. e. there cannot be any
    empty columns. The plugin uses the [strtok\_r(3)](http://man.he.net/man3/strtok_r) function to parse the lines
    of a table - see its documentation for more details. This option is mandatory.

    A horizontal tab, newline and carriage return may be specified by `\\t`,
    `\\n` and `\\r` respectively. Please note that the double backslashes are
    required because of collectd's config parsing.

The following options are available inside a **Result** block:

- **Type** _type_

    Sets the type used to dispatch the values to the daemon. Detailed information
    about types and their configuration can be found in [types.db(5)](http://man.he.net/man5/types.db). This
    option is mandatory.

- **InstancePrefix** _prefix_

    If specified, prepend _prefix_ to the type instance. If omitted, only the
    **InstancesFrom** option is considered for the type instance.

- **InstancesFrom** _column0_ \[_column1_ ...\]

    If specified, the content of the given columns (identified by the column
    number starting at zero) will be used to create the type instance for each
    row. Multiple values (and the instance prefix) will be joined together with
    dashes (_-_) as separation character. If omitted, only the **InstancePrefix**
    option is considered for the type instance.

    The plugin itself does not check whether or not all built instances are
    different. It’s your responsibility to assure that each is unique. This is
    especially true, if you do not specify **InstancesFrom**: **You** have to make
    sure that the table only contains one row.

    If neither **InstancePrefix** nor **InstancesFrom** is given, the type instance
    will be empty.

- **ValuesFrom** _column0_ \[_column1_ ...\]

    Specifies the columns (identified by the column numbers starting at zero)
    whose content is used as the actual data for the data sets that are dispatched
    to the daemon. How many such columns you need is determined by the **Type**
    setting above. If you specify too many or not enough columns, the plugin will
    complain about that and no data will be submitted to the daemon. The plugin
    uses [strtoll(3)](http://man.he.net/man3/strtoll) and [strtod(3)](http://man.he.net/man3/strtod) to parse counter and gauge values
    respectively, so anything supported by those functions is supported by the
    plugin as well. This option is mandatory.

## Plugin `tail`

The `tail plugin` follows logfiles, just like [tail(1)](http://man.he.net/man1/tail) does, parses
each line and dispatches found values. What is matched can be configured by the
user using (extended) regular expressions, as described in [regex(7)](http://man.he.net/man7/regex).

    <Plugin "tail">
      <File "/var/log/exim4/mainlog">
        Plugin "mail"
        Instance "exim"
        Interval 60
        <Match>
          Regex "S=([1-9][0-9]*)"
          DSType "CounterAdd"
          Type "ipt_bytes"
          Instance "total"
        </Match>
        <Match>
          Regex "\\<R=local_user\\>"
          ExcludeRegex "\\<R=local_user\\>.*mail_spool defer"
          DSType "CounterInc"
          Type "counter"
          Instance "local_user"
        </Match>
        <Match>
          Regex "l=([0-9]*\\.[0-9]*)"
          <DSType "Distribution">
            Percentile 99
            Bucket 0 100
            #BucketType "bucket"
          </DSType>
          Type "latency"
          Instance "foo"
        </Match>
      </File>
    </Plugin>

The config consists of one or more **File** blocks, each of which configures one
logfile to parse. Within each **File** block, there are one or more **Match**
blocks, which configure a regular expression to search for.

The **Plugin** and **Instance** options in the **File** block may be used to set
the plugin name and instance respectively. So in the above example the plugin name
`mail-exim` would be used.

These options are applied for all **Match** blocks that **follow** it, until the
next **Plugin** or **Instance** option. This way you can extract several plugin
instances from one logfile, handy when parsing syslog and the like.

The **Interval** option allows you to define the length of time between reads. If
this is not set, the default Interval will be used.

Each **Match** block has the following options to describe how the match should
be performed:

- **Regex** _regex_

    Sets the regular expression to use for matching against a line. The first
    subexpression has to match something that can be turned into a number by
    [strtoll(3)](http://man.he.net/man3/strtoll) or [strtod(3)](http://man.he.net/man3/strtod), depending on the value of `CounterAdd`, see
    below. Because **extended** regular expressions are used, you do not need to use
    backslashes for subexpressions! If in doubt, please consult [regex(7)](http://man.he.net/man7/regex). Due to
    collectd's config parsing you need to escape backslashes, though. So if you
    want to match literal parentheses you need to do the following:

        Regex "SPAM \\(Score: (-?[0-9]+\\.[0-9]+)\\)"

- **ExcludeRegex** _regex_

    Sets an optional regular expression to use for excluding lines from the match.
    An example which excludes all connections from localhost from the match:

        ExcludeRegex "127\\.0\\.0\\.1"

- **DSType** _Type_

    Sets how the values are cumulated. _Type_ is one of:

    - **GaugeAverage**

        Calculate the average of all values matched during the interval.

    - **GaugeMin**

        Report the smallest value matched during the interval.

    - **GaugeMax**

        Report the greatest value matched during the interval.

    - **GaugeLast**

        Report the last value matched during the interval.

    - **GaugePersist**

        Report the last matching value. The metric is _not_ reset to `NaN` at the end
        of an interval. It is continuously reported until another value is matched.
        This is intended for cases in which only state changes are reported, for
        example a thermometer that only reports the temperature when it changes.

    - **CounterSet**
    - **DeriveSet**
    - **AbsoluteSet**

        The matched number is a counter. Simply _sets_ the internal counter to this
        value. Variants exist for `COUNTER`, `DERIVE`, and `ABSOLUTE` data sources.

    - **GaugeAdd**
    - **CounterAdd**
    - **DeriveAdd**

        Add the matched value to the internal counter. In case of **DeriveAdd**, the
        matched number may be negative, which will effectively subtract from the
        internal counter.

    - **GaugeInc**
    - **CounterInc**
    - **DeriveInc**

        Increase the internal counter by one. These **DSType** are the only ones that do
        not use the matched subexpression, but simply count the number of matched
        lines. Thus, you may use a regular expression without submatch in this case.

        **GaugeInc** is reset to _zero_ after every read, unlike other **Gauge\***
        metrics which are reset to `NaN`.

    - **Distribution**

        Type to do calculations based on the distribution of values, primarily
        calculating percentiles. This is primarily geared towards latency, but can be
        used for other metrics as well. The range of values tracked with this setting
        must be in the range (0–2^34) and can be fractional. Please note that neither
        zero nor 2^34 are inclusive bounds, i.e. zero _cannot_ be handled by a
        distribution.

        This option must be used together with the **Percentile** and/or **Bucket**
        options.

        **Synopsis:**

            <DSType "Distribution">
              Percentile 99
              Bucket 0 100
              BucketType "bucket"
            </DSType>

        - **Percentile** _Percent_

            Calculate and dispatch the configured percentile, i.e. compute the value, so
            that _Percent_ of all matched values are smaller than or equal to the computed
            latency.

            Metrics are reported with the _type_ **Type** (the value of the above option)
            and the _type instance_ `[<Instance>-]<Percent>`.

            This option may be repeated to calculate more than one percentile.

        - **Bucket** _lower\_bound_ _upper\_bound_

            Export the number of values (a `DERIVE`) falling within the given range. Both,
            _lower\_bound_ and _upper\_bound_ may be a fractional number, such as **0.5**.
            Each **Bucket** option specifies an interval `(_lower_bound_,
            _upper_bound_]`, i.e. the range _excludes_ the lower bound and _includes_
            the upper bound. _lower\_bound_ and _upper\_bound_ may be zero, meaning no
            lower/upper bound.

            To export the entire (0–inf) range without overlap, use the upper bound of the
            previous range as the lower bound of the following range. In other words, use
            the following schema:

                Bucket   0   1
                Bucket   1   2
                Bucket   2   5
                Bucket   5  10
                Bucket  10  20
                Bucket  20  50
                Bucket  50   0

            Metrics are reported with the _type_ set by **BucketType** option (`bucket`
            by default) and the _type instance_
            `<Type>[-<Instance>]-<lower_bound>_<upper_bound>`.

            This option may be repeated to calculate more than one rate.

        - **BucketType** _Type_

            Sets the type used to dispatch **Bucket** metrics.
            Optional, by default `bucket` will be used.

    The **Gauge\*** and **Distribution** types interpret the submatch as a floating
    point number, using [strtod(3)](http://man.he.net/man3/strtod). The **Counter\*** and **AbsoluteSet** types
    interpret the submatch as an unsigned integer using [strtoull(3)](http://man.he.net/man3/strtoull). The
    **Derive\*** types interpret the submatch as a signed integer using
    [strtoll(3)](http://man.he.net/man3/strtoll). **CounterInc**, **DeriveInc** and **GaugeInc** do not use the
    submatch at all and it may be omitted in this case.

    The **Gauge\*** types, unless noted otherwise, are reset to `NaN` after being
    reported. In other words, **GaugeAverage** reports the average of all values
    matched since the last metric was reported (or `NaN` if there was no match).

- **Type** _Type_

    Sets the type used to dispatch this value. Detailed information about types and
    their configuration can be found in [types.db(5)](http://man.he.net/man5/types.db).

- **Instance** _TypeInstance_

    This optional setting sets the type instance to use.

## Plugin `tail_csv`

The _tail\_csv plugin_ reads files in the CSV format, e.g. the statistics file
written by _Snort_.

**Synopsis:**

    <Plugin "tail_csv">
      <Metric "snort-dropped">
          Type "percent"
          Instance "dropped"
          ValueFrom 1
      </Metric>
      <File "/var/log/snort/snort.stats">
          Plugin "snortstats"
          Instance "eth0"
          Interval 600
          Collect "snort-dropped"
          FieldSeparator ","
          #TimeFrom 0
      </File>
    </Plugin>

The configuration consists of one or more **Metric** blocks that define an index
into the line of the CSV file and how this value is mapped to _collectd's_
internal representation. These are followed by one or more **Instance** blocks
which configure which file to read, in which interval and which metrics to
extract.

- <**Metric** _Name_>

    The **Metric** block configures a new metric to be extracted from the statistics
    file and how it is mapped on _collectd's_ data model. The string _Name_ is
    only used inside the **Instance** blocks to refer to this block, so you can use
    one **Metric** block for multiple CSV files.

    - **Type** _Type_

        Configures which _Type_ to use when dispatching this metric. Types are defined
        in the [types.db(5)](http://man.he.net/man5/types.db) file, see the appropriate manual page for more
        information on specifying types. Only types with a single _data source_ are
        supported by the _tail\_csv plugin_. The information whether the value is an
        absolute value (i.e. a `GAUGE`) or a rate (i.e. a `DERIVE`) is taken from the
        _Type's_ definition.

    - **Instance** _TypeInstance_

        If set, _TypeInstance_ is used to populate the type instance field of the
        created value lists. Otherwise, no type instance is used.

    - **ValueFrom** _Index_

        Configure to read the value from the field with the zero-based index _Index_.
        If the value is parsed as signed integer, unsigned integer or double depends on
        the **Type** setting, see above.

- <**File** _Path_>

    Each **File** block represents one CSV file to read. There must be at least one
    _File_ block but there can be multiple if you have multiple CSV files.

    - **Plugin** _Plugin_

        Use _Plugin_ as the plugin name when submitting values.
        Defaults to `tail_csv`.

    - **Instance** _PluginInstance_

        Sets the _plugin instance_ used when dispatching the values.

    - **Collect** _Metric_

        Specifies which _Metric_ to collect. This option must be specified at least
        once, and you can use this option multiple times to specify more than one
        metric to be extracted from this statistic file.

    - **Interval** _Seconds_

        Configures the interval in which to read values from this instance / file.
        Defaults to the plugin's default interval.

    - **TimeFrom** _Index_

        Rather than using the local time when dispatching a value, read the timestamp
        from the field with the zero-based index _Index_. The value is interpreted as
        seconds since epoch. The value is parsed as a double and may be factional.

    - **FieldSeparator** _Character_

        Specify the character to use as field separator while parsing the CSV.
        Defaults to ',' if not specified. The value can only be a single character.

## Plugin `teamspeak2`

The `teamspeak2 plugin` connects to the query port of a teamspeak2 server and
polls interesting global and virtual server data. The plugin can query only one
physical server but unlimited virtual servers. You can use the following
options to configure it:

- **Host** _hostname/ip_

    The hostname or ip which identifies the physical server.
    Default: 127.0.0.1

- **Port** _port_

    The query port of the physical server. This needs to be a string.
    Default: "51234"

- **Server** _port_

    This option has to be added once for every virtual server the plugin should
    query. If you want to query the virtual server on port 8767 this is what the
    option would look like:

        Server "8767"

    This option, although numeric, needs to be a string, i. e. you **must**
    use quotes around it! If no such statement is given only global information
    will be collected.

## Plugin `ted`

The _TED_ plugin connects to a device of "The Energy Detective", a device to
measure power consumption. These devices are usually connected to a serial
(RS232) or USB port. The plugin opens a configured device and tries to read the
current energy readings. For more information on TED, visit
[http://www.theenergydetective.com/](http://www.theenergydetective.com/).

Available configuration options:

- **Device** _Path_

    Path to the device on which TED is connected. collectd will need read and write
    permissions on that file.

    Default: **/dev/ttyUSB0**

- **Retries** _Num_

    Apparently reading from TED is not that reliable. You can therefore configure a
    number of retries here. You only configure the _retries_ here, to if you
    specify zero, one reading will be performed (but no retries if that fails); if
    you specify three, a maximum of four readings are performed. Negative values
    are illegal.

    Default: **0**

## Plugin `tcpconns`

The `tcpconns plugin` counts the number of currently established TCP
connections based on the local port and/or the remote port. Since there may be
a lot of connections the default if to count all connections with a local port,
for which a listening socket is opened. You can use the following options to
fine-tune the ports you are interested in:

- **ListeningPorts** _true_|_false_

    If this option is set to _true_, statistics for all local ports for which a
    listening socket exists are collected. The default depends on **LocalPort** and
    **RemotePort** (see below): If no port at all is specifically selected, the
    default is to collect listening ports. If specific ports (no matter if local or
    remote ports) are selected, this option defaults to _false_, i. e. only
    the selected ports will be collected unless this option is set to _true_
    specifically.

- **LocalPort** _Port_

    Count the connections to a specific local port. This can be used to see how
    many connections are handled by a specific daemon, e. g. the mailserver.
    You have to specify the port in numeric form, so for the mailserver example
    you'd need to set **25**.

- **RemotePort** _Port_

    Count the connections to a specific remote port. This is useful to see how
    much a remote service is used. This is most useful if you want to know how many
    connections a local service has opened to remote services, e. g. how many
    connections a mail server or news server has to other mail or news servers, or
    how many connections a web proxy holds to web servers. You have to give the
    port in numeric form.

- **AllPortsSummary** _true_|_false_

    If this option is set to _true_ a summary of statistics from all connections
    are collected. This option defaults to _false_.

## Plugin `thermal`

- **ForceUseProcfs** _true_|_false_

    By default, the _Thermal plugin_ tries to read the statistics from the Linux
    `sysfs` interface. If that is not available, the plugin falls back to the
    `procfs` interface. By setting this option to _true_, you can force the
    plugin to use the latter. This option defaults to _false_.

- **Device** _Device_

    Selects the name of the thermal device that you want to collect or ignore,
    depending on the value of the **IgnoreSelected** option. This option may be
    used multiple times to specify a list of devices.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** _true_|_false_

    Invert the selection: If set to true, all devices **except** the ones that
    match the device names specified by the **Device** option are collected. By
    default only selected devices are collected if a selection is made. If no
    selection is configured at all, **all** devices are selected.

## Plugin `threshold`

The _Threshold plugin_ checks values collected or received by _collectd_
against a configurable _threshold_ and issues _notifications_ if values are
out of bounds.

Documentation for this plugin is available in the [collectd-threshold(5)](http://man.he.net/man5/collectd-threshold)
manual page.

## Plugin `tokyotyrant`

The _TokyoTyrant plugin_ connects to a TokyoTyrant server and collects a
couple metrics: number of records, and database size on disk.

- **Host** _Hostname/IP_

    The hostname or IP which identifies the server.
    Default: **127.0.0.1**

- **Port** _Service/Port_

    The query port of the server. This needs to be a string, even if the port is
    given in its numeric form.
    Default: **1978**

## Plugin `turbostat`

The _Turbostat plugin_ reads CPU frequency and C-state residency on modern
Intel processors by using _Model Specific Registers_.

- **CoreCstates** _Bitmask(Integer)_

    Bit mask of the list of core C-states supported by the processor.
    This option should only be used if the automated detection fails.
    Default value extracted from the CPU model and family.

    Currently supported C-states (by this plugin): 3, 6, 7

    **Example:**

        All states (3, 6 and 7):
        (1<<3) + (1<<6) + (1<<7) = 392

- **PackageCstates** _Bitmask(Integer)_

    Bit mask of the list of packages C-states supported by the processor. This
    option should only be used if the automated detection fails. Default value
    extracted from the CPU model and family.

    Currently supported C-states (by this plugin): 2, 3, 6, 7, 8, 9, 10

    **Example:**

        States 2, 3, 6 and 7:
        (1<<2) + (1<<3) + (1<<6) + (1<<7) = 396

- **SystemManagementInterrupt** _true_|_false_

    Boolean enabling the collection of the I/O System-Management Interrupt counter.
    This option should only be used if the automated detection fails or if you want
    to disable this feature.

- **DigitalTemperatureSensor** _true_|_false_

    Boolean enabling the collection of the temperature of each core. This option
    should only be used if the automated detection fails or if you want to disable
    this feature.

- **TCCActivationTemp** _Temperature_

    _Thermal Control Circuit Activation Temperature_ of the installed CPU. This
    temperature is used when collecting the temperature of cores or packages. This
    option should only be used if the automated detection fails. Default value
    extracted from **MSR\_IA32\_TEMPERATURE\_TARGET**.

- **RunningAveragePowerLimit** _Bitmask(Integer)_

    Bit mask of the list of elements to be thermally monitored. This option should
    only be used if the automated detection fails or if you want to disable some
    collections. The different bits of this bit mask accepted by this plugin are:

    - 0 ('1'): Package
    - 1 ('2'): DRAM
    - 2 ('4'): Cores
    - 3 ('8'): Embedded graphic device

- **LogicalCoreNames** _true_|_false_

    Boolean enabling the use of logical core numbering for per core statistics.
    When enabled, `cpu<n>` is used as plugin instance, where _n_ is a
    dynamic number assigned by the kernel. Otherwise, `core<n>` is used
    if there is only one package and `pkg<n>-core<m>` if there is
    more than one, where _n_ is the n-th core of package _m_.

- **RestoreAffinityPolicy** _AllCPUs_|_Restore_

    Reading data from CPU has side-effect: collectd process's CPU affinity mask
    changes. After reading data is completed, affinity mask needs to be restored.
    This option allows to set restore policy.

    **AllCPUs** (the default): Restore the affinity by setting affinity to any/all
    CPUs.

    **Restore**: Save affinity using sched\_getaffinity() before reading data and
    restore it after.

    On some systems, sched\_getaffinity() will fail due to inconsistency of the CPU
    set size between userspace and kernel. In these cases plugin will detect the
    unsuccessful call and fail with an error, preventing data collection.
    Most of configurations does not need to save affinity as Collectd process is
    allowed to run on any/all available CPUs.

    If you need to save and restore affinity and get errors like 'Unable to save
    the CPU affinity', setting 'possible\_cpus' kernel boot option may also help.

    See following links for details:

    [https://github.com/collectd/collectd/issues/1593](https://github.com/collectd/collectd/issues/1593)
    [https://sourceware.org/bugzilla/show\_bug.cgi?id=15630](https://sourceware.org/bugzilla/show_bug.cgi?id=15630)
    [https://bugzilla.kernel.org/show\_bug.cgi?id=151821](https://bugzilla.kernel.org/show_bug.cgi?id=151821)

## Plugin `ubi`

The _Ubi plugin_ collects some statistics about the UBI (Unsorted Block Image).
Values collected are the number of bad physical eraseblocks on the underlying MTD
(Memory Technology Device) and the maximum erase counter value concerning one volume.

See following links for details:

[http://www.linux-mtd.infradead.org/doc/ubi.html](http://www.linux-mtd.infradead.org/doc/ubi.html)
[http://www.linux-mtd.infradead.org/doc/ubifs.html](http://www.linux-mtd.infradead.org/doc/ubifs.html)
[https://www.kernel.org/doc/Documentation/ABI/stable/sysfs-class-ubi](https://www.kernel.org/doc/Documentation/ABI/stable/sysfs-class-ubi)

- **Device** _Name_

    Select the device _Name_ of the UBI volume. Whether it is collected or ignored
    depends on the **IgnoreSelected** setting, see below.

    See `/"IGNORELISTS"` for details.

- **IgnoreSelected** **true**|**false**

    Sets whether selected devices, i. e. the ones matches by any of the **Device**
    statements, are ignored or if all other devices are ignored. If no **Device** option
    is configured, all devices are collected. If at least one **Device** is given and no
    **IgnoreSelected** or set to **false**, **only** matching disks will be collected. If
    **IgnoreSelected**is set to **true**, all devices are collected **except** the ones
    matched.

## Plugin `unixsock`

- **SocketFile** _Path_

    Sets the socket-file which is to be created.

- **SocketGroup** _Group_

    If running as root change the group of the UNIX-socket after it has been
    created. Defaults to **collectd**.

- **SocketPerms** _Permissions_

    Change the file permissions of the UNIX-socket after it has been created. The
    permissions must be given as a numeric, octal value as you would pass to
    [chmod(1)](http://man.he.net/man1/chmod). Defaults to **0770**.

- **DeleteSocket** **false**|**true**

    If set to **true**, delete the socket file before calling [bind(2)](http://man.he.net/man2/bind), if a file
    with the given name already exists. If _collectd_ crashes a socket file may be
    left over, preventing the daemon from opening a new socket when restarted.
    Since this is potentially dangerous, this defaults to **false**.

## Plugin `uuid`

This plugin, if loaded, causes the Hostname to be taken from the machine's
UUID. The UUID is a universally unique designation for the machine, usually
taken from the machine's BIOS. This is most useful if the machine is running in
a virtual environment such as Xen, in which case the UUID is preserved across
shutdowns and migration.

The following methods are used to find the machine's UUID, in order:

- Check _/etc/uuid_ (or _UUIDFile_).
- Check for UUID from HAL ([http://www.freedesktop.org/wiki/Software/hal](http://www.freedesktop.org/wiki/Software/hal)) if
present.
- Check for UUID from `dmidecode` / SMBIOS.
- Check for UUID from Xen hypervisor.

If no UUID can be found then the hostname is not modified.

- **UUIDFile** _Path_

    Take the UUID from the given file (default _/etc/uuid_).

## Plugin `varnish`

The _varnish plugin_ collects information about Varnish, an HTTP accelerator.
It collects a subset of the values displayed by [varnishstat(1)](http://man.he.net/man1/varnishstat), and
organizes them in categories which can be enabled or disabled. Currently only
metrics shown in [varnishstat(1)](http://man.he.net/man1/varnishstat)'s _MAIN_ section are collected. The exact
meaning of each metric can be found in [varnish-counters(7)](http://man.he.net/man7/varnish-counters).

Synopsis:

    <Plugin "varnish">
      <Instance "example">
        CollectBackend     true
        CollectBan         false
        CollectCache       true
        CollectConnections true
        CollectDirectorDNS false
        CollectESI         false
        CollectFetch       false
        CollectHCB         false
        CollectObjects     false
        CollectPurge       false
        CollectSession     false
        CollectSHM         true
        CollectSMA         false
        CollectSMS         false
        CollectSM          false
        CollectStruct      false
        CollectTotals      false
        CollectUptime      false
        CollectVCL         false
        CollectVSM         false
        CollectWorkers     false
        CollectLock        false
        CollectMempool     false
        CollectManagement  false
        CollectSMF         false
        CollectVBE         false
        CollectMSE         false
      </Instance>
    </Plugin>

The configuration consists of one or more <**Instance** _Name_>
blocks. _Name_ is the parameter passed to "varnishd -n". If left empty, it
will collectd statistics from the default "varnishd" instance (this should work
fine in most cases).

Inside each <**Instance**> blocks, the following options are recognized:

- **CollectBackend** **true**|**false**

    Back-end connection statistics, such as successful, reused,
    and closed connections. True by default.

- **CollectBan** **true**|**false**

    Statistics about ban operations, such as number of bans added, retired, and
    number of objects tested against ban operations. Only available with Varnish
    3.x and above. False by default.

- **CollectCache** **true**|**false**

    Cache hits and misses. True by default.

- **CollectConnections** **true**|**false**

    Number of client connections received, accepted and dropped. True by default.

- **CollectDirectorDNS** **true**|**false**

    DNS director lookup cache statistics. Only available with Varnish 3.x. False by
    default.

- **CollectESI** **true**|**false**

    Edge Side Includes (ESI) parse statistics. False by default.

- **CollectFetch** **true**|**false**

    Statistics about fetches (HTTP requests sent to the backend). False by default.

- **CollectHCB** **true**|**false**

    Inserts and look-ups in the crit bit tree based hash. Look-ups are
    divided into locked and unlocked look-ups. False by default.

- **CollectObjects** **true**|**false**

    Statistics on cached objects: number of objects expired, nuked (prematurely
    expired), saved, moved, etc. False by default.

- **CollectPurge** **true**|**false**

    Statistics about purge operations, such as number of purges added, retired, and
    number of objects tested against purge operations. Only available with Varnish
    2.x. False by default.

- **CollectSession** **true**|**false**

    Client session statistics. Number of past and current sessions, session herd and
    linger counters, etc. False by default. Note that if using Varnish 4.x, some
    metrics found in the Connections and Threads sections with previous versions of
    Varnish have been moved here.

- **CollectSHM** **true**|**false**

    Statistics about the shared memory log, a memory region to store
    log messages which is flushed to disk when full. True by default.

- **CollectSMA** **true**|**false**

    malloc or umem (umem\_alloc(3MALLOC) based) storage statistics. The umem storage
    component is Solaris specific. Note: SMA, SMF and MSE share counters, enable
    only the one used by the Varnish instance. Available with Varnish 2.x,
    varnish 4.x and above (Not available in varnish 3.x).
    False by default.

- **CollectSMS** **true**|**false**

    synth (synthetic content) storage statistics. This storage
    component is used internally only. False by default.

- **CollectSM** **true**|**false**

    file (memory mapped file) storage statistics. Only available with Varnish 2.x,
    in varnish 4.x and above use CollectSMF.
    False by default.

- **CollectStruct** **true**|**false**

    Current varnish internal state statistics. Number of current sessions, objects
    in cache store, open connections to backends (with Varnish 2.x), etc. False by
    default.

- **CollectTotals** **true**|**false**

    Collects overview counters, such as the number of sessions created,
    the number of requests and bytes transferred. False by default.

- **CollectUptime** **true**|**false**

    Varnish uptime. Only available with Varnish 3.x and above. False by default.

- **CollectVCL** **true**|**false**

    Number of total (available + discarded) VCL (config files). False by default.

- **CollectVSM** **true**|**false**

    Collect statistics about Varnish's shared memory usage (used by the logging and
    statistics subsystems). Only available with Varnish 4.x. False by default.

- **CollectWorkers** **true**|**false**

    Collect statistics about worker threads. False by default.

- **CollectVBE** **true**|**false**

    Backend counters. Only available with Varnish 4.x and above. False by default.

- **CollectSMF** **true**|**false**

    file (memory mapped file) storage statistics. Only available with Varnish 4.x and above.
    Note: SMA, SMF and MSE share counters, enable only the one used by the Varnish
    instance. Used to be called SM in Varnish 2.x. False by default.

- **CollectManagement** **true**|**false**

    Management process counters. Only available with Varnish 4.x and above. False by default.

- **CollectLock** **true**|**false**

    Lock counters. Only available with Varnish 4.x and above. False by default.

- **CollectMempool** **true**|**false**

    Memory pool counters. Only available with Varnish 4.x and above. False by default.

- **CollectMSE** **true**|**false**

    Varnish Massive Storage Engine 2.0 (MSE2) is an improved storage backend for
    Varnish, replacing the traditional malloc and file storages. Only available
    with Varnish-Plus 4.x and above. Note: SMA, SMF and MSE share counters, enable only the
    one used by the Varnish instance. False by default.

- **CollectGOTO** **true**|**false**

    vmod-goto counters. Only available with Varnish Plus 6.x. False by default.

## Plugin `virt`

This plugin allows CPU, disk, network load and other metrics to be collected for
virtualized guests on the machine. The statistics are collected through libvirt
API ([http://libvirt.org/](http://libvirt.org/)). Majority of metrics can be gathered without
installing any additional software on guests, especially _collectd_, which runs
only on the host system.

Only _Connection_ is required.

Consider the following example config:

    <Plugin "virt">
      Connection "qemu:///system"
      HostnameFormat "hostname"
      InterfaceFormat "address"
      PluginInstanceFormat "name"
    </Plugin>

It will generate the following values:

    node42.example.com/virt-instance-0006f26c/disk_octets-vda
    node42.example.com/virt-instance-0006f26c/disk_ops-vda
    node42.example.com/virt-instance-0006f26c/if_dropped-ca:fe:ca:fe:ca:fe
    node42.example.com/virt-instance-0006f26c/if_errors-ca:fe:ca:fe:ca:fe
    node42.example.com/virt-instance-0006f26c/if_octets-ca:fe:ca:fe:ca:fe
    node42.example.com/virt-instance-0006f26c/if_packets-ca:fe:ca:fe:ca:fe
    node42.example.com/virt-instance-0006f26c/memory-actual_balloon
    node42.example.com/virt-instance-0006f26c/memory-available
    node42.example.com/virt-instance-0006f26c/memory-last_update
    node42.example.com/virt-instance-0006f26c/memory-major_fault
    node42.example.com/virt-instance-0006f26c/memory-minor_fault
    node42.example.com/virt-instance-0006f26c/memory-rss
    node42.example.com/virt-instance-0006f26c/memory-swap_in
    node42.example.com/virt-instance-0006f26c/memory-swap_out
    node42.example.com/virt-instance-0006f26c/memory-total
    node42.example.com/virt-instance-0006f26c/memory-unused
    node42.example.com/virt-instance-0006f26c/memory-usable
    node42.example.com/virt-instance-0006f26c/virt_cpu_total
    node42.example.com/virt-instance-0006f26c/virt_vcpu-0

You can get information on the metric's units from the online libvirt documentation.
For instance, _virt\_cpu\_total_ is in nanoseconds.

- **Connection** _uri_

    Connect to the hypervisor given by _uri_. For example if using Xen use:

        Connection "xen:///"

    Details which URIs allowed are given at [http://libvirt.org/uri.html](http://libvirt.org/uri.html).

- **RefreshInterval** _seconds_

    Refresh the list of domains and devices every _seconds_. The default is 60
    seconds. Setting this to be the same or smaller than the _Interval_ will cause
    the list of domains and devices to be refreshed on every iteration.

    Refreshing the devices in particular is quite a costly operation, so if your
    virtualization setup is static you might consider increasing this. If this
    option is set to 0, refreshing is disabled completely.

- **Domain** _name_
- **BlockDevice** _name:dev_
- **InterfaceDevice** _name:dev_
- **IgnoreSelected** **true**|**false**

    Select which domains and devices are collected.

    If _IgnoreSelected_ is not given or **false** then only the listed domains and
    disk/network devices are collected.

    If _IgnoreSelected_ is **true** then the test is reversed and the listed
    domains and disk/network devices are ignored, while the rest are collected.

    The domain name and device names may use a regular expression, if the name is
    surrounded by _/.../_ and collectd was compiled with support for regexps.

    The default is to collect statistics for all domains and all their devices.

    **Note:** **BlockDevice** and **InterfaceDevice** options are related to
    corresponding **\*Format** options. Specifically, **BlockDevice** filtering depends
    on **BlockDeviceFormat** setting - if user wants to filter block devices by
    'target' name then **BlockDeviceFormat** option has to be set to 'target' and
    **BlockDevice** option must be set to a valid block device target
    name("/:hdb/"). Mixing formats and filter values from different worlds (i.e.,
    using 'target' name as **BlockDevice** value with **BlockDeviceFormat** set to
    'source') may lead to unexpected results (all devices filtered out or all
    visible, depending on the value of **IgnoreSelected** option).
    Similarly, option **InterfaceDevice** is related to **InterfaceFormat** setting
    (i.e., when user wants to use MAC address as a filter then **InterfaceFormat**
    has to be set to 'address' - using wrong type here may filter out all of the
    interfaces).

    **Example 1:**

    Ignore all _hdb_ devices on any domain, but other block devices (eg. _hda_)
    will be collected:

        BlockDevice "/:hdb/"
        IgnoreSelected "true"
        BlockDeviceFormat "target"

    **Example 2:**

    Collect metrics only for block device on 'baremetal0' domain when its
    'source' matches given path:

        BlockDevice "baremetal0:/var/lib/libvirt/images/baremetal0.qcow2"
        BlockDeviceFormat source

    As you can see it is possible to filter devices/interfaces using
    various formats - for block devices 'target' or 'source' name can be
    used.  Interfaces can be filtered using 'name', 'address' or 'number'.

    **Example 3:**

    Collect metrics only for domains 'baremetal0' and 'baremetal1' and
    ignore any other domain:

        Domain "baremetal0"
        Domain "baremetal1"

    It is possible to filter multiple block devices/domains/interfaces by
    adding multiple filtering entries in separate lines.

- **BlockDeviceFormat** **target**|**source**

    If _BlockDeviceFormat_ is set to **target**, the default, then the device name
    seen by the guest will be used for reporting metrics.
    This corresponds to the `<target>` node in the XML definition of the
    domain.

    If _BlockDeviceFormat_ is set to **source**, then metrics will be reported
    using the path of the source, e.g. an image file.
    This corresponds to the `<source>` node in the XML definition of the
    domain.

    **Example:**

    If the domain XML have the following device defined:

        <disk type='block' device='disk'>
          <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
          <source dev='/var/lib/libvirt/images/image1.qcow2'/>
          <target dev='sda' bus='scsi'/>
          <boot order='2'/>
          <address type='drive' controller='0' bus='0' target='0' unit='0'/>
        </disk>

    Setting `BlockDeviceFormat target` will cause the _type instance_ to be set
    to `sda`.
    Setting `BlockDeviceFormat source` will cause the _type instance_ to be set
    to `var_lib_libvirt_images_image1.qcow2`.

    **Note:** this option determines also what field will be used for
    filtering over block devices (filter value in **BlockDevice**
    will be applied to target or source). More info about filtering
    block devices can be found in the description of **BlockDevice**.

- **BlockDeviceFormatBasename** **false**|**true**

    The **BlockDeviceFormatBasename** controls whether the full path or the
    [basename(1)](http://man.he.net/man1/basename) of the source is being used as the _type instance_ when
    **BlockDeviceFormat** is set to **source**. Defaults to **false**.

    **Example:**

    Assume the device path (source tag) is `/var/lib/libvirt/images/image1.qcow2`.
    Setting `BlockDeviceFormatBasename false` will cause the _type instance_ to
    be set to `var_lib_libvirt_images_image1.qcow2`.
    Setting `BlockDeviceFormatBasename true` will cause the _type instance_ to be
    set to `image1.qcow2`.

- **HostnameFormat** **name|uuid|hostname|metadata...**

    When the virt plugin logs data, it sets the hostname of the collected data
    according to this setting. The default is to use the guest name as provided by
    the hypervisor, which is equal to setting **name**.

    **uuid** means use the guest's UUID. This is useful if you want to track the
    same guest across migrations.

    **hostname** means to use the global **Hostname** setting, which is probably not
    useful on its own because all guests will appear to have the same name. This is
    useful in conjunction with **PluginInstanceFormat** though.

    **metadata** means use information from guest's metadata. Use
    **HostnameMetadataNS** and **HostnameMetadataXPath** to localize this information.

    You can also specify combinations of these fields. For example **name uuid**
    means to concatenate the guest name and UUID (with a literal colon character
    between, thus _"foo:1234-1234-1234-1234"_).

    At the moment of writing (collectd-5.5), hostname string is limited to 62
    characters. In case when combination of fields exceeds 62 characters,
    hostname will be truncated without a warning.

- **InterfaceFormat** **name**|**address**|**number**

    When the virt plugin logs interface data, it sets the name of the collected
    data according to this setting. The default is to use the path as provided by
    the hypervisor (the "dev" property of the target node), which is equal to
    setting **name**.

    **address** means use the interface's mac address. This is useful since the
    interface path might change between reboots of a guest or across migrations.

    **number** means use the interface's number in guest.

    **Note:** this option determines also what field will be used for
    filtering over interface device (filter value in **InterfaceDevice**
    will be applied to name, address or number).  More info about filtering
    interfaces can be found in the description of **InterfaceDevice**.

- **PluginInstanceFormat** **name|uuid|metadata|none**

    When the virt plugin logs data, it sets the plugin\_instance of the collected
    data according to this setting. The default is to not set the plugin\_instance.

    **name** means use the guest's name as provided by the hypervisor.
    **uuid** means use the guest's UUID.
    **metadata** means use information from guest's metadata.

    You can also specify combinations of the **name** and **uuid** fields.
    For example **name uuid** means to concatenate the guest name and UUID
    (with a literal colon character between, thus _"foo:1234-1234-1234-1234"_).

- **HostnameMetadataNS** **string**

    When **metadata** is used in **HostnameFormat** or **PluginInstanceFormat**, this
    selects in which metadata namespace we will pick the hostname. The default is
    _http://openstack.org/xmlns/libvirt/nova/1.0_.

- **HostnameMetadataXPath** **string**

    When **metadata** is used in **HostnameFormat** or **PluginInstanceFormat**, this
    describes where the hostname is located in the libvirt metadata. The default is
    _/instance/name/text()_.

- **ReportBlockDevices** **true**|**false**

    Enabled by default. Allows to disable stats reporting of block devices for
    whole plugin.

- **ReportNetworkInterfaces** **true**|**false**

    Enabled by default. Allows to disable stats reporting of network interfaces for
    whole plugin.

- **ExtraStats** **string**

    Report additional extra statistics. The default is no extra statistics, preserving
    the previous behaviour of the plugin. If unsure, leave the default. If enabled,
    allows the plugin to reported more detailed statistics about the behaviour of
    Virtual Machines. The argument is a space-separated list of selectors.

    Currently supported selectors are:

    - **cpu\_util**: report CPU utilization per domain in percentage.
    - **disk**: report extra statistics like number of flush operations and total
    service time for read, write and flush operations. Requires libvirt API version
    _0.9.5_ or later.
    - **disk\_err**: report disk errors if any occured. Requires libvirt API version
    _0.9.10_ or later.
    - **domain\_state**: report domain state and reason as 'domain\_state' metric.
    - **fs\_info**: report file system information as a notification. Requires
    libvirt API version _1.2.11_ or later. Can be collected only if _Guest Agent_
    is installed and configured inside VM. Make sure that installed _Guest Agent_
    version supports retrieving  file system information.
    - **job\_stats\_background**: report statistics about progress of a background
    job on a domain. Only one type of job statistics can be collected at the same time.
    Requires libvirt API version _1.2.9_ or later.
    - **job\_stats\_completed**: report statistics about a recently completed job on
    a domain. Only one type of job statistics can be collected at the same time.
    Requires libvirt API version _1.2.9_ or later.
    - **memory**: report statistics about memory usage details, provided
    by libvirt virDomainMemoryStats() function.
    - **pcpu**: report the physical user/system cpu time consumed by the hypervisor, per-vm.
    Requires libvirt API version _0.9.11_ or later.
    - **perf**: report performance monitoring events. To collect performance
    metrics they must be enabled for domain and supported by the platform. Requires
    libvirt API version _1.3.3_ or later.
    **Note**: _perf_ metrics can't be collected if _intel\_rdt_ plugin is enabled.
    - **vcpu**: report domain virtual CPUs utilisation.
    - **vcpupin**: report pinning of domain VCPUs to host physical CPUs.
    - **disk\_physical**: report 'disk\_physical' statistic for disk device.
    **Note**: This statistic is only reported for disk devices with 'source'
    property available.
    - **disk\_allocation**: report 'disk\_allocation' statistic for disk device.
    **Note**: This statistic is only reported for disk devices with 'source'
    property available.
    - **disk\_capacity**: report 'disk\_capacity' statistic for disk device.
    **Note**: This statistic is only reported for disk devices with 'source'
    property available.

- **PersistentNotification** **true**|**false**

    Override default configuration to only send notifications when there is a change
    in the lifecycle state of a domain. When set to true notifications will be sent
    for every read cycle. Default is false. Does not affect the stats being
    dispatched.

- **Instances** **integer**

    How many read instances you want to use for this plugin. The default is one,
    and the sensible setting is a multiple of the **ReadThreads** value.

    This option is only useful when domains are specially tagged.
    If you are not sure, just use the default setting.

    The reader instance will only query the domains with attached matching tag.
    Tags should have the form of 'virt-X' where X is the reader instance number,
    starting from 0.

    The special-purpose reader instance #0, guaranteed to be always present,
    will query all the domains with missing or unrecognized tag, so no domain will
    ever be left out.

    Domain tagging is done with a custom attribute in the libvirt domain metadata
    section. Value is selected by an XPath _/domain/metadata/ovirtmap/tag/text()_
    expression in the _http://ovirt.org/ovirtmap/tag/1.0_ namespace.
    (XPath and namespace values are not configurable yet).

    Tagging could be used by management applications to evenly spread the
    load among the reader threads, or to pin on the same threads all
    the libvirt domains which use the same shared storage, to minimize
    the disruption in presence of storage outages.

## Plugin `vmem`

The `vmem` plugin collects information about the usage of virtual memory.
Since the statistics provided by the Linux kernel are very detailed, they are
collected very detailed. However, to get all the details, you have to switch
them on manually. Most people just want an overview over, such as the number of
pages read from swap space.

- **Verbose** **true**|**false**

    Enables verbose collection of information. This will start collecting page
    "actions", e. g. page allocations, (de)activations, steals and so on.
    Part of these statistics are collected on a "per zone" basis.

## Plugin `vserver`

This plugin doesn't have any options. **VServer** support is only available for
Linux. It cannot yet be found in a vanilla kernel, though. To make use of this
plugin you need a kernel that has **VServer** support built in, i. e. you
need to apply the patches and compile your own kernel, which will then provide
the `/proc/virtual` filesystem that is required by this plugin.

The **VServer** homepage can be found at [http://linux-vserver.org/](http://linux-vserver.org/).

**Note**: The traffic collected by this plugin accounts for the amount of
traffic passing a socket which might be a lot less than the actual on-wire
traffic (e. g. due to headers and retransmission). If you want to
collect on-wire traffic you could, for example, use the logging facilities of
iptables to feed data for the guest IPs into the iptables plugin.

## Plugin `write_graphite`

The `write_graphite` plugin writes data to _Graphite_, an open-source metrics
storage and graphing project. The plugin connects to _Carbon_, the data layer
of _Graphite_, via _TCP_ or _UDP_ and sends data via the "line based"
protocol (per default using port 2003). The data will be sent in blocks
of at most 1428 bytes to minimize the number of network packets.

Synopsis:

    <Plugin write_graphite>
      <Node "example">
        Host "localhost"
        Port "2003"
        Protocol "tcp"
        LogSendErrors true
        Prefix "collectd"
        UseTags false
        ReverseHost false
      </Node>
    </Plugin>

The configuration consists of one or more <**Node** _Name_>
blocks. Inside the **Node** blocks, the following options are recognized:

- **Host** _Address_

    Hostname or address to connect to. Defaults to `localhost`.

- **Port** _Service_

    Service name or port number to connect to. Defaults to `2003`.

- **Protocol** _String_

    Protocol to use when connecting to _Graphite_. Defaults to `tcp`.

- **ReconnectInterval** _Seconds_

    When set to non-zero, forces the connection to the Graphite backend to be
    closed and re-opend periodically. This behavior is desirable in environments
    where the connection to the Graphite backend is done through load balancers,
    for example. When set to zero, the default, the connetion is kept open for as
    long as possible.

- **LogSendErrors** **false**|**true**

    If set to **true** (the default), logs errors when sending data to _Graphite_.
    If set to **false**, it will not log the errors. This is especially useful when
    using Protocol UDP since many times we want to use the "fire-and-forget"
    approach and logging errors fills syslog with unneeded messages.

- **Prefix** _String_

    When **UseTags** is _false_, **Prefix** value is added in front of the host name.
    When **UseTags** is _true_, **Prefix** value is added in front of series name.

    Dots and whitespace are _not_ escaped in this string (see **EscapeCharacter**
    below).

- **Postfix** _String_

    When **UseTags** is _false_, **Postfix** value appended to the host name.
    When **UseTags** is _true_, **Postgix** value appended to the end of series name
    (before the first ; that separates the name from the tags).

    Dots and whitespace are _not_ escaped in this string (see **EscapeCharacter**
    below).

- **EscapeCharacter** _Char_

    _Carbon_ uses the dot (`.`) as escape character and doesn't allow whitespace
    in the identifier. The **EscapeCharacter** option determines which character
    dots, whitespace and control characters are replaced with. Defaults to
    underscore (`_`).

- **StoreRates** **false**|**true**

    If set to **true** (the default), convert counter values to rates. If set to
    **false** counter values are stored as is, i. e. as an increasing integer
    number.

- **SeparateInstances** **false**|**true**

    If set to **true**, the plugin instance and type instance will be in their own
    path component, for example `host.cpu.0.cpu.idle`. If set to **false** (the
    default), the plugin and plugin instance (and likewise the type and type
    instance) are put into one component, for example `host.cpu-0.cpu-idle`.

    Option value is not used when **UseTags** is _true_.

- **AlwaysAppendDS** **false**|**true**

    If set to **true**, append the name of the _Data Source_ (DS) to the "metric"
    identifier. If set to **false** (the default), this is only done when there is
    more than one DS.

- **PreserveSeparator** **false**|**true**

    If set to **false** (the default) the `.` (dot) character is replaced with
    _EscapeCharacter_. Otherwise, if set to **true**, the `.` (dot) character
    is preserved, i.e. passed through.

    Option value is not used when **UseTags** is _true_.

- **DropDuplicateFields** **false**|**true**

    If set to **true**, detect and remove duplicate components in Graphite metric
    names. For example, the metric name  `host.load.load.shortterm` will
    be shortened to `host.load.shortterm`.

- **UseTags** **false**|**true**

    If set to **true**, Graphite metric names will be generated as tagged series.
    This allows for much more flexibility than the traditional hierarchical layout.

    Example:
    `test.single;host=example.com;plugin=test;plugin_instance=foo;type=single;type_instance=bar`

    You can use **Postfix** option to add more tags by specifying it like
    `;tag1=value1;tag2=value2`. Note what tagging support was added since Graphite
    version 1.1.x.

    If set to **true**, the **SeparateInstances** and **PreserveSeparator** settings
    are not used.

    Default value: **false**.

- **ReverseHost** **false**|**true**

    If set to **true**, the (dot separated) parts of the **host** field of the
    _value list_ will be rewritten in reverse order. The rewrite happens _before_
    special characters are replaced with the **EscapeCharacter**.

    This option might be convenient if the metrics are presented with Graphite in a
    DNS like tree structure (probably without replacing dots in hostnames).

    Example:
     Hostname "node3.cluster1.example.com"
     LoadPlugin "cpu"
     LoadPlugin "write\_graphite"
     <Plugin "write\_graphite">
      <Node "graphite.example.com">
       EscapeCharacter "."
       ReverseHost true
      &lt;/Node>
     &lt;/Plugin>

        result on the wire: com.example.cluster1.node3.cpu-0.cpu-idle 99.900993 1543010932

    Default value: **false**.

## Plugin `write_log`

The `write_log` plugin writes metrics as INFO log messages.

This plugin supports two output formats: _Graphite_ and _JSON_.

Synopsis:

    <Plugin write_log>
      Format Graphite
    </Plugin>

- **Format** _Format_

    The output format to use. Can be one of `Graphite` or `JSON`.

## Plugin `write_tsdb`

The `write_tsdb` plugin writes data to _OpenTSDB_, a scalable open-source
time series database. The plugin connects to a _TSD_, a leaderless, no shared
state daemon that ingests metrics and stores them in HBase. The plugin uses
_TCP_ over the "line based" protocol with a default port 4242. The data will
be sent in blocks of at most 1428 bytes to minimize the number of network
packets.

Synopsis:

    <Plugin write_tsdb>
      ResolveInterval 60
      ResolveJitter 60
      <Node "example">
        Host "tsd-1.my.domain"
        Port "4242"
        HostTags "status=production"
      </Node>
    </Plugin>

The configuration consists of one or more <**Node** _Name_>
blocks and global directives.

Global directives are:

- **ResolveInterval** _seconds_
- **ResolveJitter** _seconds_

    When _collectd_ connects to a TSDB node, it will request the hostname from
    DNS. This can become a problem if the TSDB node is unavailable or badly
    configured because collectd will request DNS in order to reconnect for every
    metric, which can flood your DNS. So you can cache the last value for
    _ResolveInterval_ seconds.
    Defaults to the _Interval_ of the _write\_tsdb plugin_, e.g. 10 seconds.

    You can also define a jitter, a random interval to wait in addition to
    _ResolveInterval_. This prevents all your collectd servers to resolve the
    hostname at the same time when the connection fails.
    Defaults to the _Interval_ of the _write\_tsdb plugin_, e.g. 10 seconds.

    **Note:** If the DNS resolution has already been successful when the socket
    closes, the plugin will try to reconnect immediately with the cached
    information. DNS is queried only when the socket is closed for a longer than
    _ResolveInterval_ + _ResolveJitter_ seconds.

Inside the **Node** blocks, the following options are recognized:

- **Host** _Address_

    Hostname or address to connect to. Defaults to `localhost`.

- **Port** _Service_

    Service name or port number to connect to. Defaults to `4242`.

- **HostTags** _String_

    When set, _HostTags_ is added to the end of the metric. It is intended to be
    used for name=value pairs that the TSD will tag the metric with. Dots and
    whitespace are _not_ escaped in this string.

- **StoreRates** **false**|**true**

    If set to **true**, convert counter values to rates. If set to **false**
    (the default) counter values are stored as is, as an increasing
    integer number.

- **AlwaysAppendDS** **false**|**true**

    If set the **true**, append the name of the _Data Source_ (DS) to the "metric"
    identifier. If set to **false** (the default), this is only done when there is
    more than one DS.

## Plugin `write_mongodb`

The _write\_mongodb plugin_ will send values to _MongoDB_, a schema-less
NoSQL database.

**Synopsis:**

    <Plugin "write_mongodb">
      <Node "default">
        Host "localhost"
        Port "27017"
        Timeout 1000
        StoreRates true
      </Node>
    </Plugin>

The plugin can send values to multiple instances of _MongoDB_ by specifying
one **Node** block for each instance. Within the **Node** blocks, the following
options are available:

- **Host** _Address_

    Hostname or address to connect to. Defaults to `localhost`.

- **Port** _Service_

    Service name or port number to connect to. Defaults to `27017`.

- **Timeout** _Milliseconds_

    Set the timeout for each operation on _MongoDB_ to _Timeout_ milliseconds.
    Setting this option to zero means no timeout, which is the default.

- **StoreRates** **false**|**true**

    If set to **true** (the default), convert counter values to rates. If set to
    **false** counter values are stored as is, i.e. as an increasing integer
    number.

- **Database** _Database_
- **User** _User_
- **Password** _Password_

    Sets the information used when authenticating to a _MongoDB_ database. The
    fields are optional (in which case no authentication is attempted), but if you
    want to use authentication all three fields must be set.

## Plugin `write_prometheus`

The _write\_prometheus plugin_ implements a tiny webserver that can be scraped
using _Prometheus_.

**Options:**

- **Host** _Host_

    Bind to the hostname / address _Host_. By default, the plugin will bind to the
    "any" address, i.e. accept packets sent to any of the hosts addresses.

    This option is supported only for libmicrohttpd newer than 0.9.0.

- **Port** _Port_

    Port the embedded webserver should listen on. Defaults to **9103**.

- **StalenessDelta** _Seconds_

    Time in seconds after which _Prometheus_ considers a metric "stale" if it
    hasn't seen any update for it. This value must match the setting in Prometheus.
    It defaults to **300** seconds (5 minutes), same as Prometheus.

    **Background:**

    _Prometheus_ has a global setting, `StalenessDelta`, which controls after
    which time a metric without updates is considered "stale". This setting
    effectively puts an upper limit on the interval in which metrics are reported.

    When the _write\_prometheus plugin_ encounters a metric with an interval
    exceeding this limit, it will inform you, the user, and provide the metric to
    _Prometheus_ **without** a timestamp. That causes _Prometheus_ to consider the
    metric "fresh" each time it is scraped, with the time of the scrape being
    considered the time of the update. The result is that there appear more
    datapoints in _Prometheus_ than were actually created, but at least the metric
    doesn't disappear periodically.

## Plugin `write_http`

This output plugin submits values to an HTTP server using POST requests and
encoding metrics with JSON or using the `PUTVAL` command described in
[collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock).

Synopsis:

    <Plugin "write_http">
      <Node "example">
        URL "http://example.com/post-collectd"
        User "collectd"
        Password "weCh3ik0"
        Format JSON
      </Node>
    </Plugin>

The plugin can send values to multiple HTTP servers by specifying one
<**Node** _Name_> block for each server. Within each **Node**
block, the following options are available:

- **URL** _URL_

    URL to which the values are submitted to. Mandatory.

- **User** _Username_

    Optional user name needed for authentication.

- **Password** _Password_

    Optional password needed for authentication.

- **VerifyPeer** **true**|**false**

    Enable or disable peer SSL certificate verification. See
    [http://curl.haxx.se/docs/sslcerts.html](http://curl.haxx.se/docs/sslcerts.html) for details. Enabled by default.

- **VerifyHost** **true|false**

    Enable or disable peer host name verification. If enabled, the plugin checks if
    the `Common Name` or a `Subject Alternate Name` field of the SSL certificate
    matches the host name provided by the **URL** option. If this identity check
    fails, the connection is aborted. Obviously, only works when connecting to a
    SSL enabled server. Enabled by default.

- **CACert** _File_

    File that holds one or more SSL certificates. If you want to use HTTPS you will
    possibly need this option. What CA certificates come bundled with `libcurl`
    and are checked by default depends on the distribution you use.

- **CAPath** _Directory_

    Directory holding one or more CA certificate files. You can use this if for
    some reason all the needed CA certificates aren't in the same file and can't be
    pointed to using the **CACert** option. Requires `libcurl` to be built against
    OpenSSL.

- **ClientKey** _File_

    File that holds the private key in PEM format to be used for certificate-based
    authentication.

- **ClientCert** _File_

    File that holds the SSL certificate to be used for certificate-based
    authentication.

- **ClientKeyPass** _Password_

    Password required to load the private key in **ClientKey**.

- **Header** _Header_

    A HTTP header to add to the request.  Multiple headers are added if this option is specified more than once.  Example:

        Header "X-Custom-Header: custom_value"

- **SSLVersion** **SSLv2**|**SSLv3**|**TLSv1**|**TLSv1\_0**|**TLSv1\_1**|**TLSv1\_2**

    Define which SSL protocol version must be used. By default `libcurl` will
    attempt to figure out the remote SSL protocol version. See
    [curl\_easy\_setopt(3)](http://man.he.net/man3/curl_easy_setopt) for more details.

- **Format** **Command**|**JSON**|**KAIROSDB**

    Format of the output to generate. If set to **Command**, will create output that
    is understood by the _Exec_ and _UnixSock_ plugins. When set to **JSON**, will
    create output in the _JavaScript Object Notation_ (JSON). When set to KAIROSDB
    , will create output in the KairosDB format.

    Defaults to **Command**.

- **Attribute** _String_ _String_

    Only available for the KAIROSDB output format.

    Consider the two given strings to be the key and value of an additional tag for
    each metric being sent out.

    You can add multiple **Attribute**.

- **TTL** _Int_

    Only available for the KAIROSDB output format.

    Sets the Cassandra ttl for the data points.

    Please refer to [http://kairosdb.github.io/docs/build/html/restapi/AddDataPoints.html?highlight=ttl](http://kairosdb.github.io/docs/build/html/restapi/AddDataPoints.html?highlight=ttl)

- **Prefix** _String_

    Only available for the KAIROSDB output format.

    Sets the metrics prefix _string_. Defaults to _collectd_.

- **Metrics** **true**|**false**

    Controls whether _metrics_ are POSTed to this location. Defaults to **true**.

- **Notifications** **false**|**true**

    Controls whether _notifications_ are POSTed to this location. Defaults to **false**.

- **StoreRates** **true|false**

    If set to **true**, convert counter values to rates. If set to **false** (the
    default) counter values are stored as is, i.e. as an increasing integer number.

- **BufferSize** _Bytes_

    Sets the send buffer size to _Bytes_. By increasing this buffer, less HTTP
    requests will be generated, but more metrics will be batched / metrics are
    cached for longer before being sent, introducing additional delay until they
    are available on the server side. _Bytes_ must be at least 1024 and cannot
    exceed the size of an `int`, i.e. 2 GByte.
    Defaults to `4096`.

- **LowSpeedLimit** _Bytes per Second_

    Sets the minimal transfer rate in _Bytes per Second_ below which the
    connection with the HTTP server will be considered too slow and aborted. All
    the data submitted over this connection will probably be lost. Defaults to 0,
    which means no minimum transfer rate is enforced.

- **Timeout** _Timeout_

    Sets the maximum time in milliseconds given for HTTP POST operations to
    complete. When this limit is reached, the POST operation will be aborted, and
    all the data in the current send buffer will probably be lost. Defaults to 0,
    which means the connection never times out.

- **LogHttpError** **false**|**true**

    Enables printing of HTTP error code to log. Turned off by default.

- <**Statistics** _Name_>

    One **Statistics** block can be used to specify cURL statistics to be collected
    for each request to the remote URL. See the section "cURL Statistics" above
    for details.

    The `write_http` plugin regularly submits the collected values to the HTTP
    server. How frequently this happens depends on how much data you are collecting
    and the size of **BufferSize**. The optimal value to set **Timeout** to is
    slightly below this interval, which you can estimate by monitoring the network
    traffic between collectd and the HTTP server.

## Plugin `write_influxdb_udp`

The write\_influxdb\_udp plugin sends data to instances of InfluxDB using the
"Line Protocol". Each plugin is sent as a measurement with a time precision of
miliseconds while plugin instance, type and type instance are sent as tags.

    <Plugin "write_influxdb_udp">
      Server "influxdb.fqdn"
      Server "influxdb2.fqdn"
      TimePrecision "ms"
      StoreRates "yes"
      WriteMetadata "no"
    </Plugin>

- **<Server** _Host_ \[_Port_\]**>**

    The **Server** statement sets a server to send datagrams to. This statement can
    appear multiple times, once for each unique destination to send to.

    The argument _Host_ may be a hostname, an IPv4 address or an IPv6 address. The
    optional second argument specifies a port number or a service name. If not
    given, the default, **8089**, is used. The arguments _Host_ and _Port_ should
    be enclosed in "quotes".

- **TimePrecision** _ms_|_us_|_ns_

    The **TimePrecision** option sets the precision of the timestamps sent to 
    InfluxDB. It must match the precision set in InfluxDB line protocol 
    configuration.

    The defaut value is _ms_. Note that InfluxDB default may differ.

- **TimeToLive** _1-255_

    Set the time-to-live of sent packets. This applies to all, unicast and
    multicast, and IPv4 and IPv6 packets. The default is to not change this value.
    That means that multicast packets will be sent with a TTL of `1` (one) on most
    operating systems.

- **MaxPacketSize** _1024-65535_

    Set the maximum size for datagrams received over the network. Packets larger
    than this will be truncated. Defaults to 1452 bytes, which is the maximum
    payload size that can be transmitted in one Ethernet frame using IPv6 /
    UDP.

- **StoreRates** **true|false**

    If set to **true**, convert absolute, counter and derive values to rates. If set
    to **false** (the default) absolute, counter and derive values are sent as is.

- **WriteMetadata** **true|false**

    Defaults to **false**. If set to **true**, send aditional tags to influxdb with
    collectd value metadata.

## Plugin `write_kafka`

The _write\_kafka plugin_ will send values to a _Kafka_ topic, a distributed
queue.
Synopsis:

    <Plugin "write_kafka">
      Property "metadata.broker.list" "broker1:9092,broker2:9092"
      <Topic "collectd">
        Format JSON
      </Topic>
    </Plugin>

The following options are understood by the _write\_kafka plugin_:

- <**Topic** _Name_>

    The plugin's configuration consists of one or more **Topic** blocks. Each block
    is given a unique _Name_ and specifies one kafka producer.
    Inside the **Topic** block, the following per-topic options are
    understood:

    - **Property** _String_ _String_

        Configure the named property for the current topic. Properties are
        forwarded to the kafka producer library **librdkafka**.

    - **Key** _String_

        Use the specified string as a partitioning key for the topic. Kafka breaks
        topic into partitions and guarantees that for a given topology, the same
        consumer will be used for a specific key. The special (case insensitive)
        string **Random** can be used to specify that an arbitrary partition should
        be used.

    - **Format** **Command**|**JSON**|**Graphite**

        Selects the format in which messages are sent to the broker. If set to
        **Command** (the default), values are sent as `PUTVAL` commands which are
        identical to the syntax used by the _Exec_ and _UnixSock plugins_.

        If set to **JSON**, the values are encoded in the _JavaScript Object Notation_,
        an easy and straight forward exchange format.

        If set to **Graphite**, values are encoded in the _Graphite_ format, which is
        `<metric> <value> <timestamp>\n`.

    - **StoreRates** **true**|**false**

        Determines whether or not `COUNTER`, `DERIVE` and `ABSOLUTE` data sources
        are converted to a _rate_ (i.e. a `GAUGE` value). If set to **false** (the
        default), no conversion is performed. Otherwise the conversion is performed
        using the internal value cache.

        Please note that currently this option is only used if the **Format** option has
        been set to **JSON**.

    - **GraphitePrefix** (**Format**=_Graphite_ only)

        A prefix can be added in the metric name when outputting in the _Graphite_
        format.

        When **GraphiteUseTags** is _false_, prefix is added before the _Host_ name.
        Metric name will be
        `<prefix><host><postfix><plugin><type><name>`

        When **GraphiteUseTags** is _true_, prefix is added in front of series name.

    - **GraphitePostfix** (**Format**=_Graphite_ only)

        A postfix can be added in the metric name when outputting in the _Graphite_
        format.

        When **GraphiteUseTags** is _false_, postfix is added after the _Host_ name.
        Metric name will be
        `<prefix><host><postfix><plugin><type><name>`

        When **GraphiteUseTags** is _true_, prefix value appended to the end of series
        name (before the first ; that separates the name from the tags).

    - **GraphiteEscapeChar** (**Format**=_Graphite_ only)

        Specify a character to replace dots (.) in the host part of the metric name.
        In _Graphite_ metric name, dots are used as separators between different
        metric parts (host, plugin, type).
        Default is `_` (_Underscore_).

    - **GraphiteSeparateInstances** **false**|**true**

        If set to **true**, the plugin instance and type instance will be in their own
        path component, for example `host.cpu.0.cpu.idle`. If set to **false** (the
        default), the plugin and plugin instance (and likewise the type and type
        instance) are put into one component, for example `host.cpu-0.cpu-idle`.

        Option value is not used when **GraphiteUseTags** is _true_.

    - **GraphiteAlwaysAppendDS** **true**|**false**

        If set to **true**, append the name of the _Data Source_ (DS) to the "metric"
        identifier. If set to **false** (the default), this is only done when there is
        more than one DS.

    - **GraphitePreserveSeparator** **false**|**true**

        If set to **false** (the default) the `.` (dot) character is replaced with
        _GraphiteEscapeChar_. Otherwise, if set to **true**, the `.` (dot) character
        is preserved, i.e. passed through.

        Option value is not used when **GraphiteUseTags** is _true_.

    - **GraphiteUseTags** **false**|**true**

        If set to **true** Graphite metric names will be generated as tagged series.

        Default value: **false**.

    - **StoreRates** **true**|**false**

        If set to **true** (the default), convert counter values to rates. If set to
        **false** counter values are stored as is, i.e. as an increasing integer number.

        This will be reflected in the `ds_type` tag: If **StoreRates** is enabled,
        converted values will have "rate" appended to the data source type, e.g.
        `ds_type:derive:rate`.

- **Property** _String_ _String_

    Configure the kafka producer through properties, you almost always will
    want to set **metadata.broker.list** to your Kafka broker list.

## Plugin `write_redis`

The _write\_redis plugin_ submits values to _Redis_, a data structure server.

Synopsis:

    <Plugin "write_redis">
      <Node "example">
          Host "localhost"
          Port "6379"
          Timeout 1000
          Prefix "collectd/"
          Database 1
          MaxSetSize -1
          MaxSetDuration -1
          StoreRates true
      </Node>
    </Plugin>

Values are submitted to _Sorted Sets_, using the metric name as the key, and
the timestamp as the score. Retrieving a date range can then be done using the
`ZRANGEBYSCORE` _Redis_ command. Additionally, all the identifiers of these
_Sorted Sets_ are kept in a _Set_ called `collectd/values` (or
`${prefix}/values` if the **Prefix** option was specified) and can be retrieved
using the `SMEMBERS` _Redis_ command. You can specify the database to use
with the **Database** parameter (default is `0`). See
[http://redis.io/commands#sorted\_set](http://redis.io/commands#sorted_set) and [http://redis.io/commands#set](http://redis.io/commands#set) for
details.

The information shown in the synopsis above is the _default configuration_
which is used by the plugin if no configuration is present.

The plugin can send values to multiple instances of _Redis_ by specifying
one **Node** block for each instance. Within the **Node** blocks, the following
options are available:

- **Node** _Nodename_

    The **Node** block identifies a new _Redis_ node, that is a new _Redis_
    instance running on a specified host and port. The node name is a
    canonical identifier which is used as _plugin instance_. It is limited to
    51 characters in length.

- **Host** _Hostname_

    The **Host** option is the hostname or IP-address where the _Redis_ instance is
    running on.

- **Port** _Port_

    The **Port** option is the TCP port on which the Redis instance accepts
    connections. Either a service name of a port number may be given. Please note
    that numerical port numbers must be given as a string, too.

- **Timeout** _Milliseconds_

    The **Timeout** option sets the socket connection timeout, in milliseconds.

- **Prefix** _Prefix_

    Prefix used when constructing the name of the _Sorted Sets_ and the _Set_
    containing all metrics. Defaults to `collectd/`, so metrics will have names
    like `collectd/cpu-0/cpu-user`. When setting this to something different, it
    is recommended but not required to include a trailing slash in _Prefix_.

- **Database** _Index_

    This index selects the redis database to use for writing operations. Defaults
    to `0`.

- **MaxSetSize** _Items_

    The **MaxSetSize** option limits the number of items that the _Sorted Sets_ can
    hold. Negative values for _Items_ sets no limit, which is the default behavior.

- **MaxSetDuration** _Seconds_

    The **MaxSetDuration** option limits the duration of items that the
    _Sorted Sets_ can hold. Negative values for _Items_ sets no duration, which
    is the default behavior.

- **StoreRates** **true**|**false**

    If set to **true** (the default), convert counter values to rates. If set to
    **false** counter values are stored as is, i.e. as an increasing integer number.

## Plugin `write_riemann`

The _write\_riemann plugin_ will send values to _Riemann_, a powerful stream
aggregation and monitoring system. The plugin sends _Protobuf_ encoded data to
_Riemann_ using UDP packets.

Synopsis:

    <Plugin "write_riemann">
      <Node "example">
        Host "localhost"
        Port "5555"
        Protocol UDP
        StoreRates true
        AlwaysAppendDS false
        TTLFactor 2.0
      </Node>
      Tag "foobar"
      Attribute "foo" "bar"
    </Plugin>

The following options are understood by the _write\_riemann plugin_:

- <**Node** _Name_>

    The plugin's configuration consists of one or more **Node** blocks. Each block
    is given a unique _Name_ and specifies one connection to an instance of
    _Riemann_. Indise the **Node** block, the following per-connection options are
    understood:

    - **Host** _Address_

        Hostname or address to connect to. Defaults to `localhost`.

    - **Port** _Service_

        Service name or port number to connect to. Defaults to `5555`.

    - **Protocol** **UDP**|**TCP**|**TLS**

        Specify the protocol to use when communicating with _Riemann_. Defaults to
        **TCP**.

    - **TLSCertFile** _Path_

        When using the **TLS** protocol, path to a PEM certificate to present
        to remote host.

    - **TLSCAFile** _Path_

        When using the **TLS** protocol, path to a PEM CA certificate to
        use to validate the remote hosts's identity.

    - **TLSKeyFile** _Path_

        When using the **TLS** protocol, path to a PEM private key associated
        with the certificate defined by **TLSCertFile**.

    - **Batch** **true**|**false**

        If set to **true** and **Protocol** is set to **TCP**,
        events will be batched in memory and flushed at
        regular intervals or when **BatchMaxSize** is exceeded.

        Notifications are not batched and sent as soon as possible.

        When enabled, it can occur that events get processed by the Riemann server
        close to or after their expiration time. Tune the **TTLFactor** and
        **BatchMaxSize** settings according to the amount of values collected, if this
        is an issue.

        Defaults to true

    - **BatchMaxSize** _size_

        Maximum payload size for a riemann packet. Defaults to 8192

    - **BatchFlushTimeout** _seconds_

        Maximum amount of seconds to wait in between to batch flushes.
        No timeout by default.

    - **StoreRates** **true**|**false**

        If set to **true** (the default), convert counter values to rates. If set to
        **false** counter values are stored as is, i.e. as an increasing integer number.

        This will be reflected in the `ds_type` tag: If **StoreRates** is enabled,
        converted values will have "rate" appended to the data source type, e.g.
        `ds_type:derive:rate`.

    - **AlwaysAppendDS** **false**|**true**

        If set to **true**, append the name of the _Data Source_ (DS) to the
        "service", i.e. the field that, together with the "host" field, uniquely
        identifies a metric in _Riemann_. If set to **false** (the default), this is
        only done when there is more than one DS.

    - **TTLFactor** _Factor_

        _Riemann_ events have a _Time to Live_ (TTL) which specifies how long each
        event is considered active. _collectd_ populates this field based on the
        metrics interval setting. This setting controls the factor with which the
        interval is multiplied to set the TTL. The default value is **2.0**. Unless you
        know exactly what you're doing, you should only increase this setting from its
        default value.

    - **Notifications** **false**|**true**

        If set to **true**, create riemann events for notifications. This is **true**
        by default. When processing thresholds from write\_riemann, it might prove
        useful to avoid getting notification events.

    - **CheckThresholds** **false**|**true**

        If set to **true**, attach state to events based on thresholds defined
        in the **Threshold** plugin. Defaults to **false**.

    - **EventServicePrefix** _String_

        Add the given string as a prefix to the event service name.
        If **EventServicePrefix** not set or set to an empty string (""),
        no prefix will be used.

- **Tag** _String_

    Add the given string as an additional tag to the metric being sent to
    _Riemann_.

- **Attribute** _String_ _String_

    Consider the two given strings to be the key and value of an additional
    attribute for each metric being sent out to _Riemann_.

## Plugin `write_sensu`

The _write\_sensu plugin_ will send values to _Sensu_, a powerful stream
aggregation and monitoring system. The plugin sends _JSON_ encoded data to
a local _Sensu_ client using a TCP socket.

Synopsis:

    <Plugin "write_sensu">
      <Node "example">
        Host "localhost"
        Port "3030"
        StoreRates true
        AlwaysAppendDS false
        IncludeSource false
        MetricHandler "influx"
        MetricHandler "default"
        NotificationHandler "flapjack"
        NotificationHandler "howling_monkey"
        Notifications true
      </Node>
      Tag "foobar"
      Attribute "foo" "bar"
    </Plugin>

The following options are understood by the _write\_sensu plugin_:

- <**Node** _Name_>

    The plugin's configuration consists of one or more **Node** blocks. Each block
    is given a unique _Name_ and specifies one connection to an instance of
    _Sensu_. Inside the **Node** block, the following per-connection options are
    understood:

    - **Host** _Address_

        Hostname or address to connect to. Defaults to `localhost`.

    - **Port** _Service_

        Service name or port number to connect to. Defaults to `3030`.

    - **StoreRates** **true**|**false**

        If set to **true** (the default), convert counter values to rates. If set to
        **false** counter values are stored as is, i.e. as an increasing integer number.

        This will be reflected in the `collectd_data_source_type` tag: If
        **StoreRates** is enabled, converted values will have "rate" appended to the
        data source type, e.g.  `collectd_data_source_type:derive:rate`.

    - **AlwaysAppendDS** **false**|**true**

        If set the **true**, append the name of the _Data Source_ (DS) to the
        "service", i.e. the field that, together with the "host" field, uniquely
        identifies a metric in _Sensu_. If set to **false** (the default), this is
        only done when there is more than one DS.

    - **Notifications** **false**|**true**

        If set to **true**, create _Sensu_ events for notifications. This is **false**
        by default. At least one of **Notifications** or **Metrics** should be enabled.

    - **Metrics** **false**|**true**

        If set to **true**, create _Sensu_ events for metrics. This is **false**
        by default. At least one of **Notifications** or **Metrics** should be enabled.

    - **Separator** _String_

        Sets the separator for _Sensu_ metrics name or checks. Defaults to "/".

    - **MetricHandler** _String_

        Add a handler that will be set when metrics are sent to _Sensu_. You can add
        several of them, one per line. Defaults to no handler.

    - **NotificationHandler** _String_

        Add a handler that will be set when notifications are sent to _Sensu_. You can
        add several of them, one per line. Defaults to no handler.

    - **EventServicePrefix** _String_

        Add the given string as a prefix to the event service name.
        If **EventServicePrefix** not set or set to an empty string (""),
        no prefix will be used.

- **Tag** _String_

    Add the given string as an additional tag to the metric being sent to
    _Sensu_.

- **Attribute** _String_ _String_

    Consider the two given strings to be the key and value of an additional
    attribute for each metric being sent out to _Sensu_.

- **IncludeSource** **false**|**true**

    If set to **true**, then the source host of the metrics/notification is passed
    on to sensu using the source attribute. This may register the host as a proxy
    client in sensu.

    If set to **false** (the default), then the hostname is discarded, making it appear
    as if the event originated from the connected sensu agent.

## Plugin `write_stackdriver`

The `write_stackdriver` plugin writes metrics to the
_Google Stackdriver Monitoring_ service.

This plugin supports two authentication methods: When configured, credentials
are read from the JSON credentials file specified with **CredentialFile**.
Alternatively, when running on
_Google Compute Engine_ (GCE), an _OAuth_ token is retrieved from the
_metadata server_ and used to authenticate to GCM.

**Synopsis:**

    <Plugin write_stackdriver>
      CredentialFile "/path/to/service_account.json"
      <Resource "global">
        Label "project_id" "monitored_project"
      </Resource>
    </Plugin>

- **CredentialFile** _file_

    Path to a JSON credentials file holding the credentials for a GCP service
    account.

    If **CredentialFile** is not specified, the plugin uses _Application Default
    Credentials_. That means which credentials are used depends on the environment:

    - The environment variable `GOOGLE_APPLICATION_CREDENTIALS` is checked. If this
    variable is specified it should point to a JSON file that defines the
    credentials.
    - The path `${HOME}/.config/gcloud/application_default_credentials.json` is
    checked. This where credentials used by the _gcloud_ command line utility are
    stored. You can use `gcloud auth application-default login` to create these
    credentials.

        Please note that these credentials are often of your personal account, not a
        service account, and are therefore unfit to be used in a production
        environment.

    - When running on GCE, the built-in service account associated with the virtual
    machine instance is used.
    See also the **Email** option below.

- **Project** _Project_

    The _Project ID_ or the _Project Number_ of the _Stackdriver Account_. The
    _Project ID_ is a string identifying the GCP project, which you can chose
    freely when creating a new project. The _Project Number_ is a 12-digit decimal
    number. You can look up both on the _Developer Console_.

    This setting is optional. If not set, the project ID is read from the
    credentials file or determined from the GCE's metadata service.

- **Email** _Email_ (GCE only)

    Choses the GCE _Service Account_ used for authentication.

    Each GCE instance has a `default` _Service Account_ but may also be
    associated with additional _Service Accounts_. This is often used to restrict
    the permissions of services running on the GCE instance to the required
    minimum. The _write\_stackdriver plugin_ requires the
    `https://www.googleapis.com/auth/monitoring` scope. When multiple _Service
    Accounts_ are available, this option selects which one is used by
    _write\_stackdriver plugin_.

- **Resource** _ResourceType_

    Configures the _Monitored Resource_ to use when storing metrics.
    More information on _Monitored Resources_ and _Monitored Resource Types_ are
    available at [https://cloud.google.com/monitoring/api/resources](https://cloud.google.com/monitoring/api/resources).

    This block takes one string argument, the _ResourceType_. Inside the block are
    one or more **Label** options which configure the resource labels.

    This block is optional. The default value depends on the runtime environment:
    on GCE, the `gce_instance` resource type is used, otherwise the `global`
    resource type ist used:

    - **On GCE**, defaults to the equivalent of this config:

            <Resource "gce_instance">
              Label "project_id" "<project_id>"
              Label "instance_id" "<instance_id>"
              Label "zone" "<zone>"
            </Resource>

        The values for _project\_id_, _instance\_id_ and _zone_ are read from the GCE
        metadata service.

    - **Elsewhere**, i.e. not on GCE, defaults to the equivalent of this config:

            <Resource "global">
              Label "project_id" "<Project>"
            </Resource>

        Where _Project_ refers to the value of the **Project** option or the project ID
        inferred from the **CredentialFile**.

- **Url** _Url_

    URL of the _Stackdriver Monitoring_ API. Defaults to
    `https://monitoring.googleapis.com/v3`.

## Plugin `write_syslog`

The `write_syslog` plugin writes data in _syslog_ format log messages.
It implements the basic syslog protocol, RFC 5424, extends it with
content-based filtering, rich filtering capabilities,
flexible configuration options and adds features such as using TCP for transport.
The plugin can connect to a _Syslog_ daemon, like syslog-ng and rsyslog, that will
ingest metrics, transform and ship them to the specified output.
The plugin uses _TCP_ over the "line based" protocol with a default port 44514.
The data will be sent in blocks of at most 1428 bytes to minimize the number of
network packets.

Synopsis:

    <Plugin write_syslog>
      ResolveInterval 60
      ResolveJitter 60
      <Node "example">
        Host "syslog-1.my.domain"
        Port "44514"
        Prefix "collectd"
        MessageFormat "human"
        HostTags ""
      </Node>
    </Plugin>

The configuration consists of one or more <**Node** _Name_>
blocks and global directives.

Global directives are:

- **ResolveInterval** _seconds_
- **ResolveJitter** _seconds_

    When _collectd_ connects to a syslog node, it will request the hostname from
    DNS. This can become a problem if the syslog node is unavailable or badly
    configured because collectd will request DNS in order to reconnect for every
    metric, which can flood your DNS. So you can cache the last value for
    _ResolveInterval_ seconds.
    Defaults to the _Interval_ of the _write\_syslog plugin_, e.g. 10 seconds.

    You can also define a jitter, a random interval to wait in addition to
    _ResolveInterval_. This prevents all your collectd servers to resolve the
    hostname at the same time when the connection fails.
    Defaults to the _Interval_ of the _write\_syslog plugin_, e.g. 10 seconds.

    **Note:** If the DNS resolution has already been successful when the socket
    closes, the plugin will try to reconnect immediately with the cached
    information. DNS is queried only when the socket is closed for a longer than
    _ResolveInterval_ + _ResolveJitter_ seconds.

Inside the **Node** blocks, the following options are recognized:

- **Host** _Address_

    Hostname or address to connect to. Defaults to `localhost`.

- **Port** _Service_

    Service name or port number to connect to. Defaults to `44514`.

- **HostTags** _String_

    When set, _HostTags_ is added to the end of the metric.
    It is intended to be used for adding additional metadata to tag the metric with.
    Dots and whitespace are _not_ escaped in this string.

    Examples:

    When MessageFormat is set to "human".

        ["prefix1" "example1"="example1_v"]["prefix2" "example2"="example2_v"]"

    When MessageFormat is set to "JSON", text should be in JSON format.
    Escaping the quotation marks is required.

        HostTags "\"prefix1\": {\"example1\":\"example1_v\",\"example2\":\"example2_v\"}"

- **MessageFormat** _String_

    _MessageFormat_ selects the format in which messages are sent to the
    syslog deamon, human or JSON. Defaults to human.

    Syslog message format:

    &lt;priority>VERSION ISOTIMESTAMP HOSTNAME APPLICATION PID MESSAGEID STRUCTURED-DATA MSG

    The difference between the message formats are in the STRUCTURED-DATA and MSG parts.

    Human format:

        <166>1 ISOTIMESTAMP HOSTNAME collectd PID MESSAGEID
        ["collectd" "value": "v1" "plugin"="plugin_v" "plugin_instance"="plugin_instance_v"
        "type_instance"="type_instance_v" "type"="type_v" "ds_name"="ds_name_v" "interval"="interval_v" ]
        "host_tag_example"="host_tag_example_v" plugin_v.type_v.ds_name_v="v1"

    JSON format:

        <166>1 ISOTIMESTAMP HOSTNAME collectd PID MESSAGEID STRUCTURED-DATA
        {
          "collectd": {
          "time": time_as_epoch, "interval": interval_v, "plugin": "plugin_v",
          "plugin_instance": "plugin_instance_v", "type":"type_v",
          "type_instance": "type_instance_v", "plugin_v": {"type_v": v1}
          } , "host":"host_v", "host_tag_example": "host_tag_example_v"
        }

- **StoreRates** **false**|**true**

    If set to **true**, convert counter values to rates. If set to **false**
    (the default) counter values are stored as is, as an increasing
    integer number.

- **AlwaysAppendDS** **false**|**true**

    If set to **true**, append the name of the _Data Source_ (DS) to the "metric"
    identifier. If set to **false** (the default), this is only done when there is
    more than one DS.

- **Prefix** _String_

    When set, _Prefix_ is added to all metrics names as a prefix. It is intended in
    case you want to be able to define the source of the specific metric. Dots and
    whitespace are _not_ escaped in this string.

## Plugin `xencpu`

This plugin collects metrics of hardware CPU load for machine running Xen
hypervisor. Load is calculated from 'idle time' value, provided by Xen.
Result is reported using the `percent` type, for each CPU (core).

This plugin doesn't have any options (yet).

## Plugin `zookeeper`

The _zookeeper plugin_ will collect statistics from a _Zookeeper_ server
using the mntr command.  It requires Zookeeper 3.4.0+ and access to the
client port.

**Synopsis:**

    <Plugin "zookeeper">
      Host "127.0.0.1"
      Port "2181"
    </Plugin>

- **Host** _Address_

    Hostname or address to connect to. Defaults to `localhost`.

- **Port** _Service_

    Service name or port number to connect to. Defaults to `2181`.

# THRESHOLD CONFIGURATION

Starting with version `4.3.0` collectd has support for **monitoring**. By that
we mean that the values are not only stored or sent somewhere, but that they
are judged and, if a problem is recognized, acted upon. The only action
collectd takes itself is to generate and dispatch a "notification". Plugins can
register to receive notifications and perform appropriate further actions.

Since systems and what you expect them to do differ a lot, you can configure
**thresholds** for your values freely. This gives you a lot of flexibility but
also a lot of responsibility.

Every time a value is out of range a notification is dispatched. This means
that the idle percentage of your CPU needs to be less then the configured
threshold only once for a notification to be generated. There's no such thing
as a moving average or similar - at least not now.

Also, all values that match a threshold are considered to be relevant or
"interesting". As a consequence collectd will issue a notification if they are
not received for **Timeout** iterations. The **Timeout** configuration option is
explained in section ["GLOBAL OPTIONS"](#global-options). If, for example, **Timeout** is set to
"2" (the default) and some hosts sends it's CPU statistics to the server every
60 seconds, a notification will be dispatched after about 120 seconds. It may
take a little longer because the timeout is checked only once each **Interval**
on the server.

When a value comes within range again or is received after it was missing, an
"OKAY-notification" is dispatched.

Here is a configuration example to get you started. Read below for more
information.

    <Plugin threshold>
      <Type "foo">
        WarningMin    0.00
        WarningMax 1000.00
        FailureMin    0.00
        FailureMax 1200.00
        Invert false
        Instance "bar"
      </Type>

      <Plugin "interface">
        Instance "eth0"
        <Type "if_octets">
          FailureMax 10000000
          DataSource "rx"
        </Type>
      </Plugin>

      <Host "hostname">
        <Type "cpu">
          Instance "idle"
          FailureMin 10
        </Type>

        <Plugin "memory">
          <Type "memory">
            Instance "cached"
            WarningMin 100000000
          </Type>
        </Plugin>
      </Host>
    </Plugin>

There are basically two types of configuration statements: The `Host`,
`Plugin`, and `Type` blocks select the value for which a threshold should be
configured. The `Plugin` and `Type` blocks may be specified further using the
`Instance` option. You can combine the block by nesting the blocks, though
they must be nested in the above order, i. e. `Host` may contain either
`Plugin` and `Type` blocks, `Plugin` may only contain `Type` blocks and
`Type` may not contain other blocks. If multiple blocks apply to the same
value the most specific block is used.

The other statements specify the threshold to configure. They **must** be
included in a `Type` block. Currently the following statements are recognized:

- **FailureMax** _Value_
- **WarningMax** _Value_

    Sets the upper bound of acceptable values. If unset defaults to positive
    infinity. If a value is greater than **FailureMax** a **FAILURE** notification
    will be created. If the value is greater than **WarningMax** but less than (or
    equal to) **FailureMax** a **WARNING** notification will be created.

- **FailureMin** _Value_
- **WarningMin** _Value_

    Sets the lower bound of acceptable values. If unset defaults to negative
    infinity. If a value is less than **FailureMin** a **FAILURE** notification will
    be created. If the value is less than **WarningMin** but greater than (or equal
    to) **FailureMin** a **WARNING** notification will be created.

- **DataSource** _DSName_

    Some data sets have more than one "data source". Interesting examples are the
    `if_octets` data set, which has received (`rx`) and sent (`tx`) bytes and
    the `disk_ops` data set, which holds `read` and `write` operations. The
    system load data set, `load`, even has three data sources: `shortterm`,
    `midterm`, and `longterm`.

    Normally, all data sources are checked against a configured threshold. If this
    is undesirable, or if you want to specify different limits for each data
    source, you can use the **DataSource** option to have a threshold apply only to
    one data source.

- **Invert** **true**|**false**

    If set to **true** the range of acceptable values is inverted, i. e.
    values between **FailureMin** and **FailureMax** (**WarningMin** and
    **WarningMax**) are not okay. Defaults to **false**.

- **Persist** **true**|**false**

    Sets how often notifications are generated. If set to **true** one notification
    will be generated for each value that is out of the acceptable range. If set to
    **false** (the default) then a notification is only generated if a value is out
    of range but the previous value was okay.

    This applies to missing values, too: If set to **true** a notification about a
    missing value is generated once every **Interval** seconds. If set to **false**
    only one such notification is generated until the value appears again.

- **Percentage** **true**|**false**

    If set to **true**, the minimum and maximum values given are interpreted as
    percentage value, relative to the other data sources. This is helpful for
    example for the "df" type, where you may want to issue a warning when less than
    5 % of the total space is available. Defaults to **false**.

- **Hits** _Number_

    Delay creating the notification until the threshold has been passed _Number_
    times. When a notification has been generated, or when a subsequent value is
    inside the threshold, the counter is reset. If, for example, a value is
    collected once every 10 seconds and **Hits** is set to 3, a notification
    will be dispatched at most once every 30 seconds.

    This is useful when short bursts are not a problem. If, for example, 100% CPU
    usage for up to a minute is normal (and data is collected every
    10 seconds), you could set **Hits** to **6** to account for this.

- **Hysteresis** _Number_

    When set to non-zero, a hysteresis value is applied when checking minimum and
    maximum bounds. This is useful for values that increase slowly and fluctuate a
    bit while doing so. When these values come close to the threshold, they may
    "flap", i.e. switch between failure / warning case and okay case repeatedly.

    If, for example, the threshold is configures as

        WarningMax 100.0
        Hysteresis 1.0

    then a _Warning_ notification is created when the value exceeds _101_ and the
    corresponding _Okay_ notification is only created once the value falls below
    _99_, thus avoiding the "flapping".

# FILTER CONFIGURATION

Starting with collectd 4.6 there is a powerful filtering infrastructure
implemented in the daemon. The concept has mostly been copied from
_ip\_tables_, the packet filter infrastructure for Linux. We'll use a similar
terminology, so that users that are familiar with iptables feel right at home.

## Terminology

The following are the terms used in the remainder of the filter configuration
documentation. For an ASCII-art schema of the mechanism, see
["General structure"](#general-structure) below.

- **Match**

    A _match_ is a criteria to select specific values. Examples are, of course, the
    name of the value or it's current value.

    Matches are implemented in plugins which you have to load prior to using the
    match. The name of such plugins starts with the "match\_" prefix.

- **Target**

    A _target_ is some action that is to be performed with data. Such actions
    could, for example, be to change part of the value's identifier or to ignore
    the value completely.

    Some of these targets are built into the daemon, see ["Built-in targets"](#built-in-targets)
    below. Other targets are implemented in plugins which you have to load prior to
    using the target. The name of such plugins starts with the "target\_" prefix.

- **Rule**

    The combination of any number of matches and at least one target is called a
    _rule_. The target actions will be performed for all values for which **all**
    matches apply. If the rule does not have any matches associated with it, the
    target action will be performed for all values.

- **Chain**

    A _chain_ is a list of rules and possibly default targets. The rules are tried
    in order and if one matches, the associated target will be called. If a value
    is handled by a rule, it depends on the target whether or not any subsequent
    rules are considered or if traversal of the chain is aborted, see
    ["Flow control"](#flow-control) below. After all rules have been checked, the default targets
    will be executed.

## General structure

The following shows the resulting structure:

    +---------+
    ! Chain   !
    +---------+
         !
         V
    +---------+  +---------+  +---------+  +---------+
    ! Rule    !->! Match   !->! Match   !->! Target  !
    +---------+  +---------+  +---------+  +---------+
         !
         V
    +---------+  +---------+  +---------+
    ! Rule    !->! Target  !->! Target  !
    +---------+  +---------+  +---------+
         !
         V
         :
         :
         !
         V
    +---------+  +---------+  +---------+
    ! Rule    !->! Match   !->! Target  !
    +---------+  +---------+  +---------+
         !
         V
    +---------+
    ! Default !
    ! Target  !
    +---------+

## Flow control

There are four ways to control which way a value takes through the filter
mechanism:

- **jump**

    The built-in **jump** target can be used to "call" another chain, i. e.
    process the value with another chain. When the called chain finishes, usually
    the next target or rule after the jump is executed.

- **stop**

    The stop condition, signaled for example by the built-in target **stop**, causes
    all processing of the value to be stopped immediately.

- **return**

    Causes processing in the current chain to be aborted, but processing of the
    value generally will continue. This means that if the chain was called via
    **Jump**, the next target or rule after the jump will be executed. If the chain
    was not called by another chain, control will be returned to the daemon and it
    may pass the value to another chain.

- **continue**

    Most targets will signal the **continue** condition, meaning that processing
    should continue normally. There is no special built-in target for this
    condition.

## Synopsis

The configuration reflects this structure directly:

    PostCacheChain "PostCache"
    <Chain "PostCache">
      <Rule "ignore_mysql_show">
        <Match "regex">
          Plugin "^mysql$"
          Type "^mysql_command$"
          TypeInstance "^show_"
        </Match>
        <Target "stop">
        </Target>
      </Rule>
      <Target "write">
        Plugin "rrdtool"
      </Target>
    </Chain>

The above configuration example will ignore all values where the plugin field
is "mysql", the type is "mysql\_command" and the type instance begins with
"show\_". All other values will be sent to the `rrdtool` write plugin via the
default target of the chain. Since this chain is run after the value has been
added to the cache, the MySQL `show_*` command statistics will be available
via the `unixsock` plugin.

## List of configuration options

- **PreCacheChain** _ChainName_
- **PostCacheChain** _ChainName_

    Configure the name of the "pre-cache chain" and the "post-cache chain". The
    argument is the name of a _chain_ that should be executed before and/or after
    the values have been added to the cache.

    To understand the implications, it's important you know what is going on inside
    _collectd_. The following diagram shows how values are passed from the
    read-plugins to the write-plugins:

          +---------------+
          !  Read-Plugin  !
          +-------+-------+
                  !
        + - - - - V - - - - +
        : +---------------+ :
        : !   Pre-Cache   ! :
        : !     Chain     ! :
        : +-------+-------+ :
        :         !         :
        :         V         :
        : +-------+-------+ :  +---------------+
        : !     Cache     !--->!  Value Cache  !
        : !     insert    ! :  +---+---+-------+
        : +-------+-------+ :      !   !
        :         !   ,------------'   !
        :         V   V     :          V
        : +-------+---+---+ :  +-------+-------+
        : !  Post-Cache   +--->! Write-Plugins !
        : !     Chain     ! :  +---------------+
        : +---------------+ :
        :                   :
        :  dispatch values  :
        + - - - - - - - - - +

    After the values are passed from the "read" plugins to the dispatch functions,
    the pre-cache chain is run first. The values are added to the internal cache
    afterwards. The post-cache chain is run after the values have been added to the
    cache. So why is it such a huge deal if chains are run before or after the
    values have been added to this cache?

    Targets that change the identifier of a value list should be executed before
    the values are added to the cache, so that the name in the cache matches the
    name that is used in the "write" plugins. The `unixsock` plugin, too, uses
    this cache to receive a list of all available values. If you change the
    identifier after the value list has been added to the cache, this may easily
    lead to confusion, but it's not forbidden of course.

    The cache is also used to convert counter values to rates. These rates are, for
    example, used by the `value` match (see below). If you use the rate stored in
    the cache **before** the new value is added, you will use the old, **previous**
    rate. Write plugins may use this rate, too, see the `csv` plugin, for example.
    The `unixsock` plugin uses these rates too, to implement the `GETVAL`
    command.

    Last but not last, the **stop** target makes a difference: If the pre-cache
    chain returns the stop condition, the value will not be added to the cache and
    the post-cache chain will not be run.

- **Chain** _Name_

    Adds a new chain with a certain name. This name can be used to refer to a
    specific chain, for example to jump to it.

    Within the **Chain** block, there can be **Rule** blocks and **Target** blocks.

- **Rule** \[_Name_\]

    Adds a new rule to the current chain. The name of the rule is optional and
    currently has no meaning for the daemon.

    Within the **Rule** block, there may be any number of **Match** blocks and there
    must be at least one **Target** block.

- **Match** _Name_

    Adds a match to a **Rule** block. The name specifies what kind of match should
    be performed. Available matches depend on the plugins that have been loaded.

    The arguments inside the **Match** block are passed to the plugin implementing
    the match, so which arguments are valid here depends on the plugin being used.
    If you do not need any to pass any arguments to a match, you can use the
    shorter syntax:

        Match "foobar"

    Which is equivalent to:

        <Match "foobar">
        </Match>

- **Target** _Name_

    Add a target to a rule or a default target to a chain. The name specifies what
    kind of target is to be added. Which targets are available depends on the
    plugins being loaded.

    The arguments inside the **Target** block are passed to the plugin implementing
    the target, so which arguments are valid here depends on the plugin being used.
    If you do not need any to pass any arguments to a target, you can use the
    shorter syntax:

        Target "stop"

    This is the same as writing:

        <Target "stop">
        </Target>

## Built-in targets

The following targets are built into the core daemon and therefore need no
plugins to be loaded:

- **return**

    Signals the "return" condition, see the ["Flow control"](#flow-control) section above. This
    causes the current chain to stop processing the value and returns control to
    the calling chain. The calling chain will continue processing targets and rules
    just after the **jump** target (see below). This is very similar to the
    **RETURN** target of iptables, see [iptables(8)](http://man.he.net/man8/iptables).

    This target does not have any options.

    Example:

        Target "return"

- **stop**

    Signals the "stop" condition, see the ["Flow control"](#flow-control) section above. This
    causes processing of the value to be aborted immediately. This is similar to
    the **DROP** target of iptables, see [iptables(8)](http://man.he.net/man8/iptables).

    This target does not have any options.

    Example:

        Target "stop"

- **write**

    Sends the value to "write" plugins.

    Available options:

    - **Plugin** _Name_

        Name of the write plugin to which the data should be sent. This option may be
        given multiple times to send the data to more than one write plugin. If the
        plugin supports multiple instances, the plugin's instance(s) must also be
        specified.

    If no plugin is explicitly specified, the values will be sent to all available
    write plugins.

    Single-instance plugin example:

        <Target "write">
          Plugin "rrdtool"
        </Target>

    Multi-instance plugin example:

        <Plugin "write_graphite">
          <Node "foo">
          ...
          </Node>
          <Node "bar">
          ...
          </Node>
        </Plugin>
         ...
        <Target "write">
          Plugin "write_graphite/foo"
        </Target>

- **jump**

    Starts processing the rules of another chain, see ["Flow control"](#flow-control) above. If
    the end of that chain is reached, or a stop condition is encountered,
    processing will continue right after the **jump** target, i. e. with the
    next target or the next rule. This is similar to the **-j** command line option
    of iptables, see [iptables(8)](http://man.he.net/man8/iptables).

    Available options:

    - **Chain** _Name_

        Jumps to the chain _Name_. This argument is required and may appear only once.

    Example:

        <Target "jump">
          Chain "foobar"
        </Target>

## Available matches

- **regex**

    Matches a value using regular expressions.

    Available options:

    - **Host** _Regex_
    - **Plugin** _Regex_
    - **PluginInstance** _Regex_
    - **Type** _Regex_
    - **TypeInstance** _Regex_
    - **MetaData** _String_ _Regex_

        Match values where the given regular expressions match the various fields of
        the identifier of a value. If multiple regular expressions are given, **all**
        regexen must match for a value to match.

    - **Invert** **false**|**true**

        When set to **true**, the result of the match is inverted, i.e. all value lists
        where all regular expressions apply are not matched, all other value lists are
        matched. Defaults to **false**.

    Example:

        <Match "regex">
          Host "customer[0-9]+"
          Plugin "^foobar$"
        </Match>

- **timediff**

    Matches values that have a time which differs from the time on the server.

    This match is mainly intended for servers that receive values over the
    `network` plugin and write them to disk using the `rrdtool` plugin. RRDtool
    is very sensitive to the timestamp used when updating the RRD files. In
    particular, the time must be ever increasing. If a misbehaving client sends one
    packet with a timestamp far in the future, all further packets with a correct
    time will be ignored because of that one packet. What's worse, such corrupted
    RRD files are hard to fix.

    This match lets one match all values **outside** a specified time range
    (relative to the server's time), so you can use the **stop** target (see below)
    to ignore the value, for example.

    Available options:

    - **Future** _Seconds_

        Matches all values that are _ahead_ of the server's time by _Seconds_ or more
        seconds. Set to zero for no limit. Either **Future** or **Past** must be
        non-zero.

    - **Past** _Seconds_

        Matches all values that are _behind_ of the server's time by _Seconds_ or
        more seconds. Set to zero for no limit. Either **Future** or **Past** must be
        non-zero.

    Example:

        <Match "timediff">
          Future  300
          Past   3600
        </Match>

    This example matches all values that are five minutes or more ahead of the
    server or one hour (or more) lagging behind.

- **value**

    Matches the actual value of data sources against given minimum / maximum
    values. If a data-set consists of more than one data-source, all data-sources
    must match the specified ranges for a positive match.

    Available options:

    - **Min** _Value_

        Sets the smallest value which still results in a match. If unset, behaves like
        negative infinity.

    - **Max** _Value_

        Sets the largest value which still results in a match. If unset, behaves like
        positive infinity.

    - **Invert** **true**|**false**

        Inverts the selection. If the **Min** and **Max** settings result in a match,
        no-match is returned and vice versa. Please note that the **Invert** setting
        only effects how **Min** and **Max** are applied to a specific value. Especially
        the **DataSource** and **Satisfy** settings (see below) are not inverted.

    - **DataSource** _DSName_ \[_DSName_ ...\]

        Select one or more of the data sources. If no data source is configured, all
        data sources will be checked. If the type handled by the match does not have a
        data source of the specified name(s), this will always result in no match
        (independent of the **Invert** setting).

    - **Satisfy** **Any**|**All**

        Specifies how checking with several data sources is performed. If set to
        **Any**, the match succeeds if one of the data sources is in the configured
        range. If set to **All** the match only succeeds if all data sources are within
        the configured range. Default is **All**.

        Usually **All** is used for positive matches, **Any** is used for negative
        matches. This means that with **All** you usually check that all values are in a
        "good" range, while with **Any** you check if any value is within a "bad" range
        (or outside the "good" range).

    Either **Min** or **Max**, but not both, may be unset.

    Example:

        # Match all values smaller than or equal to 100. Matches only if all data
        # sources are below 100.
        <Match "value">
          Max 100
          Satisfy "All"
        </Match>

        # Match if the value of any data source is outside the range of 0 - 100.
        <Match "value">
          Min   0
          Max 100
          Invert true
          Satisfy "Any"
        </Match>

- **empty\_counter**

    Matches all values with one or more data sources of type **COUNTER** and where
    all counter values are zero. These counters usually _never_ increased since
    they started existing (and are therefore uninteresting), or got reset recently
    or overflowed and you had really, _really_ bad luck.

    Please keep in mind that ignoring such counters can result in confusing
    behavior: Counters which hardly ever increase will be zero for long periods of
    time. If the counter is reset for some reason (machine or service restarted,
    usually), the graph will be empty (NAN) for a long time. People may not
    understand why.

- **hashed**

    Calculates a hash value of the host name and matches values according to that
    hash value. This makes it possible to divide all hosts into groups and match
    only values that are in a specific group. The intended use is in load
    balancing, where you want to handle only part of all data and leave the rest
    for other servers.

    The hashing function used tries to distribute the hosts evenly. First, it
    calculates a 32 bit hash value using the characters of the hostname:

        hash_value = 0;
        for (i = 0; host[i] != 0; i++)
          hash_value = (hash_value * 251) + host[i];

    The constant 251 is a prime number which is supposed to make this hash value
    more random. The code then checks the group for this host according to the
    _Total_ and _Match_ arguments:

        if ((hash_value % Total) == Match)
          matches;
        else
          does not match;

    Please note that when you set _Total_ to two (i. e. you have only two
    groups), then the least significant bit of the hash value will be the XOR of
    all least significant bits in the host name. One consequence is that when you
    have two hosts, "server0.example.com" and "server1.example.com", where the host
    name differs in one digit only and the digits differ by one, those hosts will
    never end up in the same group.

    Available options:

    - **Match** _Match_ _Total_

        Divide the data into _Total_ groups and match all hosts in group _Match_ as
        described above. The groups are numbered from zero, i. e. _Match_ must
        be smaller than _Total_. _Total_ must be at least one, although only values
        greater than one really do make any sense.

        You can repeat this option to match multiple groups, for example:

            Match 3 7
            Match 5 7

        The above config will divide the data into seven groups and match groups three
        and five. One use would be to keep every value on two hosts so that if one
        fails the missing data can later be reconstructed from the second host.

    Example:

        # Operate on the pre-cache chain, so that ignored values are not even in the
        # global cache.
        <Chain "PreCache">
          <Rule>
            <Match "hashed">
              # Divide all received hosts in seven groups and accept all hosts in
              # group three.
              Match 3 7
            </Match>
            # If matched: Return and continue.
            Target "return"
          </Rule>
          # If not matched: Return and stop.
          Target "stop"
        </Chain>

## Available targets

- **notification**

    Creates and dispatches a notification.

    Available options:

    - **Message** _String_

        This required option sets the message of the notification. The following
        placeholders will be replaced by an appropriate value:

        - **%{host}**
        - **%{plugin}**
        - **%{plugin\_instance}**
        - **%{type}**
        - **%{type\_instance}**

            These placeholders are replaced by the identifier field of the same name.

        - **%{ds:**_name_**}**

            These placeholders are replaced by a (hopefully) human readable representation
            of the current rate of this data source. If you changed the instance name
            (using the **set** or **replace** targets, see below), it may not be possible to
            convert counter values to rates.

        Please note that these placeholders are **case sensitive**!

    - **Severity** **"FAILURE"**|**"WARNING"**|**"OKAY"**

        Sets the severity of the message. If omitted, the severity **"WARNING"** is
        used.

    Example:

        <Target "notification">
          Message "Oops, the %{type_instance} temperature is currently %{ds:value}!"
          Severity "WARNING"
        </Target>

- **replace**

    Replaces parts of the identifier using regular expressions.

    Available options:

    - **Host** _Regex_ _Replacement_
    - **Plugin** _Regex_ _Replacement_
    - **PluginInstance** _Regex_ _Replacement_
    - **TypeInstance** _Regex_ _Replacement_
    - **MetaData** _String_ _Regex_ _Replacement_
    - **DeleteMetaData** _String_ _Regex_

        Match the appropriate field with the given regular expression _Regex_. If the
        regular expression matches, that part that matches is replaced with
        _Replacement_. If multiple places of the input buffer match a given regular
        expression, only the first occurrence will be replaced.

        You can specify each option multiple times to use multiple regular expressions
        one after another.

    Example:

        <Target "replace">
          # Replace "example.net" with "example.com"
          Host "\\<example.net\\>" "example.com"

          # Strip "www." from hostnames
          Host "\\<www\\." ""
        </Target>

- **set**

    Sets part of the identifier of a value to a given string.

    Available options:

    - **Host** _String_
    - **Plugin** _String_
    - **PluginInstance** _String_
    - **TypeInstance** _String_
    - **MetaData** _String_ _String_

        Set the appropriate field to the given string. The strings for plugin instance,
        type instance, and meta data may be empty, the strings for host and plugin may
        not be empty. It's currently not possible to set the type of a value this way.

        The following placeholders will be replaced by an appropriate value:

        - **%{host}**
        - **%{plugin}**
        - **%{plugin\_instance}**
        - **%{type}**
        - **%{type\_instance}**

            These placeholders are replaced by the identifier field of the same name.

        - **%{meta:**_name_**}**

            These placeholders are replaced by the meta data value with the given name.

        Please note that these placeholders are **case sensitive**!

    - **DeleteMetaData** _String_

        Delete the named meta data field.

    Example:

        <Target "set">
          PluginInstance "coretemp"
          TypeInstance "core3"
        </Target>

## Backwards compatibility

If you use collectd with an old configuration, i. e. one without a
**Chain** block, it will behave as it used to. This is equivalent to the
following configuration:

    <Chain "PostCache">
      Target "write"
    </Chain>

If you specify a **PostCacheChain**, the **write** target will not be added
anywhere and you will have to make sure that it is called where appropriate. We
suggest to add the above snippet as default target to your "PostCache" chain.

## Examples

Ignore all values, where the hostname does not contain a dot, i. e. can't
be an FQDN.

    <Chain "PreCache">
      <Rule "no_fqdn">
        <Match "regex">
          Host "^[^\.]*$"
        </Match>
        Target "stop"
      </Rule>
      Target "write"
    </Chain>

# IGNORELISTS

**Ignorelists** are a generic framework to either ignore some metrics or report
specific metrics only. Plugins usually provide one or more options to specify
the items (mounts points, devices, ...) and the boolean option
`IgnoreSelected`.

- **Select** _String_

    Selects the item _String_. This option often has a plugin specific name, e.g.
    **Sensor** in the `sensors` plugin. It is also plugin specific what this string
    is compared to. For example, the `df` plugin's **MountPoint** compares it to a
    mount point and the `sensors` plugin's **Sensor** compares it to a sensor name.

    By default, this option is doing a case-sensitive full-string match. The
    following config will match `foo`, but not `Foo`:

        Select "foo"

    If _String_ starts and ends with `/` (a slash), the string is compiled as a
    _regular expression_. For example, so match all item starting with `foo`, use
    could use the following syntax:

        Select "/^foo/"

    The regular expression is _not_ anchored, i.e. the following config will match
    `foobar`, `barfoo` and `AfooZ`:

        Select "/foo/"

    The **Select** option may be repeated to select multiple items.

- **IgnoreSelected** **true**|**false**

    If set to **true**, matching metrics are _ignored_ and all other metrics are
    collected. If set to **false**, matching metrics are _collected_ and all other
    metrics are ignored.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd-exec(5)](http://man.he.net/man5/collectd-exec),
[collectd-perl(5)](http://man.he.net/man5/collectd-perl),
[collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock),
[types.db(5)](http://man.he.net/man5/types.db),
[hddtemp(8)](http://man.he.net/man8/hddtemp),
[iptables(8)](http://man.he.net/man8/iptables),
[kstat(3KSTAT)](http://man.he.net/man3KSTAT/kstat),
[mbmon(1)](http://man.he.net/man1/mbmon),
[psql(1)](http://man.he.net/man1/psql),
[regex(7)](http://man.he.net/man7/regex),
[rrdtool(1)](http://man.he.net/man1/rrdtool),
[sensors(1)](http://man.he.net/man1/sensors)

# AUTHOR

Florian Forster <octo@collectd.org>
