Param(
[parameter(Mandatory=$true, HelpMessage="Target Portal(s)")]
[string[]]$targetportals

)

#Add target portals
foreach($targetportal in $targetportals){
New-IscsiTargetPortal -TargetPortalAddress $targetportal
}

#Refresh iSCSI targets
Update-IscsiTarget

#Find Netapp targets
$NetApptargets = Get-IscsiTarget | ? {$_.NodeAddress -match "com.netapp"} | Sort-Object -Unique Target

#Get ISCSI IP addresses
$iscsiIPs = Get-NetIPAddress | ? {$_.InterfaceAlias -match "ISCSI" -and $_.AddressFamily -match 'ipv4'} | Select-Object IPAddress

Connect-IscsiTarget -NodeAddress $NetApptargets.NodeAddress -InitiatorPortalAddress $iscsiIPs[0].IPAddress -TargetPortalAddress $targetportals[0] -IsMultipathEnabled $true -IsPersistent $true
Connect-IscsiTarget -NodeAddress $NetApptargets.NodeAddress -InitiatorPortalAddress $iscsiIPs[0].IPAddress -TargetPortalAddress $targetportals[1] -IsMultipathEnabled $true -IsPersistent $true
Connect-IscsiTarget -NodeAddress $NetApptargets.NodeAddress -InitiatorPortalAddress $iscsiIPs[1].IPAddress -TargetPortalAddress $targetportals[2] -IsMultipathEnabled $true -IsPersistent $true
Connect-IscsiTarget -NodeAddress $NetApptargets.NodeAddress -InitiatorPortalAddress $iscsiIPs[1].IPAddress -TargetPortalAddress $targetportals[3] -IsMultipathEnabled $true -IsPersistent $true

#Set disks to online and initialize
$iSCSIDisks = Get-Disk | ? {$_.FriendlyName -match "NETAPP LUN"}
foreach ($disk in $iSCSIDisks){
    if ($disk.OperationalStatus -match "Offline") {
        Write-Output "Changing disk $($disk.Number) to online"
        $disk | Set-Disk -IsOffline $false
    }
    else{
        Write-Output "Disk $($disk.Number) is online"
    }
    if ($disk.PartitionStyle -match "RAW"){
        $disk | Initialize-Disk -PartitionStyle GPT
    }
    else{
        Write-Output "Disk $($disk.Number) has been initialized"
    }
}

#Create new volumes from the disks
New-Partition -DiskNumber 1 -DriveLetter E -UseMaximumSize 
New-Partition -DiskNumber 2 -DriveLetter F -UseMaximumSize
New-Partition -DiskNumber 3 -DriveLetter G -UseMaximumSize
New-Partition -DiskNumber 4 -DriveLetter H -UseMaximumSize
New-Partition -DiskNumber 5 -DriveLetter J -UseMaximumSize

Get-Volume -DriveLetter E | Format-Volume -NewFileSystemLabel UserDB -FileSystem NTFS -Confirm:$false
Get-Volume -DriveLetter F | Format-Volume -NewFileSystemLabel DTC -FileSystem NTFS -Confirm:$false
Get-Volume -DriveLetter G | Format-Volume -NewFileSystemLabel SystemDB -FileSystem NTFS -Confirm:$false
Get-Volume -DriveLetter H | Format-Volume -NewFileSystemLabel TempDB -FileSystem NTFS -Confirm:$false
Get-Volume -DriveLetter J | Format-Volume -NewFileSystemLabel Quorum -FileSystem NTFS -Confirm:$false



