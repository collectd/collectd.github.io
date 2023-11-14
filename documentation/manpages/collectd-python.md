---
title: collectd-python(5)
---
# NAME

collectd-python - Documentation of collectd's `python plugin`

# SYNOPSIS

    LoadPlugin python
    # ...
    <Plugin python>
      ModulePath "/path/to/your/python/modules"
      LogTraces true
      Interactive false
      Import "spam"

      <Module spam>
        spam "wonderful" "lovely"
      </Module>
    </Plugin>

# DESCRIPTION

The `python plugin` embeds a Python-interpreter into collectd and provides an
interface to collectd's plugin system. This makes it possible to write plugins
for collectd in Python. This is a lot more efficient than executing a
Python-script every time you want to read a value with the `exec plugin` (see
[collectd-exec(5)](./collectd-exec.md)) and provides a lot more functionality, too.

The minimum required Python version is _2.6_.

# CONFIGURATION

- **LoadPlugin** _Plugin_

    Loads the Python plugin _Plugin_.

- **Encoding** _Name_

    The default encoding for Unicode objects you pass to collectd. If you omit this
    option it will default to **ascii** on _Python 2_. On _Python 3_ it will
    always be **utf-8**, as this function was removed, so this will be silently
    ignored.
    These defaults are hardcoded in Python and will ignore everything else,
    including your locale.

- **ModulePath** _Name_

    Prepends _Name_ to **sys.path**. You won't be able to import any scripts you
    wrote unless they are located in one of the directories in this list. Please
    note that it only has effect on plugins loaded after this option. You can
    use multiple **ModulePath** lines to add more than one directory.

- **LogTraces** _bool_

    If a Python script throws an exception it will be logged by collectd with the
    name of the exception and the message. If you set this option to true it will
    also log the full stacktrace just like the default output of an interactive
    Python interpreter. This does not apply to the CollectError exception, which
    will never log a stacktrace.
    This should probably be set to false most of the time but is very useful for
    development and debugging of new modules.

- **Interactive** _bool_

    This option will cause the module to launch an interactive Python interpreter
    that reads from and writes to the terminal. Note that collectd will terminate
    right after starting up if you try to run it as a daemon while this option is
    enabled so make sure to start collectd with the **-f** option.

    The **collectd** module is _not_ imported into the interpreter's globals. You
    have to do it manually. Be sure to read the help text of the module, it can be
    used as a reference guide during coding.

    This interactive session will behave slightly differently from a daemonized
    collectd script as well as from a normal Python interpreter:

    - **1.** collectd will try to import the **readline** module to give you a decent
    way of entering your commands. The daemonized collectd won't do that.
    - **2.** Python will be handling _SIGINT_. Pressing _Ctrl+C_ will usually cause
    collectd to shut down. This would be problematic in an interactive session,
    therefore Python will be handling it in interactive sessions. This allows you
    to use _Ctrl+C_ to interrupt Python code without killing collectd. This also
    means you can catch _KeyboardInterrupt_ exceptions which does not work during
    normal operation.

        To quit collectd send _EOF_ (press _Ctrl+D_ at the beginning of a new line).

    - **3.** collectd handles _SIGCHLD_. This means that Python won't be able to
    determine the return code of spawned processes with system(), popen() and
    subprocess. This will result in Python not using external programs like less
    to display help texts. You can override this behavior with the **PAGER**
    environment variable, e.g. _export PAGER=less_ before starting collectd.
    Depending on your version of Python this might or might not result in an
    **OSError** exception which can be ignored.

        If you really need to spawn new processes from Python you can register an init
        callback and reset the action for SIGCHLD to the default behavior. Please note
        that this _will_ break the exec plugin. Do not even load the exec plugin if
        you intend to do this!

        There is an example script located in **contrib/python/getsigchld.py**  to do
        this. If you import this from _collectd.conf_ SIGCHLD will be handled
        normally and spawning processes from Python will work as intended.

- **Import** _Name_

    Imports the python script _Name_ and loads it into the collectd
    python process. If your python script is not found, be sure its
    directory exists in python's **sys.path**. You can prepend to the
    **sys.path** using the **ModulePath** configuration option.

