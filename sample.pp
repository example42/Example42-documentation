# Just some sample code used in presentations on Example42 modules
# This sample class is not intended to be used 'as is', it provides
# some code usage samples 

class sample {

### Data Separation alternatives
# Set (Top Scope/ENC) variables and include classes:
$::openssh_template = 'site/openssh/openssh.conf.erb'
include openssh

# Use Hiera:
hiera('openssh_template')
include openssh

# Use Parametrized Classes:
class { 'openssh':
  template => 'site/openssh/openssh.conf.erb',
}

# Happily mix different patterns:
$::monitor = true
$::monitor_tool = [ 'nagios' , 'munin' , 'puppi' ]
class { 'openssh':
  template => 'site/openssh/openssh.conf.erb',
}


### Customize: How to provide configuration files
# Provide Main Configuration as a static file ...
class { 'openssh':
  source => 'puppet:///modules/site/ssh/sshd.conf'
}

# an array of files looked up on a first match logic ...
class { 'openssh':
  source => [ "puppet:///modules/site/ssh/sshd.conf-${fqdn}",
              "puppet:///modules/site/ssh/openssh.conf"],
}

# As an erb template:
class { 'openssh':
  template => 'site/ssh/sshd.conf.erb',
}

# Config File Path is defined in params.pp (can be overriden):
class { 'openssh':  
  config_file => '/etc/ssh/sshd_config',
}


#### Customize: Configuration Dir
# You can manage the whole Configuration Directory:
class { 'openssh':
  source_dir => 'puppet:///modules/site/ssh/sshd/',
}
# This copies all the files in lab42/files/ssh/sshd/* to local config_dir

# You can purge any existing file on the destination config_dir which are not present on the source_dir path:
class { 'openssh':
  source_dir => 'puppet:///modules/site/ssh/sshd/',
  source_dir_purge => true, # default is false
}
# WARNING: Use with care

# Config Dir Path is defined in params.pp (can be overriden):
class { 'openssh':
  config_dir => '/etc/ssh',
}


### Customize Application Parameters.
# An example: Use the puppet module to manage pe-puppet!
class { 'puppet':
  template           => 'lab42/pe-puppet/puppet.conf.erb',
  package            => 'pe-puppet',
  service            => 'pe-puppet',
  service_status     => true,
  config_file        => '/etc/puppetlabs/puppet/puppet.conf',
  config_file_owner  => 'root',
  config_file_group  => 'root',
  config_file_init   => '/etc/sysconfig/pe-puppet',
  process            => 'ruby',
  process_args       => 'puppet',
  process_user       => 'root',
  config_dir         => '/etc/puppetlabs/puppet/',
  pid_file           => '/var/run/pe-puppet/agent.pid',
  log_file           => '/var/log/pe-puppet/puppet.log',
  log_dir            => '/var/log/pe-puppet',
}


### Managed Behaviour
# Enable Auditing:
class { 'openssh':
  audit_only => true, # Default: false
}

## Manage Service Autorestart:
class { 'openssh':
  service_autorestart => false, # Default: true
}
# No automatic service restart when a configuration file / dir changes

# Manage Software Version:
class { 'foo':
  version => '1.2.0', # Default: unset
}
# Specify the package version you want to be installed.
# Set => 'latest' to force installation of latest version 


### Custom Options
# With templates you can provide an hash of custom options:
class { 'openssh':
  template => 'site/ssh/sshd.conf.erb',
  options  => {
    'LogLevel' => 'INFO',
    'UsePAM'   => 'yes',
  },
}


### Custom Classes
# Provide added resources in a Custom Class:
class { 'openssh':
  my_class => 'site/my_openssh',
}
# This autoloads: site/manifests/my_openssh.pp 

# Custom class can stay in your site module:
class site::my_openssh {
  file { 'motd':
    path    => '/etc/motd',
    content => template('site/openssh/motd.erb'),
  }
}


### Decommisioning
# Disable openssh service:
class { 'openssh':
  disable => true
}

# Deactivate openssh service only at boot time:
class { 'openssh':
  disableboot => true
}
# Useful when a service is managed by another tool (ie: a cluster suite)

# Remove openssh (package and files):
class { 'openssh':
  absent => true
}


### Cross-module integrations
# Integration with other modules sets and conflicts management is not easy.

# Strategy 1: Provide the option to use the module's prerequisite resources:
class { 'logstash':
  install_prerequisites => false, # Default true
}

# Strategy 2: Use if ! defined when defining common resources
if ! defined(Package['git']) {
  package { 'git': ensure => installed } 
}

# Strategy 3: Always define in Modulefile the module's dependencies
dependency 'example42/puppi', '>= 2.0.0'

# Strategy 4: Never assume your resource defaults are set for others
Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }


### Extend: Monitor
# Manage Abstract Automatic Monitoring:
class { 'openssh':
  monitor      => true,
  monitor_tool => [ 'nagios','puppi','monit' ],
  monitor_target => $::ip_addess # Default
}

# Monitoring is based on these parameters defined in params.pp:
class { 'openssh':
  port         => '22',
  protocol     => 'tcp',
  service      => 'ssh[d]',  # According to OS 
  process      => 'sshd', 
  process_args => '',
  process_user => 'root',
  pid_file     => '/var/run/sshd.pid',
}


# Manage Automatic Firewalling (host based):
class { 'openssh':
  firewall      => true,
  firewall_tool => 'iptables',
  firewall_src  => '10.0.0.0/8',
  firewall_dst  => $::ipaddress_eth1, # Default is $::ipaddress
}

# Firewalling is based on these parameters defined in params.pp:
class { 'openssh':  
  port         => '22',
  protocol     => 'tcp',
}


### Manage Puppi Integration:
class { 'openssh':
  puppi        => true,       # Default: false
  puppi_helper => 'standard', # Default
}

}
