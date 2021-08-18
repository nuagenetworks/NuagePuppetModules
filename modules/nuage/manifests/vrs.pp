# == Class: nuage::vrs
#
# Setup of Nuage VRS.
#
# === Parameters
#
# [*active_controller*]
#   (required) IP address of the active VSP controller
#
# [*standby_controller*]
#   (optional) IP address of the standby VSP controller
#
# [*bridge_mtu*]
#   (optional) non-default MTU configuration
#
# [*enable_hw_offload*]
#   (optional) Configure OVS to use
#   Hardware Offload
#   Defaults to False
#
# [*package_ensure*]
#  (optional) Ensure that Nuage VRS package is present.
#  Default is True
#
# [*vrs_extra_configs*]
#   (optional) Extra config params and values for
#   nuage-openvswitch
#   Default is undef

class nuage::vrs (
  $active_controller,
  $standby_controller = undef,
  $bridge_mtu = undef,
  $enable_hw_offload = false,
  $package_ensure    = 'present',
  $vrs_extra_configs = undef,
) {

  include ::nuage::params

  package { $nuage::params::nuage_vrs_package:
    ensure => $package_ensure,
    name   => $nuage::params::nuage_vrs_package
  }

  file_line { 'openvswitch active controller ip address':
    ensure  => present,
    line    => "ACTIVE_CONTROLLER=${active_controller}",
    match   => '([^_]|^)ACTIVE_CONTROLLER=',
    path    => '/etc/default/openvswitch',
    notify  => Service[$nuage::params::nuage_vrs_service],
    require => Package[$nuage::params::nuage_vrs_package],
  }

  if $standby_controller != undef {
    file_line { 'openvswitch standby controller ip address':
      ensure  => present,
      line    => "STANDBY_CONTROLLER=${standby_controller}",
      match   => '([^_]|^)STANDBY_CONTROLLER=',
      path    => '/etc/default/openvswitch',
      notify  => Service[$nuage::params::nuage_vrs_service],
      require => Package[$nuage::params::nuage_vrs_package],
    }
  }

  if $bridge_mtu != undef and $bridge_mtu != '' {
    file_line { 'non-default MTU configuration':
      ensure  => present,
      line    => "BRIDGE_MTU=${bridge_mtu}",
      match   => 'BRIDGE_MTU=',
      path    => '/etc/default/openvswitch',
      notify  => Service[$nuage::params::nuage_vrs_service],
      require => Package[$nuage::params::nuage_vrs_package],
    }
  }

  if $enable_hw_offload {
    vs_config { 'other_config:hw-offload':
      value  => 'true',
      notify => Service[$nuage::params::nuage_vrs_service],
      wait   => true,
    }
  }

  if $vrs_extra_configs != undef and $vrs_extra_configs != {} {
    $vrs_extra_configs.each |$key, $value| {
      file_line { "configuring $key":
        ensure  => present,
        line    => "$key=$value",
        match   => "^$key=",
        path    => '/etc/default/openvswitch',
        notify  => Service[$nuage::params::nuage_vrs_service],
        require => Package[$nuage::params::nuage_vrs_package],
      }
    }
  }

  service { $nuage::params::nuage_vrs_service:
    ensure => 'running',
    name   => $nuage::params::nuage_vrs_service,
    enable => true,
  }

  firewall { '118 neutron vxlan networks ipv4':
    ensure => 'absent',
    state  => 'NEW',
    chain  => 'INPUT',
    proto  => 'udp',
    dport  => '4789',
    action => 'accept',
  }

  # We are adding "stateless" in the name because puppet will not allow
  # two Resources sharing same Statement. The other reason is to
  # show difference in the name for these 2 rules.
  firewall { '118 neutron stateless vxlan networks ipv4':
    chain  => 'INPUT',
    proto  => 'udp',
    dport  => '4789',
    action => 'accept',
  }
}
