# DC/OS Terraform

This is an umbrella repository for all [terraform modules](https://github.com/dcos-terraform) for DC/OS.

## Get Started

First, pull all the Terraform module dependencies.

```bash
$ git clone <URL_TO_THIS_REPO>
$ make bootstrap
```

All Terraform modules are git submodules linked to the actual git repositories for the Terraform modules.

Now, you can start to edit Terraform module files.
No need to modify module `source` fields as those will be automatically rewritten for local testing.
Once you are done, type the following command to create the local testing environment:

```bash
$ make tenv
```

The command will output a directory path in the end.
The directory should have Terraform initialized with your locally modified Terraform modules.

```bash
$ cd <GENERATED_PATH>
$ terraform apply
```

## Modules Layout

The Terraform modules in this repository follow this layout:

```bash
modules/<provider>/<name>
```

## How Local Testing Works

Under the hood, we created a helper command `module-source-converter` to automatically convert module `source` fields to use [relative local paths](https://www.terraform.io/docs/modules/sources.html#local-paths).

The helper is based on the HCL [parser](https://github.com/hashicorp/hcl/tree/master/hcl/parser) and [printer](https://github.com/hashicorp/hcl/tree/master/hcl/printer) provided by Hashicorp.
