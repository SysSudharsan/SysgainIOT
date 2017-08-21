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

 $psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
 Login-AzureRmAccount -Credential $psCred
 Get-AzureRmSubscription

 $StorageAccount = @{
    ResourceGroupName = $storageAccountRg;
    Name = $storageAccountName;
    SkuName = 'Standard_GRS';
    Location = $storageAccountLocation;
    }
 New-AzureRmStorageAccount @StorageAccount;
 $Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName 
 $StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $Keys[0].Value
 New-AzureStorageContainer -Context $StorageContext -Name webbackup;
 New-AzureStorageContainer -Context $StorageContext -Name apibackup;

    Start-Sleep -s 30

 $storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName
    $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey[0].Value
    $blobContainerName1 = "webbackup"

    $sasUrl1 = New-AzureStorageContainerSASToken -Name $blobContainerName1 -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url1 = Write-Output $sasUrl1
    $sasUrl11 = $url1
    
    $backup1 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $webappName -StorageAccountUrl $sasUrl11

    Start-Sleep -s 60

    $blobContainerName2 = "apibackup"

    $sasUrl2 = New-AzureStorageContainerSASToken -Name $blobContainerName2 -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url2 = Write-Output $sasUrl2
    $sasUrl12 = $url2
    
   
    $backup2 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $apiappName -StorageAccountUrl $sasUrl12
    
    Start-Sleep -s 60

  $dbSetting1 = New-AzureRmWebAppDatabaseBackupSetting -Name DB1 -DatabaseType SqlAzure -ConnectionString $webappdbconnstrng
 # $dbSetting2 = New-AzureRmWebAppDatabaseBackupSetting -Name DB2 -DatabaseType SqlAzure -ConnectionString "Server=tcp:trendsqlw4yjl.database.windows.net,1433;Initial Catalog=dsm;Persist Security Info=False;User ID=adminuser;Password=Password@1234;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"  

 $dbBackup1 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $webappName -BackupName backup1 -StorageAccountUrl $sasUrl11 -Databases $dbSetting1
 # $dbBackup2 = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $apiappName -BackupName backup2 -StorageAccountUrl $sasUrl12 -Databases $dbSetting2

 Edit-AzureRmWebAppBackupConfiguration -Name $webappName -ResourceGroupName $storageAccountRg -StorageAccountUrl $sasUrl11 -FrequencyInterval 1 -FrequencyUnit Day -RetentionPeriodInDays 30 -Databases $dbSetting1 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)


 Edit-AzureRmWebAppBackupConfiguration -Name $apiappName -ResourceGroupName $storageAccountRg -StorageAccountUrl $sasUrl12 -FrequencyInterval 1 -FrequencyUnit Day -RetentionPeriodInDays 30 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)

}
}
