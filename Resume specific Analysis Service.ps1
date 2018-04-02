workflow resume-gsi-x-aas
{
   

    write-output "Script Started"
    $con = Get-AutomationConnection -Name AzureRunAsConnection
	
	#Login 
    Add-AzureRMAccount -ServicePrincipal -Tenant $Con.TenantID -ApplicationId $Con.ApplicationID -CertificateThumbprint $Con.CertificateThumbprint
	write-output "Authenticated with Automation Run As Account."

	#Hardcode Resource Group and Azure Analysis Service
	$RGroup = 'ResourceGroup'
	$AASName = 'ResourceName'
	
	#Get Status of Azure Analysis Service and log
	$status = Get-AzureRMAnalysisServicesServer -ResourceGroupName $RGroup -Name $AASName
	write-output "Azure Analysis Service $($status.Name) has the status of $($status.State)"
	write-output "Azure Analysis Service $($status.Name) will now be resumed"

	#Suspend Azure Analysis Service and log
	Resume-AzureRMAnalysisServicesServer -Name $AASName
	$status = Get-AzureRMAnalysisServicesServer -ResourceGroupName $RGroup -Name $AASName
	write-output "Azure Analysis Service $($status.Name) now has the status of $($status.State)"
	
	
	
}