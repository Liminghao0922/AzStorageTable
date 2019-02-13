@{

    # ID used to uniquely identify this module
    GUID                   = '93DAA983-1EC8-45E3-B457-FA9F61A8C703'

    # Author of this module
    Author                 = 'Minghao Li (MSFT)'

    # Company or vendor of this module
    CompanyName            = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright              = '© Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description            = 'Sample functions to add/retrieve/update entities on Azure Storage Tables from PowerShell. It requires latest Azure PowerShell module installed, which can be downloaded follow https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.3.0.'

    # HelpInfo URI of this module
    HelpInfoUri            = 'https://blogs.technet.microsoft.com/paulomarques/2017/01/17/working-with-azure-storage-tables-from-powershell/'
	
    # Version number of this module
    ModuleVersion          = '1.0.0'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion      = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '4.7.2'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    # Script module or binary module file associated with this manifest
    #ModuleToProcess = ''

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules          = @('AzStorageTableCoreHelper.psm1')

    FunctionsToExport      = @('Add-AzStorageTableRow',
        'Get-AzStorageTableRowAll',
        'Get-AzStorageTableRowByPartitionKey',
        'Get-AzStorageTableRowByPartitionKeyRowKey',
        'Get-AzStorageTableRowByColumnName',
        'Get-AzStorageTableRowByCustomFilter',
        'Update-AzStorageTableRow',
        'Remove-AzStorageTableRow',
        'Get-AzStorageTableTable'
    )

    VariablesToExport      = ''

}
