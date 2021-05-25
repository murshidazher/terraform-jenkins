# Mastering Terraform - Integrating with Jenkins and Ansible

> The end-to-end workflow with terraform, jenkins and ansible playbooks

- This has all the terraform and jenkins workflow, once you have a full infrastructure as code using terraform you would use jenkins to deploy them to their individual environments. We can write jenkins pipeline scripts to configure these deployment as well as ansible playbooks which will be integrated with jenkins and terraform. `SVM` is used to see the changes in the infrastructure overtime.

## Installing terraform manually

```sh
> cd Downloads
> mv terraform /usr/local/bin # this will add it to the path
> terraform --version
```

## Up & Running

We will occasionally use the `terraform init` at the start of a project and in some undeniable situations,

```sh
> terraform init
> terraform apply
```

## Terraform Outputs & Interpolations

### Interpolations

`${}` this is an interpolations in terraform. We can check the values returned back we can see the [reference attributes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#attributes-reference). Example of this would be, `${aws_vpc.my_vpc.cidr_block}`.

## Terraform Local State Files

If the local `terraform.tfstate` file is deleted then all the resources created using this terraform file would lose its connection meaning that the resources would be still available in the aws account but terraform wont have ny control over it.

As a best practice never tamper with this file and we should preserve it.

## Terraform Remote State File

> The terraform s3 backend [documentation](https://www.terraform.io/docs/language/settings/backends/s3.html). Create the s3 bucket manually or use another terraform file to create it.

In order to solve multiple users collaborating together to work with the same terraform state, we need to have a remote backend. The most preferred backend out of it all is the `s3` backend.

This bucket cant be create inside the file because before any resources is created it needs to check the state file. To do that this bucket should exists.

After adding the bucket details we need to reinitialize terraform,

```sh
> terraform init
```

We can delete the local files afterwards since it wont be used afterwards
- We need to enable `versioning` so we can go back to a previous version of the state if needed.
- We also need to enable `encryption` so that if are using RDS, the RDS password would be in the `tfstate` so encryption will prevent the password being out in the open.

## Terraform Locking Remote State Files

> Name of DynamoDB table is used for [state locking](https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking)

If multiple users are creating resources from the same state file concurrently then it can create inconsistent state files.

It is always good to keep a log on the current user working on the state file and block the remaining users until the present user operations are complete.

The `dynamodb` table will be used for state locking, so we need to manually create this table before executing the terraform script. It should also have have a primary key named `LockID` with type of `string`.

```txt
aws console -> dynamodb -> create table
table name: javahome-tf
primary key: LockID 
type: string
```

Again we need to use terraform init, to reinitialize the lock. If we make an update we will have a dynamodb entry and after its successful there wont be any lock to it.

## Terraform Variables

If a type isn't given then the type is inferred by the given default value. If we need to change the value on runtime,

```sh
> terraform apply -var "vpc_cidr=10.30.0.0/16" #overrides the default value
> terraform apply -var "vpc_cidr=10.30.0.0/16" -auto-approve # to approve the changes
```

We can also use any filename with the `tfvars` extension to pass environment and multiple values,

```sh
> terraform apply -var-file=dev.tfvars
```

## Terraform Workspace

Mantaining multiple environment in terraform can be tedious, what if we need a `dev` and `prod` environment with same configuration but maintain different varaibles.

This is where we need workspaces, and terraform by default maintains one workspace called `default`.

```sh
> terraform workspace list # created at terraform init
* default
```

To create two new workspaces,

```sh
> terraform workspace new dev
> terraform workspace new prod
```

Terraform will maintain a seperate state file for `dev` and a seperate state file for `prod`. Inside the s3 remote backend there would be a dir called `env -> dev | prod` and inside that we can find the state files.

If we need to provision the resources in the dev workspaces we need to first select the dev workspace.

```sh
> terraform workspace select dev
> terraform apply
```

We can reference the terraform current workspace to get the current env to add the environment to tags.

```tf
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "JavaHomeVPC"
    Environment = "${terraform.workspace}"
    Location    = "India"
  }
}
```

## Terraform Loops

What if we need to create 10 VPC instances, we can use the loops. We can use the `count` attribute to loop.

```tf
resource "aws_vpc" "my_vpc" {
  count            = 10
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "JavaHomeVPC"
    Environment = "${terraform.workspace}"
    Location    = "India"
  }
}
```

## Terraform Conditions

What if certain configuration should be used only in `dev` and not in production then we can use the conditions. What if we only need to create a vpc in `prod`, `count = 0` means doesn't create the vpc.

```tf
resource "aws_vpc" "my_vpc" {
  count            = "${terraform.workspace == "dev"? 0 : 1}"
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "JavaHomeVPC"
    Environment = "${terraform.workspace}"
    Location    = "India"
  }
}
```

## Terraform Local Variables

If we have an expression repeatedly used inside our code we can use them as a part of our local variable and make use of them. In the future, if we need to change it we can change it in a single place. You use the `local` body to create a local variable.

```
locals {
  vpc_name = terraform.workspace == "dev" ? "javahome-dev" : "javahome-prod"
}


resource "aws_vpc" "my_vpc" {
  count            = terraform.workspace == "dev" ? 0 : 1
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "${local.vpc_name}"
    Environment = "${terraform.workspace}"
    Location    = "India"
  }
}
```