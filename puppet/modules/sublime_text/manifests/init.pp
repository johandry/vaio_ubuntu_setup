class sublime_text {

  $sublime_text_url		= "http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3083_amd64.deb"

  exec { "download sublime-text":
    command 	=> "wget -O /tmp/sublime-text.deb ${sublime_text_url} && dpkg --install /tmp/sublime-text.deb",
    creates		=> "/usr/bin/subl",
    logoutput	=> on_failure,
  }
}