- &lt;**Module** _Name_> block

    This block may be used to pass on configuration settings to a Python module.
    The configuration is converted into an instance of the **Config** class which is
    passed to the registered configuration callback. See below for details about
    the **Config** class and how to register callbacks.

    The _name_ identifies the callback.

# STRINGS

There are a lot of places where strings are sent from collectd to Python and
from Python to collectd. How exactly this works depends on whether byte or
unicode strings or Python2 or Python3 are used.

Python2 has _str_, which is just bytes, and _unicode_. Python3 has _str_,
which is a unicode object, and _bytes_.

When passing strings from Python to collectd all of these object are supported
in all places, however _str_ should be used if possible. These strings must
not contain a NUL byte. Ignoring this will result in a _TypeError_ exception.
If a byte string was used it will be used as is by collectd. If a unicode
object was used it will be encoded using the default encoding (see above). If
this is not possible Python will raise a _UnicodeEncodeError_ exception.

When passing strings from collectd to Python the behavior depends on the
Python version used. Python2 will always receive a _str_ object. Python3 will
usually receive a _str_ object as well, however the original string will be
decoded to unicode using the default encoding. If this fails because the
string is not a valid sequence for this encoding a _bytes_ object will be
returned instead.

# WRITING YOUR OWN PLUGINS

Writing your own plugins is quite simple. collectd manages plugins by means of
**dispatch functions** which call the appropriate **callback functions**
registered by the plugins. Any plugin basically consists of the implementation
of these callback functions and initializing code which registers the
functions with collectd. See the section "EXAMPLES" below for a really basic
example. The following types of **callback functions** are known to collectd
(all of them are optional):

- configuration functions

    These are called during configuration if an appropriate
    **Module** block has been encountered. It is called once for each **Module**
    block which matches the name of the callback as provided with the
    **register\_config** method - see below.

    Python thread support has not been initialized at this point so do not use any
    threading functions here!

- init functions

    These are called once after loading the module and before any
    calls to the read and write functions. It should be used to initialize the
    internal state of the plugin (e. g. open sockets, ...). This is the
    earliest point where you may use threads.

- read functions

    These are used to collect the actual data. It is called once
    per interval (see the **Interval** configuration option of collectd). Usually
    it will call **plugin\_dispatch\_values** to dispatch the values to collectd
    which will pass them on to all registered **write functions**. If this function
    throws any kind of exception the plugin will be skipped for an increasing
    amount of time until it returns normally again.

- write functions

    These are used to write the dispatched values. It is called
    once for every value that was dispatched by any plugin.

- flush functions

    These are used to flush internal caches of plugins. It is
    usually triggered by the user only. Any plugin which caches data before
    writing it to disk should provide this kind of callback function.

- log functions

    These are used to pass messages of plugins or the daemon itself
    to the user.

- notification function

    These are used to act upon notifications. In general, a
    notification is a status message that may be associated with a data instance.
    Usually, a notification is generated by the daemon if a configured threshold
    has been exceeded (see the section "THRESHOLD CONFIGURATION" in
    [collectd.conf(5)](./collectd.conf.md) for more details), but any plugin may dispatch
    notifications as well.

- shutdown functions

    These are called once before the daemon shuts down. It should
    be used to clean up the plugin (e.g. close sockets, ...).

Any function (except log functions) may throw an exception in case of
errors. The exception will be passed on to the user using collectd's logging
mechanism. If a log callback throws an exception it will be printed to standard
error instead.

See the documentation of the various **register\_** methods in the section
"FUNCTIONS" below for the number and types of arguments passed to each
**callback function**. This section also explains how to register **callback
functions** with collectd.

To enable a module, copy it to a place where Python can find it (i. e. a
directory listed in **sys.path**) just as any other Python plugin and add
an appropriate **Import** option to the configuration file. After restarting
collectd you're done.

# CLASSES

The following complex types are used to pass values between the Python plugin
and collectd:

## CollectdError

This is an exception. If any Python script raises this exception it will
still be treated like an error by collectd but it will be logged as a
warning instead of an error and it will never generate a stacktrace.

    class CollectdError(Exception)

Basic exception for collectd Python scripts.
Throwing this exception will not cause a stacktrace to be logged, even if
LogTraces is enabled in the config.

## Signed

The Signed class is just a long. It has all its methods and behaves exactly
like any other long object. It is used to indicate if an integer was or should
be stored as a signed or unsigned integer object.

    class Signed(long)

