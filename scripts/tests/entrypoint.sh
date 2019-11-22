#!/usr/bin/env bash
set -euo pipefail

# Copy host files in the workdir
cp -R /tmp/tads-host/* /tmp/tads

# Clean dev files
rm -rf /tmp/tads/terraform/environments/production/.terraform
rm -f /tmp/tads/terraform/environments/production/terraform.tfstate
rm -rf /tmp/tads/vagrant/.vagrant
rm -f /tmp/tads/vagrant/vagrant.yml
rm -f /tmp/tads/ansible/inventories/production
rm -f /tmp/tads/ansible/vault_keys/*

exec "$@"
