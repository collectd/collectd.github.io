---
title: collectd-tg(1)
---
# NAME

collectd-tg - Traffic generator for collectd.

# SYNOPSIS

collectd-tg **-n** _num\_vl_ **-H** _num\_hosts_ **-p** _num\_plugins_ **-i** _interval_ **-d** _dest_ **-D** _dport_

# DESCRIPTION

**collectd-tg** generates bogus _collectd_ network traffic. While host, plugin
and values are generated randomly, the generated traffic tries to mimic "real"
traffic as closely as possible.

# ARGUMENTS AND OPTIONS

The following options are understood by _collectd-tg_. The order of the
arguments generally doesn't matter, as long as no argument is passed more than
once.

- **-n** _num\_vl_

    Sets the number of unique _value lists_ (VL) to generate. Defaults to 10000.

- **-H** _num\_hosts_

    Sets the number of unique hosts to simulate. Defaults to 1000.

- **-p** _num\_plugins_

    Sets the number of unique plugins to simulate. Defaults to 20.

- **-i** _interval_

    Sets the interval in which each _value list_ is dispatched. Defaults to 10.0
    seconds.

- **-d** _dest_

    Sets the destination to which to send the generated network traffic. Defaults
    to the IPv6 multicast address, `ff18::efc0:4a42`.

- **-D** _dport_

    Sets the destination port or service to which to send the generated network
    traffic. Defaults to _collectd's_ default port, `25826`.

- **-h**

    Print usage summary.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md)

# AUTHOR

Florian Forster &lt;octo at collectd.org>
