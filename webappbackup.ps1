#param(
#[string] $azureAccountName,
#[string] $azurePassword,
#[string] $Tenantid,
#[string] $storageAccountRg
#Login
$azureAccountName ="nvtuluva@sysgaincloud.onmicrosoft.com"
$azurePassword = ConvertTo-SecureString "indiatimes@225" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
Login-AzureRmAccount -Credential $psCred
Get-AzureRmSubscription

# Storage Account Input
$storageAccountName = "webbackupacc"
    $storageAccountRg = "sudhartestwebapp"

    # This returns an array of keys for your storage account. Be sure to select the appropriate key. Here we select the first key as a default.
    $storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountRg -Name $storageAccountName
    $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey[0].Value

    $blobContainerName = "backup6"
    $sasUrl = New-AzureStorageContainerSASToken -Name $blobContainerName -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri
    $url = Write-Output $sasUrl

$sasUrl1 = $url
    $resourceGroupName = "sudhartestwebapp"
    $appName = "sudhartestwebapp"
    $backup = New-AzureRmWebAppBackup -ResourceGroupName $resourceGroupName -Name $appName -StorageAccountUrl $sasUrl1


    Start-Sleep -s 60

    $dbSetting1 = New-AzureRmWebAppDatabaseBackupSetting -Name webappDB -DatabaseType SqlAzure -ConnectionString "Server=tcp:weappsudhar.database.windows.net,1433;Initial Catalog=webappDB;Persist Security Info=False;User ID=dbadmin;Password=Welcome12345;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=50;"
    $dbBackup = New-AzureRmWebAppBackup -ResourceGroupName $resourceGroupName -Name $appName -BackupName SudharBackup -StorageAccountUrl $sasUrl1 -Databases $dbSetting1


    Edit-AzureRmWebAppBackupConfiguration -Name $appName -ResourceGroupName $resourceGroupName `
      -StorageAccountUrl $sasUrl1 -FrequencyInterval 6 -FrequencyUnit Hour -Databases $dbSetting1 `
      -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1)
