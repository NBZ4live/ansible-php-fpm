[![Build Status](http://img.shields.io/travis/NBZ4live/ansible-php-fpm.svg?style=flat)](https://travis-ci.org/NBZ4live/ansible-php-fpm) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-php--fpm-blue.svg?style=flat)](https://galaxy.ansible.com/list#/roles/304)

php-fpm
========

This role installs and configures the php-fpm interpreter.

Requirements
------------

This role requires Ansible 1.4 or higher and tested platforms are listed in the metadata file.

Role Variables
--------------

The role uses the following variables:

 - **php_fpm_pools**: The list a pools for php-fpm, each pools is a hash with
   a name entry (used for filename), all the other entries in the hash are pool
   directives (see http://php.net/manual/en/install.fpm.configuration.php).
 - **php_fpm_pool_defaults**: A list of default directives used for all php-fpm pools
   (see http://php.net/manual/en/install.fpm.configuration.php).
 - **php_fpm_apt_packages**: The list of packages to be installed by the
  ```apt```, defaults to ```[php5-fpm]```.
   module.
 - **php_fpm_yum_packages**: The list of packages to be installed by the
   ```yum``` module, defaults to ```[php-fpm]```.
 - **php_fpm_ini**: Customization for php-fpm's php.ini as a list of options,
   each option is a hash using the following structure:
     - **option**: The name of the option.
     - **value**: The string value to be associated with the option.
     - **section**: Section name in INI file.
 - **php_fpm_config**: Customization for php-fpm's configuration file as a list
   of options.
 - **php_fpm_apt_packages**: The APT packages to install, defaults to ```[php5-fpm]```.
 - **php_fpm_yum_packages**: The Yum packages to install, defaults to ```[php-fpm]```.
 - **php_fpm_default_pool**:
     - **delete**: Set to a ```True``` value to delete the default pool.
     - **name**: The filename the default pool configuration file.

Example configuration
--------------

    - role: php-fpm
      php_fpm_pool_defaults:
        pm: dynamic
        pm.max_children: 5
        pm.start_servers: 2
        pm.min_spare_servers: 1
        pm.max_spare_servers: 3
      php_fpm_pools:
       - name: foo
         user: www-data
         group: www-data
         listen: 8000
         chdir: /
       - name: bar
         user: www-data
         group: www-data
         listen: 8001
       php_fpm_ini:
       # PHP section directives
       - option: "engine"
         section: "PHP"
         value: "1"
       - option: "error_reporting"
         section: "PHP"
         value: "E_ALL & ~E_DEPRECATED & ~E_STRICT"
       - option: "date.timezone"
         section: "PHP"
         value: "Europe/Berlin"
       # soap section directives
       - option: "soap.wsdl_cache_dir"
         section: "soap"
         value: "/tmp"
       # Pdo_mysql section directives
       - option: "pdo_mysql.cache_size"
         section: "Pdo_mysql"
         value: "2000"
       php_fpm_config:
       - option: "log_level"
         section: "global"
         value: "notice"
       - option: "syslog.facility"
         section: "global"
         value: "daemon"

Example usage
-------

    ---
    # file: task.yml
    - hosts: all
      roles:
        - nbz4live.php-fpm
        - {
            role: nbz4live.php-fpm,
            php_fpm_pools:[
              {name: foo, user: www-data, group: www-data, listen: 8000, chdir: /}
            ]
          }
        - role: php-fpm
            php_fpm_pools:
              - name: bar
                user: www-data
                group: www-data
                listen: 9000
                chdir: /
        
License
-------

BSD

Author Information
------------------

- Sergey Fayngold
- Pierre Buyle <buyle@pheromone.ca>
