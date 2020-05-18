# Space Cloner
Sample PowerShell script to help you clone a space using the Octopus Deploy Restful API.

# This cloning process is provided as is!
Please test it on an empty space before attempting to use it for any kind of real-world use.  Please clone this repo and modify the script to meet your needs.  This script should be a starting point for your process.

# Use Cases
This script was written to solve the following use cases.

- As a user I want to split my one massive default space into [multiple spaces on the same instance](docs/UseCase-BreakUpSpace.md).
- As a user I have two Octopus Deploy instances.  One for dev/test deployments.  Another for staging/prod deployments.  I have the [same set of projects I want to keep in sync](docs/UseCase-KeepInstancesInSync.md).
- As a user I want to clone a set of projects to a test instance to [verify an upgrade](docs/UseCase-CopyToTestInstance.md).
- As a user I have a set of "parent" projects.  I clone from that project when I need to create a new project.  However, when the process on the "parent" project is updated I would like to [update the existing "child" projects](docs/UseCase-ParentChildProjects.md).

## Possible but not recommended.

- As a user I want to merge multiple Octopus Deploy instances into the one space on one instance.  We wouldn't recommend merging multiple disparate instances into one massive space.  The chance of overwriting something important is very high.  Just like steering a car with your knees, while possible it is not recommended.

# How It Works
Please see the [how it works page](docs/HowItWorks.md).

# Debugging and Logging
Please see the [debugging and logging page](docs/Debugging.md).

# Reference
Please see [parameter reference page](docs/ParameterReference.md)

# Examples
Please see the [example page](docs/Examples.md)

# FAQ
Some common questions and answers about this sample project.

### Why was this script created?
This script was developed by the Customer Success team at Octopus Deploy.  We use it to clone items for our [samples instance](https://samples.octopus.app).

### Will you fix my bug?  
Maybe.  As this is a sample script we may or may not fix it.  You can submit an issue.  We will triage it and give you a decision on if it will be fixed.  You are free to fork this repo and fix the issue yourself.

What won't be fixed:
- Failures as a result of cloning from differences in versions, for example `3.17.14` to `2020.2.6`.  
- Certain Excluded Object Types (sensitive variables, targets, workers, etc).  They were excluded for a specific reason.  
- Bugs from versions `3.x`, or `2018.x`.  If the script happens to work for those versions, yay, but it is unsupported.

### What about feature requests?
Unless it is something we (Customer Success) needs, we probably won't add it ourselves.  We encourage you to fork the repo, add your desired functionality.  If you think others will benefit submit a PR.

### Do you accept pull requests?
Yes!  If you want to improve this script please submit a pull request!

### Can I use this to migrate from self-hosted to the cloud?
It won't do a full migration.  Because this script uses the Octopus API, as long as your machine can see both the source and destination, it should work.  However, it doesn't clone everything.  See the [how it works](docs/HowItWorks.md) page for details on what it will and won't clone.  This script will help jump start your migration.

### Is this the space migration / self-hosted to Octopus Cloud migrator tool we've been waiting for?
No.  It was designed for specific use cases and the limits placed on it were intentional.  It can't access your Master Key, and without that it cannot decrypt you sensitive data.  It should get you 80% of the way there.  You are free to fork this repo to modify the scripts to help get you another 15% of the way there.  

### What version of Octopus Deploy does this support?
It _should_ work with any Octopus version `3.4` or higher.  It was developed by testing against a version running `2020.x`.  Take from that what you will. 

The script will run a check at the start to compare the major and minor versions of the source and destination.  

**Unless the source and destination major.minor versions are the same, the script will not proceed.**

You will notice some version checks being run in the script.  This is to prevent the script from calling the API when it shouldn't.