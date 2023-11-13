# NAME

collectd-java - Documentation of collectd's "java plugin"

# SYNOPSIS

    LoadPlugin "java"
    <Plugin "java">
      JVMArg "-verbose:jni"
      JVMArg "-Djava.class.path=/opt/collectd/lib/collectd/bindings/java"
      
      LoadPlugin "org.collectd.java.Foobar"
      <Plugin "org.collectd.java.Foobar">
        # To be parsed by the plugin
      </Plugin>
    </Plugin>

# DESCRIPTION

The _Java_ plugin embeds a _Java Virtual Machine_ (JVM) into _collectd_ and
provides a Java interface to part of collectd's API. This makes it possible to
write additions to the daemon in Java.

This plugin is similar in nature to, but shares no code with, the _Perl_
plugin by Sebastian Harl, see [collectd-perl(5)](http://man.he.net/man5/collectd-perl) for details.

# CONFIGURATION

A short outline of this plugin's configuration can be seen in ["SYNOPSIS"](#synopsis)
above. For a complete list of all configuration options and their semantics
please read ["Plugin `java`" in collectd.conf(5)](http://man.he.net/man5/collectd.conf).

# OVERVIEW

When writing additions for collectd in Java, the underlying C base is mostly
hidden from you. All complex data types are converted to their Java counterparts
before they're passed to your functions. These Java classes reside in the
_org.collectd.api_ namespace.

The _Java_ plugin will create one object of each class configured with the
**LoadPlugin** option. The constructor of this class can then register "callback
methods", i. e. methods that will be called by the daemon when
appropriate.

The available classes are:

- **org.collectd.api.Collectd**

    All API functions exported to Java are implemented as static functions of this
    class. See ["EXPORTED API FUNCTIONS"](#exported-api-functions) below.

- **org.collectd.api.OConfigValue**

    Corresponds to `oconfig_value_t`, defined in `src/liboconfig/oconfig.h`.

- **org.collectd.api.OConfigItem**

    Corresponds to `oconfig_item_t`, defined in `src/liboconfig/oconfig.h`.

- **org.collectd.api.DataSource**

    Corresponds to `data_source_t`, defined in `src/plugin.h`.

- **org.collectd.api.DataSet**

    Corresponds to `data_set_t`, defined in `src/plugin.h`.

- **org.collectd.api.ValueList**

    Corresponds to `value_list_t`, defined in `src/plugin.h`.

- **org.collectd.api.Notification**

    Corresponds to `notification_t`, defined in `src/plugin.h`.

In the remainder of this document, we'll use the short form of these names, for
example **ValueList**. In order to be able to use these abbreviated names, you
need to **import** the classes.

# EXPORTED API FUNCTIONS

All collectd API functions that are available to Java plugins are implemented
as _public static_ functions of the **Collectd** class. This makes
calling these functions pretty straight forward. For example, to send an error
message to the daemon, you'd do something like this:

    Collectd.logError ("That wasn't chicken!");

The following are the currently exported functions.

## registerConfig

Signature: _int_ **registerConfig** (_String_ name,
_CollectdConfigInterface_ object);

Registers the **config** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["config callback"](#config-callback) below.

## registerInit

Signature: _int_ **registerInit** (_String_ name,
_CollectdInitInterface_ object);

Registers the **init** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["init callback"](#init-callback) below.

## registerRead

Signature: _int_ **registerRead** (_String_ name,
_CollectdReadInterface_ object)

Registers the **read** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["read callback"](#read-callback) below.

## registerWrite

Signature: _int_ **registerWrite** (_String_ name,
_CollectdWriteInterface_ object)

Registers the **write** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["write callback"](#write-callback) below.

## registerFlush

Signature: _int_ **registerFlush** (_String_ name,
_CollectdFlushInterface_ object)

Registers the **flush** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["flush callback"](#flush-callback) below.

## registerShutdown

Signature: _int_ **registerShutdown** (_String_ name,
_CollectdShutdownInterface_ object);

Registers the **shutdown** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["shutdown callback"](#shutdown-callback) below.

## registerLog

Signature: _int_ **registerLog** (_String_ name,
_CollectdLogInterface_ object);

Registers the **log** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["log callback"](#log-callback) below.

## registerNotification

Signature: _int_ **registerNotification** (_String_ name,
_CollectdNotificationInterface_ object);

Registers the **notification** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["notification callback"](#notification-callback) below.

## registerMatch

Signature: _int_ **registerMatch** (_String_ name,
_CollectdMatchFactoryInterface_ object);

Registers the **createMatch** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["match callback"](#match-callback) below.

## registerTarget

Signature: _int_ **registerTarget** (_String_ name,
_CollectdTargetFactoryInterface_ object);

Registers the **createTarget** function of _object_ with the daemon.

Returns zero upon success and non-zero when an error occurred.

See ["target callback"](#target-callback) below.

## dispatchValues

Signature: _int_ **dispatchValues** (_ValueList_)

Passes the values represented by the **ValueList** object to the
`plugin_dispatch_values` function of the daemon. The "data set" (or list of
"data sources") associated with the object are ignored, because
`plugin_dispatch_values` will automatically lookup the required data set. It
is therefore absolutely okay to leave this blank.

Returns zero upon success or non-zero upon failure.

## getDS

Signature: _DataSet_ **getDS** (_String_)

Returns the appropriate _type_ or **null** if the type is not defined.

## logError

Signature: _void_ **logError** (_String_)

Sends a log message with severity **ERROR** to the daemon.

## logWarning

Signature: _void_ **logWarning** (_String_)

Sends a log message with severity **WARNING** to the daemon.

## logNotice

Signature: _void_ **logNotice** (_String_)

Sends a log message with severity **NOTICE** to the daemon.

## logInfo

Signature: _void_ **logInfo** (_String_)

Sends a log message with severity **INFO** to the daemon.

## logDebug

Signature: _void_ **logDebug** (_String_)

Sends a log message with severity **DEBUG** to the daemon.

# REGISTERING CALLBACKS

When starting up, collectd creates an object of each configured class. The
constructor of this class should then register "callbacks" with the daemon,
using the appropriate static functions in **Collectd**,
see ["EXPORTED API FUNCTIONS"](#exported-api-functions) above. To register a callback, the object being
passed to one of the register functions must implement an appropriate
interface, which are all in the **org.collectd.api** namespace.

A constructor may register any number of these callbacks, even none. An object
without callback methods is never actively called by collectd, but may still
call the exported API functions. One could, for example, start a new thread in
the constructor and dispatch (submit to the daemon) values asynchronously,
whenever one is available.

Each callback method is now explained in more detail:

## config callback

Interface: **org.collectd.api.CollectdConfigInterface**

Signature: _int_ **config** (_OConfigItem_ ci)

This method is passed a **OConfigItem** object, if both, method and
configuration, are available. **OConfigItem** is the root of a tree representing
the configuration for this plugin. The root itself is the representation of the
**<Plugin />** block, so in next to all cases the children of the
root are the first interesting objects.

To signal success, this method has to return zero. Anything else will be
considered an error condition and the plugin will be disabled entirely.

See ["registerConfig"](#registerconfig) above.

## init callback

Interface: **org.collectd.api.CollectdInitInterface**

Signature: _int_ **init** ()

This method is called after the configuration has been handled. It is
supposed to set up the plugin. e. g. start threads, open connections, or
check if can do anything useful at all.

To signal success, this method has to return zero. Anything else will be
considered an error condition and the plugin will be disabled entirely.

See ["registerInit"](#registerinit) above.

## read callback

Interface: **org.collectd.api.CollectdReadInterface**

Signature: _int_ **read** ()

This method is called periodically and is supposed to gather statistics in
whatever fashion. These statistics are represented as a **ValueList** object and
sent to the daemon using [dispatchValues](#dispatchvalues).

To signal success, this method has to return zero. Anything else will be
considered an error condition and cause an appropriate message to be logged.
Currently, returning non-zero does not have any other effects. In particular,
Java "read"-methods are not suspended for increasing intervals like C
"read"-functions.

See ["registerRead"](#registerread) above.

## write callback

Interface: **org.collectd.api.CollectdWriteInterface**

Signature: _int_ **write** (_ValueList_ vl)

This method is called whenever a value is dispatched to the daemon. The
corresponding C "write"-functions are passed a `data_set_t`, so they can
decide which values are absolute values (gauge) and which are counter values.
To get the corresponding `List<DataSource>`, call the **getDataSource**
method of the **ValueList** object.

To signal success, this method has to return zero. Anything else will be
considered an error condition and cause an appropriate message to be logged.

See ["registerWrite"](#registerwrite) above.

## flush callback

Interface: **org.collectd.api.CollectdFlushInterface**

Signature: _int_ **flush** (_int_ timeout, _String_ identifier)

This method is called when the daemon received a flush command. This can either
be done using the `USR1` signal (see [collectd(1)](http://man.he.net/man1/collectd)) or using the _unixsock_
plugin (see [collectd-unixsock(5)](http://man.he.net/man5/collectd-unixsock)).

If _timeout_ is greater than zero, only values older than this number of
seconds should be flushed. To signal that all values should be flushed
regardless of age, this argument is set to a negative number.

The _identifier_ specifies which value should be flushed. If it is not
possible to flush one specific value, flush all values. To signal that all
values should be flushed, this argument is set to _null_.

To signal success, this method has to return zero. Anything else will be
considered an error condition and cause an appropriate message to be logged.

See ["registerFlush"](#registerflush) above.

## shutdown callback

Interface: **org.collectd.api.CollectdShutdownInterface**

Signature: _int_ **shutdown** ()

This method is called when the daemon is shutting down. You should not rely on
the destructor to clean up behind the object but use this function instead.

To signal success, this method has to return zero. Anything else will be
considered an error condition and cause an appropriate message to be logged.

See ["registerShutdown"](#registershutdown) above.

## log callback

Interface: **org.collectd.api.CollectdLogInterface**

Signature: _void_ **log** (_int_ severity, _String_ message)

This callback can be used to receive log messages from the daemon.

The argument _severity_ is one of:

- org.collectd.api.Collectd.LOG\_ERR
- org.collectd.api.Collectd.LOG\_WARNING
- org.collectd.api.Collectd.LOG\_NOTICE
- org.collectd.api.Collectd.LOG\_INFO
- org.collectd.api.Collectd.LOG\_DEBUG

The function does not return any value.

See ["registerLog"](#registerlog) above.

## notification callback

Interface: **org.collectd.api.CollectdNotificationInterface**

Signature: _int_ **notification** (_Notification_ n)

This callback can be used to receive notifications from the daemon.

To signal success, this method has to return zero. Anything else will be
considered an error condition and cause an appropriate message to be logged.

See ["registerNotification"](#registernotification) above.

## match callback

The match (and target, see ["target callback"](#target-callback) below) callbacks work a bit
different from the other callbacks above: You don't register a match callback
with the daemon directly, but you register a function which, when called,
creates an appropriate object. The object creating the "match" objects is
called "match factory".

See ["registerMatch"](#registermatch) above.

### Factory object

Interface: **org.collectd.api.CollectdMatchFactoryInterface**

Signature: _CollectdMatchInterface_ **createMatch**
(_OConfigItem_ ci);

Called by the daemon to create "match" objects.

Returns: A new object which implements the **CollectdMatchInterface** interface.

### Match object

Interface: **org.collectd.api.CollectdMatchInterface**

Signature: _int_ **match** (_DataSet_ ds, _ValueList_ vl);

Called when processing a chain to determine whether or not a _ValueList_
matches. How values are matches is up to the implementing class.

Has to return one of:

- **Collectd.FC\_MATCH\_NO\_MATCH**
- **Collectd.FC\_MATCH\_MATCHES**

## target callback

The target (and match, see ["match callback"](#match-callback) above) callbacks work a bit
different from the other callbacks above: You don't register a target callback
with the daemon directly, but you register a function which, when called,
creates an appropriate object. The object creating the "target" objects is
called "target factory".

See ["registerTarget"](#registertarget) above.

### Factory object

Interface: **org.collectd.api.CollectdTargetFactoryInterface**

Signature: _CollectdTargetInterface_ **createTarget**
(_OConfigItem_ ci);

Called by the daemon to create "target" objects.

Returns: A new object which implements the **CollectdTargetInterface**
interface.

### Target object

Interface: **org.collectd.api.CollectdTargetInterface**

Signature: _int_ **invoke** (_DataSet_ ds, _ValueList_ vl);

Called when processing a chain to perform some action. The action performed is
up to the implementing class.

Has to return one of:

- **Collectd.FC\_TARGET\_CONTINUE**
- **Collectd.FC\_TARGET\_STOP**
- **Collectd.FC\_TARGET\_RETURN**

# EXAMPLE

This short example demonstrates how to register a read callback with the
daemon:

    import org.collectd.api.Collectd;
    import org.collectd.api.ValueList;
    
    import org.collectd.api.CollectdReadInterface;
    
    public class Foobar implements CollectdReadInterface
    {
      public Foobar ()
      {
        Collectd.registerRead ("Foobar", this);
      }
      
      public int read ()
      {
        ValueList vl;
        
        /* Do something... */
        
        Collectd.dispatchValues (vl);
      }
    }

# PLUGINS

The following plugins are implemented in _Java_. Both, the **LoadPlugin**
option and the **Plugin** block must be inside the
**<Plugin java>** block (see above).

## GenericJMX plugin

The GenericJMX plugin reads _Managed Beans_ (MBeans) from an _MBeanServer_
using JMX. JMX is a generic framework to provide and query various management
information. The interface is used by Java processes to provide internal
statistics as well as by the _Java Virtual Machine_ (JVM) to provide
information about the memory used, threads and so on. 

The configuration of the _GenericJMX plugin_ consists of two blocks: _MBean_
blocks that define a mapping of MBean attributes to the “types” used by
_collectd_, and _Connection_ blocks which define the parameters needed to
connect to an _MBeanServer_ and what data to collect. The configuration of the
_SNMP plugin_ is similar in nature, in case you know it.

### MBean blocks

_MBean_ blocks specify what data is retrieved from _MBeans_ and how that data
is mapped on the _collectd_ data types. The block requires one string
argument, a name. This name is used in the _Connection_ blocks (see below) to
refer to a specific _MBean_ block. Therefore, the names must be unique.

The following options are recognized within _MBean_ blocks: 

- **ObjectName** _pattern_

    Sets the pattern which is used to retrieve _MBeans_ from the _MBeanServer_.
    If more than one MBean is returned you should use the **InstanceFrom** option
    (see below) to make the identifiers unique.

    See also:
    [http://java.sun.com/javase/6/docs/api/javax/management/ObjectName.html](http://java.sun.com/javase/6/docs/api/javax/management/ObjectName.html)

- **InstancePrefix** _prefix_

    Prefixes the generated _plugin instance_ with _prefix_. _(optional)_

- **InstanceFrom** _property_

    The _object names_ used by JMX to identify _MBeans_ include so called
    _“properties”_ which are basically key-value-pairs. If the given object name
    is not unique and multiple MBeans are returned, the values of those properties
    usually differ. You can use this option to build the _plugin instance_ from
    the appropriate property values. This option is optional and may be repeated to
    generate the _plugin instance_ from multiple property values. 

- **&lt;value />** blocks

    The _value_ blocks map one or more attributes of an _MBean_ to a value list
    in _collectd_. There must be at least one Value block within each _MBean_
    block.

    - **Type** type

        Sets the data set used within _collectd_ to handle the values of the _MBean_
        attribute.

    - **InstancePrefix** _prefix_

        Works like the option of the same name directly beneath the _MBean_ block, but
        sets the type instance instead. _(optional)_

    - **InstanceFrom** _prefix_

        Works like the option of the same name directly beneath the _MBean_ block, but
        sets the type instance instead. _(optional)_

    - **PluginName** _name_

        When set, overrides the default setting for the _plugin_ field
        (`GenericJMX`).

    - **Table** **true**|**false**

        Set this to true if the returned attribute is a _composite type_. If set to
        true, the keys within the _composite type_ is appended to the
        _type instance_.

    - **Attribute** _path_

        Sets the name of the attribute from which to read the value. You can access the
        keys of composite types by using a dot to concatenate the key name to the
        attribute name. For example: “attrib0.key42”. If **Table** is set to **true**
        _path_ must point to a _composite type_, otherwise it must point to a numeric
        type. 

### Connection blocks

Connection blocks specify _how_ to connect to an _MBeanServer_ and what data
to retrieve. The following configuration options are available:

- **Host** _name_

    Host name used when dispatching the values to _collectd_. The option sets this
    field only, it is _not_ used to connect to anything and doesn't need to be a
    real, resolvable name.

- **ServiceURL** _URL_

    Specifies how the _MBeanServer_ can be reached. Any string accepted by the
    _JMXServiceURL_ is valid.

    See also:
    [http://java.sun.com/javase/6/docs/api/javax/management/remote/JMXServiceURL.html](http://java.sun.com/javase/6/docs/api/javax/management/remote/JMXServiceURL.html)

- **User** _name_

    Use _name_ to authenticate to the server. If not configured, “monitorRole”
    will be used.

- **Password** _password_

    Use _password_ to authenticate to the server. If not given, unauthenticated
    access is used.

- **InstancePrefix** _prefix_

    Prefixes the generated _plugin instance_ with _prefix_. If a second
    _InstancePrefix_ is specified in a referenced _MBean_ block, the prefix
    specified in the _Connection_ block will appear at the beginning of the
    _plugin instance_, the prefix specified in the _MBean_ block will be appended
    to it.

- **Collect** _mbean\_block\_name_

    Configures which of the _MBean_ blocks to use with this connection. May be
    repeated to collect multiple _MBeans_ from this server. 

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[collectd-perl(5)](http://man.he.net/man5/collectd-perl),
[types.db(5)](http://man.he.net/man5/types.db)

# AUTHOR

Florian Forster &lt;octo at collectd.org>
