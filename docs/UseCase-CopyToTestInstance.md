# Copying to and from test instance

A lot of customers like to stand up a test instance to verify upgrades.  They want a set of projects that mimic the common deployment processes as their production instance.  

This use case is supported in with the Space Cloner script.

Please refer to the [how it works page](HowItWorks.md#what-will-it-clone) to get a full list of items cloned and not cloned.

# Example

In this case, you probably want to copy everything, but only include a handful of projects.  In the example script below it will copy all everything in a space plus a set of specific projects.

The other options are:
- `OverwriteExistingVariables` - set to `True` so variables are always overwritten (except for sensitive variables).
- `AddAdditionalVariableValuesOnExistingVariableSets` - set to `True` to add new variables values found for the same variable name.  
- `OverwriteExistingCustomStepTemplates` - Set to `True` so the step templates are kept in sync. You might have made some recent changes to the step template.  It is important to keep them up to date.
- `OverwriteExistingLifecyclesPhases` - Set to `True` since this is a full clone the overwrite existing lifecycle phases has been set to true as well.

```PowerShell
CloneSpace.ps1 -SourceOctopusUrl "https://instance1.yoursite.com" `
    -SourceOctopusApiKey "SOME KEY" `
    -SourceSpaceName "My Space Name" `
    -DestinationOctopusUrl "https://instance2.yoursite.com" `
    -DestinationOctopusApiKey "My Key" `
    -DestinationSpace Name "My Space Name" `    
    -EnvironmentsToClone "all" `
    -WorkerPoolsToClone "all" `
    -ProjectGroupsToClone "all" `
    -TenantTagsToClone "all" `
    -ExternalFeedsToClone "all" `
    -StepTemplatesToClone "all" `
    -InfrastructureAccountsToClone "all" `
    -LibraryVariableSetsToClone "all" `
    -LifeCyclesToClone "all" `
    -ProjectsToClone "Redgate - Feature Branch Example,DBUp SQL Server" `
    -TenantsToClone "all" `   
    -OverwriteExistingVariables "true" `
    -AddAdditionalVariableValuesOnExistingVariableSets "true" `
    -OverwriteExistingCustomStepTemplates "true" `
    -OverwriteExistingLifecyclesPhases "true"
```