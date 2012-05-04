#
# jenkins module
#
# Copyright 2010, Atizo AG
# Simon Josi simon.josi+puppet(at)atizo.com
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class jenkins(
  $home = '/var/lib/jenkins',
  $java_cmd = '',
  $user = 'jenkins',
  $java_options = '-Djava.awt.headless=true',
  $port = '8080',
  $ajp_port = '8009',
  $debug_level = 5,
  $enable_access_log = 'no',
  $handler_max = 100,
  $handler_idle = 20,
  $extra_arguments = '',
  $git_support = false
) {
  yum::repo{'jenkins':
    descr => 'Jenkins Repository',
    baseurl => 'http://pkg.jenkins-ci.org/redhat',
    enabled => 1,
    gpgcheck => 0,
  }
  package{'jenkins':
    ensure => present,
    require => Yum::Repo['jenkins'],
  }
  service{'jenkins':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => [
      Package['jenkins'],
      File['/etc/sysconfig/jenkins'],
    ],
  }
  augeas{"set_jenkins_user_shell":
    context => "/files/etc/passwd",
    changes => "set jenkins/shell '/bin/bash'",
    onlyif => "get jenkins/shell != '/bin/bash'",
    require => Package['jenkins'],
  }
  file{'/etc/sysconfig/jenkins':
    content => template('jenkins/sysconfig.erb'),
    require => Package['jenkins'],
    notify => Service['jenkins'],
    owner => root, group => root, mode => 0444;
  }
  if $git_support {
    include jenkins::git
  }
}
