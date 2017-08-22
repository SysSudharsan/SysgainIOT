<#
Long-term backup retention is currently in preview and available in the following regions: 
Australia East, Australia Southeast, Brazil South, Central US, East Asia, East US, East US 2, 
India Central, India South, Japan East, Japan West, North Central US, North Europe, South Central US, 
Southeast Asia, West Europe, and West US.
#>

workflow dbbackupscript{
param(
        [Parameter(Mandatory=$true)]
        [string]
        $azureAccountName,

        [Parameter(Mandatory=$true)]
        [string]
        $azurePassword,

        [Parameter(Mandatory=$true)]
        [string]
        $resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]
        $sqlserverName,

        [Parameter(Mandatory=$true)]
        [string]
        $recoveryServiceVaultName,

        [Parameter(Mandatory=$true)]
        [string]
        $RetentionDurationType,

        [Parameter(Mandatory=$true)]
        [string]
        $RetentionCount

) 

InlineScript{

        $azureAccountName = $Using:azureAccountName
        $azurePassword = $Using:azurePassword
        $resourceGroupName = $Using:resourceGroupName
        $sqlserverName = $Using:sqlserverName
        $recoveryServiceVaultName = $Using:recoveryServiceVaultName
        $RetentionDurationType = $Using:RetentionDurationType
        $RetentionCount = $Using:RetentionCount

 # $azureAccountName ="nvtuluva@sysgaincloud.onmicrosoft.com"
 # $azurePassword = ConvertTo-SecureString "indiatimes@225" -AsPlainText -Force
 $psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
 Login-AzureRmAccount -Credential $psCred
 Get-AzureRmSubscription

 # Create a recovery services vault

 # $resourceGroupName = "srikala-iot5"
 # $serverName = "trendsqlerxwa"


 $serverLocation = (Get-AzureRmSqlServer -ServerName $sqlserverName -ResourceGroupName $resourceGroupName).Location
 # $recoveryServiceVaultName = "vmbackupvault567"

 $vault = New-AzureRmRecoveryServicesVault -Name $recoveryServiceVaultName -ResourceGroupName $resourceGroupName -Location $serverLocation 
 Set-AzureRmRecoveryServicesBackupProperties -BackupStorageRedundancy LocallyRedundant -Vault $vault

 # Set your server to use the vault to for long-term backup retention 

 Set-AzureRmSqlServerBackupLongTermRetentionVault -ResourceGroupName $resourceGroupName -ServerName $serverName -ResourceId $vault.Id

 # Retrieve the default retention policy for the AzureSQLDatabase workload type
 $retentionPolicy = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureSQLDatabase

 # Set the retention value to two years (you can set to any time between 1 week and 10 years)
 $retentionPolicy.RetentionDurationType = $RetentionDurationType
 $retentionPolicy.RetentionCount = $RetentionCount
 $retentionPolicyName = "dbRetentionPolicy"

 # Set the vault context to the vault you are creating the policy for
 Set-AzureRmRecoveryServicesVaultContext -Vault $vault

 # Create the new policy
 $policy = New-AzureRmRecoveryServicesBackupProtectionPolicy -name $retentionPolicyName -WorkloadType AzureSQLDatabase -retentionPolicy $retentionPolicy
 $policy

 # Enable long-term retention for a specific SQL database
 $policyState = "enabled"
 Set-AzureRmSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName -State $policyState -ResourceId $policy.Id

}
}
