# Discover Consul settings
module "consul" {
  source       = "github.com/nubisproject/nubis-terraform//consul?ref=v2.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
}

# Configure our Consul provider, module can't do it for us
provider "consul" {
  address    = "${module.consul.address}"
  scheme     = "${module.consul.scheme}"
  datacenter = "${module.consul.datacenter}"
}

# Publish our outputs into Consul for our application to consume
resource "consul_keys" "config" {
  # For mod_auth_openidc
  key {
    name   = "openid_server_passphrase"
    path   = "${module.consul.config_prefix}/OpenID/Server/Passphrase"
    value  = "${random_id.openid_server_passphrase.b64_url}"
    delete = true
  }
  key {
    name   = "openid_server_memcached"
    path   = "${module.consul.config_prefix}/OpenID/Server/Memcached"
    value  = "${module.cache.endpoint}"
    delete = true
  }
}

resource "random_id" "openid_server_passphrase" {
  byte_length = 16
}
