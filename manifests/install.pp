class cerebro::install (
  $version      = $::cerebro::version,
  $address      = $::cerebro::address,
  $port         = $::cerebro::port,
  $user         = $::cerebro::cerebro_user,
  $package_url  = $::cerebro::package_url,
  $sysconfig    = $::cerebro::sysconfig,
  $proxy_server = $::cerebro::proxy_server,
  $proxy_type   = $::cerebro::proxy_type,
) {
  $group = $user
  $real_package_url = pick($package_url, "https://github.com/lmenezes/cerebro/releases/download/v${version}/cerebro-${version}.tgz")

  file { "/opt/cerebro-${version}":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  archive { "/tmp/cerebro-${version}.tgz":
    source       => $real_package_url,
    extract      => true,
    extract_path => '/opt',
    creates      => "/opt/cerebro-${version}/bin",
    cleanup      => true,
    user         => $user,
    group        => $group,
    proxy_server => $proxy_server,
    proxy_type   => $proxy_type,
    require      => File["/opt/cerebro-${version}"],
  }

  file { '/opt/cerebro':
    ensure  => 'link',
    target  => "/opt/cerebro-${version}",
    require => Archive["/tmp/cerebro-${version}.tgz"],
  }

  file { '/opt/cerebro/logs':
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => File['/opt/cerebro'],
  }

  file { '/var/log/cerebro':
    ensure => 'link',
    target => '/opt/cerebro/logs',
  }

  file { '/etc/cerebro':
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  file { '/var/cerebro':
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  file { '/var/run/cerebro':
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  file { '/etc/tmpfiles.d/cerebro.conf':
    content => template('cerebro/etc/tmpfiles.d/cerebro.conf.erb'),
  }


  if ($::operatingsystem == 'Amazon') {
    file { '/etc/init.d/cerebro':
      content => template('cerebro/etc/init.d/cerebro.erb'),
      mode    => '0744',
    }
  } else {
    ::systemd::unit_file { 'cerebro.service':
      content => template('cerebro/etc/systemd/system/cerebro.service.erb'),
    }
  }

}
