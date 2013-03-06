# Install mysql server and set up wordpress database
class wordpress::db {
	include mysql
 	mysql::db { "${wordpress::db_name}": }
	package { 'mysql':
	    notify => Service['mysql']
	  }
}
