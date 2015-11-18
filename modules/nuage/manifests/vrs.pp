# == Class: nuage::vrs
#
# Setup of Nuage VRS.
#
# === Parameters
#
# [*active_controller*]
#   (required) IP address of the active VSP controller
#
# [*backup_controller*]
#   (optional) IP address of the backup VSP controller
#
# [*package_ensure*]
#  (optional) Ensure that Nuage VRS package is present.
#  Default is True
#

class nuage::vrs (
  $active_controller,
  $backup_controller = undef,
  $package_ensure    = 'present',
) {

  include ::nuage::params

  package { $nuage::params::nuage_vrs_package:
    ensure => $package_ensure,
    name   => $nuage::params::nuage_vrs_package
  }


  file_line { 'openvswitch active controller ip address':
    ensure  => present,
    line    => "ACTIVE_CONTROLLER=${active_controller}",
    match   => 'ACTIVE_CONTROLLER=',
    path    => '/etc/default/openvswitch',
    notify  => Service[$nuage::params::nuage_vrs_service],
    require => Package[$nuage::params::nuage_vrs_package],
  }

  if $backup_controller != undef {
    file_line { 'openvswitch backup controller ip address':
      ensure  => present,
      line    => "BACKUP_CONTROLLER=${backup_controller}",
      match   => 'BACKUP_CONTROLLER=',
      path    => '/etc/default/openvswitch',
      notify  => Service[$nuage::params::nuage_vrs_service],
      require => Package[$nuage::params::nuage_vrs_package],
    }
  }

  service { $nuage::params::nuage_vrs_service:
    ensure => 'running',
    name   => $nuage::params::nuage_vrs_service,
    enable => true,
  }
}
