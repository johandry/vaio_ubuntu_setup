class users (
  $username = $users::username
) {

  user { "${username}":
    ensure      => "present",
    managehome  => true,
    groups      => ['docker'],
  }

}