# Set defaults for file ownership/permissions
File {
  owner => "root",
  group => "root",
  mode  => 0644,
}

# Set defaults for path in executions
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

node "vaio.johandry.com" {

  $username		= johandry
  $timestamp	= generate('/bin/date', '+%m%d%Y_%H:%M:%S')

  include base
  include vpn

}
