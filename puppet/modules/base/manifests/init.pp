class base () {

  exec { 'apt-get update & upgrade':
    command		=> "apt-get update && apt-get upgrade -y",
    logoutput	=> on_failure,
  }

}
