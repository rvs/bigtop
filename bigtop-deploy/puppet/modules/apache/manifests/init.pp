class apache {
  package { "httpd":
    ensure => latest
  }

  service { "httpd":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["httpd"],
  }
}
