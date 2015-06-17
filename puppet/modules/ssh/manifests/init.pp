class ssh (
  $username           = $users::username,
  $id_rsa_content     = $ssh::id_rsa,
  $id_rsa_pub_content = $ssh::id_rsa_pub,
  $ssh_config_content = $ssh::config
) {

  package { 'openssh-server':
    ensure => installed,
  }
  file { '/etc/ssh/sshd_config':
    ensure  => file,
    owner   => root,
    group   => root,
    notify  => Service['ssh'],
    require => Package['openssh-server'],
  }
  service { 'ssh':
    enable      => true,
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package["openssh-server"],
  }

  file { "/home/${username}/.ssh":
    ensure    => "directory",
    mode      => 0700,
    owner     => $username,
    group     => $username,
  }
  file { "/home/${username}/.ssh/id_rsa":
    ensure    => "present",
    mode      => 0600,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.ssh"],
    content   => $id_rsa_content,
  }
  file { "/home/${username}/.ssh/id_rsa.pub":
    ensure    => "present",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.ssh"],
    content   => $id_rsa_pub_content,
  }
  file { "/home/${username}/.ssh/config":
    ensure    => "present",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.ssh"],
    content   => $ssh_config_content,
  }
}