# How it works
You provide the a source Octopus instance space and a destination Octopus instance space.  It will hit the API of both instances and copy items from the source space into the destination space.

## What will it clone
The script `CloneSpace.ps1` will clone the following:

- Environments
- Worker Pools (not workers, just the pools)
- Project Groups
- External Feeds
- Tenant Tags
- Step Templates (both community and custom step templates)
- Accounts
- Library Variable Sets
- Lifecycles
- Script Modules
- Machine Policies
- Projects
    - Settings
    - Deployment Process
    - Runbooks
    - Variables
- Tenants (no tenant variables)
- Targets (no polling tentacles)
- Workers (no polling tentacles)

## What won't it clone
The script `CloneSpace.ps1` will not clone the following items:
- Tenant Variables
- Deployments
- Releases
- Packages
- Users
- Teams
- Roles
- External Auth Providers (or groups)
- Server settings like folders
- Spaces
- Project Versioning Strategy (clears out package references)
- Project Automatic Release Creation (clears out package references)

The assumption is you are using this script to clone a process to another instance for testing purposes.  You don't need the headache of deployments, releases and everything associated with it.

Tenant variables were excluded mostly due to how they are returned from the API.  Honestly it looked like a bit of a maintenance nightmare.

## The Space Has to Exist
The space on the source and destination must exist prior to running the script.  The script will fail if the destination space doesn't exist.  It doesn't create a space for you.

## Leaves in Place
This script was designed to be run multiple times with the same parameters.  It isn't useful if the script is constantly overwriting / removing values each time you run it.  It will not overwrite the following:

- Accounts (match by name)
- Feeds (match by name)
- Tenants (match by name)
- Sensitive variables (match by name)
- Community Step Templates (match by name)
- Worker Pools (match by name)
- Process steps (match by name)
- Channels (match by name)
- Project Versioning Strategy (once you set it in the destination project, it keeps it)
- Project Automatic Release Creation (once you set it in the destination project, it keeps it)
- Workers (match by name)
- Targets (match by name)

## Limitations
Because this is hitting the Octopus API (and not the database) it cannot decrypt items from the Octopus Database.  It also cannot download packages for you.

Please see the [sensitive variables page](SensitiveVariables.md) for more information on the script handles sensitive variables.

## Simple Relationship Management
The process does not attempt to walk a tree of dependencies.  It loads up all the necessary data from the source and destination.  When it comes across an ID in the source space it will attempt to find the corresponding ID in the destination space.  If it cannot find a matching item it removes that binding.  

If that binding on a specific object is required the script will fail.  

Let's use environment scoping as the example.  In my source I have a variable set called `Global`.  That variable set has an environment scoped to environments.

![](../img/source-global-variables-environment-scoping.png)

In my destination space I only have three of those four environments, `Test`, `Staging`, and `Production`.  As a result, the cloned variable set still has the `Development` value but it doesn't have a scope associated with it.

![](../img/destination-global-variables-environment-scoping-missing-env.png)

## Intelligent Process Cloning
This script assumes when you clone a deployment process you want to add missing steps but leave existing steps as is.

I have a deployment process on my source where I added a new step.

![](../img/process-source-added-step.png)

My destination deployment process has a new step on the end that is not in the source.

![](../img/destination-deployment-process-before-sync.png)

After the sync is complete the new step was added and the additional step was left as is.

![](../img/destination-deployment-process-after-sync.png)

The rules for cloning a deployment process are:

- Clone steps not found in the destination process
- Leave existing steps as is
- Clear out package references when cloning new steps
- The source process is the source of truth for step order.  It will ensure the destination deployment process order matches.  It will then add additional steps found in the deployment process not found in the source to the end of the deployment process.

## Targets and Workers

The script will clone your targets and workers.  However there are a few key items you should know.

The first is if you are cloning from one instance to another the tentacle will not trust the server thumbprint.  You will need to run `Tentacle configure --trust="YOUR SERVER THUMBPRINT"` on the server itself for the tentacle to trust the new server.  See [documentation](https://octopus.com/docs/octopus-rest-api/tentacle.exe-command-line/configure) for more details.

Secondly, the clone script only supports a subset of all targets.  The targets supported are:

- Listening Tentacle
- K8s Cluster (not using a token or cert to auth with)
- Cloud Regions
- Azure Web Apps

Due to how polling tentacles work, the script cannot clone polling tentacles from one instance to another.  The polling tentacles won't know about the switch.  You will need to set up a new polling tentacle instance on the server.  