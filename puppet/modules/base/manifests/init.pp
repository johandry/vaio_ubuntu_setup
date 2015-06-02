class base {

  # Make sure the user was created
  user { "${username}":
    ensure		  => "present",
    managehome	=> true,
    groups		  => ['docker'],
  }

  # Make sure the FQDN is set
  host { "vaio.johandry.com":
    ip			     => "127.0.1.1",
    host_aliases => "vaio",
  }

  # Make sure puppet is installed
  exec { "dpkg install puppetlabs repository":
    command		=> "wget -O /tmp/puppetlabs-release.deb ${puppetlabs_url} && dpkg -i /tmp/puppetlabs-release.deb && apt-get update",
    creates		=> "/etc/apt/sources.list.d/puppetlabs.list",
    logoutput	=> on_failure,
  }
  package { "puppet":
    ensure		=> "latest",
    require		=> Exec['dpkg install puppetlabs repository'],
  }
  # Puppet requirements
  # package { "hiera-gpg"
  #   ensure    => "installed",
  #   provider  => "gem",
  # }

  file { "/home/${username}/bin":
    ensure		=> "directory",
    mode		  => 0750,
    owner		  => "${username}",
    group		  => "${username}",
  }
  file { "/home/${username}/bin/common.sh":
    ensure 		=> "file",
    mode		  => 0750,
    owner     => "${username}",
    group     => "${username}",
    source		=> "puppet:///modules/base/common.sh",
  }

  file { "/home/${username}/.bashrc":
    ensure    => "file",
    mode      => 0644,
    owner     => "${username}",
    group     => "${username}",
    source    => "puppet:///modules/base/bashrc",
  }

  file { "/etc/profile.d/personal-settings.sh":
    ensure 		=> "file",
    mode		  => 0640,
    owner	    => "${username}",
    group	    => "${username}",
    source		=> "puppet:///modules/base/personal-settings.sh",
  }

  # Apply the puppet rules every 2 hours
  cron { "apply puppet rules every 2 hours":
    ensure    => present,
    command   => "puppet apply -v /etc/puppet/manifests/site.pp",
    user      => "root",
    hour      => '*/2',
    minute    => 0,
  }


  # Update the OS only if the file /tmp/last_update_stamp_from_puppet does not exists (unless).
  # The file /tmp/last_update_stamp_from_puppet will be deleted every Monday at 12:00 by root's cron or in every reboot (because it is in /tpm/ which is volatil)
  exec { 'apt-get update':
    command		=> "apt-get update && apt-get upgrade -y && echo $timestamp > /tmp/last_update_stamp_from_puppet",
    logoutput	=> on_failure,
    unless		=> "test -e /var/opt/last_update_stamp_from_puppet",
  }
  cron { "remove last_update_stamp_from_puppet":
    ensure		=> present,
    command		=> "rm -f /tmp/last_update_stamp_from_puppet",
    user		  => "root",
    hour		  => 12,
    minute		=> 0,
    weekday		=> "Monday",
  }

  # Generate SSH Key
  # exec { "ssh-keygen":
  #   command		=> "ssh-keygen -q -N '' -f /home/${username}/.ssh/id_rsa -t rsa -b 4096 -C '' && ssh-add",
  #   creates		=> "/home/${username}/.ssh/id_rsa",
  #   logoutput	=> on_failure,
  # }
  exec {"Uncompress ssh-settings":
    command   => "tar xzf ssh-settings.tar.gz && chown root.root *",
    cwd       => "/etc/puppet/modules/base/files/",
    creates   => "/etc/puppet/modules/base/files/id_rsa",
    logoutput => on_failure,
  }
  file { "/home/${username}/.ssh":
    ensure		=> "directory",
    mode		  => 0700,
    owner	    => "${username}",
    group     => "${username}",
    require   => Exec["Uncompress ssh-settings"],
  }
  file { "/home/${username}/.ssh/id_rsa":
    ensure		=> "present",
    mode		  => 0600,
    owner	    => "${username}",
    group	    => "${username}",
    require   => File["/home/${username}/.ssh"],
    source    => "puppet:///modules/base/id_rsa",
  }
  file { "/home/${username}/.ssh/id_rsa.pub":
    ensure		=> "present",
    mode		  => 0640,
    owner	    => "${username}",
    group	    => "${username}",
    require   => File["/home/${username}/.ssh"],
    source    => "puppet:///modules/base/id_rsa.pub",
  }
  file { "/home/${username}/.ssh/config":
    ensure    => "present",
    mode      => 0640,
    owner     => "${username}",
    group     => "${username}",
    require   => File["/home/${username}/.ssh"],
    source    => "puppet:///modules/base/config",
  }

  # Create ~/Workspace and clone github project
  file { "/home/${username}/Workspace":
    ensure		=> "directory",
    mode      => 0750,
    owner     => "${username}",
    group     => "${username}",
  }
  file { "/home/${username}/.gitconfig":
    ensure 		=> "file",
    mode      => 0664,
    owner     => "${username}",
    group     => "${username}",
    source		=> "puppet:///modules/base/gitconfig",
  }
  exec { "git clone vaio_ubuntu_setup from GitHub":
    cwd       => "/home/${username}/Workspace",
    command		=> "git clone git@github.com:johandry/vaio_ubuntu_setup.git /home/${username}/Workspace/vaio_ubuntu_setup",
    creates		=> "/home/${username}/Workspace/vaio_ubuntu_setup",
    user      => "${username}",
    environment	=> ["HOME=/home/${username}"],
    logoutput	=> on_failure,
  }

}
