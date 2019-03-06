    $computername = $env:COMPUTERNAME
    $date = Get-Date -Format MM_dd_yy
    #Ensure there are no existing clusters
    Set-Service ClusSvc -startuptype "disabled" -ComputerName $computername
    Import-Module FailoverClusters
    Clear-ClusterNode

    #Test cluster and produce report
    Test-Cluster -Node $node1,$node2 -ReportName "Desktop\ClusterValidation_$($date)" 

    #Create Cluster
    New-Cluster -Name $clustername -Node $node1,$node2 -StaticAddress $ip

    #Set Cluster quorum
    Get-ClusterQuorum -Cluster $clustername | Set-ClusterQuorum -NodeandDiskMajority "Cluster Disk 4"

    #Add heartbeat network adapter, configure IP, name adapter/NIC Heartbeat and configure DTC
    #Testing TFS changes
