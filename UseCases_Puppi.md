# Use Cases: Puppi deployments

The Puppi module can be used to create the environment for puppi deploy operations.
Here are some samples of the Puppet code needed to manage different kinds of deployments.


## Puppi deploy samples

This are real world examples (with names changed) of different usage patterns.

### Java Deployments

Here is a simple war deployment where

- the **$source** war is copied to the **$deploy_root** directory as 'tomcat' **$user**

        puppi::project::war { 'WWWEraser':
        
          source       => 'http://deploy.example42.com/projects/WWWEraser.war',
          user         => 'tomcat',
          deploy_root  => '/opt/tomcat/instances/WWWEraser/webapps',
        
        }

A more elaborated alternative, with:

- execution of a custom command before the deploy but a specific use and at a the specific order in the deploy sequence (**$predeploy_***);

- custom backup exclusion patterns (backup is done with rsync, and you can directly specify rsync options) (**$backup_rsync_options**);

- restart of tomcat and the temporary disabling of monit and puppet services. 

        puppi::project::war { 'WWWEraser':
        
          source       => 'http://deploy.example42.com/projects/WWWEraser.war',
          user         => 'tomcat',
          deploy_root  => '/opt/tomcat/instances/WWWEraser/webapps',
        
          predeploy_customcommand => 'rm -rf /opt/tomcat/instances/WWWEraser/webapps',
          predeploy_user          => 'root',
          predeploy_priority      => '39',
        
          backup_rsync_options    => '--include WWWEraser.war',
        
          init_script      => 'tomcat',
          disable_services => 'monit puppet',
        
          report_email     => 'deployments@example42.com',
        
        }

What follows is another sample where the artifact to deploy is retrieved from different sources according to the node's environment (here set via the variable $env).

Here are also set other options:

- keep only 2 backup copies for rollbacks, default 5 (**$backup_retention**);

- do not check for the war's exploded dir (used on a Jboss server) (**$check_deploy**);

- delete all the existing files in the $deploy_root before deploying the WAR (**$clean_deploy**);

- disable the automatic execution of puppi checks before and after the deploy (**$run_checks**).

        puppi::project::war { 'grandweb':
  
          source           => $::env ? {
            devel   => 'http://deploy.example42.com/latest/grandweb.ear' ,
            test    => 'http://deploy.example42.com/test/grandweb.ear' ,
            default => 'http://deploy.example42.com/prod/grandweb.ear' ,
          },
    
          deploy_root      => '/opt/jboss/standalone/deployments/' ,
          user             => 'jboss' ,

          backup_retention => 2 ,

          report_email     => 'roots@example42.com,lab@example42.com',
      
          check_deploy     => false,
          clean_deploy     => false,
          run_checks       => false,

        }
  
 
There also a Maven specific deploy procedure which fetches **maven-metadata.xml** files (typically from a Nexus repository) and retrieve the referred artefacts.
 
The following sample deploys from a Nexus server. Here is defined:
 
 - the basic url of project's maven-metadata.xml (**$source**);
 
 - a Maven qualifier to identify a tarball containing static data (**$document_suffix**) and where to explode this tarball (**$document_root**);
 
 - some specific backup options  (**$backup_rsync_options**);
 
 - a quick way to introduce some delays before and after the deploy operation with pre and post deploy commands.
 
        puppi::project::maven { 'mgdiskcache':

          source           => "http://nexus.${::domain}/deploy/com/mg/fe/mgdiskcache",
          user             => 'mgdiskcache',

          document_suffix  => 'src-mgdiskcache-Prod',
          document_root    => '/store/pgdiskcache',

          report_email     => 'mgdiskcache@example42.com',

          check_deploy     => false,

          # Do not backup the snapshot and the var data as this is useless
          backup_rsync_options => "-x --exclude .snapshot/\*\*\* --exclude var/\*\*\*",

          predeploy_customcommand  => 'sleep 2',
          postdeploy_customcommand => 'sleep 2',

        }

A faily more elaborated example (not too elegant) where different values for different environments are set, based on a custom $env variable.

