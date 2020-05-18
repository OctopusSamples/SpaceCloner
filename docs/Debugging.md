# Logging

This script will write to the host for you to keep track of what is going on.  It will also write to additional logs.  Each run will generate two new logs.

- CleanUpLog -> A log of items indicating what you will need to clean up
- Log -> The verbose log of the clone

The logs will be placed in the $PSScriptRoot\Core folder (where logging.ps1 is located) folder.

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