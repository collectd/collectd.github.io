---
title: collectd-nagios(1)
---
# NAME

collectd-nagios - Nagios plugin for querying collectd

# SYNOPSIS

collectd-nagios **-s** _socket_ **-n** _value\_spec_ **-H** _hostname_ _\[options\]_

# DESCRIPTION

This small program is the glue between collectd and nagios. collectd collects
various performance statistics which it provides via the `unixsock plugin`,
see [collectd-unixsock(5)](./collectd-unixsock.md). This program is called by Nagios, connects to the
UNIX socket and reads the values from collectd. It then returns **OKAY**,
**WARNING** or **CRITICAL** depending on the values and the ranges provided by
Nagios.

# ARGUMENTS AND OPTIONS

The following arguments and options are required and understood by
collectd-nagios. The order of the arguments generally doesn't matter, as long
as no argument is passed more than once.

- **-s** _socket_

    Path of the UNIX socket opened by collectd's `unixsock plugin`.

- **-n** _value\_spec_

    The value to read from collectd. The argument is in the form
    `plugin[-instance]/type[-instance]`.

- **-H** _hostname_

    Hostname to query the values for.

- **-d** _data\_source_

    Each _value\_spec_ may be made of multiple "data sources". With this option you
    can select one or more data sources. To select multiple data sources simply
    specify this option again. If multiple data sources are examined they are
    handled according to the consolidation function given with the **-g** option.

- **-g** **none**_&#124;_**average**_&#124;_**sum**

    When multiple data sources are selected from a value spec, they can be handled
    differently depending on this option. The values of the following meaning:

    - **none**

        No consolidation if done and the warning and critical regions are applied to
        each value independently.

    - **average**

        The warning and critical ranges are applied to the average of all values.

    - **sum**

        The warning and critical ranges are applied to the sum of all values.

    - **percentage**

        The warning and critical ranges are applied to the ratio (in percent) of the
        first value and the sum of all values. A warning is returned if the first
        value is not defined or if all values sum up to zero.

- **-c** _range_
- **-w** _range_

    Set the critical (**-c**) and warning (**-w**) ranges. These options mostly
    follow the normal syntax of Nagios plugins. The general format is
    "_min_**:**_max_". If a value is smaller than _min_ or bigger than _max_, a
    _warning_ or _critical_ status is returned, otherwise the status is
    _success_.

    The tilde sign (**~**) can be used to explicitly specify infinity. If **~** is
    used as a _min_ value, negative infinity is used. In case of _max_, it is
    interpreted as positive infinity.

    If the first character of the _range_ is the at sign (**@**), the meaning
    of the range will be inverted. I. e. all values _within_ the range will
    yield a _warning_ or _critical_ status, while all values _outside_ the range
    will result in a _success_ status.

    _min_ (and the colon) may be omitted,
    _min_ is then assumed to be zero. If _max_ (but not the trailing colon) is
    omitted, _max_ is assumed to be positive infinity.

- **-m**

    If this option is given, "Not a Number" (NaN) is treated as _critical_. By
    default, the _none_ consolidation reports NaNs as _warning_. Other
    consolidations simply ignore NaN values.

# RETURN VALUE

As usual for Nagios plugins, this program writes a short, one line status
message to STDOUT and signals success or failure with its return value. It
exits with a return value of **0** for _success_, **1** for _warning_ and **2**
for _critical_. If the values are not available or some other error occurred,
it returns **3** for _unknown_.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md),
[collectd-unixsock(5)](./collectd-unixsock.md),
[http://nagios.org/](http://nagios.org/)

# AUTHOR

Florian Forster &lt;octo at collectd.org>
