# Use Cases: Example42 modules and Foreman Integration

There are different approaches you can follow to integrate Example42 modules with Foreman (or generally with any other ENC) and they are related to how Example42 modules accept parameters:

- Via direct class declaration, with all the needed parameters explicitely set when declaring the class:

        class { 'openssh':
          template => 'site/openssh/sshd.config.erb',
        }




- Via Hiera using key names like $modulename_$parameter or (default behaviour on Puppet3) $modulename::$parameter

        ---
          openssh_template: 'site/openssh/sshd.config.erb'
          
        ---  
          openssh::template: 'site/openssh/sshd.config.erb'


- Via Top Scope variables

        Set openssh_template = site/openssh/sshd.config.erb in Foreman parameters


## Using Example42 modules

Usage of Example42 modules in Foreman is not different from the one you can have with other modules, just just have more options on where to place your data.

On Foreman therefore you have to:

-  Clone Example42 modules in your PuppetMaster's modulepath

        git clone --recursive https://github.com/example42/puppet-modules-nextgen.git /etc/puppet/modules
        
- Have a Foreman-Proxy running on the PuppetMaster (this is needed for the next step)

- Import all the classes in Foreman (Menu: More / Configuration / Puppet Classes / Import from <puppetmaster ). This may take a while, because Foreman parses and saves all the parameters of all the classes. This step, strictly speaking, is not required but it allows you directly and quicker inclusion of the available classes.


## Alternative usage patterns

At this point you have different alternatives on where to place your data:

- Once all the classes are imported in Foreman you an manage directly their parameters using Smart Variables to set them. There parameters are used in parametrized classes declarations (via the ENC).

- You can use Foreman to include classes and set "normal" variables (as the ones you can set per HostGroups/Node/OperatingSystem... in the Parameters tab). These parameters appear as top scope variables.

- You can use Foreman to include classes and place on Hiera all your parameters

- You can use Foreman to include classes and place your variables in Foreman and/or in your custom site module (where you already have to place your local files and templates).

There are some variations on these patterns, which basically relate to how much information you want to place in Foreman GUI and how much in external files (either hiera or custom modules), but they somehow depend on personal needs and choices.


