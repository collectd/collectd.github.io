---
title: collectd-threshold(5)
---
# NAME

collectd-threshold - Documentation of collectd's _Threshold plugin_

# SYNOPSIS

    LoadPlugin "threshold"
    <Plugin "threshold">
      <Type "foo">
        WarningMin    0.00
        WarningMax 1000.00
        FailureMin    0.00
        FailureMax 1200.00
        Invert false
        Instance "bar"
      </Type>
    </Plugin>

# DESCRIPTION

Starting with version `4.3.0` _collectd_ has support for **monitoring**. By
that we mean that the values are not only stored or sent somewhere, but that
they are judged and, if a problem is recognized, acted upon. The only action
the _Threshold plugin_ takes itself is to generate and dispatch a
_notification_. Other plugins can register to receive notifications and
perform appropriate further actions.

Since systems and what you expect them to do differ a lot, you can configure
_thresholds_ for your values freely. This gives you a lot of flexibility but
also a lot of responsibility.

Every time a value is out of range, a notification is dispatched. This means
that the idle percentage of your CPU needs to be less then the configured
threshold only once for a notification to be generated. There's no such thing
as a moving average or similar - at least not now.

Also, all values that match a threshold are considered to be relevant or
"interesting". As a consequence collectd will issue a notification if they are
not received for **Timeout** iterations. The **Timeout** configuration option is
explained in section ["GLOBAL OPTIONS" in collectd.conf(5)](./collectd.conf.md). If, for example,
**Timeout** is set to "2" (the default) and some hosts sends its CPU statistics
to the server every 60 seconds, a notification will be dispatched after about
120 seconds. It may take a little longer because the timeout is checked only
once each **Interval** on the server.

When a value comes within range again or is received after it was missing, an
"OKAY-notification" is dispatched.

# CONFIGURATION

Here is a configuration example to get you started. Read below for more
information.

    LoadPlugin "threshold"
    <Plugin "threshold">
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
      
        <Type "load">
           DataSource "midterm"
           FailureMax 4
           Hits 3
           Hysteresis 3
        </Type>
      </Host>
    </Plugin>

There are basically two types of configuration statements: The `Host`,
`Plugin`, and `Type` blocks select the value for which a threshold should be
configured. The `Plugin` and `Type` blocks may be specified further using the
`Instance` option. You can combine the block by nesting the blocks, though
they must be nested in the above order, i.e. `Host` may contain either
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

- **Invert** **true**&#124;**false**

    If set to **true** the range of acceptable values is inverted, i.e. values
    between **FailureMin** and **FailureMax** (**WarningMin** and **WarningMax**) are
    not okay. Defaults to **false**.

- **Persist** **true**&#124;**false**

    Sets how often notifications are generated. If set to **true** one notification
    will be generated for each value that is out of the acceptable range. If set to
    **false** (the default) then a notification is only generated if a value is out
    of range but the previous value was okay.

    This applies to missing values, too: If set to **true** a notification about a
    missing value is generated once every **Interval** seconds. If set to **false**
    only one such notification is generated until the value appears again.

- **PersistOK** **true**&#124;**false**

    Sets how OKAY notifications act. If set to **true** one notification will be
    generated for each value that is in the acceptable range. If set to **false**
    (the default) then a notification is only generated if a value is in range but
    the previous value was not.

- **Percentage** **true**&#124;**false**

    If set to **true**, the minimum and maximum values given are interpreted as
    percentage value, relative to the other data sources. This is helpful for
    example for the "df" type, where you may want to issue a warning when less than
    5 % of the total space is available. Defaults to **false**.

- **Hits** _Value_

    Sets the number of occurrences which the threshold must be raised before to
    dispatch any notification or, in other words, the number of **Interval**s
    that the threshold must be match before dispatch any notification.

- **Hysteresis** _Value_

    Sets the hysteresis value for threshold. The hysteresis is a method to prevent
    flapping between states, until a new received value for a previously matched
    threshold down below the threshold condition (**WarningMax**, **FailureMin** or
    everything else) minus the hysteresis value, the failure (respectively warning)
    state will be keep.

- **Interesting** **true**&#124;**false**

    If set to **true** (the default), a notification with severity `FAILURE` will
    be created when a matching value list is no longer updated and purged from the
    internal cache. When this happens depends on the _interval_ of the value list
    and the global **Timeout** setting. See the **Interval** and **Timeout** settings
    in [collectd.conf(5)](./collectd.conf.md) for details. If set to **false**, this event will be
    ignored.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md)

# AUTHOR

Florian Forster &lt;octo at collectd.org>
