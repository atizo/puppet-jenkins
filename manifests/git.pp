class jenkins::git {
  include git
  Class['jenkins::git'] <- Class['jenkins']
  file{"${jenkins::home}/.ssh":
    ensure => directory,
    owner => jenkins, group => jenkins, mode => 0700;
  }
  exec{'jenkins_ssh_keypair':
    user => $jenkins::user,
    command => "ssh-keygen -f ${jenkins::home}/.ssh/id_rsa -t rsa -N ''",
    require => File["${jenkins::home}/.ssh"],
    creates => "${jenkins::home}/.ssh/id_rsa",
  }
  file{"${jenkins::home}/.ssh/config":
    source => [
      "puppet://$server/modules/site-jenkins/git/$fqdn/conf",
    ],
    require => File["${jenkins::home}/.ssh"],
    owner => jenkins, group => jenkins, mode => 0444;
  }
}
