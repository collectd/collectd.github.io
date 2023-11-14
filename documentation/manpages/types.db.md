---
title: types.db(5)
---
# NAME

types.db - Data-set specifications for the system statistics collection daemon
**collectd**

# SYNOPSIS

    bitrate    value:GAUGE:0:4294967295
    counter    value:COUNTER:U:U
    if_octets  rx:COUNTER:0:4294967295, tx:COUNTER:0:4294967295

# DESCRIPTION

The `types.db` file contains collectd's metric type specifications. Each line
describes one metric type, which is called "data set" in collectd. Each line
consists of two or more fields delimited by spaces and/or horizontal tabs.

For example, the following defines two data sets, "bytes" and "total\_bytes".

    bytes        value:GAUGE:0:U
    total_bytes  value:DERIVE:0:U

The first field defines the name of the data set. By convention, data set names
use lower-case alphanumeric characters and underscores (`_`) only. Also by
convention, if a metric makes sense both as a cumulative metric (e.g.
`DERIVE`) _and_ a non-cumulative metric (i.e. `GAUGE`), the cumulative
metric gets a `total_` prefix. For example, `bytes` is a `GAUGE` and
`total_bytes` is a `DERIVE`.

The second and each following field defines a named metric value, called "data
source".  New data sets with multiple data sources are strongly discouraged.
Each field is a colon-separated tuple of the data source name, value type,
minimum and maximum values: _ds-name_**:**_ds-type_**:**_min_**:**_max_.

- _ds-name_ is, by convention, a lower-case alphanumeric string. If the data set
contains a single data source, it is called "value" by convention. Data source
names must be unique within a data set.
- _ds-type_ may be **DERIVE**, **GAUGE**, or **COUNTER**. For historic reasons a
type called **ABSOLUTE** is also supported, but its use is strongly discouraged,
and it should not be used for new metric type definitions.
- _min_ and _max_ define the range of valid values this data source. Either or
both may be unbounded, which is specified by providing `U` instead of a
number. For cumulative metric values, _min_ and _max_ apply to the value's
rate, not the raw cumulative metric value.

# FILES

The location of the types.db file is defined by the **TypesDB** configuration
option (see [collectd.conf(5)](./collectd.conf.md)). It defaults to collectd's shared data
directory, i. e. `_prefix_/share/collectd/`.

# CUSTOM TYPES

If you want to specify custom types, you should do so by specifying a custom
file in addition to the default one (see [FILES](https://metacpan.org/pod/FILES)) above. You can do that by
having multiple **TypesDB** statements in your configuration file or by
specifying more than one file in one line.

For example:

    TypesDB "/opt/collectd/share/collectd/types.db"
    TypesDB "/opt/collectd/etc/types.db.custom"

**Note**: Make sure to make this file available on all systems if you're
sending values over the network.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md),
[rrdcreate(1)](http://man.he.net/man1/rrdcreate)

# AUTHOR

**collectd** has been written by Florian Forster
&lt;octo at collectd.org>.

This manpage has been written by Sebastian Harl
&lt;sh at tokkee.org>.
