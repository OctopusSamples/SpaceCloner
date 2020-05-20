# Space Cloner
Sample PowerShell script to help you clone a space using the Octopus Deploy Restful API.

# This cloning process is provided as is
This script was developed internally for the Customer Success team at Octopus Deploy to solve specific use cases we encounter each day.  We are sharing this script to help others.  Think of this script as a starting point for your process.

Please test it on an empty space before attempting to use it for any kind of real-world use.  If you find something isn't working for your instance, fork this repo and modify the script to meet your needs.  

# Use Cases
This script was written to solve the following use cases.

- As a user I want to split my one massive default space into [multiple spaces on the same instance](docs/UseCase-BreakUpSpace.md).
- As a user I have two Octopus Deploy instances.  One for dev/test deployments.  Another for staging/prod deployments.  I have the [same set of projects I want to keep in sync](docs/UseCase-KeepInstancesInSync.md).
- As a user I want to clone a set of projects to a test instance to [verify an upgrade](docs/UseCase-CopyToTestInstance.md).
- As a user I have a set of "parent" projects.  I clone from that project when I need to create a new project.  However, when the process on the "parent" project is updated I would like to [update the existing "child" projects](docs/UseCase-ParentChildProjects.md).
- As a user I would like to copy my projects from [self-hosted Octopus to Octopus Cloud](docs/UseCase-MigrateFromSelfHostedToCloud.md).

## Possible but not recommended.

- As a user I want to merge multiple Octopus Deploy instances into the one space on one instance.  We wouldn't recommend merging multiple disparate instances into one massive space.  The chance of overwriting something important is very high.  Just like steering a car with your knees, while possible it is not recommended.

# How It Works
Please see the [how it works page](docs/HowItWorks.md).

# Sensitive Variables
Please see the page [sensitive variables](docs/SensitiveVariables.md) to see how sensitive variables are handled.

# Debugging and Logging
Please see the [debugging and logging page](docs/Debugging.md).

# Reference
Please see [parameter reference page](docs/ParameterReference.md).

# Examples
Please see the [example page](docs/Examples.md).

# FAQ
Some common questions and answers about this sample project.

### Why was this script created?
This script was developed by the Customer Success team at Octopus Deploy.  We use it to clone items for our [samples instance](https://samples.octopus.app).

### Will you fix my bug?  
Maybe.  As this is a sample script we may or may not fix it.  You can submit an issue.  We will triage it and give you a decision on if it will be fixed.  You are free to fork this repo and fix the issue yourself.

### What won't be fixed
The following issues we know will happen and we have no intention of ever fixing.
- Failures as a result of cloning from differences in versions, for example `3.17.14` to `2020.2.6`.  
- Certain Excluded Object Types (sensitive variables, teams, users, etc).  They were excluded for a specific reason.  
- Bugs from versions `3.x`, or `2018.x`.  If the script happens to work for those versions, yay, but it is unsupported.

### What about feature requests?
Unless it is something we (Customer Success) needs, we probably won't add it ourselves.  We encourage you to fork the repo, add your desired functionality.  If you think others will benefit submit a PR.

### Do you accept pull requests?
Yes!  If you want to improve this script please submit a pull request!

### Can I use this to migrate from self-hosted to the cloud?
Yes.  However, this script will only jump start your migration, but it it won't do a full migration.  This script hits the API, meaning it won't have access to your sensitive variables, and purposely leaves out workers and tentacles.  See the [how it works](docs/HowItWorks.md) page for details on what it will and won't clone.  

### Is this the space migration / self-hosted to Octopus Cloud migrator tool that has been teased in the past?
No.  It was designed for specific use cases and the limits placed on it were intentional.  For example, it can't access your Master Key, and without that it cannot decrypt you sensitive data.  It should get you 80% of the way there.  You are free to fork this repo to modify the scripts to help get you another 15% of the way there.  

### What version of Octopus Deploy does this script support?
It _should_ work with any Octopus version `3.4` or higher.  It was developed by testing against a version running `2020.x`.  Take from that what you will. 

The script will run a check at the start to compare the major and minor versions of the source and destination.  

**Unless the source and destination major.minor versions are the same, the script will not proceed.**

You will notice some version checks being run in the script.  This is to prevent the script from calling specific API endpoints when it shouldn't.

### What permissions should the users tied to the API keys have?
For the source instance, a user with read-only permissions to all objects copied is required.  It will never write anything back to the source.

For the destination instance, we recommend a user with `Space Manager` or higher.  You can go through and lock down permissions as you see fit, but `Space Manager` will get you going.

### Can I use this in a Octopus Deploy runbook?
Yes!  It is a PowerShell script.  It calls the APIs, so you should be fine in using it in an Octopus Deploy runbook.

### Why doesn't this script create the destination space?
Honestly, it's a security concern.  There are two built-in roles which provide space create permission, `System Manager` and `System Administrator`.  The [service account user](https://octopus.com/docs/security/users-and-teams/service-accounts) would either need to be added to `Octopus Managers` or `Octopus Administrators` teams.  That user would also have permissions to create users and update other settings on your instance.  We want you to feel comfortable using the script as is.  Requiring elevated permissions is concern and it isn't something we felt good about asking our users to do.

Yes, you can create a custom role and assign the service account user to that role.  The goal of this script is it should "just work" with a minimal amount of configuration on your end.  Once you start diving into permissions and custom roles, it is going to be much harder to get working.  