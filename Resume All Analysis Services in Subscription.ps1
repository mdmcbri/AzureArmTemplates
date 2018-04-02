workflow auto-resume-aas
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
        if($status.State -ne "Succeeded")
        {
            write-Output "Azure Analysis Services $($status.Name) is currently being resumed"
            #If the status is not equal to Online/Succeeded, resume the AAS
            $status | Resume-AzureRMAnalysisServicesServer
            write-Output "Azure Analysis Services $($status.Name) has been resumed"
        }    
	}
}