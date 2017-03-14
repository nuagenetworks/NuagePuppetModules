import sys
import subprocess
from pipes import quote

interfaces = sys.argv[1].split(',')
vfs = sys.argv[2]

for iface in interfaces:
  print "creating VFs for interface: %s"%iface
  cmd1 = "echo '%s' > /sys/class/net/%s/device/sriov_numvfs" %(quote(vfs[0]), quote(iface))
  subprocess.call(cmd1, shell=True)
  cmd = "echo %s >> /etc/rc.local" %(quote(cmd1))
  subprocess.call(cmd, shell=True)
  print "enabling lldp for interface: %s"%iface
  cmd = "lldptool set-lldp -i %s adminStatus=rxtx" %(quote(iface))
  subprocess.call(cmd, shell=True)
  cmd = "lldptool -T -i %s -V  sysName enableTx=yes" %(quote(iface))
  subprocess.call(cmd, shell=True)
  cmd = "lldptool -T -i %s -V  portDesc enableTx=yes" %(quote(iface))
  subprocess.call(cmd, shell=True)
  cmd = "lldptool -T -i %s -V  sysDesc enableTx=yes" %(quote(iface))
  subprocess.call(cmd, shell=True)
  cmd = "lldptool -T -i %s -V sysCap enableTx=yes" %(quote(iface))
  subprocess.call(cmd, shell=True)
