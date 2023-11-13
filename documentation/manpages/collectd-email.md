# NAME

collectd-email - Documentation of collectd's `email plugin`

# SYNOPSIS

    # See collectd.conf(5)
    LoadPlugin email
    # ...
    <Plugin email>
      SocketGroup "collectd"
      SocketPerms "0770"
      MaxConns 5
    </Plugin>

# DESCRIPTION

The `email plugin` opens an UNIX-socket over which one can submit email
statistics, such as the number of "ham", "spam", "virus", etc. mails
received/handled, spam scores and matched spam checks.

This plugin is intended to be used with the
[Mail::SpamAssassin::Plugin::Collectd](https://metacpan.org/pod/Mail::SpamAssassin::Plugin::Collectd) SpamAssassin-plugin which is included
in `contrib/`, but is of course not limited to that use.

# OPERATION

This plugin collects data indirectly by providing a UNIX-socket that external
programs can connect to. A simple line based protocol is used to communicate
with the plugin:

- E-Mail type (e.g. "ham", "spam", "virus", ...) and size (bytes):

        e:<type>:<size>

    If `size` is less than or equal to zero, `size` is ignored.

- Spam score:

        s:<value>

- Successful spam checks (e.g. "BAYES\_99", "SUBJECT\_DRUG\_GAP\_C", ...):

        c:<type1>[,<type2>,...]

    Each line is limited to 256 characters (including the newline character). 
    Longer lines will be ignored.

# SEE ALSO

[collectd(1)](http://man.he.net/man1/collectd),
[collectd.conf(5)](http://man.he.net/man5/collectd.conf)

# AUTHOR

The `email plugin` has been written by Sebastian Harl &lt;sh at tokkee.org>.

The SpamAssassin-plugin has been written by Alexander Wirt &lt;formorer at formorer.de>.

This manpage has been written by Florian Forster &lt;octo at collectd.org>.
