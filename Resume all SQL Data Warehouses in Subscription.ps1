workflow auto-resume-sqldw
{
    $con = Get-AutomationConnection -Name AzureRunAsConnection


	#Login 
    Add-AzureRMAccount -ServicePrincipal -Tenant $Con.TenantID -ApplicationId $Con.ApplicationID -CertificateThumbprint $Con.CertificateThumbprint

    #Get all SQL Datawarehouses in the subscription
    $dws = Get-AzureRmResource | Where-Object ResourceType -EQ "Microsoft.Sql/servers/databases" | Where-Object Kind -ILike "*datawarehouse*"
    
    #Loop through each datawarehouse
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
        if($status.Status -ne "Online")
        {
            write-Output "Database $($status.DatabaseName) is currently being resumed"
            #If the status is not equal to "Online", resume the SQLDW
            Resume-AzureRmSqlDatabase -ResourceGroupName "$rg" -ServerName "$sn" -DatabaseName "$db"
            write-Output "Database $($status.DatabaseName) has been resumed"
            
        }    
	}
}