This is a long by another name. Use it in meta data dicts
to choose the way it is stored in the meta data.

## Unsigned

The Unsigned class is just a long. It has all its methods and behaves exactly
like any other long object. It is used to indicate if an integer was or should
be stored as a signed or unsigned integer object.

    class Unsigned(long)

This is a long by another name. Use it in meta data dicts
to choose the way it is stored in the meta data.

## Config

The Config class is an object which keeps the information provided in the
configuration file. The sequence of children keeps one entry for each
configuration option. Each such entry is another Config instance, which
may nest further if nested blocks are used.

    class Config(object)

This represents a piece of collectd's config file. It is passed to scripts with
config callbacks (see **register\_config**) and is of little use if created
somewhere else.

It has no methods beyond the bare minimum and only exists for its data members.

Data descriptors defined here:

- parent

    This represents the parent of this node. On the root node
    of the config tree it will be None.

- key

    This is the keyword of this item, i.e. the first word of any given line in the
    config file. It will always be a string.

- values

    This is a tuple (which might be empty) of all value, i.e. words following the
    keyword in any given line in the config file.

    Every item in this tuple will be either a string, a float or a boolean,
    depending on the contents of the configuration file.

- children

    This is a tuple of child nodes. For most nodes this will be empty. If this node
    represents a block instead of a single line of the config file it will contain
    all nodes in this block.

## PluginData

This should not be used directly but it is the base class for both Values and
Notification. It is used to identify the source of a value or notification.

    class PluginData(object)

This is an internal class that is the base for Values and Notification. It is
pretty useless by itself and was therefore not exported to the collectd module.

Data descriptors defined here:

- host

    The hostname of the host this value was read from. For dispatching this can be
    set to an empty string which means the local hostname as defined in
    collectd.conf.

- plugin

    The name of the plugin that read the data. Setting this member to an empty
    string will insert "python" upon dispatching.

- plugin\_instance

    Plugin instance string. May be empty.

- time

    This is the Unix timestamp of the time this value was read. For dispatching
    values this can be set to zero which means "now". This means the time the value
    is actually dispatched, not the time it was set to 0.

- type

    The type of this value. This type has to be defined in your _types.db_.
    Attempting to set it to any other value will raise a _TypeError_ exception.
    Assigning a type is mandatory, calling dispatch without doing so will raise a
    _RuntimeError_ exception.

- type\_instance

    Type instance string. May be empty.

## Values

A Value is an object which features a sequence of values. It is based on the
_PluginData_ type and uses its members to identify the values.

    class Values(PluginData)

A Values object used for dispatching values to collectd and receiving values
from write callbacks.

Method resolution order:

- Values
- PluginData
- object

Methods defined here:

- **dispatch**(\[type\]\[, values\]\[, plugin\_instance\]\[, type\_instance\]\[, plugin\]\[, host\]\[, time\]\[, interval\]) -> None.

    Dispatch this instance to the collectd process. The object has members for each
    of the possible arguments for this method. For a detailed explanation of these
    parameters see the member of the same same.

    If you do not submit a parameter the value saved in its member will be
    submitted. If you do provide a parameter it will be used instead, without
    altering the member.

- **write**(\[destination\]\[, type\]\[, values\]\[, plugin\_instance\]\[, type\_instance\]\[, plugin\]\[, host\]\[, time\]\[, interval\]) -> None.

    Write this instance to a single plugin or all plugins if "destination" is
    omitted. This will bypass the main collectd process and all filtering and
    caching. Other than that it works similar to "dispatch". In most cases
    "dispatch" should be used instead of "write".

Data descriptors defined here:

- interval

    The interval is the timespan in seconds between two submits for the same data
    source. This value has to be a positive integer, so you can't submit more than
    one value per second. If this member is set to a non-positive value, the
    default value as specified in the config file will be used (default: 10).

    If you submit values more often than the specified interval, the average will
    be used. If you submit less values, your graphs will have gaps.

- values

    These are the actual values that get dispatched to collectd. It has to be a
    sequence (a tuple or list) of numbers. The size of the sequence and the type of
    its content depend on the type member your _types.db_ file. For more
    information on this read the [types.db(5)]./(./types.db.md) manual page.

    If the sequence does not have the correct size upon dispatch a _RuntimeError_
    exception will be raised. If the content of the sequence is not a number, a
    _TypeError_ exception will be raised.

