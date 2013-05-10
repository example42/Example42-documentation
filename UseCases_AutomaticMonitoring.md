# Use Cases: Automatic monitoring with Nagios , Icinga and Puppi

Some sample usage patterns for enabling automatic monitoring with Example42 modules.

## Basic usage
To enable monitoring for all the (example42) modules you install, by default, you have to set these Top Scope or Hiera variables.

    # To enable monitoring (equivalent to hiera('monitor'))
    $::monitor = true
    
    # To define which tools to use by default (equivalent to hiera('monitor_tool'))
    # Can be an array
    $::monitor_tool = [ 'puppi' , 'nagios' ]

When set as monitor_tool, puppi is installed on the system and provides the handy `puppi check` shell command which is based on the same nagios plugins required by Nagios monitoring (currently only via nrpe, would like to develop check_mk or other integrations in the future)

Nrpe therefone should stay on all the hosts to be monitored. You can define your Nagios servers allowed_hosts.
    
    # Place this in a "general" class, used by all your nodes
    class { 'nrpe':
      allowed_hosts => [ '10.42.42.11' , '10.42.42.16' , $::ipaddress, '127.0.0.1' ],
    }

Then on the nagios server you just have to include the nagios class (**storeconfigs** MUST be enabled):

    class { 'nagios':
    }

If your Nagios server is on **Ubuntu** or **Debian** you have to fix the path where automatic nagios configurations are exported by clients to the Nagios server. This is a badly documented and not perfect approach and it requires the setting of a Top Scope variable (either via your ENV or in /etc/puppet/manifests/site.pp)

    $::nagios_customconfigdir = '/etc/nagios3/auto.d' # Default is /etc/nagios/auto.d

That's all. Given these settings you have monitoring on Nagios and via puppi check of all the Example42 modules you use (generally process and listening port is checked).

## Other cases

In some situations I've more complex and customized setups.

A feature of the nagios (and icinga) module I'm quite proud of is the automatic sharding of nagios checks on different servers based on custom logic.

For example, if you use a variable called $::env to define the operational environment of your nodes, you can have a separated Nagios server for each environment. Just set at top scope the $nagios_grouplogic variable:

    $::nagios_grouplogic = 'env'

You can do something similar to have a nagios server for datacenter (as identified by the variable $::dc)

    $::nagios_grouplogic = 'dc'

You'll probably need to add custom checks, this can be in different ways.

One is to gather your additional resources in a dedicated class.

Another is the defining of a custom source when plain Nagios configuration files are retrieved and deployed as is: 

    class { 'nagios':
      my_class         => 'example42::my_nagios',
      extra_source_dir => "puppet:///modules/example42/nagios/${site}/${env}/",
    }

In a case I had to disable Nrpe checks over ssl with:

    class { 'nagios':
      use_ssl  => false,
    }
    

## Using Icinga

Very similar to the nagios module is the icinga one, it adds some features (more or less well tested…).

To use it set globally:

    $::monitor_tool = [ 'puppi' , 'icinga' ]

then keep the nrpe class on all the monitored clients and icinga on the monitoring server: 

    class { 'icinga':
      enable_icingaweb       => true,
      enable_idoutils        => true,
      db_password_idoutils   => '1c1ng41d0',
      db_password_icingaweb  => '1c1ng4',
      source_dir_icingaweb   => 'puppet:///modules/example42/icinga/icingaweb',
      source_dir_extra       => 'puppet:///modules/example42/icinga/extra',
      source_dir_purge_extra => false,
    }

## Adding custom checks

Besides the checks that are automatically added for the modules you that you install on the nodes you can easily add custom checks that use the monitor meta-module defines.

For example you can define in your site module a class like:

    class example42::monitor::role_mywebservice
    
      monitor::port { "Port_Remote_SMS_Gateway":          
        protocol    => 'tcp',
        port        => '7780',
        target      => "sms.${::domain}",
        enable      => true,
        checksource => 'local',
        tool        => $::monitor_tool,
      }

      monitor::url { "Url_Application_OK":
        url         => "http://mywebservice.${::domain/checks/general",
        port        => '80',
        target      => $::fqdn,
        pattern     => 'All Systems OK',
        enable      => true,
        tool        => $::monitor_tool,
      }
    }
 
this adds a remote port check and an url check based on a given pattern to your monitor tools (puppi, nagios, etc.).

I find these url and (remote) ports checks particularly useful with **puppi check** when I want to quickly verify the server components status after an application deploy or during a failure.
 
## Conclusion 

A note for conclusion.

Both the Nagios and Icinga modules are quite complex and not too much organic.

They have a lot of features and try to adapt to different OS and use cases, but have several (too many) parameters not well documented.

Some cleanup, more tests, and better documentation are definitively needed.

Do you use these modules?

Can you manage to do that without changing the nagios/icinga modules (that's the whole point behind modules' reusability)?

Opinions, usage samples, questions and improvements are welcomed.


