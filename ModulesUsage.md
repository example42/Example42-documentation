# MODULES USAGE

The NextGen Example42 Puppet modules share a common layout that makes it possible to use them with a coherent and standard (at least inside the same module set) appoach.

All the new modules have a set of standard arguments to manage common tasks and, of course, some module specific ones.

Here are the common options and usage patterns that you can find generally on all the NextGen modules.

## ALTERNATIVE OPTIONS TO PROVIDE DATA
In the NextGen Example42 modules you have 3 different ways to provide variables to a module:

* With the old style "Set variables and include class" pattern:

        $openssh_template = 'example42/openssh/openssh.conf.erb'
        include openssh

* As a parametrized class:

        class { 'openssh':
          template => 'example42/openssh/openssh.conf.erb',
        }

* Using Hiera: all the module params have an automatic Hiera lookup, if Hiera is available.

You can even, under some degrees, mix these patterns.

You can for example set general top scope variables that affect all your parametrized classes:

        $puppi = true
        $monitor = true
        $monitor_tool = [ 'nagios' , 'munin' , 'puppi' ]
        class { 'openssh':
          template => 'example42/openssh/openssh.conf.erb',
        }

The above example has the same effect of:

        class { 'openssh':
          template     => 'example42/openssh/openssh.conf.erb',
          puppi        => true,
          monitor      => true,
          monitor_tool => [ 'nagios' , 'munin' , 'puppi' ],
        }

Note that if you use the "Set variables and include class" pattern you can define variables only at the top level scope or in a ENC (External Node Classifer) like Puppet Dashboard, Puppet Enterprise Console or The Foreman.

Below you have an overview of the most important module's parameters (you can mix and aggregate them).

The examples use parametrized classes, but for all the parameters you can set a $openssh_ top scope variable or Hiera lookup.

For example, the variable "$openssh_absent" is equivant to the "absent =>" parameter or hiera('openssh_absent').

## THE MAGIC OF PARAMS_LOOKUP
The described behaviour is provided by the function params_lookup used for each module's argument.
This function is provided by the puppi module, which is required by every Example42 module.
Note that you are not forced to use (include) Puppi itself to use Example42 modules, you just need it to autoload its functions (in this case consider it as a Example42 stdlib).

Params_lookup has this behaviour, for each parameter passed to a class or defined where is used:

- If the argument is explicitely set, while calling the class, that's the value used (that's standard Puppet behaviour). For example: 

        class { "openssh":
          monitor_tool => [ "nagios" , "munin" , "puppi" ],
        }

- If no argument is explicitely defined an automatic lookup is made with this precedence (first matched value is returned by the function):

- If Hiera exists, an Hiera lookup is done to a variable with the same name and the class name as prefix:

       hiera('openssh_monitor_tool')

- If Hiera exists and the params_lookup has the 'global' option set, an Hiera lookup is done on a general variable with the same name:

       hiera('monitor_tool')

- If Hiera does not exist or doesn't return any value the lookup is done on top scope variables.
  First a module specific top scope variable is looked for:

       ::openssh_monitor_tool

- If nothing is found , and if the 'global' option is set, a lookup is done directlty wuth the parameter name:

       ::monitor_tool

- Finally if the module's user has not set the variable in any way, the function looks for the default value (or the right value for different operating systems) in the params class of the same module:

       ::openssh::params::monitor_tool

This is done for each argument provided by the main module class. Some of these arguments are related to the relevant application setup on different operating system, you generally have not to change them (BUT you still can, if needed): package, service, config_file... and so on.
Other arguments affect the module's behaviour and how you can customize it without modifying it. Let's see the most important ones.


## USAGE - Basic management
* Install openssh with default settings

        class { 'openssh': }

* Disable openssh service. This disables the service at boot time and stops it if is running.

        class { 'openssh':
          disable => true
        }

* Disable openssh service at boot time, but don't stop if is running.

        class { 'openssh':
          disableboot => true
        }

* Remove openssh package. This removes the package and the files managed by the module.

        class { 'openssh':
          absent => true
        }

* Enable auditing without without making changes on existing openssh configuration files. Use it to test changes before applying them.

        class { 'openssh':
          audit_only => true
        }

* Do not automatically restart a service when the relevant configuration file / dir is changed. This can be useful in some specific cases (for example to avoid an automatic puppetmaster service restart when puppet.conf changes).

        class { 'openssh':
          service_autorestart => false
        }

* Provide a specific version of the main class package. This is actually the value passed to the ensure => argument for the main module's package (if absent => is not true ) 

        class { 'openssh':
          version => '1:3.8.1p1-11',
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file. Use this parameter to manage the configuration file content with static files (eventually using an array to manage specific cases). This parameter can cohexist with the template => one.

        class { 'openssh':
          source => [ "puppet:///modules/lab42/openssh/openssh.conf-${hostname}" , "puppet:///modules/lab42/openssh/openssh.conf" ], 
        }


* Use custom source directory for the whole configuration dir. This is useful if you want to store on the Puppetmaster the whole content of a configuration directory (or also only the file you want to change, if you keep source_dir_purge => false )

        class { 'openssh':
          source_dir       => 'puppet:///modules/lab42/openssh/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Use this to populate the configuration file with a template. Alternative to the source => option.

        class { 'openssh':
          template => 'example42/openssh/openssh.conf.erb',      
        }

* Define custom options that can be used in a custom template without the need to add parameters to the openssh class. This is generally an hash of value/key pairs.

        class { 'openssh':
          template => 'example42/openssh/openssh.conf.erb',    
          options  => {
            'LogLevel' => 'DEBUG',
            'UsePAM'   => 'yes',
          },
        }

  The Hash values can be used in your custom templates with the **options_lookup** function, which can also set a default value if it's not found the defined key:

        LogLevel <%= scope.function_options_lookup(['LogLevel','INFO']) %>
        UsePAM <%= scope.function_options_lookup(['UsePAM','no']) %>


* Automatically include a custom subclass. This is useful if you want to add extra resources to the module, without changing it. The included class can inherit or not the main class (avoid inheritance if you don't need to override parameters of existing resources).

        class { 'openssh':
          my_class => 'example42::myopenssh',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default). Note that this option requires the usage of Example42 puppi module and actually installs puppi on the target host. Even if the puppi module is required by all the other modules (for some of the functions it provides), you are not forced to actually install/activate it.

        class { 'openssh': 
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with a puppi::helper define ) to customize the output of puppi commands 

        class { 'openssh':
          puppi        => true,
          puppi_helper => 'myhelper', 
        }

* Activate automatic monitoring (recommended, but disabled by default). This option requires the usage of Example42 monitor and relevant monitor tools modules. With the monitor_tool array you can define which tools to use to monitor the resources provided by the module. 

        class { 'openssh':
          monitor      => true,
          monitor_tool => [ 'nagios' , 'monit' , 'munin' ],
        }

* Activate automatic firewalling. This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { 'openssh':       
          firewall      => true,
          firewall_tool => 'iptables',
          firewall_src  => '10.42.0.0/24',
          firewall_dst  => $ipaddress_eth0,
        }


