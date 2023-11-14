## Databricks Multiple Workspace Repository Example

### Folder Structure
The repository is broken out into **four or more** subsections.
- **Common Infrastructure**: Databricks infrastucture that is common across all workspaces
    - Logging: Creation of the billable usage and audit logs
    - Unity Catalog: Creation of the Unity Catalog
&nbsp;

- **Common Modules: Account**: Reusable assets for account-level resources
    - Cloud Provider Credential: Asset to create the underlying credential
    - Cloud Provider Network: Asset to create the underlying network
    - Cloud Provider Storage: Asset to create the underlying storage
    - Metastore Assignment: Asset to assign the calling workspace to the metastore
    - Workspace Creation: Asset to create the workspace based on the outputs of the previous modules
 &nbsp;

- **Common Modules: Workspace**: Reusable assets for workspace-level resources
    - Cluster: Asset to create a cluster
    - Cluster Policy: Asset to create a cluster policy
    - Secrets: Asset to create a workspace specific secret
&nbsp;

- **Databricks: Environment Example**: Databricks workspaces per environment or other logical group
    - Cloud Provider: Subsection for cloud related assets from modules and environment specifics (e.g. network peering)
    - Databricks Account: Subsection for account related assets from modules and environment specifics (e.g. identitiy assignment)
    - Databricks Workspace: Subsection for workspace related assets from modules and enviornment specifics (e.g. repos, notebooks, etc.)

### How to use:
- Create a .tfvars file based on the examples found in the tvfvars_examples page in each seperate pipeline (Unity Catalog, Logging, and the various Databricks environments)
- **Recommended**: Set environment variables for your AWS and Databricks credentials
- Terraform init (each pipeline)
- Terraform plan (each pipeline)
- Terraform apply (each pipeline)

**Note**: Please raise a git issues with any problems or concerns about the repo.

### FAQ:
- **"Error: cannot create mws credentials: MALFORMED_REQUEST: Failed credential validation checks: please use a valid cross account IAM role with permissions setup correctly. What do I do to fix this?"**
    - This occurs after the networking configured is finalized. This is due to a race condition between the IAM role and the logging of it to the Databricks endpoint. Please re-plan and apply and it will go through. It can be mitigated with a sleep condition. We are looking at adding this sleep condition into the repo.
- **"What do I do with identities?"**. 
    - Identities should be integrated with SCIM. Once they are integrated with SCIM, reference them as data sources, similar to the identity assignment example. Then continue to assign permissions through the workspace provider.