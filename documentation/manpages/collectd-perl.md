# NAME

collectd-perl - Documentation of collectd's `perl plugin`

# SYNOPSIS

    LoadPlugin perl
    # ...
    <Plugin perl>
      IncludeDir "/path/to/perl/plugins"
      BaseName "Collectd::Plugins"
      EnableDebugger ""
      LoadPlugin "FooBar"

      <Plugin FooBar>
        Foo "Bar"
      </Plugin>
    </Plugin>

# DESCRIPTION

The `perl plugin` embeds a Perl-interpreter into collectd and provides an
interface to collectd's plugin system. This makes it possible to write plugins
for collectd in Perl. This is a lot more efficient than executing a
Perl-script every time you want to read a value with the `exec plugin` (see
[collectd-exec(5)](http://man.he.net/man5/collectd-exec)) and provides a lot more functionality, too.

# CONFIGURATION

- **LoadPlugin** _Plugin_

    Loads the Perl plugin _Plugin_. This does basically the same as **use** would
    do in a Perl program. As a side effect, the first occurrence of this option
    causes the Perl-interpreter to be initialized.

- **BaseName** _Name_

    Prepends _Name_**::** to all plugin names loaded after this option. This is
    provided for convenience to keep plugin names short. All Perl-based plugins
    provided with the _collectd_ distributions reside in the `Collectd::Plugins`
    namespace.

- <**Plugin** _Name_> block

    This block may be used to pass on configuration settings to a Perl plugin. The
    configuration is converted into a config-item data type which is passed to the
    registered configuration callback. See below for details about the config-item
    data type and how to register callbacks.

    The _name_ identifies the callback. It is used literally and independent of
    the **BaseName** setting.

- **EnableDebugger** _Package_\[=_option_,...\]

    Run collectd under the control of the Perl source debugger. If _Package_ is
    not the empty string, control is passed to the debugging, profiling, or
    tracing module installed as Devel::_Package_. A comma-separated list of
    options may be specified after the "=" character. Please note that you may not
    leave out the _Package_ option even if you specify **""**. This is the same as
    using the **-d:Package** command line option.

    See [perldebug](https://metacpan.org/pod/perldebug) for detailed documentation about debugging Perl.

    This option does not prevent collectd from daemonizing, so you should start
    collectd with the **-f** command line option. Else you will not be able to use
    the command line driven interface of the debugger.

- **IncludeDir** _Dir_

    Adds _Dir_ to the **@INC** array. This is the same as using the **-IDir**
    command line option or **use lib Dir** in the source code. Please note that it
    only has effect on plugins loaded after this option.

- **RegisterLegacyFlush** _true|false_

    The `Perl plugin` used to register one flush callback (called **"perl"**) and
    call all Perl-based flush handlers when this callback was called. Newer versions
    of the plugin wrap the Perl flush handlers and register them directly with the
    daemon _in addition_ to the legacy **"perl"** callback. This allows to call
    specific Perl flush handlers, but has the downside that flushing _all_ plugins
    now calls the Perl flush handlers twice (once directly and once via the legacy
    callback). Unfortunately, removing the **"perl"** callback would break backwards
    compatibility.

    This option allows you to disable the legacy **"perl"** flush callback if you care
    about the double call and don't call the **"perl"** callback in your setup.

# WRITING YOUR OWN PLUGINS

Writing your own plugins is quite simple. collectd manages plugins by means of
**dispatch functions** which call the appropriate **callback functions**
registered by the plugins. Any plugin basically consists of the implementation
of these callback functions and initializing code which registers the
functions with collectd. See the section "EXAMPLES" below for a really basic
example. The following types of **callback functions** are known to collectd
(all of them are optional):

- configuration functions

    This type of functions is called during configuration if an appropriate
    **Plugin** block has been encountered. It is called once for each **Plugin**
    block which matches the name of the callback as provided with the
    **plugin\_register** method - see below.

- init functions

    This type of functions is called once after loading the module and before any
    calls to the read and write functions. It should be used to initialize the
    internal state of the plugin (e. g. open sockets, ...). If the return
    value evaluates to **false**, the plugin will be disabled.

- read functions

    This type of function is used to collect the actual data. It is called once
    per interval (see the **Interval** configuration option of collectd). Usually
    it will call **plugin\_dispatch\_values** to dispatch the values to collectd
    which will pass them on to all registered **write functions**. If the return
    value evaluates to **false** the plugin will be skipped for an increasing
    amount of time until it returns **true** again.

- write functions

    This type of function is used to write the dispatched values. It is called
    once for each call to **plugin\_dispatch\_values**.

- flush functions

    This type of function is used to flush internal caches of plugins. It is
    usually triggered by the user only. Any plugin which caches data before
    writing it to disk should provide this kind of callback function.

- log functions

    This type of function is used to pass messages of plugins or the daemon itself
    to the user.

- notification function

    This type of function is used to act upon notifications. In general, a
    notification is a status message that may be associated with a data instance.
    Usually, a notification is generated by the daemon if a configured threshold
    has been exceeded (see the section "THRESHOLD CONFIGURATION" in
    [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for more details), but any plugin may dispatch
    notifications as well.

- shutdown functions

    This type of function is called once before the daemon shuts down. It should
    be used to clean up the plugin (e.g. close sockets, ...).

Any function (except log functions) may set the **$@** variable to describe
errors in more detail. The message will be passed on to the user using
collectd's logging mechanism.

See the documentation of the **plugin\_register** method in the section
"METHODS" below for the number and types of arguments passed to each
**callback function**. This section also explains how to register **callback
functions** with collectd.

To enable a plugin, copy it to a place where Perl can find it (i. e. a
directory listed in the **@INC** array) just as any other Perl plugin and add
an appropriate **LoadPlugin** option to the configuration file. After
restarting collectd you're done.

# DATA TYPES

The following complex types are used to pass values between the Perl plugin
and collectd:

- Config-Item

    A config-item is one structure which keeps the information provided in the
    configuration file. The array of children keeps one entry for each
    configuration option. Each such entry is another config-item structure, which
    may nest further if nested blocks are used.

        {
          key      => key,
          values   => [ val1, val2, ... ],
          children => [ { ... }, { ... }, ... ]
        }

- Data-Set

    A data-set is a list of one or more data-sources. Each data-source defines a
    name, type, min- and max-value and the data-set wraps them up into one
    structure. The general layout looks like this:

        [{
          name => 'data_source_name',
          type => DS_TYPE_COUNTER || DS_TYPE_GAUGE || DS_TYPE_DERIVE || DS_TYPE_ABSOLUTE,
          min  => value || undef,
          max  => value || undef
        }, ...]

- Value-List

    A value-list is one structure which features an array of values and fields to
    identify the values, i. e. time and host, plugin name and
    plugin-instance as well as a type and type-instance. Since the "type" is not
    included in the value-list but is passed as an extra argument, the general
    layout looks like this:

        {
          values => [123, 0.5],
          time   => time (),
          interval => plugin_get_interval (),
          host   => $hostname_g,
          plugin => 'myplugin',
          type   => 'myplugin',
          plugin_instance => '',
          type_instance   => ''
        }

- Notification

    A notification is one structure defining the severity, time and message of the
    status message as well as an identification of a data instance. Also, it
    includes an optional list of user-defined meta information represented as
    (name, value) pairs:

        {
          severity => NOTIF_FAILURE || NOTIF_WARNING || NOTIF_OKAY,
          time     => time (),
          message  => 'status message',
          host     => $hostname_g,
          plugin   => 'myplugin',
          type     => 'mytype',
          plugin_instance => '',
          type_instance   => '',
          meta     => [ { name => <name>, value => <value> }, ... ]
        }

- Match-Proc

    A match-proc is one structure storing the callbacks of a "match" of the filter
    chain infrastructure. The general layout looks like this:

        {
          create  => 'my_create',
          destroy => 'my_destroy',
          match   => 'my_match'
        }

- Target-Proc

    A target-proc is one structure storing the callbacks of a "target" of the
    filter chain infrastructure. The general layout looks like this:

        {
          create  => 'my_create',
          destroy => 'my_destroy',
          invoke  => 'my_invoke'
        }

# METHODS

The following functions provide the C-interface to Perl-modules. They are
exported by the ":plugin" export tag (see the section "EXPORTS" below).

- **plugin\_register** (_type_, _name_, _data_)

    Registers a callback-function or data-set.

    _type_ can be one of:

    - TYPE\_CONFIG
    - TYPE\_INIT
    - TYPE\_READ
    - TYPE\_WRITE
    - TYPE\_FLUSH
    - TYPE\_LOG
    - TYPE\_NOTIF
    - TYPE\_SHUTDOWN
    - TYPE\_DATASET

    _name_ is the name of the callback-function or the type of the data-set,
    depending on the value of _type_. (Please note that the type of the data-set
    is the value passed as _name_ here and has nothing to do with the _type_
    argument which simply tells **plugin\_register** what is being registered.)

    The last argument, _data_, is either a function name or an array-reference.
    If _type_ is **TYPE\_DATASET**, then the _data_ argument must be an
    array-reference which points to an array of hashes. Each hash describes one
    data-set. For the exact layout see **Data-Set** above. Please note that
    there is a large number of predefined data-sets available in the **types.db**
    file which are automatically registered with collectd - see [types.db(5)](http://man.he.net/man5/types.db) for
    a description of the format of this file.

    **Note**: Using **plugin\_register** to register a data-set is deprecated. Add
    the new type to a custom [types.db(5)](http://man.he.net/man5/types.db) file instead. This functionality might
    be removed in a future version of collectd.

    If the _type_ argument is any of the other types (**TYPE\_INIT**, **TYPE\_READ**,
    ...) then _data_ is expected to be a function name. If the name is not
    prefixed with the plugin's package name collectd will add it automatically.
    The interface slightly differs from the C interface (which expects a function
    pointer instead) because Perl does not support to share references to
    subroutines between threads.

    These functions are called in the various stages of the daemon (see the
    section "WRITING YOUR OWN PLUGINS" above) and are passed the following
    arguments:

    - TYPE\_CONFIG

        The only argument passed is _config-item_. See above for the layout of this
        data type.

    - TYPE\_INIT
    - TYPE\_READ
    - TYPE\_SHUTDOWN

        No arguments are passed.

    - TYPE\_WRITE

        The arguments passed are _type_, _data-set_, and _value-list_. _type_ is a
        string. For the layout of _data-set_ and _value-list_ see above.

    - TYPE\_FLUSH

        The arguments passed are _timeout_ and _identifier_. _timeout_ indicates
        that only data older than _timeout_ seconds is to be flushed. _identifier_
        specifies which values are to be flushed.

    - TYPE\_LOG

        The arguments are _log-level_ and _message_. The log level is small for
        important messages and high for less important messages. The least important
        level is **LOG\_DEBUG**, the most important level is **LOG\_ERR**. In between there
        are (from least to most important): **LOG\_INFO**, **LOG\_NOTICE**, and
        **LOG\_WARNING**. _message_ is simply a string **without** a newline at the end.

    - TYPE\_NOTIF

        The only argument passed is _notification_. See above for the layout of this
        data type.

- **plugin\_unregister** (_type_, _plugin_)

    Removes a callback or data-set from collectd's internal list of
    functions / datasets.

- **plugin\_dispatch\_values** (_value-list_)

    Submits a _value-list_ to the daemon. If the data-set identified by
    _value-list_->{_type_}
    is found (and the number of values matches the number of data-sources) then the
    type, data-set and value-list is passed to all write-callbacks that are
    registered with the daemon.

- **plugin\_write** (\[**plugins** => _..._\]\[, **datasets** => _..._\],
**valuelists** => _..._)

    Calls the write function of the given _plugins_ with the provided _data
    sets_ and _value lists_. In contrast to **plugin\_dispatch\_values**, it does
    not update collectd's internal cache and bypasses the filter mechanism (see
    [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for details). If the **plugins** argument has been omitted,
    the values will be dispatched to all registered write plugins. If the
    **datasets** argument has been omitted, the required data sets are looked up
    according to the `type` member in the appropriate value list. The value of
    all three arguments may either be a single scalar or a reference to an array.
    If the **datasets** argument has been specified, the number of data sets has to
    equal the number of specified value lists.

- **plugin\_flush** (\[**timeout** => _timeout_\]\[, **plugins** => _..._\]\[,
**identifiers** => _..._\])

    Flush one or more plugins. _timeout_ and the specified _identifiers_ are
    passed on to the registered flush-callbacks. If omitted, the timeout defaults
    to `-1`. The identifier defaults to the undefined value. If the **plugins**
    argument has been specified, only named plugins will be flushed. The value of
    the **plugins** and **identifiers** arguments may either be a string or a
    reference to an array of strings.

- **plugin\_dispatch\_notification** (_notification_)

    Submits a _notification_ to the daemon which will then pass it to all
    notification-callbacks that are registered.

- **plugin\_log** (_log-level_, _message_)

    Submits a _message_ of level _log-level_ to collectd's logging mechanism.
    The message is passed to all log-callbacks that are registered with collectd.

- **ERROR**, **WARNING**, **NOTICE**, **INFO**, **DEBUG** (_message_)

    Wrappers around **plugin\_log**, using **LOG\_ERR**, **LOG\_WARNING**,
    **LOG\_NOTICE**, **LOG\_INFO** and **LOG\_DEBUG** respectively as _log-level_.

- **plugin\_get\_interval** ()

    Returns the interval of the current plugin as a floating point number in
    seconds. This value depends on the interval configured within the
    `LoadPlugin perl` block or the global interval (see [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for
    details).

The following function provides the filter chain C-interface to Perl-modules.
It is exported by the ":filter\_chain" export tag (see the section "EXPORTS"
below).

- **fc\_register** (_type_, _name_, _proc_)

    Registers filter chain callbacks with collectd.

    _type_ may be any of:

    - FC\_MATCH
    - FC\_TARGET

    _name_ is the name of the match or target. By this name, the callbacks are
    identified in the configuration file when specifying a **Match** or **Target**
    block (see [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for details).

    _proc_ is a hash reference. The hash includes up to three callbacks: an
    optional constructor (**create**) and destructor (**destroy**) and a mandatory
    **match** or **invoke** callback. **match** is called whenever processing an
    appropriate match, while **invoke** is called whenever processing an
    appropriate target (see the section "FILTER CONFIGURATION" in
    [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for details). Just like any other callbacks, filter chain
    callbacks are identified by the function name rather than a function pointer
    because Perl does not support to share references to subroutines between
    threads. The following arguments are passed to the callbacks:

    - create

        The arguments passed are _config-item_ and _user-data_. See above for the
        layout of the config-item data-type. _user-data_ is a reference to a scalar
        value that may be used to store any information specific to this particular
        instance. The daemon does not care about this information at all. It's for the
        plugin's use only.

    - destroy

        The only argument passed is _user-data_ which is a reference to the user data
        initialized in the **create** callback. This callback may be used to cleanup
        instance-specific information and settings.

    - match, invoke

        The arguments passed are _data-set_, _value-list_, _meta_ and _user-data_.
        See above for the layout of the data-set and value-list data-types. _meta_ is
        a pointer to an array of meta information, just like the **meta** member of the
        notification data-type (see above). _user-data_ is a reference to the user
        data initialized in the **create** callback.

# GLOBAL VARIABLES

- **$hostname\_g**

    As the name suggests this variable keeps the hostname of the system collectd
    is running on. The value might be influenced by the **Hostname** or
    **FQDNLookup** configuration options (see [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for details).

- **$interval\_g**

    This variable keeps the interval in seconds in which the read functions are
    queried (see the **Interval** configuration option).

    **Note:** This variable should no longer be used in favor of
    `plugin_get_interval()` (see above). This function takes any plugin-specific
    interval settings into account (see the `Interval` option of `LoadPlugin` in
    [collectd.conf(5)](http://man.he.net/man5/collectd.conf) for details).

Any changes to these variables will be globally visible in collectd.

# EXPORTS

By default no symbols are exported. However, the following export tags are
available (**:all** will export all of them):

- **:plugin**
    - **plugin\_register** ()
    - **plugin\_unregister** ()
    - **plugin\_dispatch\_values** ()
    - **plugin\_flush** ()
    - **plugin\_flush\_one** ()
    - **plugin\_flush\_all** ()
    - **plugin\_dispatch\_notification** ()
    - **plugin\_log** ()
- **:types**
    - **TYPE\_CONFIG**
    - **TYPE\_INIT**
    - **TYPE\_READ**
    - **TYPE\_WRITE**
    - **TYPE\_FLUSH**
    - **TYPE\_SHUTDOWN**
    - **TYPE\_LOG**
    - **TYPE\_DATASET**
- **:ds\_types**
    - **DS\_TYPE\_COUNTER**
    - **DS\_TYPE\_GAUGE**
    - **DS\_TYPE\_DERIVE**
    - **DS\_TYPE\_ABSOLUTE**
- **:log**
    - **ERROR** ()
    - **WARNING** ()
    - **NOTICE** ()
    - **INFO** ()
    - **DEBUG** ()
    - **LOG\_ERR**
    - **LOG\_WARNING**
    - **LOG\_NOTICE**
    - **LOG\_INFO**
    - **LOG\_DEBUG**
- **:filter\_chain**
    - **fc\_register**
    - **FC\_MATCH\_NO\_MATCH**
    - **FC\_MATCH\_MATCHES**
    - **FC\_TARGET\_CONTINUE**
    - **FC\_TARGET\_STOP**
    - **FC\_TARGET\_RETURN**
- **:fc\_types**
    - **FC\_MATCH**
    - **FC\_TARGET**
- **:notif**
    - **NOTIF\_FAILURE**
    - **NOTIF\_WARNING**
    - **NOTIF\_OKAY**
- **:globals**
    - **$hostname\_g**
    - **$interval\_g**

# EXAMPLES

Any Perl plugin will start similar to:

    package Collectd::Plugins::FooBar;

    use strict;
    use warnings;

    use Collectd qw( :all );

A very simple read function might look like:

    sub foobar_read
    {
      my $vl = { plugin => 'foobar', type => 'gauge' };
      $vl->{'values'} = [ rand(42) ];
      plugin_dispatch_values ($vl);
      return 1;
    }

A very simple write function might look like:

    sub foobar_write
    {
      my ($type, $ds, $vl) = @_;
      for (my $i = 0; $i < scalar (@$ds); ++$i) {
        print "$vl->{'plugin'} ($vl->{'type'}): $vl->{'values'}->[$i]\n";
      }
      return 1;
    }

A very simple match callback might look like:

    sub foobar_match
    {
      my ($ds, $vl, $meta, $user_data) = @_;
      if (matches($ds, $vl)) {
        return FC_MATCH_MATCHES;
      } else {
        return FC_MATCH_NO_MATCH;
      }
    }

To register those functions with collectd:

    plugin_register (TYPE_READ, "foobar", "foobar_read");
    plugin_register (TYPE_WRITE, "foobar", "foobar_write");

    fc_register (FC_MATCH, "foobar", "foobar_match");

See the section "DATA TYPES" above for a complete documentation of the data
types used by the read, write and match functions.

# NOTES

- Please feel free to send in new plugins to collectd's mailing list at
&lt;collectd at collectd.org> for review and, possibly,
inclusion in the main distribution. In the latter case, we will take care of
keeping the plugin up to date and adapting it to new versions of collectd.

    Before submitting your plugin, please take a look at
    [http://collectd.org/dev-info.shtml](http://collectd.org/dev-info.shtml).

# CAVEATS

- collectd is heavily multi-threaded. Each collectd thread accessing the perl
plugin will be mapped to a Perl interpreter thread (see [threads(3perl)](http://man.he.net/man3perl/threads)).
Any such thread will be created and destroyed transparently and on-the-fly.

    Hence, any plugin has to be thread-safe if it provides several entry points
    from collectd (i. e. if it registers more than one callback or if a
    registered callback may be called more than once in parallel). Please note
    that no data is shared between threads by default. You have to use the
    **threads::shared** module to do so.

- Each function name registered with collectd has to be available before the
first thread has been created (i. e. basically at compile time). This
basically means that hacks (yes, I really consider this to be a hack) like
`*foo = \&bar; plugin_register (TYPE_READ, "plugin", "foo");` most likely
will not work. This is due to the fact that the symbol table is not shared
across different threads.
- Each plugin is usually only loaded once and kept in memory for performance
reasons. Therefore, END blocks are only executed once when collectd shuts
down. You should not rely on END blocks anyway - use **shutdown functions**
instead.
- The perl plugin exports the internal API of collectd which is considered
unstable and subject to change at any time. We try hard to not break backwards
compatibility in the Perl API during the life cycle of one major release.
However, this cannot be guaranteed at all times. Watch out for warnings
dispatched by the perl plugin after upgrades.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[collectd-exec(5)](http://man.he.net/man5/collectd-exec),
[types.db(5)](http://man.he.net/man5/types.db),
[perl(1)](http://man.he.net/man1/perl),
[threads(3perl)](http://man.he.net/man3perl/threads),
[threads::shared(3perl)](http://man.he.net/man3perl/threads::shared),
[perldebug(1)](http://man.he.net/man1/perldebug)

# AUTHOR

The `perl plugin` has been written by Sebastian Harl
&lt;sh at tokkee.org>.

This manpage has been written by Florian Forster
&lt;octo at collectd.org> and Sebastian Harl
&lt;sh at tokkee.org>.
