# NAME

collectd-lua - Documentation of collectd's `Lua plugin`

# SYNOPSIS

    LoadPlugin lua
    # ...
    <Plugin lua>
      BasePath "/path/to/your/lua/scripts"
      Script "script1.lua"
      Script "script2.lua"
    </Plugin>

# DESCRIPTION

The `Lua plugin` embeds a Lua interpreter into collectd and provides an
interface to collectd's plugin system. This makes it possible to write plugins
for collectd in Lua. This is a lot more efficient than executing a
Lua script every time you want to read a value with the `exec plugin` (see
[collectd-exec(5)](http://man.he.net/man5/collectd-exec)) and provides a lot more functionality, too.

The minimum required Lua version is _5.1_.

# CONFIGURATION

- **LoadPlugin** _Lua_

    Loads the Lua plugin.

- **BasePath** _Name_

    The directory the `Lua plugin` looks in to find script **Script**.
    If set, this is also prepended to **package.path**.

- **Script** _Name_

    The script the `Lua plugin` is going to run.
    If **BasePath** is not specified, this needs to be an absolute path.

# WRITING YOUR OWN PLUGINS

Writing your own plugins is quite simple. collectd manages plugins by means of
**dispatch functions** which call the appropriate **callback functions**
registered by the plugins. Any plugin basically consists of the implementation
of these callback functions and initializing code which registers the
functions with collectd. See the section "EXAMPLES" below for a really basic
example. The following types of **callback functions** are implemented in the
Lua plugin (all of them are optional):

- read functions

    These are used to collect the actual data. It is called once
    per interval (see the **Interval** configuration option of collectd). Usually
    it will call **collectd.dispatch\_values** to dispatch the values to collectd
    which will pass them on to all registered **write functions**. If this function
    does not return 0, interval between its calls will grow until function returns
    0 again. See the **MaxReadInterval** configuration option of collectd.

- write functions

    These are used to write the dispatched values. They are called
    once for every value that was dispatched by any plugin.

# FUNCTIONS

The following functions are provided to Lua modules:

- register\_read(callback)

    Function to register read callbacks.
    The callback will be called without arguments.
    If this callback function does not return 0 the next call will be delayed by
    an increasing interval.

- register\_write(callback)

    Function to register write callbacks.
    The callback function will be called with one argument passed, which will be a
    table of values.
    If this callback function does not return 0 next call will be delayed by
    an increasing interval.

- log\_error, log\_warning, log\_notice, log\_info, log\_debug(_message_)

    Log a message with the specified severity.

# EXAMPLES

> A very simple read function might look like:
>
>     function read()
>       collectd.log_info("read function called")
>       t = {
>           host = 'localhost',
>           plugin = 'myplugin',
>           type = 'counter',
>           values = {42},
>       }
>       collectd.dispatch_values(t)
>       return 0
>     end
>
> A very simple write function might look like:
>
>     function write(vl)
>       for i = 1, #vl.values do
>         collectd.log_info(vl.host .. '.' .. vl.plugin .. '.' .. vl.type .. ' ' .. vl.values[i])
>       end
>       return 0
>     end
>
> To register those functions with collectd:
>
>     collectd.register_read(read)     -- pass function as variable
>     collectd.register_write("write") -- pass by global-scope function name

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf),
[lua(1)](http://man.he.net/man1/lua),

# AUTHOR

The `Lua plugin` has been written by
Julien Ammous &lt;j.ammous at gmail.com>,
Florian Forster &lt;octo at collectd.org> and
Ruben Kerkhof &lt;ruben at rubenkerkhof.com>.

This manpage has been written by Ruben Kerkhof
&lt;ruben at rubenkerkhof.com>.
It is based on the [collectd-perl(5)](http://man.he.net/man5/collectd-perl) manual page by
Florian Forster &lt;octo at collectd.org> and
Sebastian Harl &lt;sh at tokkee.org>.
