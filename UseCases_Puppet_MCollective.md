# Use Cases: Puppet and MCollective infrastructure -  TODO

## All-In-One Puppet+Passenger+Foreman+PuppetDB setup

      $my_puppet_group_email = "roots@example42.com"

      class { 'puppet':
        server          => "puppet.${::domain}",
        postrun_command => "/usr/bin/mailpuppicheck -m ${my_puppet_group_email} -r 2",
        module_path     => "/etc/puppet/modules:/usr/share/puppet-modules-nextgen",
        allow           => ['127.0.0.1','*'],
        mode            => 'server',
        nodetool        => 'foreman',
        db              => 'puppetdb',
        db_server       => "puppet.${::domain}",
        db_port         => '8081',
        passenger       => true,
      }

      class { 'puppetdb':
        db_type      => 'postgresql',
        require      => Class['postgresql'],
      }

      class { 'postgresql':
      }

      class { 'foreman':
        install_mode    => 'all',
        install_proxy   => true,
        db              => 'mysql',
        db_server       => '127.0.0.1',
        db_user         => 'foreman',
        db_password     => 'f0rem4n!',
        puppet_server   => "puppet.${::domain}",
        unattended      => true,
        authentication  => true,
        passenger       => true,
      }
      
