# Use Cases: Puppet and MCollective infrastructure -  TODO

Some sample code to setup a Puppet infrastructure.



      # Puppet
      # Calculated random times for puppetruns
      $rand_minute = fqdn_rand(60)
      $rand_hour = fqdn_rand(3)
      $rand_hour_set = $rand_hour ? {
        '0' => '0,3,6,9,12,15,18,21',
        '1' => '1,4,7,10,13,16,19,22',
        '2' => '2,5,8,11,14,17,20,23',
        default => '*', # This should never be met
      }
      $puppet_cron = "$rand_minute $rand_hour_set * * *"
      $puppet_fqdn = "puppet"
      $my_puppet_group_email = "roots@example42.com"

      class { 'puppet':
        server       => $puppet_fqdn,
        runmode      => 'manual',
        croninterval => $puppet_cron,
        croncommand  => '/usr/bin/puppet agent --onetime --ignorecache --no-usecacheonfailure',
        postrun_command => "/usr/bin/mailpuppicheck -m $my_puppet_group_email -r 2",
        module_path => "/etc/my_puppet/modules:/etc/puppet/modules:/usr/share/puppet-modules-nextgen",
        allow        => ['127.0.0.1','*'],
        mode         => $::role ? {
          'puppet' => 'server',
          default  => 'client',
        },
        reporturl    => "http://$puppet_fqdn:3000/reports",
    #    passenger    => $::role ? {
    #      'puppet' => true,
    #      default  => false,
    #    },
        nodetool     => 'foreman',
        db           => 'puppetdb',
        db_server    => $puppet_fqdn,
        db_port      => '8081',
        firewall     => false,
        passenger       => true,
      }


/*
  class { 'mysql':
    root_password => 'auto',
    firewall     => false,
    firewall_src  => [ '10.0.0.0/8' ],
    firewall_dst  => $ipaddress_eth1,
  }
*/

  class { 'puppetdb':
    db_type      => 'postgresql',
    require      => Class['postgresql'],
    monitor_target => '127.0.0.1',
  }

  class { 'postgresql':
  }

  class { 'foreman':
    install_mode    => 'all',
    install_proxy   => true,
    db              => 'mysql',
    db_server       => '127.0.0.1',
    db_user         => 'foreman',
    db_password     => 'forem4n!',
    puppet_server   => "puppet1.${::domain}",
    unattended      => true,
    authentication  => true,
    passenger       => true,
  }
      
