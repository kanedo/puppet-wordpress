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
    }

      exec {
      'wordpress_extract_installer':
        command      => "unzip -o\
                        ${wordpress_src}/setup_files/${wordpress_archive}",
        refreshonly  => true,
        path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
  }
}