- meta

    These are the meta data for this Value object.
    It has to be a dictionary of numbers, strings or bools. All keys must be
    strings. _int_ and &lt;long> objects will be dispatched as signed integers unless
    they are between 2\*\*63 and 2\*\*64-1, which will result in a unsigned integer.
    You can force one of these storage classes by using the classes
    **collectd.Signed** and **collectd.Unsigned**. A meta object received by a write
    callback will always contain **Signed** or **Unsigned** objects.

## Notification

A notification is an object defining the severity and message of the status
message as well as an identification of a data instance by means of the members
of _PluginData_ on which it is based.

class Notification(PluginData)
The Notification class is a wrapper around the collectd notification.
It can be used to notify other plugins about bad stuff happening. It works
similar to Values but has a severity and a message instead of interval
and time.
Notifications can be dispatched at any time and can be received with
register\_notification.

Method resolution order:

- Notification
- PluginData
- object

Methods defined here:

- **dispatch**(\[type\]\[, message\]\[, plugin\_instance\]\[, type\_instance\]\[, plugin\]\[, host\]\[, time\]\[, severity\]\[, meta\]) -> None.  Dispatch a notification.

    Dispatch this instance to the collectd process. The object has members for each
    of the possible arguments for this method. For a detailed explanation of these
    parameters see the member of the same same.

    If you do not submit a parameter the value saved in its member will be
    submitted. If you do provide a parameter it will be used instead, without
    altering the member.

Data descriptors defined here:

- message

    Some kind of description of what's going on and why this Notification was
    generated.

- severity

    The severity of this notification. Assign or compare to _NOTIF\_FAILURE_,
    _NOTIF\_WARNING_ or _NOTIF\_OKAY_.

- meta

    These are the meta data for the Notification object.
    It has to be a dictionary of numbers, strings or bools. All keys must be
    strings. _int_ and _long_ objects will be dispatched as signed integers unless
    they are between 2\*\*63 and 2\*\*64-1, which will result in a unsigned integer.
    One of these storage classes can be forced by using the classes
    **collectd.Signed** and **collectd.Unsigned**. A meta object received by a
    notification callback will always contain **Signed** or **Unsigned** objects.

# FUNCTIONS

The following functions provide the C-interface to Python-modules.

