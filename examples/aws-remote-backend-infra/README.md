S3 bucket remote backend for Terraform state files
=========================

In this example, we show how to use S3 bucket as a remote backend for Terraform project's state files. Two major reasons that you should use remote backend instead of default local backend are:
1. State files contains sensitive information and you want to protect them, encrypt and store in a secured storage.
2. When collaborating with other team members, you want to safe keep your state files and enforce locking to prevent conflicts.

### Architecture

> The chart below shows the components of a S3 remote backend  

<img src="../charts/tf_remote_s3_backend.png" width="800">

### Setup remote backend

1. Use the default local backend (comment out all the scripts in `terraform` block, line 5 in `main.tf`), read and modify `main.tf` accordingly, this is to create a S3 bucket (with versioning and server-side encryption) and a dynamoDB table for the locking mechanism.
2. Run `terraform init` and `terraform apply` to create the S3 bucket and dynamoDB table, at this step, you observe states stored in local file `terraform.tfstate`.
3. Uncomment the `terraform` block, to configure the backend. Then run `terraform init` again, this will migrate the state file from local to S3 bucket. Input `Yes` when prompted.
4. After you entered `Yes`, you will see the state file is now stored in S3 bucket. You can also check the dynamoDB table to see the lock record; and now the local state file will become empty.


### How to destroy remote backend infra

To properly destroy remote backend infra, you need to migrate the state files to local first, to avoid having conflicts. 

1. Comment out the `terraform` block in `main.tf`, to switch to use local backend. This step moves the state file from S3 bucket to local.
2. Run `terraform init` and `terraform destroy` to destroy the remote backend infra.

### Other projects to use this remote backend

You only need to configure the same terraform backend block in other terraform projects, to let them use the same remote backend. Inside the backend configs, you need to design the `key` in your bucket to be unique for each project.