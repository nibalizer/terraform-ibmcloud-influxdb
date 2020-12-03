# Terraform IBM Cloud InfluxDB

This is terraform files for setting up influxdb on the ibmcloud vpc gen 2 virtual infrastructure.

This repo has two goals:

1) Usefully spin up infrastructure for influxdb (actually installing influx is left to ansible modules)

2) Provide a more complete example of a real world use of terraform for ibmcloud (gen2) and a pattern for translating terraform scripts designed for aws into ibmcloud.


This was heavily inspired by the [aws terraform for influxdb](https://github.com/influxdata/terraform-aws-influxdb).



## Usage

Set up terraform (pulls ibmcloud provider)

```
terraform init
```


Set IBM Cloud API Key env vars:

```
# You only need this one
export TF_VAR_ibmcloud_api_key="e7b0c6a8-f1f1-4aa4-b666-bb82b136719f"
# Set these to empty strings, they are not used since this is all gen2
export TF_VAR_iaas_classic_username=""
export TF_VAR_iaas_classic_api_key=""
```

Setup ssh key for ibmcloud, set in terraform

```
$ ibmcloud is keys
```


Set the name of the ssh key here:
```
vim terraform.tfvars
```

Run:

```
terraform apply
```
