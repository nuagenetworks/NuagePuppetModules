# == Class: nuage::nuage_sriov
#
# Setup services and interfaces for SRIOV
#
# === Parameters
#
# [*lldp_enabled*]
# (optional) The state of LLDP service
# Defaults to false
#
# [*interface_names*]
# (optional) Interface names on which SRIOV needs to be configured
# Defaults to undef
#
# [*number_of_vfs*]
# (optional) Number of Virtual Functions to be configured per NIC for SRIOV
# Defaults to undef
#
class nuage::nuage_sriov (
  $lldp_enabled    = false,
  $interface_names = undef,
  $number_of_vfs   = undef,
) {

  include ::nuage::params

  if $lldp_enabled {
    $package_ensure = 'present'
    $lldp_service_ensure = 'running'
  } else {
    $package_ensure = 'absent'
    $lldp_service_ensure = 'stopped'
  }

  package { 'lldp-package':
    ensure => $package_ensure,
    name   => $nuage::params::lldp_package
  }

  service { 'lldp-service':
    ensure  => $lldp_service_ensure,
    name    => $nuage::params::lldp_service,
    enable  => $lldp_enabled,
    require => Package['lldp-package'],
  }

  if $interface_names {
    exec { 'set-lldp':
      path    => '/usr/bin:/sbin',
      cwd     => '/etc/puppet/modules/nuage/manifests',
      command => "python configure_sriov_interfaces.py \"$interface_names\" \"$number_of_vfs\"",
      logoutput => true,
      require => Service['lldp-service'],
    }
  }
}
