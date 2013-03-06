# Install wordpress application and its dependencies
class wordpress::app {
  require boxen::config
  $wordpress_archive = 'wordpress-3.5.1.zip'
  $wordpress_src = "${boxen::config::srcdir}/${name}"

  file {
    'wordpress_application_dir':
      ensure  =>  directory,
      path    =>  $wordpress_src,
      before  =>  File['wordpress_setup_files_dir'];
    'wordpress_setup_files_dir':
      ensure  =>  directory,
      path    =>  "${wordpress_src}/setup_files",
      before  =>  File[
                      'wordpress_php_configuration',
                      'wordpress_themes',
                      'wordpress_plugins',
                      'wordpress_installer',
                      'wordpress_htaccess_configuration'
                      ];
    'wordpress_installer':
      ensure  =>  file,
      path    =>  "${wordpress_src}/setup_files/${wordpress_archive}",
      notify  =>  Exec['wordpress_extract_installer'],
      source  =>  "puppet:///modules/wordpress/${wordpress_archive}";
    'wordpress_php_configuration':
      ensure     =>  file,
      path       =>  "${wordpress_src}/wp-config.php",
      content    =>  template('wordpress/wp-config.erb'),
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_htaccess_configuration':
      ensure     =>  file,
      path       =>  "${wordpress_src}/.htaccess",
      source     =>  'puppet:///modules/wordpress/.htaccess',
      subscribe  =>  Exec['wordpress_extract_installer'];
    'wordpress_themes':
      ensure     => directory,
      path       => "${wordpress_src}/setup_files/themes",
      source     => 'puppet:///modules/wordpress/themes/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_themes'],
      subscribe  => Exec['wordpress_extract_installer'];
    'wordpress_plugins':
      ensure     => directory,
      path       => "${wordpress_src}/setup_files/plugins",
      source     => 'puppet:///modules/wordpress/plugins/',
      recurse    => true,
      purge      => true,
      ignore     => '.svn',
      notify     => Exec['wordpress_extract_plugins'],
      subscribe  => Exec['wordpress_extract_installer'];
    }

      exec {
      'wordpress_extract_installer':
        command      => "unzip -o\
                        ${wordpress_src}/setup_files/${wordpress_archive}\
                        -d /opt/",
        refreshonly  => true,
        require      => Package['unzip'],
        path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
  }
}
