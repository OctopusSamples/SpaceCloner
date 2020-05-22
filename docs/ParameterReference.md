# Parameter Reference

The script accepts the following parameters.

## Source Information
- `SourceOctopusUrl` - the base url of the source Octopus Server for example: https://samples.octopus.app.  This can be the same as the destination.
- `SourceOctopusApiKey` - the API key to access the source Octopus Server, user must have read permissions
- `SourceSpaceName` - the name of the space you wish to copy from

## Destination Information
- `DestinationOctopusUrl` - the base url of the destination Octopus Server for example https://codeaperture.octopus.app.  This can be the same as the source.
- `DestinationOctopusApiKey` - the API key to access the destination Octopus Server, the user must have edit permissions
- `DestinationSpaceName` - the name of the space you wish to copy to.

## Items To Clone

All the items to clone parameters allow for the following filters:
- `all` -> special keyword which will clone everything
- Wildcards -> use AWS* to pull in all items starting with AWS
- Specific item names -> pass in specific item names to clone that item and only that item

You can provide a comma separated list of items.  For example setting the `VariableSetsToClone` to "AWS*,Global,Notification" will clone all variable sets which start with AWS, along with the global and notification variable sets.  

If you wish to skip an item you can exclude it from the parameter list OR set the value to an empty string "".  You must specify items to clone.  

- `EnvironmentsToClone` - The list of environments to clone.
- `ExternalFeedsToClone` - The list of external feeds to clone.  
- `InfrastructureAccountsToClone` - The list of accounts feeds to clone.  
- `LibraryVariableSetsToClone` - The list of library variable sets to clone. 
- `LifeCyclesToClone` - The list of lifecycles to clone.  
- `MachinePoliciesToClone` - The list of machine policies to clone.  
- `ProjectGroupsToClone` - The list of project groups to clone.  
- `ProjectsToClone` - The list of projects to clone.  
- `ScriptModulesToClone` - The list of script modules to clone. 
- `SpaceTeamsToClone` - The list of teams specific to the space to clone.  Will not clone system teams.  Version 2019 or higher required. 
- `StepTemplatesToClone` - The list of step templates to clone.  
- `TargetsToClone` - The list of targets to clone.  Please note, this won't clone any polling tentacles.
- `TenantsToClone` - The list of tenants to clone.  Please note, this will not clone tenant variables.
- `TenantTagsToClone` - The list of tenant tags to clone.  
- `WorkerPoolsToClone` - The list of worker pools to clone.  
- `WorkersToClone` - The list of worker to clone.  Please note, this won't clone any polling tentacles.         

## Parent / Child Projects
- `ParentProjectName` - The name of the project to clone.  This has to match to exactly one project in the source information.  If this is specified the regular project cloner process is skipped.
- `ChildProjectsToSync` - The list of projects to sync the deployment process with.   Uses the same wild card matching as the other filters.  Can match to 1 to N number of projects.

## Options

The values for these options are either `True`, `False` or `null`.  Null will cause the default parameter to be used.

- `OverwriteExistingCustomStepTemplates` - Indicates if existing custom step templates (not community step templates) should be overwritten.  Useful when you make a change to a step template you want to move over to another instance.  Defaults to `false`.
- `OverwriteExistingLifecyclesPhases` - Indicates you want to overwrite the phases on existing lifecycles.  This is useful when you have an updated lifecycle you want applied to applied to another space/instance.  You would want to leave this to false if the destination lifecycle has different phases.  Defaults to `false`.
- `OverwriteExistingVariables` - Indicates if all existing variables (except sensitive variables) should be overwritten.  Defaults to `false`.
- `CloneProjectChannelRules` - Indicates if the project channel rules should be cloned and overwrite existing channel rules.  Defaults to `false`.
- `CloneProjectRunbooks` - Indicates if project runbooks should be cloned or should be skipped.  This is useful when you just want a quick copy of a project and the variables, but not the runbooks.  Defaults to `true`.
- `CloneTeamUserRoleScoping` - Indicates if the space teams should have their scoping cloned.  Will use the same teams based on parameter `SpaceTeamsToClone`.  Defaults to `false`.
- `AddAdditionalVariableValuesOnExistingVariableSets` - Indicates a variable on the destination should only have one value.  You would have multiple values if you were scoping variables.  Defaults to `false`.

## AddAdditionalVariableValuesOnExistingVariableSets further detail

On your source you have a variable set with the following values:

![](../img/source-space-more-values.png)

On your destination space you have the same variable set with the following values:

![](../img/destination-less-values.png)

When the variable `AddAdditionalVariableValuesOnExistingVariableSets` is set to `True` it will add that missing value.

When the variable `AddAdditionalVariableValuesOnExistingVariableSets` is set to `False` it will not add that missing value.