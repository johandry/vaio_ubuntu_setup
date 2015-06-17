class development (
  $username           = $users::username,
  $sublime_text_url   = $development::sublime_text_url
) {

  file { "/home/${username}/Workspace":
    ensure    => "directory",
    mode      => 0750,
    owner     => $username,
    group     => $username,
  }

  file { "/home/${username}/Sandbox":
    ensure    => "directory",
    mode      => 0750,
    owner     => $username,
    group     => $username,
  }

  file { "/home/${username}/.gitconfig":
    ensure    => "file",
    mode      => 0664,
    owner     => $username,
    group     => $username,
    source    => "puppet:///modules/development/gitconfig",
  }

  exec { "git clone vaio_ubuntu_setup from GitHub":
    cwd       => "/home/${username}/Workspace",
    command   => "git clone git@github.com:johandry/vaio_ubuntu_setup.git /home/${username}/Workspace/vaio_ubuntu_setup",
    creates   => "/home/${username}/Workspace/vaio_ubuntu_setup",
    user      => $username,
    environment => ["HOME=/home/${username}"],
    logoutput => on_failure,
  }

  # Install Python 
  package { ["python3", "python3-pip"]:
    ensure    => "latest",
  }
  
  # Install Sublime Text 3
  exec { "install sublime-text":
    command   => "wget -O /tmp/sublime-text.deb ${sublime_text_url} && dpkg --install /tmp/sublime-text.deb",
    creates   => "/usr/bin/subl",
    logoutput => on_failure,
  }
  # After this, install the Packages with Sublime Text Package Control because it will update them to the latest version
}