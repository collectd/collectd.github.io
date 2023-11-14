---
title: collectd-snmp(5)
---
# NAME

collectd-snmp - Documentation of collectd's `snmp plugin`

# SYNOPSIS

    LoadPlugin snmp
    # ...
    <Plugin snmp>
      <Data "powerplus_voltge_input">
        Table false
        Type "voltage"
        TypeInstance "input_line1"
        Scale 0.1
        Values "SNMPv2-SMI::enterprises.6050.5.4.1.1.2.1"
      </Data>
      <Data "hr_users">
        Table false
        Type "users"
        Shift -1
        Values "HOST-RESOURCES-MIB::hrSystemNumUsers.0"
      </Data>
      <Data "std_traffic">
        Table true
        Type "if_octets"
        TypeInstanceOID "IF-MIB::ifDescr"
        #FilterOID "IF-MIB::ifOperStatus"
        #FilterValues "1", "2"
        Values "IF-MIB::ifInOctets" "IF-MIB::ifOutOctets"
      </Data>
      <Data "lancom_stations_total">
          Type "counter"
          PluginInstance "stations_total"
          Table true
          Count true
          Values "SNMPv2-SMI::enterprises.2356.11.1.3.32.1.10" # SNMPv2-SMI::enterprises.lancom-systems.lcos.lcsStatus.lcsStatusWlan.lcsStatusWlanStationTableTable.lcsStatusWlanStationTableEntry.lcsStatusWlanStationTableEntryState
      </Data>
      <Data "lancom_stations_connected">
          Type "counter"
          PluginInstance "stations_connected"
          Table true
          Count true
          Values "SNMPv2-SMI::enterprises.2356.11.1.3.32.1.10" # SNMPv2-SMI::enterprises.lancom-systems.lcos.lcsStatus.lcsStatusWlan.lcsStatusWlanStationTableTable.lcsStatusWlanStationTableEntry.lcsStatusWlanStationTableEntryState
          FilterOID "SNMPv2-SMI::enterprises.2356.11.1.3.32.1.10"
          FilterValues "3" # eConnected
      </Data>

      <Host "some.switch.mydomain.org">
        Address "192.168.0.2"
        Version 1
        Community "community_string"
        Collect "std_traffic"
        Interval 120
        Timeout 10
        Retries 1
      </Host>
      <Host "some.server.mydomain.org">
        Address "192.168.0.42"
        Version 2
        Community "another_string"
        Collect "std_traffic" "hr_users"
      </Host>
      <Host "secure.router.mydomain.org">
        Address "192.168.0.7:165"
        Version 3
        SecurityLevel "authPriv"
        Username "cosmo"
        AuthProtocol "SHA"
        AuthPassphrase "setec_astronomy"
        PrivacyProtocol "AES"
        PrivacyPassphrase "too_many_secrets"
        Collect "std_traffic"
      </Host>
      <Host "some.ups.mydomain.org">
        Address "tcp:192.168.0.3"
        Version 1
        Community "more_communities"
        Collect "powerplus_voltge_input"
        Interval 300
        Timeout 5
        Retries 5
      </Host>
    </Plugin>

# DESCRIPTION

The `snmp plugin` queries other hosts using SNMP, the simple network
management protocol, and translates the value it receives to collectd's
internal format and dispatches them. Depending on the write plugins you have
loaded they may be written to disk or submitted to another instance or
whatever you configured.

Because querying a host via SNMP may produce a timeout the "complex reads"
polling method is used. The ReadThreads parameter in the main configuration
influences the number of parallel polling jobs which can be undertaken. If
you expect timeouts or some polling to take a long time, you should increase
this parameter. Note that other plugins also use the same threads.

# CONFIGURATION

Since the aim of the `snmp plugin` is to provide a generic interface to SNMP,
its configuration is not trivial and may take some time.

