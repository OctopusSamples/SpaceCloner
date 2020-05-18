# Space Cloner
Sample script to help you clone a space.

## This cloning process is provided as is!
Please test it on an empty space before attempting to use it for any kind of real-world use.  Please clone this repo and modify the script to meet your needs.  This script should be a starting point for your process.

## Who uses this process?
This script was developed by the Customer Success team at Octopus Deploy.  We use it to clone items for our [samples instance](https://samples.octopus.app).

## Will you fix my bug?  
Submit an issue if you encounter a bug.  We will triage it and give you a decision on if it will be fixed.

What won't be fixed:
- Failures as a result of cloning from differences in versions, for example `3.17.14` to `2020.2.6`.  
- Certain Excluded Object Types (sensitive variables, targets, workers, etc).  They were excluded for a specific reason.  
- Bugs from versions `3.x`, or `2018.x`.  If the script happens to work for those versions, yay, but it is unsupported.

## What about feature requests?
Unless it is something we (Customer Success) needs, we probably won't add it ourselves.  We encourage you to fork the repo, add your desired functionality.  If you think others will benefit submit a PR.

## Do you accept pull requests?
Yes!  If you want to improve this script please submit a pull request!

# Use Cases
This script was written to solve the following use cases.

- As a user I want to split my one massive default space into multiple spaces on the same instance.  [More details](docs/UseCase-BreakUpSpace.md)
- As a user I have two Octopus Deploy instances.  One for dev/test deployments.  Another for staging/prod deployments.  I have the same set of projects I want to keep in sync. [More details](docs/UseCase-KeepInstancesInSync.md)
- As a user I want to clone a set of projects to a test instance to experiment with some new options.
- As a user I want to merge multiple Octopus Deploy instances into the one space on one instance (we wouldn't recommend this, but it is possible).
- As a user I have a set of "master" projects.  I clone from that project when I need to create a new project.  However, when the process on the "master" project is updated I would like to update the existing projects.

# Versions Supported

It _should_ work with any Octopus version `3.4` or higher.  It was developed by testing against a version running `2020.x`.  Take from that what you will. 

The script will run a check at the start to compare the major and minor versions of the source and destination.  

**Unless the source and destination major.minor versions are the same, the script will not proceed.**

You will notice some version checks being run in the script.  This is to prevent the script from calling the API when it shouldn't.

# How It Works
Please see the [how it works page](docs/HowItWorks.md).

# Logging

This script will write to the host for you to keep track of what is going on.  It will also write to additional logs.  Each run will generate two new logs.

- CleanUpLog -> A log of items indicating what you will need to clean up
- Log -> The verbose log of the clone

The logs will be placed in the $PSScriptRoot\Core folder (where logging.ps1 is located) folder.

# Reference

Please see [parameter reference page](docs/ParameterReference.md)

## Examples

All these examples are for the [Target - SQL Server Space](https://samples.octopus.app/app#/Spaces-106) on the samples instance.

### Clone Everything
Set everything to all.  `All` is special keyword for the script.  When it sees that it will grab everything.

```
CloneSpace.ps1 -SourceOctopusUrl "https://samples.octopus.app" -SourceOctopusApiKey "SOME KEY" -SourceSpaceName "Target - SQL Server" -DestinationOctopusUrl "https://myinstance.octopus" -DestinationOctopusApiKey "My Key" -DestinationSpace Name "Demo Clone" -EnvironmentsToClone "all" -WorkerPoolsToClone "all" -ProjectGroupsToClone "all" -TenantTagsToClone "all" -ExternalFeedsToClone "all" -StepTemplatesToClone "all" -InfrastructureAccountsToClone "all" -LibraryVariableSetsToClone "all" -LifeCyclesToClone "all" -ProjectsToClone "all" -TenantsToClone "all" -OverwriteExistingVariables "True" -OneInstanceOfVariableAllowedOnDestination "False" -OverwriteExistingCustomStepTemplates "True" -OverwriteExistingLifecyclesPhases "True"
```

### Clone specific project(s)
If all you want to do is clone a specific project without worrying about dependencies you could do this.  It will ensure all the steps and variables and channels from the source project appear in the destination project.  It won't overwrite existing values.

```
CloneSpace.ps1 -SourceOctopusUrl "https://samples.octopus.app" -SourceOctopusApiKey "SOME KEY" -SourceSpaceName "Target - SQL Server" -DestinationOctopusUrl "https://myinstance.octopus" -DestinationOctopusApiKey "My Key" -DestinationSpace Name "Demo Clone" -ProjectsToClone "Redgate - Feature Branch Example,Redgate - Simple Deployment"
```

# Debugging

This is a script manipulating data and then calling an API, it is possible it will send a bad JSON body up to the API.  

All JSON requests are stored in the log.  For example:

```
Going to invoke POST https://code-aperture.octopus.app/api/Spaces-104/Environments with the following body
{
    "Id":  null,
    "Name":  "Test",
    "Description":  "",
    "SortOrder":  1,
    "UseGuidedFailure":  false,
    "AllowDynamicInfrastructure":  false,
    "SpaceId":  "Spaces-104",
    "ExtensionSettings":  [
                              {
                                  "ExtensionId":  "issuetracker-jira",
                                  "Values":  {

                                             }
                              }
                          ],
    "Links":  {
                  "Self":  "/api/Spaces-106/environments/Environments-111",
                  "Machines":  "/api/Spaces-106/environments/Environments-111/machines{?skip,take,partialName,roles,isDisabled,healthStatuses,commStyles,tenantIds,tenantTags,shellNames}",
                  "SinglyScopedVariableDetails":  "/api/Spaces-106/environments/Environments-111/singlyScopedVariableDetails",
                  "Metadata":  "/api/Spaces-106/environments/Environments-111/metadata"
              }
}
```

You can copy that body and URL into Postman to manipulate until it works for you.  Once you know the cause you can update the script to make sure it doesn't happen again.