Here is also defined:

- a Maven qualifier to identify a tarball containing configuration data (**$config_suffix**) and where to explode this tarball (**$config_root**);

        puppi::project::maven { 'gsite':
 
          source           => "http://deploy.${::domain}/nexus/com/acme/gsite/",
          deploy_root      => '/app/tomcat/gsite/webapps',
          user             => 'gsite',

          config_suffix    => $::env ? {      
            test    => 'cfg-test',
            preprod => 'cfg-pre',
            prod    => 'cfg-pro',
          },
          config_root      => '/app/tomcat/gsite/shared/classes',

          document_root    => $::env ? {
            test    => '/store/www/site.test-example42.com/gsite',
      	    preprod => '/store/www/site.pre-example42.com/gsite',
      	    prod    => '/store/www/site.example42.com/gsite',
          },
          document_suffix  => $::env ? {
            test    => "src-test',
            preprod => "src-pre',
            prod    => "src-pro',
          },
          document_user    => $env ? {
            test    => 'gsite',
            preprod => 'gsite',
            prod    => 'gsite',
          },

          disable_services => 'monit puppet apache2',
          init_script      => 'tomcat-gsite',

      }

### Files deployments

Simple deployments based on the extraction of a tar ball can be done with:

        puppi::project::tar { 'wordpress':

          source      => 'http://deploy.${::domain}/public/wordpress/wordpress-3.1.tar.gz',
          deploy_root => '/store/www/wordpress',
          user        => 'wordpress",
          
        }

Whole directories can be synced via rsync with:

        puppi::project::dir { 'xlserver-app':

          source           => "rsync://debian.${::domain}/deploy/initdir/xlserver_app/",
          deploy_root      => '/opt/xlserver/',
 
        }


    
    
### The puppi::project::builder alternative

The default deploy procedures provided by Puppi are the defines in puppi::project::. Since many of these complex defines have many parts in common, there is one, called '**builder**', that supports different common types of source files to manage.

This ones does the same of the above **puppi::project::tar { 'wordpress':**

        puppi::project::builder { 'wordpress':
  
          source       => 'http://deploy.${::domain}/public/wordpress/wordpress-3.1.tar.gz',
          deploy_root  => '/store/www/wordpress',
          user         => 'wordpress",
  
          source_type  => 'tarball',

        }        

This is equivant to the above **puppi::project::dir { 'xlserver-app':**

        puppi::project::builder { 'xlserver-app':

          source           => "rsync://deploy.${::domain}/deploy/initdir/xlserver_app/",
          deploy_root      => '/opt/xlserver/',
 
          source_type      => 'dir',

        }
 
 And this unpacks a zip file instead of a tarball:
 
        puppi::project::builder { 'wordpress':
  
          source       => 'http://deploy.${::domain}/public/wordpress/wordpress-3.1.zip',
          deploy_root  => '/store/www/wordpress',
          user         => 'wordpress",
                  
          source_type  => 'zip',

        }   



### Deployments from SCMs 

I've also cases where the code to deploy is retrieved directly from a SCM.

Here's a sample with **git** with different branches used on different environments

          puppi::project::git { 'frontend':
            source           => "http://deploy:${secret::code_deploy_password}@code.example42.com:80/scm/git/frontend" ,
            branch           => $::env ? {
              devel   => 'master',
              test    => 'test',
              default => 'prod',
            },
            deploy_root      => '/var/www/frontend' ,
            user             => 'root' ,
            backup_retention => 3 ,
            report_email     => 'roots@example42.com,developers@example42.com',
            run_checks       => false,
          }


### Database operations

Database operations can be managed via a puppi deploy. Here the specific sql file is applied on a Mysql server with the given credentials
 
            puppi::project::mysql { "cms_sql":
              source           => "http://deploy.${::domain}/db/cms/latest_update.sql",
              mysql_user       => 'cms',
              mysql_password   => $secret::db_cms_pw,
              mysql_host       => 'localhost',
              mysql_database   => 'cms',
              always_deploy    => false,
            }
            