Since the `Net-SNMP` library is used you can use all the environment variables
that are interpreted by that package. See [snmpcmd(1)](http://man.he.net/man1/snmpcmd) for more details.

There are two types of blocks that can be contained in the
`<Plugin snmp>` block: **Data** and **Host**:

## The **Data** block

The **Data** block defines a list of values or a table of values that are to be
queried. The following options can be set:

- **Type** _type_

    collectd's type that is to be used, e. g. "if\_octets" for interface
    traffic or "users" for a user count. The types are read from the **TypesDB**
    (see [collectd.conf(5)](./collectd.conf.md)), so you may want to check for which types are
    defined. See [types.db(5)]./(./types.db.md) for a description of the format of this file.

- **Table** _true&#124;false_

    Define if this is a single list of values or a table of values. The difference
    is the following:

    When **Table** is set to **false**, the OIDs given to **Values** (see below) are
    queried using the `GET` SNMP command (see [snmpget(1)](http://man.he.net/man1/snmpget)) and transmitted to
    collectd. **One** value list is dispatched and, eventually, one file will be
    written.

    When **Table** is set to **true**, the OIDs given to **Values**, **TypeInstanceOID**,
    **PluginInstanceOID**, **HostOID** and **FilterOID** (see below) are queried using
    the `GETNEXT` SNMP command until the subtree is left. After all the lists
    (think: all columns of the table) have been read, either (**Count** set to **false**)
    **several** value sets will be dispatched and, eventually, several files will be
    written, or (**Count** set to **true**) one single value will be dispatched. If you
    configure a **Type** (see above) which needs more than one data source (for
    example `if_octets` which needs `rx` and `tx`) you will need to specify more
    than one (two, in the example case) OIDs with the **Values** option and can't use
    the **Count** option. This has nothing to do with the **Table** setting.

    For example, if you want to query the number of users on a system, you can use
    `HOST-RESOURCES-MIB::hrSystemNumUsers.0`. This is one value and belongs to one
    value list, therefore **Table** must be set to **false**. Please note that, in
    this case, you have to include the sequence number (zero in this case) in the
    OID.

    Counter example: If you want to query the interface table provided by the
    `IF-MIB`, e. g. the bytes transmitted. There are potentially many
    interfaces, so you will want to set **Table** to **true**. Because the
    `if_octets` type needs two values, received and transmitted bytes, you need to
    specify two OIDs in the **Values** setting, in this case likely
    `IF-MIB::ifHCInOctets` and `IF-MIB::ifHCOutOctets`. But, this is because of
    the **Type** setting, not the **Table** setting.

    Since the semantic of **Instance** and **Values** depends on this setting you
    need to set it before setting them. Doing vice versa will result in undefined
    behavior.

- **Plugin** _Plugin_

    Use _Plugin_ as the plugin name of the values that are dispatched.
    Defaults to `snmp`.

- **PluginInstance** _Instance_

    Sets the plugin-instance of the values that are dispatched to _Instance_ value.

    When **Table** is set to _true_ and **PluginInstanceOID** is set then this option
    has no effect.

    Defaults to an empty string.

- **TypeInstance** _Instance_

    Sets the type-instance of the values that are dispatched to _Instance_ value.

    When **Table** is set to _true_ and **TypeInstanceOID** is set then this option
    has no effect.

    Defaults to an empty string.

- **TypeInstanceOID** _OID_
- **PluginInstanceOID** _OID_
- **HostOID** _OID_

    If **Table** is set to _true_, _OID_ is interpreted as an SNMP-prefix that will
    return a list of values. Those values are then used as the actual type-instance,
    plugin-instance or host of dispatched metrics. An example would be the
    `IF-MIB::ifDescr` subtree. [variables(5)](http://man.he.net/man5/variables) from the SNMP distribution describes
    the format of OIDs. When option is set to empty string, then "SUBID" will be used
    as the value.

    Prefix may be set for values with use of appropriate **TypeInstancePrefix**,
    **PluginInstancePrefix** and **HostPrefix** options.

    When **Table** is set to _false_ or **Count** is set to _true_, these options
    have no effect.

    Defaults: When no one of these options is configured explicitly,
    **TypeInstanceOID** defaults to an empty string.

- **TypeInstancePrefix**
- **PluginInstancePrefix**
- **HostPrefix**

    These options are intented to be used together with **TypeInstanceOID**,
    **PluginInstanceOID** and **HostOID** respectively.

    If set, _String_ is preprended to values received by querying the agent.

    When **Table** is set to _false_ or **Count** is set to _true_, these options
    have no effect.

    The `UPS-MIB` is an example where you need this setting: It has voltages of
    the inlets, outlets and the battery of an UPS. However, it doesn't provide a
    descriptive column for these voltages. In this case having 1, 2, ... as
    instances is not enough, because the inlet voltages and outlet voltages may
    both have the subids 1, 2, ... You can use this setting to distinguish
    between the different voltages.

- **Instance** _Instance_

    Attention: this option exists for backwards compatibility only and will be
    removed in next major release. Please use **TypeInstance** / **TypeInstanceOID**
    instead.

    The meaning of this setting depends on whether **Table** is set to _true_ or
    _false_.

    If **Table** is set to _true_, option behaves as **TypeInstanceOID**.
    If **Table** is set to _false_, option behaves as **TypeInstance**.

    Note what **Table** option must be set before setting **Instance**.

- **InstancePrefix** _String_

    Attention: this option exists for backwards compatibility only and will be
    removed in next major release. Please use **TypeInstancePrefix** instead.

- **Values** _OID_ \[_OID_ ...\]

    Configures the values to be queried from the SNMP host. The meaning slightly
    changes with the **Table** setting. [variables(5)](http://man.he.net/man5/variables) from the SNMP distribution
    describes the format of OIDs.

    If **Table** is set to _true_, each _OID_ must be the prefix of all the
    values to query, e. g. `IF-MIB::ifInOctets` for all the counters of
    incoming traffic. This subtree is walked (using `GETNEXT`) until a value from
    outside the subtree is returned.

    If **Table** is set to _false_, each _OID_ must be the OID of exactly one
    value, e. g. `IF-MIB::ifInOctets.3` for the third counter of incoming
    traffic.

- **Count** _true&#124;false_

    Instead of dispatching one or multiple values per Table entry containing the
    _OID_(s) given in the **Values** option, just dispatch a single count giving the
    number of entries that would have been dispatched. This is especially useful when
    combined with the filtering options (see below) to count the number of entries in
    a Table matching certain criteria.

    When **Table** is set to _false_, this option has no effect.

- **Scale** _Value_

    The gauge-values returned by the SNMP-agent are multiplied by _Value_.  This
    is useful when values are transferred as a fixed point real number. For example,
    thermometers may transfer **243** but actually mean **24.3**, so you can specify
    a scale value of **0.1** to correct this. The default value is, of course,
    **1.0**.

    This value is not applied to counter-values.

- **Shift** _Value_

    _Value_ is added to gauge-values returned by the SNMP-agent after they have
    been multiplied by any **Scale** value. If, for example, a thermometer returns
    degrees Kelvin you could specify a shift of **273.15** here to store values in
    degrees Celsius. The default value is, of course, **0.0**.

    This value is not applied to counter-values.

- **Ignore** _Value_ \[, _Value_ ...\]

    The ignore values allows one to ignore TypeInstances based on their name and
    the patterns specified by the various values you've entered. The match is a
    glob-type shell matching.

    When **Table** is set to _false_ then this option has no effect.

- **InvertMatch** _true&#124;false(default)_

    The invertmatch value should be use in combination of the Ignore option.
    It changes the behaviour of the Ignore option, from a blocklist behaviour
    when InvertMatch is set to false, to a allowlist when specified to true.

- **FilterOID** _OID_
- **FilterValues** _Value_ \[, _Value_ ...\]
- **FilterIgnoreSelected** _true&#124;false(default)_

    When **Table** is set to _true_, these options allow to configure filtering
    based on MIB values.

    The **FilterOID** declares _OID_ to fill table column with values.
    The **FilterValues** declares values list to do match. Whether table row will be
    collected or ignored depends on the **FilterIgnoreSelected** setting.
    As with other plugins that use the daemon's ignorelist functionality, a string
    that starts and ends with a slash is interpreted as a regular expression.

    If no selection is configured at all, **all** table rows are selected.

    When **Table** is set to _false_ then these options has no effect.

    See **Table** and `/"IGNORELISTS"` for details.

## The Host block

The **Host** block defines which hosts to query, which SNMP community and
version to use and which of the defined **Data** to query.

The argument passed to the **Host** block is used as the hostname in the data
stored by collectd.

- **Address** _IP-Address_&#124;_Hostname_

    Set the address to connect to. Address may include transport specifier and/or
    port number.

- **Version** **1**&#124;**2**&#124;**3**

    Set the SNMP version to use. When giving **2** version `2c` is actually used.

- **Community** _Community_

    Pass _Community_ to the host. (Ignored for SNMPv3).

- **Username** _Username_

    Sets the _Username_ to use for SNMPv3 security.

- **SecurityLevel** _authPriv_&#124;_authNoPriv_&#124;_noAuthNoPriv_

    Selects the security level for SNMPv3 security.

- **Context** _Context_

    Sets the _Context_ for SNMPv3 security.

- **AuthProtocol** _MD5_&#124;_SHA_

    Selects the authentication protocol for SNMPv3 security.

- **AuthPassphrase** _Passphrase_

    Sets the authentication passphrase for SNMPv3 security.

- **PrivacyProtocol** _AES_&#124;_DES_

    Selects the privacy (encryption) protocol for SNMPv3 security.

- **PrivacyPassphrase** _Passphrase_

    Sets the privacy (encryption) passphrase for SNMPv3 security.

- **Collect** _Data_ \[_Data_ ...\]

    Defines which values to collect. _Data_ refers to one of the **Data** block
    above. Since the config file is read top-down you need to define the data
    before using it here.

- **Interval** _Seconds_

    Collect data from this host every _Seconds_ seconds. This option is meant for
    devices with not much CPU power, e. g. network equipment such as
    switches, embedded devices, rack monitoring systems and so on. Since the
    **Step** of generated RRD files depends on this setting it's wise to select a
    reasonable value once and never change it.

- **Timeout** _Seconds_

    How long to wait for a response. The `Net-SNMP` library default is 1 second.

- **Retries** _Integer_

    The number of times that a query should be retried after the Timeout expires.
    The `Net-SNMP` library default is 5.

- **BulkSize** _Integer_

    Configures the size of SNMP bulk transfers. The default is 0, which disables bulk transfers altogether.

# SEE ALSO

[collectd(1)](./collectd.md),
[collectd.conf(5)](./collectd.conf.md),
[snmpget(1)](http://man.he.net/man1/snmpget),
[snmpgetnext(1)](http://man.he.net/man1/snmpgetnext),
[variables(5)](http://man.he.net/man5/variables),
[unix(7)](http://man.he.net/man7/unix)

# AUTHORS

Florian Forster &lt;octo@collectd.org>
Michael Pilat &lt;mike@mikepilat.com>
