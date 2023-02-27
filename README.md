# terraform-azurerm-byol-palo-new-rg-new-vnet

This Repo will create a Resource Group, creat a virtual network with mgmt, untrust, trust subnet, and place Palo in the subnet.
It will also bootstrap the Palo with preconfigured policies to allow trust -> untrust (SNAT), allow trust -> trust, deny everything else.

mgmt subnet will be associated with DefaultNSG, where it allows incoming connection your egress public IP for management, it also allow inocming connection within vNet CIDR, but block everything else.

Palo will have three interfaces
- eth0 -> mgmt
- eth1 -> untrust
- eth2 -> trust

Both untrust and trust have IP Forwarding enabled. mgmt have IP Forwarding disabled.

Static route will be configured
- 0/0 -> first IP of untrust subnet via eth1
- RFC1918 -> first IP of trust subnet via eth2

HTTPs enabled for trust interface management, this will be used for Health Check from Internal Network Load Balancer.

Included bootstrapped firewall username: ```fwadmin```
Password: ```sb%BSu/.T+j3```

It's reccommended you create your own bootstrap.xml, so that it will have different default password and SSH public Key value

https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-bootstrapxml-file

Reference to bootstrap/bootstrap.xml, find and replace VM name and static routes target IP wth following:
```
    ${palo_vm_name} -> Two references
    ${trust_subnet_router} -> First IP of trust subnet, three references for the three RFC1918 ranges
    ${untrust_subnet_router} -> First IP of untrust subnet, one reference for the default route
```
