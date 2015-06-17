class ssh (
  $username  = $users::username,
  $id_rsa,
  $id_rsa_pub,
  $config
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
    content   => $id_rsa,
  }
  file { "/home/${username}/.ssh/id_rsa.pub":
    ensure    => "present",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.ssh"],
    content   => $id_rsa_pub,
  }
  file { "/home/${username}/.ssh/config":
    ensure    => "present",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    require   => File["/home/${username}/.ssh"],
    content   => $config,
  }

  file { "/root/.ssh":
    ensure    => "directory",
    mode      => 0700,
    owner     => root,
    group     => root,
  }
  file { "/root/.ssh/id_rsa":
    ensure    => "present",
    mode      => 0600,
    owner     => root,
    group     => root,
    require   => File["/root/.ssh"],
    content   => $id_rsa,
  }
  file { "/root/.ssh/id_rsa.pub":
    ensure    => "present",
    mode      => 0640,
    owner     => root,
    group     => root,
    require   => File["/root/.ssh"],
    content   => $id_rsa_pub,
  }
  file { "/root/.ssh/config":
    ensure    => "present",
    mode      => 0640,
    owner     => root,
    group     => root,
    require   => File["/root/.ssh"],
    content   => $config,
  }
}