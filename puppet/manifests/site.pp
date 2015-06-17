# Set defaults for file ownership/permissions
File {
  owner => "root",
  group => "root",
  mode  => 0644,
}

# Set defaults for path in executions
Exec { 
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] 
}

stage {'init': }
stage {'finish': }

Stage['init'] -> Stage['main'] -> Stage['finish']

node "vaio.johandry.com" {

  $timestamp  = generate('/bin/date', '+%m%d%Y_%H:%M:%S')

  # include base
  include users
  include networking
  include ssh
  include git
  include puppet
  
  include utils
  include scripts

  include development
  include devops

  include office
}
