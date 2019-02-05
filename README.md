# DC/OS Terraform

This is an umbrella repository for all [terraform modules](https://github.com/dcos-terraform) for DC/OS.

## Prerequisite

- GNU Make
- git
- [hub](https://hub.github.com/)
- [terraform](https://www.terraform.io/downloads.html)
- [terraform-docs](https://github.com/segmentio/terraform-docs)

## Get Started

First, pull all the Terraform module dependencies.

```bash
$ git clone <URL_TO_THIS_REPO>
$ make init
```

All Terraform modules are git submodules linked to the actual git repositories for the Terraform modules.

Then, create a local feature branch to develop your features.

```bash
$ BRANCH=mybranch make branch
```

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

If your change involves input/output variables, you will need to update the docs as well.
The following command will automatically update the docs based on your change to the terraform files.

```bash
$ make docs
```

When you are ready to upstream your changes, the command below will go to each submodule and apply all the changes and create a branch for review.

```bash
$ make upstream
```

The branch name will be automatically generated based on your current branch name and your username.
If you want to automatically create a PR, use the following command:

```bash
$ SUBMIT_PR=true make upstream
```

## Developing in Docker

You can run all the commands above in a Docker environment.
Simply run `scripts/shell` will take you to a Docker environment with all tooling installed.

```bash
$ scripts/shell
...
-------------------------
|    Dev environment    |
-------------------------
/source$ make tenv
...
```

You can also use that in a non-interactive environment (e.g., CI).

```bash
$ scripts/shell -c "make tenv"
```

## Options

### ssh github access

If you github organazation requires you to use ssh github access for authentication, you can easily switch to this with this command below:

```bash
$ make ssh-git
```

### http github access

If you need to revert back to any reason, here is the command:

```bash
$ make http-git
```

## Modules Layout

The Terraform modules in this repository follow this layout:

```bash
modules/<provider>/<name>
```

## How Local Testing Works

Under the hood, we created a helper command `module-source-converter` to automatically convert module `source` fields to use [relative local paths](https://www.terraform.io/docs/modules/sources.html#local-paths).

The helper is based on the HCL [parser](https://github.com/hashicorp/hcl/tree/master/hcl/parser) and [printer](https://github.com/hashicorp/hcl/tree/master/hcl/printer) provided by Hashicorp.
