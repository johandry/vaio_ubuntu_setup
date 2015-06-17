class puppet (
  $puppetlabs_url   = $puppet::puppetlabs_url,
  $username         = $users::username
) {

  exec { "dpkg install puppetlabs repository":
    command   => "wget -O /tmp/puppetlabs-release.deb ${puppetlabs_url} && dpkg -i /tmp/puppetlabs-release.deb && apt-get update",
    creates   => "/etc/apt/sources.list.d/puppetlabs.list",
    logoutput => on_failure,
  }
  package { "puppet":
    ensure    => "latest",
    require   => Exec['dpkg install puppetlabs repository'],
  }

  # As Puppet Master is not installed, this make sure all the rules are set.
  cron { "apply puppet rules every 2 hours":
    ensure    => present,
    command   => "puppet apply -v /etc/puppet/manifests/site.pp",
    user      => "root",
    hour      => '*/2',
    minute    => 0,
  }

  # Hiera
  package { "hiera-eyaml":
    ensure    => "installed",
    provider  => "gem",
  }
  file { "/etc/hiera.yaml":
    ensure    => "link",
    target    => "/etc/puppet/hiera.yaml"
  }

  # Keys for Hiera-eyaml for Puppet
  file { "/etc/puppet/secure":
    ensure    => "directory",
    mode      => 0775,
    owner     => "root",
    group     => "root",
  }
  file { "/etc/puppet/secure/keys":
    ensure    => "directory",
    mode      => 0775,
    owner     => "root",
    group     => "root",
  }
  file { "/etc/puppet/secure/keys/private_key.pkcs7.pem":
    ensure    => "present",
    mode      => 0600,
    owner     => "root",
    group     => "root",
    source    => "puppet:///modules/puppet/private_key.pkcs7.pem",
  }
  file { "/etc/puppet/secure/keys/public_key.pkcs7.pem":
    ensure    => "present",
    mode      => 0664,
    owner     => "root",
    group     => "root",
    source    => "puppet:///modules/puppet/public_key.pkcs7.pem",
  }

  # Keys for Hiera-eyaml for User
  file { "/home/${username}/.eyaml":
    ensure    => "directory",
    mode      => 0750,
    owner     => $username,
    group     => $username,
  }
  file { "/home/${username}/.eyaml/keys":
    ensure    => "directory",
    mode      => 0750,
    owner     => $username,
    group     => $username,
  }
  file { "/home/${username}/.eyaml/config.yaml":
    ensure    => "file",
    mode      => 0640,
    owner     => $username,
    group     => $username,
    content   => "---
pkcs7_public_key: '/home/${username}/.eyaml/keys/public_key.pkcs7.pem'
pkcs7_private_key: '/home/${username}/.eyaml/keys/private_key.pkcs7.pem'
    "
  }
  file { "/home/${username}/.eyaml/keys/private_key.pkcs7.pem":
    ensure    => "present",
    mode      => 0600,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/puppet/private_key.pkcs7.pem",
  }
  file { "/home/${username}/.eyaml/keys/public_key.pkcs7.pem":
    ensure    => "present",
    mode      => 0664,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/puppet/public_key.pkcs7.pem",
  }

  exec { 'git init puppet':
    command   => "git init --bare puppet && \
cd /home/${username}/Workspace/vaio_ubuntu_setup/puppet && \
git remote add origin git@localhost:/var/git/puppet && \
git add . && \
git commit -m 'Initial Commit' && \
git push origin master",
    creates   => "/var/git/puppet",
    cwd       => "/var/git",
    require   => [ Package["git"], Exec['git clone vaio_ubuntu_setup from GitHub'] ],
  }
  file { '/var/git/puppet':
    ensure    => "directory",
    mode      => 0755,
    owner     => 'git',
    group     => 'git',
    require   => Exec['git init puppet']
  }

}