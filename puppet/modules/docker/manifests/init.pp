class docker {

  # docker Group
  group { "docker":
    ensure 		=> "present",
  }

  exec { "install docker":
    command 	=> "wget -qO- https://get.docker.com/ | sh",
    creates		=> "/usr/bin/docker",
    logoutput	=> on_failure,
  }

}
