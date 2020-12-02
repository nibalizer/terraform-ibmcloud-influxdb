# terraform ibmcloud influxdb

This is terraform files for setting up influxdb on the ibmcloud vpc gen 2 virtual infrastructure.

This repo has two goals:

1) Usefully spin up infrastructure for influxdb (actually installing influx is left to ansible modules)

2) Provide a more complete example of a real world use of terraform for ibmcloud (gen2) and a pattern for translating terraform scripts designed for aws into ibmcloud.


This was heavily inspired by the [aws terraform for influxdb](https://github.com/influxdata/terraform-aws-influxdb).


