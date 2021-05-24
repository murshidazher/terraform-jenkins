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
- We need to enable versioning so we can go back to a previous version of the state if needed.
- We also need to enable encryption so that if are using RDS, the RDS password would be in the `tfstate` so encryption will prevent the password being out in the open.

## Terraform Locking Remote State Files

If multiple users are creating resources then it can create inconsistent state files.

