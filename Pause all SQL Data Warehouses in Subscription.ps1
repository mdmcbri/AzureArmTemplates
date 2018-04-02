workflow auto-pause-sqldw
{
	#$CredentialName = "SQLDW-Cred"
    $con = Get-AutomationConnection -Name AzureRunAsConnection

    #Get the credential with the above name from the Automation Asset store
    #$psCred = Get-AutomationPSCredential -Name $CredentialName
    #if(!$psCred) {
    #    Throw "Could not find an Automation Credential Asset named '${CredentialName}'. Make sure you have created one in this Automation Account."
    #}

	#Login using the above Credential
    #Login-AzureRmAccount -Credential $psCred -TenantId "c1eb5112-7946-4c9d-bc57-40040cfe3a91" -SubscriptionId "2993487a-69fa-4da2-8f33-773d303742ad"
    Add-AzureRMAccount -ServicePrincipal -Tenant $Con.TenantID -ApplicationId $Con.ApplicationID -CertificateThumbprint $Con.CertificateThumbprint

    #Get all SQL Datawarehouses in the subscription
    $dws = Get-AzureRmResource | Where-Object ResourceType -EQ "Microsoft.Sql/servers/databases" | Where-Object Kind -ILike "*datawarehouse*"
    
    #Loop through each SQLDW
    foreach($dw in $dws)
    {
        $rg = $dw.ResourceGroupName
        $dwc = $dw.ResourceName.split("/")
        $sn = $dwc[0]
        $db = $dwc[1]
        #$status = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sn -DatabaseName $db | Select Status
        $status = Get-AzureRmSqlDatabase -ResourceGroupName $rg -ServerName $sn -DatabaseName $db 
        write-output "Database $($status.DatabaseName) found with the status of $($status.Status)"
        #write-Output "Status is $($status.Status)"
        #Check the status
        if($status.Status -ne "Paused")
        {
            write-Output "Database $($status.DatabaseName) is currently being paused"
            #If the status is not equal to "Paused", pause the SQLDW
            Suspend-AzureRmSqlDatabase -ResourceGroupName "$rg" -ServerName "$sn" -DatabaseName "$db"
            write-Output "Database $($status.DatabaseName) is now paused"
        }    
	}
}