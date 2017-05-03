basic AWS VPC spin up via Terraform
===================================

These Terraform configs spin up a basic VPC with public & private
subnets and all the related bits (NAT gateways, Internet gateway,
route tables, etc.) plus a small EC2 instance intended to be a VPN
gateway.  This is the base infra I spin up before tinkering with a new
thing.

Configuring a VPN is left as an exercise for you, dear reader.  But if
you're just looking for a simple laptop<->AWS solution check out
[Algo](https://github.com/trailofbits/algo).


Usage
-----

* edit `terraform.tfvars`

Note: `cluster_name` is just a unique name for this group of
infrastructure.  You can call it whatever.

```
    $ terraform plan -out /tmp/plan.out
    $ terraform apply /tmp/plan.out
```

* configure your VPN instance
