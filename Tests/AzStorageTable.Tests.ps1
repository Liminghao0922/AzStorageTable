Import-Module .\Az.StorageTable.psd1 -Force

$choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Y", "&N")
$useEmulator = $Host.UI.PromptForChoice("Use local Azure Storage Emulator?", "", $choices, 0)
$useEmulator = $useEmulator -eq 0

$uniqueString = Get-Date -UFormat "PsTest%Y%m%dT%H%M%S"

Describe "AzStorageTable" {
    BeforeAll {
        if ($useEmulator) {
            $context = New-AzStorageContext -Local
        }
        else {
            $subscriptionName = Read-Host "Enter Azure Subscription Id"                
            $locationName = Read-Host "Enter Azure Location name"

            Write-Host -for DarkGreen "Login to Azure"
            #Login-AzureRmAccount
            Select-AzSubscription -Subscription $subscriptionName

            Write-Host -for DarkGreen "Creating resource group $($uniqueString)"
            New-AzResourceGroup -Name $uniqueString -Location $locationName

            Write-Host -for DarkGreen "Creating storage account $($uniqueString.ToLower())"
            New-AzStorageAccount -ResourceGroupName $uniqueString -Name $uniqueString.ToLower() -Location $locationName -SkuName Standard_LRS -Kind StorageV2

            $storage = Get-AzStorageAccount -ResourceGroupName $uniqueString -Name $uniqueString
            #  $context = New-AzStorageContext -ConnectionString  $storage.Context.ConnectionString
            $context = $storage.Context
        }

        # Storage Table
        $tables = [System.Collections.ArrayList]@()
        $tableNames = @("$($uniqueString)insert", "$($uniqueString)delete")
        foreach ($tableName in $tableNames) {
            Write-Host -for DarkGreen "Creating Storage Table $($tableName)"
            $table = New-AzStorageTable -Name $tableName -Context $context
            $tables.Add($table)
        }       
    }

    Context "Get-AzStorageTableTable" {
        if (-not $useEmulator) {
            $table = Get-AzStorageTableTable -resourceGroup $uniqueString -storageAccountName $uniqueString -table "$($uniqueString)insert"
            $table | Should Not Be $null
        }
    }

    Context "Add-StorageTableRow" {
        BeforeAll {
            $tableInsert = $tables | Where-Object -Property Name -EQ "$($uniqueString)insert"
        }

        It "Can add entity" {
            $expectedPK = "pk"
            $expectedRK = "rk"

            Add-AzStorageTableRow -table $tableInsert `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowAll -table $tableInsert

            $entity.PartitionKey | Should be $expectedPK
            $entity.RowKey | Should be $expectedRK
        }

        It "Can add entity with empty partition key" {
            $expectedPK = ""
            $expectedRK = "rk"

            Add-AzStorageTableRow -table $tableInsert `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByPartitionKey -table $tableInsert `
                -partitionKey $expectedPK

            $entity.PartitionKey | Should be $expectedPK
            $entity.RowKey | Should be $expectedRK
        }

        It "Can add entity with empty row key" {
            $expectedPK = "pk"
            $expectedRK = ""

            Add-AzStorageTableRow -table $tableInsert `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByColumnName -table $tableInsert `
                -columnName "RowKey" -value $expectedRK -operator Equal

            $entity.PartitionKey | Should be $expectedPK
            $entity.RowKey | Should be $expectedRK
        }

        It "Can add entity with empty partition and row keys" {
            $expectedPK = ""
            $expectedRK = ""

            Add-AzStorageTableRow -table $tableInsert `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByCustomFilter -table $tableInsert `
                -customFilter "(PartitionKey eq '$($expectedPK)') and (RowKey eq '$($expectedRK)')"

            $entity.PartitionKey | Should be $expectedPK
            $entity.RowKey | Should be $expectedRK
        }

        It "Can get entity by partion key and row key" {
            $expectedPK = "pk1"
            $expectedRK = "rk1"

            Add-AzStorageTableRow -table $tableInsert `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByPartitionKeyRowKey -table $tableInsert `
                -partitionKey $expectedPK -rowKey $expectedRK

            $entity.PartitionKey | Should be $expectedPK
            $entity.RowKey | Should be $expectedRK
        }

    }

    Context "Remove-AzureStorageTableRow" {
        BeforeAll {
            $tableDelete = $tables | Where-Object -Property Name -EQ "$($uniqueString)delete"
        }

        It "Can delete entity" {
            $expectedPK = "pk"
            $expectedRK = "rk"

            Add-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowAll -table $tableDelete

            $entity | Should Not Be $null

            Remove-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK -rowKey $expectedRK

            $entity = Get-AzStorageTableRowAll -table $tableDelete

            $entity | Should Be $null
        }

        It "Can delete entity with empty partition key" {
            $expectedPK = ""
            $expectedRK = "rk"

            Add-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByPartitionKey -table $tableDelete `
                -partitionKey $expectedPK

            $entity | Should Not Be $null

            Remove-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK -rowKey $expectedRK

            $entity = Get-AzStorageTableRowByPartitionKey -table $tableDelete `
                -partitionKey $expectedPK

            $entity | Should Be $null
        }

        It "Can delete entity with empty row key" {
            $expectedPK = "pk"
            $expectedRK = ""

            Add-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByColumnName -table $tableDelete `
                -columnName "RowKey" -value $expectedRK -operator Equal

            $entity | Should Not Be $null

            Remove-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK -rowKey $expectedRK

            $entity = Get-AzStorageTableRowByColumnName -table $tableDelete `
                -columnName "RowKey" -value $expectedRK -operator Equal

            $entity | Should Be $null
        }

        It "Can delete entity with empty partition and row keys" {
            $expectedPK = ""
            $expectedRK = ""

            Add-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK `
                -rowKey $expectedRK `
                -property @{}

            $entity = Get-AzStorageTableRowByCustomFilter -table $tableDelete `
                -customFilter "(PartitionKey eq '$($expectedPK)') and (RowKey eq '$($expectedRK)')"

            $entity | Should Not Be $null

            Remove-AzStorageTableRow -table $tableDelete `
                -partitionKey $expectedPK -rowKey $expectedRK

            $entity = Get-AzStorageTableRowByCustomFilter -table $tableDelete `
                -customFilter "(PartitionKey eq '$($expectedPK)') and (RowKey eq '$($expectedRK)')"

            $entity | Should Be $null
        }
    }

    AfterAll { 
        Write-Host -for DarkGreen "Cleanup in process"

        if ($useEmulator) {
            foreach ($tableName in $tableNames) {
                Remove-AzStorageTable -Context $context -Name $tableName -Force
            }
        }
        else {
            Remove-AzStorageAccount -Context $context
        }

        Write-Host -for DarkGreen "Done"
    }
}