
<#

Title: RemoteiSCSIConfig.ps1
Author: Bradford Perkins
Description: This script configures the iSCSI network adapters, enables iSCSI, installs MPIO, and configures MPIO after a reboot. It utilizes a workflow to reboot the server and finalize the script.

Usage: prep-ISCSI -PSComputerName 10.58.161.33 -VLAN_Name ISCSI -ISCSI_AIP 10.58.17.22 -ISCSI_BIP 10.58.17.23 -PSCredential 10.58.161.33\administrator

#>

#Creates the workflow to configure iSCSI
workflow prep-ISCSI {
	#Create parameters
	param ([string[]]$VLAN_Name,
	   	   [string[]]$ISCSI_AIP,
	 	   [string[]]$ISCSI_BIP)
	
	#Name the iSCSI adapters and configure default subnet mask
	$VLAN_A = "$($VLAN_Name)_A"
	$VLAN_B = "$($VLAN_Name)_B"
	$ISCSI_Mask = 24
	
	#Rename Network Adapters to designate iSCSI A and B interfaces
	Get-NetAdapter -Name "Ethernet 1" | Rename-NetAdapter -NewName $VLAN_A
	Get-NetAdapter -Name "Ethernet 2" | Rename-NetAdapter -NewName $VLAN_B
	
	#Set IP address on ISCSI_A adapter
	$VLAN_AAdapter = Get-NetAdapter -Name $VLAN_A
	New-NetIPAddress `
        -InterfaceAlias $VLAN_AAdapter.Name `
        -AddressFamily IPv4 `
        -IPAddress $ISCSI_AIP `
        -PrefixLength $ISCSI_Mask
	
	#Set IP address on ISCSI_B adapter
	$VLAN_BAdapter = Get-NetAdapter -Name $VLAN_B
	New-NetIPAddress `
	    -InterfaceAlias $VLAN_BAdapter.Name `
	    -AddressFamily IPv4 `
	    -IPAddress $ISCSI_BIP `
	    -PrefixLength $ISCSI_Mask
	
	#Configure Jumbo Frames	
	Set-NetAdapterAdvancedProperty -Name ISCSI* -RegistryKeyword "*JumboPacket" -Registryvalue 9014
	
	#Enable iSCSI and Configure to Start Automatically, Set-Service is required when running the command remotely
	Set-Service msiscsi -Status Running
	Set-Service msiscsi -startuptype "automatic"
	
	##Install Windows features needed for a SQL cluster
	Enable and configure MPIO
	Enable-WindowsOptionalFeature -Online -FeatureName MultipathIO
	Install Failover Clustering
	Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
	Install-WindowsFeature -Name RSAT-Clustering-Mgmt
	Install-WindowsFeature -Name RSAT-Clustering-Powershell
	Install .NET 3.5
	Install-WindowsFeature -Name Net-Framework-Core -Source D:\sources\sxs
	
	Enable-MSDSMAutomaticClaim -BusType iSCSI -ErrorAction SilentlyContinue
	
	#Reboot computer and continue configuration of MPIO
	Restart-Computer -Wait -Force -For WinRM
	#Change default load balancing policy to Least Queue Depth
	Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy LQD -ErrorAction SilentlyContinue
	Set-MPIOSetting -NewDiskTimeout 60 -ErrorAction SilentlyContinue
	
}
#$creds = Get-Credential
#prep-ISCSI -PSComputerName 10.68.67.156 -VLAN_Name ISCSI -ISCSI_AIP 10.68.17.110 -ISCSI_BIP 10.68.17.111 -PSCredential $creds
