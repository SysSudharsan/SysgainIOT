workflow webappbackupscript{
param(
        [Parameter(Mandatory=$true)]
        [string]
        $azureAccountName,

        [Parameter(Mandatory=$true)]
        [string]
        $azurePassword,

        [Parameter(Mandatory=$true)]
        [string]
        $storageAccountRg,

        [Parameter(Mandatory=$true)]
        [string]
        $storageAccountName,

        [Parameter(Mandatory=$true)]
        [string]
        $storageAccountLocation,

        [Parameter(Mandatory=$true)]
        [string]
        $webappName,

        [Parameter(Mandatory=$true)]
        [string]
        $apiappName,

        [Parameter(Mandatory=$true)]
        [string]
        $webappdbconnstrng

) 

InlineScript{

        $azureAccountName = $Using:azureAccountName
        $azurePassword = $Using:azurePassword
        $storageAccountRg = $Using:storageAccountRg
        $storageAccountName = $Using:storageAccountName
        $storageAccountLocation = $Using:storageAccountLocation
        $webappName = $Using:webappName
        $apiappName = $Using:apiappName
        $webappdbconnstrng = $Using:webappdbconnstrng
   <#
        $azureAccountName = "nvtuluva@sysgaincloud.onmicrosoft.com"
        $azurePassword = "indiatimes@225"
        $storageAccountRg = "srikala-iot5"
        $storageAccountName = "sysgain2010"
        $storageAccountLocation = "West US"
        $webappName = "webtestiot"
        $apiappName = "apiservererxwa"
        $webappdbconnstrng = "Server=tcp:sqlservererxwa.database.windows.net,1433;Initial Catalog=azuredb;Persist Security Info=False;User ID=sqluser;Password=Password@1234;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
 #>
 Set-ExecutionPolicy -ExecutionPolicy Unrestricted  -Force
 #$azureAccountName ="nvtuluva@sysgaincloud.onmicrosoft.com"
 #$azurePassword = ConvertTo-SecureString "indiatimes@225" -AsPlainText -Force
 $psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
 Login-AzureRmAccount -Credential $psCred
 Get-AzureRmSubscription
 #$storageAccountRg = "srikala-iot3"
 #$storageAccountName = "sysgain502"
 $webappContainer = "webappbackup"
 $apiappContainer = "apiappbackup"
 # $storageAccountKey = "Ib4ZfqBZvVqKfog/SMsN30XhUTuXPmQ4N0nOXOXuDPGt6buqI14HuZ3wbvc+/tOyJCf4+C6T8l7ErnbWq2YhKQ=="

 $StorageAccount = @{
    ResourceGroupName = $storageAccountRg;
    Name = $storageAccountName;
    SkuName = 'Standard_GRS';
    Location = $storageAccountLocation;
    }
 New-AzureRmStorageAccount @StorageAccount;
 $storageAccountKey1 = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName

 $Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName; 
 $StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $Keys[0].Value;

 New-AzureStorageContainer -Context $StorageContext -Name webappbackup;
 New-AzureStorageContainer -Context $StorageContext -Name apiappbackup;

 # $destStorageCtx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
	
 # New-AzureStorageContainer -Name $webappContainer -Context $destStorageCtx -Permission Container
 # New-AzureStorageContainer -Name $apiappContainer -Context $destStorageCtx -Permission Container

    Start-Sleep -s 60
 
    $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey1[0].Value
    

    $sasUrl1 = New-AzureStorageContainerSASToken -Name $webappContainer -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url1 = Write-Output $sasUrl1
    $sasUrl11 = $url1
    
    # $appName1 = "webiotapp"
    $backup1 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $webappName -StorageAccountUrl $sasUrl11

  Start-Sleep -s 60

    $sasUrl2 = New-AzureStorageContainerSASToken -Name $apiappContainer -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url2 = Write-Output $sasUrl2
    $sasUrl12 = $url2
    
    # $appName2 = "apiserverw4yjl"
    $backup2 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $apiappName -StorageAccountUrl $sasUrl12
    
    Start-Sleep -s 60

  $dbSetting1 = New-AzureRmWebAppDatabaseBackupSetting -Name DB1 -DatabaseType SqlAzure -ConnectionString $webappdbconnstrng
 # $dbSetting2 = New-AzureRmWebAppDatabaseBackupSetting -Name DB2 -DatabaseType SqlAzure -ConnectionString "Server=tcp:trendsqlw4yjl.database.windows.net,1433;Initial Catalog=dsm;Persist Security Info=False;User ID=adminuser;Password=Password@1234;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"  


 # $dbBackup2 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $appName2 -BackupName backup2 -StorageAccountUrl $sasUrl12 -Databases $dbSetting2
 $dbBackup1 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $webappName -BackupName backup1 -StorageAccountUrl $sasUrl11 -Databases $dbSetting1

 Edit-AzureRmWebAppBackupConfiguration -Name $apiappName -ResourceGroupName $storageAccountRg -StorageAccountUrl $sasUrl12 -FrequencyInterval 1 -FrequencyUnit Day -RetentionPeriodInDays 30 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)


 Edit-AzureRmWebAppBackupConfiguration -Name $webappName -ResourceGroupName $storageAccountRg -StorageAccountUrl $sasUrl11 -FrequencyInterval 1 -FrequencyUnit Day -RetentionPeriodInDays 30 -Databases $dbSetting1 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)

}
}
