class git (
  $git_id_rsa_pub  = $ssh::id_rsa_pub
) {

  package { 'git':
    ensure => installed,
  }

  file { '/var/git':
    ensure  => directory,
    mode    => 0755,
    owner   => 'git',
    group   => 'git',
  }
  
  user { 'git':
    ensure      => present,
    comment     => 'Git',
    home        => '/var/git',
    shell       => '/bin/bash',
    managehome  => true,
  }

  group { 'git':
    ensure      => present,
  }

  file { '/var/git/.ssh':
    ensure  => directory,
    mode    => 0700,
    owner   => 'git',
    group   => 'git',
  }
  file { "/var/git/.ssh/authorized_keys":
    ensure    => file,
    mode      => 0640,
    owner     => git,
    group     => git,
    require   => File["/var/git/.ssh"],
    content   => $git_id_rsa_pub,
  }
}