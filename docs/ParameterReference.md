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
- `EnvironmentsToClone` - Comma separated list of environments to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all environments.  Examples: "test,staging,production" or "all" or "prod*".  Default value is `null` indicating nothing will be cloned.
- `ExternalFeedsToClone` - Comma separated list of external feeds to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all external feeds.  Examples: "AWS*,docker hub" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `InfrastructureAccountsToClone` - Comma separated list of accounts feeds to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all accounts.  Examples: "AWS*,Azure*" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `LibraryVariableSetsToClone` - Comma separated list of library variable sets to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all variable sets.  Examples: "AWS*,Global" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `LifeCyclesToClone` - Comma separated list of lifecycles to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all lifecycles.  Examples: "AWS*,Default" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `MachinePoliciesToClone` - Comma separated list of machine policies to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all machine policies.  Examples: "AWS*,Default" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `ProjectGroupsToClone` - Comma separated list of project groups to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all project groups.  Examples: "AWS*,default project group" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `ProjectsToClone` - Comma separated list of projects to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all projects.  Examples: "AWS*,SQL Server" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.  This will not clone releases or deployments.
- `ScriptModulesToClone` - Comma separated list of script modules to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all script modules.  Examples: "get*" or "all".  Default value is `null` indicating nothing will be cloned.
- `StepTemplatesToClone` - Comma separated list of step templates to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all step templates.  Examples: "AWS*,SQL Server*" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `TargetsToClone` - Comma separated list of targets to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all targets.  Examples: "AWS*,development worker pool" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.  Please note, this won't clone any polling tentacles.
- `TenantsToClone` - Comma separated list of tenants to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all tenants.  Examples: "AWS*,internal" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `TenantTagsToClone` - Comma separated list of tenant tags to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all tenant tags.  Examples: "AWS*,my tag" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `WorkerPoolsToClone` - Comma separated list of worker pools to clone.  It will not clone workers.  Uses wildcard matching.  If you supply the word "all" it will clone all worker pools.  Examples: "AWS*,development worker pool" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.
- `WorkersToClone` - Comma separated list of worker to clone.  Uses wildcard matching.  If you supply the word "all" it will clone all workers.  Examples: "AWS*,development worker pool" or "all" or "AWS*".  Default value is `null` indicating nothing will be cloned.  Please note, this won't clone any polling tentacles.         

## Parent / Child Projects
- `ParentProjectName` - The name of the project to clone.  This has to match to exactly one project in the source information.  If this is specified the regular project cloner process is skipped.
- `ChildProjectsToSync` - The list of projects to sync the deployment process with.   Uses wildcard matching.  If you supply the word "all" it will clone all lifecycles.  Examples: "AWS*,Default" or "all" or "AWS*".  Default value is `null` indicating nothing will be synced.

## Options
- OverwriteExistingCustomStepTemplates` - Indicates if existing custom step templates (not community step templates) should be overwritten.  Useful when you make a change to a step template you want to move over to another instance.  Possible values are `true` or `false`.  Defaults to `false`.
- OverwriteExistingLifecyclesPhases` - Indicates you want to overwrite the phases on existing lifecycles.  This is useful when you have an updated lifecycle you want applied to applied to another space/instance.  You would want to leave this to false if the destination lifecycle has different phases.  Possible values are `true` or `false`.  Defaults to `false`.
- OverwriteExistingVariables` - Indicates if all existing variables (except sensitive variables) should be overwritten.  Possible values are `true` or `false`.  Defaults to `false`.
- CloneProjectRunbooks` - Indicates if project runbooks should be cloned or should be skipped.  This is useful when you just want a quick copy of a project and the variables, but not the runbooks.  Possible values are `true` or `false`.  Defaults to `true`.
- AddAdditionalVariableValuesOnExistingVariableSets` - Indicates a variable on the destination should only have one value.  You would have multiple values if you were scoping variables.  Possible values are `true` or `false`.  Defaults to `false`.

## AddAdditionalVariableValuesOnExistingVariableSets further detail

On your source you have a variable set with the following values:

![](../img/source-space-more-values.png)

On your destination space you have the same variable set with the following values:

![](../img/destination-less-values.png)

When the variable `AddAdditionalVariableValuesOnExistingVariableSets` is set to `True` it will add that missing value.

When the variable `AddAdditionalVariableValuesOnExistingVariableSets` is set to `False` it will not add that missing value.