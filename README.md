php-fpm
========

This role installs and configures the php-fpm interpreter.

Requirements
------------

This role requires Ansible 1.4 or higher and tested platforms are listed in the metadata file.

Role Variables
--------------

The variables that can be passed to this role and a brief description about
them are as follows.

    # A list of the php.ini sections with directives.
    # Note that any valid php.ini directive can be added here.
    # (see the http://php.net documentation for details.)
    # 
    php_config:
      PHP:
        engine: "1"
        short_open_tag: "1"
        date.timezone: "Europe/Berlin"
        ...
      CLI Server:
        cli_server.color: "1"
      Pdo_mysql:
        pdo_mysql.cache_size: "2000"
      ...

    # A list of hashs that define fpm configuration
    fpm_config:
      pid: "/var/run/php5-fpm.pid"
      error_log: "/var/log/php5-fpm.log"
      syslog.facility: "daemon"
      syslog.ident: "php-fpm"
      log_level: "notice"
      emergency_restart_threshold: "0"
      emergency_restart_interval: "0"
      process_control_timeout: "0"
      process.max: "0"
      daemonize: "yes"
      include: "/etc/php5/fpm/pool.d/*.conf"

    # A list of hashs that define the pools for php-fpm,
    # as with the php.ini directives. Any valid server parameters
    # can be defined here.
    fpm_pools:
      - pool:
          name: foo
          vars:
            - user = www-data
            - group = www-data
            - listen = 8000
            - pm = dynamic
            - pm.max_children = 5
            - pm.start_servers = 2
            - pm.min_spare_servers = 1
            - pm.max_spare_servers = 3
            - chdir = /

Dependencies
------------

None

License
-------

BSD

Author Information
------------------

Sergey Fayngold
