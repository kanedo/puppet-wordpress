# Install mysql server and set up wordpress database
class wordpress::db {
	include mysql
	service { 'dev.mysql':
	    ensure      => running,
	    enable      => true,
	    hasrestart  => true,
	    hasstatus   => true,
	  }
 	mysql::db { "${wordpress::db_name}": }
}
