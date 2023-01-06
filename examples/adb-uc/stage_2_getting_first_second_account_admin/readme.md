### Stage 2 Make AAD Global Admin SPN to be the first Databricks account admin

In Stage 2, we az login using an AAD Global Admin SPN, and use this identity to hit the Databricks Provider Account Level endpoint to make it as the first account admin.

Once this SPN becomes the first Databricks Account Admin, then this SPN can make other SPNs as account admins, then you can remove the AAD Global Admin role from this initial SPN.

This sample script requires a variable `long_lasting_spn_id`, you should have prepared this SPN and supply its id to this variable.

Stage 3 deployment steps:

az login as AAD Global Admin SPN:
`az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>`

Supply value to `long_lasting_spn_id` variable.

Change `account_id` attribute inside the databricks provider:
```
provider "databricks" { // account level endpoint
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = "f3b0d159-720f-4d2e-bdc4-18104f13f419" // Databricks will provide
  auth_type  = "azure-cli"                            // az login with SPN
}
```

In this stage 2 folder, run:

```bash
terraform init & terraform apply
```

This completes Stage 2, now you should have a long lasting SPN with Databricks Account Admin role and it can make other identities as account admins. You can now remove the first SPN's AAD Global Admin role.