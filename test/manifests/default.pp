notify{"Testing 1 2 3 from puppet!": }

file { "/tmp/folder":
    ensure => "directory",
    mode => 0777,
}

file { "/tmp/folder/file_from_puppet":
    ensure => "present",
    mode => 0666,
    content => "some content\n",
}
