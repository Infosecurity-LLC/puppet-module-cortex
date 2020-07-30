# == Class: cortex::config
#
# Perform configuration for Cortex package. This involves the following steps:
# 1. Adding the application.conf file from templates, which is requried for launching the server.
# 2. Cloning the GitHub repository containing Cortex analyzers.
class cortex::config inherits cortex {
  require ::cortex::install

  group { $cortex::group:
    ensure => 'present',
  }

  user { $cortex::user:
    ensure => 'present',
    gid    => $cortex::group,
  }

  file { $cortex::config_dir:
    ensure => directory,
    owner  => $cortex::user,
    group  => $cortex::group,
    mode   => '0550',
  }

  file { "${cortex::config_dir}/${cortex::config_file}":
    ensure  => file,
    content => template($cortex::config_template),
    owner   => $cortex::user,
    group   => $cortex::group,
    mode    => '0440',
    notify  => Service['cortex.service'],
  }

  # Clone the Cortex-Analyzers GitHub repository.
  if $cortex::analyzers_git_path {
    vcsrepo { $cortex::analyzers_git_path:
      ensure   => present,
      provider => git,
      source   => $cortex::analyzers_git_repo,
      revision => $cortex::analyzers_git_repo_tag,
      owner    => $cortex::user,
      group    => $cortex::group,
      notify  => Service['cortex.service'],
    }
  }
}