- **register\_\***(_callback_\[, _data_\]\[, _name_\]) -> identifier

    There are eight different register functions to get callback for eight
    different events. With one exception all of them are called as shown above.

    - _callback_ is a callable object that will be called every time the event is
    triggered.
    - _data_ is an optional object that will be passed back to the callback function
    every time it is called. If you omit this parameter no object is passed back to
    your callback, not even None.
    - _name_ is an optional identifier for this callback. The default name is
    **python**._module_. _module_ is taken from the **\_\_module\_\_** attribute of
    your callback function. Every callback needs a unique identifier, so if you
    want to register the same callback multiple times in the same module you need to
    specify a name here. Otherwise it's safe to ignore this parameter.
    - _identifier_ is the full identifier assigned to this callback.

    These functions are called in the various stages of the daemon (see the section
    ["WRITING YOUR OWN PLUGINS"](#writing-your-own-plugins) above) and are passed the following arguments:

    - register\_config

        The only argument passed is a _Config_ object. See above for the layout of this
        data type.
        Note that you cannot receive the whole config files this way, only **Module**
        blocks inside the Python configuration block. Additionally you will only
        receive blocks where your callback identifier matches **python.**_blockname_.

    - register\_init

        The callback will be called without arguments.

    - register\_read(callback\[, interval\]\[, data\]\[, name\]) -> _identifier_

        This function takes an additional parameter: _interval_. It specifies the
        time between calls to the callback function.

        The callback will be called without arguments.

    - register\_shutdown

        The callback will be called without arguments.

    - register\_write

        The callback function will be called with one argument passed, which will be a
        _Values_ object. For the layout of _Values_ see above.
        If this callback function throws an exception the next call will be delayed by
        an increasing interval.

    - register\_flush

        Like **register\_config** is important for this callback because it determines
        what flush requests the plugin will receive.

        The arguments passed are _timeout_ and _identifier_. _timeout_ indicates
        that only data older than _timeout_ seconds is to be flushed. _identifier_
        specifies which values are to be flushed.

    - register\_log

        The arguments are _severity_ and _message_. The severity is an integer and
        small for important messages and high for less important messages. The least
        important level is **LOG\_DEBUG**, the most important level is **LOG\_ERR**. In
        between there are (from least to most important): **LOG\_INFO**, **LOG\_NOTICE**,
        and **LOG\_WARNING**. _message_ is simply a string **without** a newline at the
        end.

        If this callback throws an exception it will **not** be logged. It will just be
        printed to **sys.stderr** which usually means silently ignored.

    - register\_notification

        The only argument passed is a _Notification_ object. See above for the layout of this
        data type.

- **unregister\_\***(_identifier_) -> None

    Removes a callback or data-set from collectd's internal list of callback
    functions. Every _register\_\*_ function has an _unregister\_\*_ function.
    _identifier_ is either the string that was returned by the register function
    or a callback function. The identifier will be constructed in the same way as
    for the register functions.

- **get\_dataset**(_name_) -> _definition_

    Returns the definition of a dataset specified by _name_. _definition_ is a list
    of tuples, each representing one data source. Each tuple has 4 values:

    - name

        A string, the name of the data source.

    - type

        A string that is equal to either of the variables **DS\_TYPE\_COUNTER**,
        **DS\_TYPE\_GAUGE**, **DS\_TYPE\_DERIVE** or **DS\_TYPE\_ABSOLUTE**.

    - min

        A float or None, the minimum value.

    - max

        A float or None, the maximum value.

- **flush**(_plugin\[, timeout\]\[, identifier\]) -_ None

    Flush one or all plugins. _timeout_ and the specified _identifiers_ are
    passed on to the registered flush-callbacks. If omitted, the timeout defaults
    to `-1`. The identifier defaults to None. If the **plugin** argument has been
    specified, only named plugin will be flushed.

- **error**, **warning**, **notice**, **info**, **debug**(_message_)

    Log a message with the specified severity.

# EXAMPLES

Any Python module will start similar to:

    import collectd

A very simple read function might look like:

    import random

    def read(data=None):
      vl = collectd.Values(type='gauge')
      vl.plugin='python.spam'
      vl.dispatch(values=[random.random() * 100])

A very simple write function might look like:

    def write(vl, data=None):
      for i in vl.values:
        print "%s (%s): %f" % (vl.plugin, vl.type, i)

To register those functions with collectd:

    collectd.register_read(read)
    collectd.register_write(write)

See the section ["CLASSES"](#classes) above for a complete documentation of the data
types used by the read, write and match functions.

# CAVEATS

- collectd is heavily multi-threaded. Each collectd thread accessing the Python
plugin will be mapped to a Python interpreter thread. Any such thread will be
created and destroyed transparently and on-the-fly.

    Hence, any plugin has to be thread-safe if it provides several entry points
    from collectd (i. e. if it registers more than one callback or if a
    registered callback may be called more than once in parallel).

- The Python thread module is initialized just before calling the init callbacks.
This means you must not use Python's threading module prior to this point. This
includes all config and possibly other callback as well.
- The python plugin exports the internal API of collectd which is considered
unstable and subject to change at any time. We try hard to not break backwards
compatibility in the Python API during the life cycle of one major release.
However, this cannot be guaranteed at all times. Watch out for warnings
dispatched by the python plugin after upgrades.

# KNOWN BUGS

- Not all aspects of the collectd API are accessible from Python. This includes
but is not limited to filters.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md),
[collectd-perl(5)](./collectd-perl.md),
[collectd-exec(5)](./collectd-exec.md),
[types.db(5)]./(./types.db.md),
[python(1)](http://man.he.net/man1/python),

# AUTHOR

The `python plugin` has been written by
Sven Trenkel &lt;collectd at semidefinite.de>.

This manpage has been written by Sven Trenkel
&lt;collectd at semidefinite.de>.
It is based on the [collectd-perl(5)](./collectd-perl.md) manual page by
Florian Forster &lt;octo at collectd.org> and
Sebastian Harl &lt;sh at tokkee.org>.
