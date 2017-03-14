# == Class: nuage::params
#
# Parameters to be used during configuration
# Based on osfamily
#
# === Parameters
#

class nuage::params {
  if($::osfamily == 'RedHat') {
    $python_novaclient        = 'python-novaclient'
    $nuage_metadata_agent     = 'nuage-metadata-agent'
    $nuage_vrs_package        = 'nuage-openvswitch'
    $nuage_vrs_service        = 'openvswitch'
    $lldp_package             = 'lldpad'
    $lldp_service             = 'lldpad'
  }
  elsif($::osfamily == 'Debian') {
    $python_novaclient        = 'python-novaclient'
    $nuage_metadata_agent     = 'nuage-metadata-agent'
    $nuage_vrs_package        = 'nuage-openvswitch'
    $nuage_vrs_service        = 'nuage-openvswitch-switch'
    $lldp_package             = 'lldpad'
    $lldp_service             = 'lldpad'
  }
}
