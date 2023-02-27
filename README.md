# terraform-azurerm-byol-palo-new-rg-new-vnet

This Repo will create a Resource Group, creat a virtual network with mgmt, untrust, trust subnet, and place Palo in the subnet.
It will also bootstrap the Palo with preconfigured policies to allow trust -> untrust (SNAT), allow trust -> trust, deny everything else.

untrust subnet will be associated with DefaultNSG, where it allows incoming connection your egress public IP, it also allow inocming connection within vNet CIDR, but block everything else.