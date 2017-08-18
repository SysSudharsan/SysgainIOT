
Set-ExecutionPolicy -ExecutionPolicy Unrestricted  -Force
$azureAccountName ="nvtuluva@sysgaincloud.onmicrosoft.com"
$azurePassword = ConvertTo-SecureString "indiatimes@225" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
Login-AzureRmAccount -Credential $psCred
Get-AzureRmSubscription
$storageAccountRg = "sysgainwebapp"
$storageAccountName = "komali100"
$StorageAccount = @{
    ResourceGroupName = $storageAccountRg;
    Name = $storageAccountName;
    SkuName = 'Standard_GRS';
    Location = 'West US';
    }
New-AzureRmStorageAccount @StorageAccount;
$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName 
$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $Keys[0].Value
New-AzureStorageContainer -Context $StorageContext -Name backup;
    Start-Sleep -s 30
 $storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName
    $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey[0].Value
    $blobContainerName = "backup"
    $sasUrl = New-AzureStorageContainerSASToken -Name $blobContainerName -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url = Write-Output $sasUrl
$sasUrl1 = $url
    
    $appName = "sysgainwebapp"
    $backup = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $appName -StorageAccountUrl $sasUrl1

    Start-Sleep -s 60
    
    $dbSetting1 = New-AzureRmWebAppDatabaseBackupSetting -Name syswebapp -DatabaseType SqlAzure -ConnectionString "Server=tcp:syswebapp.database.windows.net,1433;Initial Catalog=syswebapp;Persist Security Info=False;User ID=dbadmin;Password=Welcome12345;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=50;"
    $dbBackup = New-AzureRmWebAppBackup -ResourceGroupName $storageAccountRg -Name $appName -BackupName SudharBackup -StorageAccountUrl $sasUrl1 -Databases $dbSetting1
 

 Edit-AzureRmWebAppBackupConfiguration -Name $appName -ResourceGroupName $storageAccountRg -StorageAccountUrl $sasUrl1 -FrequencyInterval 1 -FrequencyUnit Day -RetentionPeriodInDays 30 -Databases $dbSetting1 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)




 
