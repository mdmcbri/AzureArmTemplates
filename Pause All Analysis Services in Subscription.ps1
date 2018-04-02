workflow auto-pause-aas
{
    $con = Get-AutomationConnection -Name AzureRunAsConnection

	#Login 
    Add-AzureRMAccount -ServicePrincipal -Tenant $Con.TenantID -ApplicationId $Con.ApplicationID -CertificateThumbprint $Con.CertificateThumbprint

    #Get all Azure Analysis Services in the subscription
    $aas = Get-AzureRmResource | Where-Object ResourceType -EQ "Microsoft.AnalysisServices/servers" 
    
    #Loop through each AAS
    foreach($as in $aas)
    {
        $rg = $as.ResourceGroupName
        $asname = $as.ResourceName
		$status = Get-AzureRMAnalysisServicesServer -ResourceGroupName $rg -Name $asname
        write-output "Azure Analysis Services $($status.Name) found with the status of $($status.State)"
		
        #Check the status
        if($status.State -ne "Paused")
        {
            write-Output "Azure Analysis Services $($status.Name) is currently being paused"
            #If the status is not equal to "Paused", pause the AAS
            $status | Suspend-AzureRMAnalysisServicesServer
            write-Output "Azure Analysis Services $($status.Name) is now paused"
        }    
	}
}