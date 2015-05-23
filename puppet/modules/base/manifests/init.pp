class base {

  # Google Chrome URL
  $google_chrome_url	= "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  $puppet_url			= ""


  # Make sure the user was created
  user { "${username}":
    ensure		=> "present",
    managehome	=> true,
    groups		=> ['docker'],
  }

  # Make sure the FQDN is set
  host { "vaio.johandry.com":
    ip			 => "127.0.1.1",
    host_aliases => "vaio",
  }

  # Make sure puppet is installed
  exec { "dpkg install puppetlabs repository":
    command		=> "wget -O /tmp/puppetlabs-release.deb ${puppet_url} && dpkg -i /tmp/puppetlabs-release.deb && apt-get update",
    creates		=> "/etc/apt/sources.list.d/puppetlabs.list",
    logoutput	=> on_failure,
  }
  package { "puppet":
    ensure		=> "latest",
    require		=> Exec['dpkg install puppetlabs repository'],
  }

  file { "/home/${username}/bin":
    ensure		=> "directory",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
  }
  file { "/home/${username}/bin/common.sh":
    ensure 		=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source		=> "puppet:///modules/base/common.sh",
  }
  file { "/home/${username}/bin/vpn.sh":
    ensure 		=> "file",
    mode		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
    source		=> "puppet:///modules/base/vpn.sh",
  }

  # Update the OS only if the file /var/opt/last_update_stamp_from_puppet does not exists (unless).
  # The file /var/opt/last_update_stamp_from_puppet will be deleted every Monday at 12:00 by root's cron
  exec { 'apt-get update':
    command		=> "apt-get update && apt-get upgrade -y && echo $timestamp > /var/opt/last_update_stamp_from_puppet",
    logoutput	=> on_failure,
    unless		=> "test -e /var/opt/last_update_stamp_from_puppet",
  }
  cron { "remove last_update_stamp_from_puppet":
    ensure		=> present,
    command		=> "rm -f /var/opt/last_update_stamp_from_puppet",
    user		=> "root",
    hour		=> 12,
    minute		=> 0,
	weekday		=> "Monday",
  }

  # Generate SSH Key
  exec { "ssh-keygen":
    command		=> "ssh-keygen -q -N '' -f /home/${username}/.ssh/id_rsa -t rsa -b 4096 -C 'Sony VAIO with Ubuntu'",
    creates		=> "/home/${username}/.ssh/id_rsa",
    logoutput	=> on_failure,
  }
  file { "/home/${username}/.ssh":
    ensure		=> "directory",
    mode		=> 0700,
    owner		=> "${username}",
    group		=> "${username}",
  }
  file { "/home/${username}/.ssh/id_rsa":
    ensure		=> "present",
    mode		=> 0600,
    owner		=> "${username}",
    group		=> "${username}",
  }
  file { "/home/${username}/.ssh/id_rsa.pub":
    ensure		=> "present",
    mode		=> 0644,
    owner		=> "${username}",
    group		=> "${username}",
  }

  # Create ~/Workspace and clone github project
  file { "/home/${username}/Workspace":
    ensure		=> "directory",
    mode 		=> 0750,
    owner		=> "${username}",
    group		=> "${username}",
  }
  file { "/home/${username}/.gitconfig":
    ensure 		=> "file",
    mode		=> 0664,
    owner		=> "${username}",
    group		=> "${username}",
    source		=> "puppet:///modules/base/gitconfig",
  }
  exec { "git clone vaio_ubuntu_setup from GitHub":
    cwd			=> "/home/${username}/Workspace",
    command		=> "git clone git@github.com:johandry/vaio_ubuntu_setup.git /home/${username}/Workspace/vaio_ubuntu_setup",
	creates		=> "/home/${username}/Workspace/vaio_ubuntu_setup",
    user		=> "${username}",
    environment	=> ["HOME=/home/${username}"],
    logoutput	=> on_failure,
  }

}
