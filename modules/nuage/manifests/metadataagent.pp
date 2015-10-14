# == Class: nuage::metadataagent
#
# Setup of Nuage MetaData agent.
#
# === Parameters
#
# [*nuage_metadata_port*]
#  TCP Port to listen for metadata server requests 
# (metadata_port in neutron.conf)
# 
# [*nuage_nova_metadata_ip*]
#  IP address used by Nova metadata server 
# (nova_metadata_ip in neutron.conf)
#
# [*nuage_nova_metadata_port*]
#  TCP Port used by Nova metadata server 
#  (metadata_listen_port in nova.conf or nova_metadata_port in neutron.conf)
#
# [*shared_secret*]
#  Shared secret to sign the instance-id request 
# (neutron_metadata_proxy_shared_secret in nova.conf or 
#   metadata_proxy_shared_secret in neutron.conf)
#
# [*nuage_nova_client_version*]
#  Defaults to '2'
#
# [*nuage_nova_os_username*]
#  Defaults to 'admin'
#
# [*nuage_nova_os_password*]
#  Defaults to 'admin'
#
# [*nuage_nova_os_tenant_name*]
#  Defaults to "demo"
#
# [*nuage_nova_auth_url*]
#  Defaults to http://<nova_metadata_ip>:5000/v2.0
#
# [*nuage_metadata_agent_start_with_ovs*]
# Set to True if nuage-metadata-agent needs to be started with 
# nuage-openvswitch-switch
#
# [*nuage_nova_api_endpoint_type*]
#  One of publicURL, internalURL, adminURL
#
# [*nuage_nova_region_name*]
#  Based on keystone endpoint-list
#
# [*package_ensure*]
#  To ensure that the nuage-metadata-agent package is available

class nuage::metadataagent(
  $metadata_port = '9697',
  $nova_metadata_ip = '127.0.0.1',
  $nova_metadata_port = '8775',
  $metadata_secret = 'NuageNetworksSharedSecret',
  $nova_client_version = '2',
  $nova_os_username = 'admin',
  $nova_os_password = 'admin',
  $nova_os_tenant_name = 'demo',
  $nova_auth_ip = undef,
  $metadata_agent_start_with_ovs = 'true',
  $nova_api_endpoint_type = 'publicURL',
  $nova_region_name = 'RegionOne',
  $package_ensure = present,
) {

  if $::neutron::core_plugin != 'neutron.plugins.nuage.plugin.NuagePlugin' {
    fail('Nuage plugin should be the core_plugin to use nuage-metadata-agent')
  }
  
  include ::nuage::params
  
  package { $::nuage::params::python_novaclient:
    ensure => present,
  }

  package { $::nuage::params::nuage_metadata_agent:
    ensure  => present,
    require => Package[$::nuage::params::python_novaclient]
  } ->
  file { '/etc/default/nuage-metadata-agent':
    content => template('nuage/nuage-metadata-agent.erb'),
    notify  => Service[$::nuage::params::nuage_openvswitch_switch],
  }

  service { $::nuage::params::nuage_vrs_package:
    subscribe => File['/etc/default/nuage-metadata-agent'],
  }
}
