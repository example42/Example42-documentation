Well, maybe these questions are not so "frequently" asked, but they are ones I would like to be asked in order to give a general idea about the Example42 Puppet Modules.

## What are Example42 Puppet Modules, first of all?
It's a set of Puppet modules that can be used to configure and manage via Puppet many different applications.
They are released under the Apache 2 licence and are freely usable, changeable and distributable.
The official site is http://www.example42.com.
Code is available on GitHub.
Documentation is here and in each module's README and class files. 

## Why should I use these modules?
There are a lot of good modules around, and a lot of not so good ones.
Many are done with a "work for me" approach and most of them have an heterogeneous set of parameters.
Example42 modules have been designed from scratch to have true and full reusability: you should be able to use them and adapt them to your needs without changing anything.
That's the main and most important feature of the modules, other features (not so common in modules are): decommissioning support (you can remove what the module installs), multi OS coverage (it's very easy to add support for a new OS), optional automatic monitoring and firewalling (what is installed by the module is automatically monitored / firewalled using different tools) and a coherent set of common parameters which makes it easy to use a new module out of the box.
They have also documentation in PuppetDoc format, Rspec tests and Puppet Lint coverage.
Finally, these modules are used (and contributed) by various people (they are among the most popular Puppet modules on GitHub).

## I have seen some Example42 modules on the Puppet Forge, should I use them?
NO, better to get them from GitHub. On the Puppet Forge are uploaded only a small and not updated set of Example42 Puppet modules.
This is due to the fact that, at the moment, uploading a module to the Forge is still a manual and cumbersome procedure.
This is probably going to change soon and when it will be possible to automate the upload (or when there'll be GitHub integration), the Example42 modules will be definitively be on the Puppet Forge.

## Should I use the whole module set? Can I just cherry pick the module(s) I need.
Sure you can. Even if provided as a full set of modules, it's possible to use just a few of them.
Actually particular care has been taken in trying to make these modules interoperable with others:

- They only require one common module: 'puppi' 

- They optionally require other modules if the relevant features are used: 'monitor' and 'firewall' (and the relevant specific tool modules, like nagios, icinga, iptables...)

In many cases, on the most recent developments, when a module requires packages or resources from other Example42 modules, they are placed in a dedicated subclass (foo::prerequisite) which is included by default but can be disabled (setting the parameter install_prerequisites to false) so that you can provide the same resources with other modules.

## What's Puppi? I don't want it!
Well, you must cope with it... but first of all be aware that you don't need to install Puppi on your systems to use the modules, you just need to have it in your modulepath so that the external libraries it provides are used in the modules. Basically Puppi provides some facts and most importantly, some functions, which are used by the Example42 modules, that's the part that is required by all the modules.
Given this, you might also give a try to Puppi itself and install it on your systems (include puppi):
Puppi is a Puppet Module that installs on your system the puppi (shell) command and its whole configuration environment.

The puppi command has different actions that can be used to perform different operations, from deployment of applications to review of the system status.
You can find more information about Puppi on its README, or in this article.

## What are the monitor and firewall modules?
They are so called meta-modules, they contain some generic defines (monitor::port, monitor::url... ) that configure the relevant resources to monitor/firewall ports, services urls, or whatever using the preferred tool.
All Example42 modules have built in integration to monitor or firewall the services they provide: in the module is written WHAT to monitor/firewall, not HOW to do it.
The HOW is managed by the monitor and firewall modules, the WHAT is expressed by defines like monitor::port { 'apache': port => 80 ... }.
Note that by default these features are not enabled on the modules, to enable them you have to set to true the parameter(s) 'monitor' and/or 'firewall' and then specify what monitor/firewall tool to use.
For example:

    class { 'openssh':
      monitor => true,
      monitor_tool => [ 'puppi' , 'nagios' ],
    }

## What's this params_lookup thing I see everywhere?
Params_lookup is a Puppet function (provided by the Puppi module, and this is the main reason why all the modules have the puppi dependency) that is used on all the parameters of the MAIN class of each module. This function allows you to specify the value of the relevant parameter in different ways: on Hiera, if present, on a top scope variable, or the params class of the module, where default values for each parameter are set.
Basically it does something very similar to what the Data Bindings do on Puppet 3: an automatic lookup for the parameter value, when not explicitely set. There are some differenced though:

- Params_lookup was introduced some months before the release of Puppet 3 and works also on Puppet 2.6 (and later)

- Params_lookup besides Hiera looks up at top scope variables (the one you can set via facts, an enc or on manifests/site.pp) 

- The lookup on Hiera is slightly different: for a parameter called, for example, 'ntpserver' on a ntp module, Data Bindings look for hiera(ntp::ntpserver), Params_lookup look for hiera(ntp_ntpserver)
- Params_lookup can also look for a general variables, when the 'global' parameter is defined. For example where you see something like:

        class apache ( [...]
          $monitor = params_lookup( 'monitor' , 'global' ),

the params_lookup function (which is used to retrive the default value if the parameter is not explicitly declared) looks with this order (first match):

- If Hiera is present: hiera(apache_monitor)

- If Hiera is present: hiera(monitor)

- Top scope Variable: $::apache_monitor

- Top scope Variable: $::monitor

- Default value defined in $apache::params::monitor

This allows you to set site wide parameters (for example to enable monitoring for all the modules) and make module specific exceptions.

## What are the modules templates?
Example42 modules are written in a way that makes it quick and easy to generate a new module from an existing template (blueprint).
The script module_clone.sh can be used to generate a new module from an existing module or a template.
There are different templates available for different kind on modules and some research is always done to explore different modules design patterns.

## NextGen, OldGen... WTF??
If you look at the GitHub you will find a pletora of modules and you might wonder how to cope with them.
Currently there are 2 generations of Example42 Puppet modules.

- The "Old" generation (1.0) was done before the release of Puppet 2.6 and contains modules that are compatible with older Puppet versions.

- The "Next" generation (2.0) does an heavy usage of parametrized classes and is compatible only with Puppet 2.6 and later. Each nextgen module has its own git repo, and all the nextgen modules are collected as submodules on https://github.com/example42/puppet-modules-nextgen.

The main (and most followed) repository is https://github.com/example42/puppet-modules which contains both old and nextgen modules (the old ones are in the directories present in the same repo, the nextgen ones are all git submodules). This puppet-modules repository is going to progressively (on a job-driven basis described below) replace the old modules with the nextgen ones.
My personal recommendation is to use only NextGen modules.

# How do I install and update the modules?
You can pick single modules git cloning them and their dependencies (give a look at the Modulefile and remember that puppi is required, and monitor/firewall are needed only if you use the relative features).

You can install the whole modules set via git:
git clone --recursive https://github.com/example42/puppet-modules-nextgen.git /etc/puppet/modules
you can place them in /etc/puppet/modules, /usr/share/puppet/modules or any directory you've included in your PuppetMaster's modulepath.
I suggest to place other modules (the ones picked from other sources or your "site" module) in a different directory, so that you can easily update the Example42 modules.
To update the whole set you can execute the script, from the modules directory:

    Example42-tools/sync.sh

which basically just executes these commands:

    git pull origin master
    git submodule sync
    git submodule init
    git submodule update
    git submodule foreach git checkout master
    git submodule foreach git pull origin master

DO NOT DO THIS on production environment (well you can (I did that too at times), but don't complain here if something goes wrong). Even if particular care is given to backwards compatibility, some changes on the module may not have the effects you want (if only for the restart of a service because some "spaces" have been added in a configuration file).

# How can I contribute to the modules?
Believe it or not most part of the Example42 modules is written by a single person, me, Alessandro Franceschi, who does it for fun and profit mostly in his spare time.
The modules are supposed to be used out of the box, without the need to change anything in them: if you find yourself modifying them either they have bugs or missing features (and a Pull Request on GitHub is always welcomed) or you are using them in the wrong way (and feel free to ask on the Google Group for help).
The amount of features requests or issues on Github is growing and development is mostly done on an job-driven way: I develop features needed for the customer I'm working for.

If you want to contribute to the modules (whose licence is open and will remain open) you can:

- Issue bugs on GitHub.

- Help people on the Example42 Puppet modules Google Group, replying to questions.

- Write your own patches/enahancements and make a pull request on GitHub.

- Sponsor the development of new modules or the enhancement of the existing ones.