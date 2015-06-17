class git (
  $ssh_git_authorized_keys_content  = $git::ssh_git_authorized_keys
) {

  package { 'git':
    ensure => installed,
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
    content   => $ssh_git_authorized_keys_content,
  }
}