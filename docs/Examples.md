# Clone Space Script Examples
This script was written to solve the following use cases.  The options you choose depend on the use case.

- As a user I want to split my one massive default space into [multiple spaces on the same instance](docs/UseCase-BreakUpSpace.md).
- As a user I have two Octopus Deploy instances.  One for dev/test deployments.  Another for staging/prod deployments.  I have the [same set of projects I want to keep in sync](docs/UseCase-KeepInstancesInSync.md).
- As a user I want to clone a set of projects to a test instance to [verify an upgrade](UseCase-CopyToTestInstance.md).
- As a user I have a set of "parent" projects.  I clone from that project when I need to create a new project.  However, when the process on the "parent" project is updated I would like to [update the existing "child" projects](UseCase-ParentChildProjects.md).

## Possible but not recommended.

- As a user I want to merge multiple Octopus Deploy instances into the one space on one instance.  We wouldn't recommend merging multiple disparate instances into one massive space.  The chance of overwriting something important is very high.  Just like steering a car with your knees, while possible it is not recommended.