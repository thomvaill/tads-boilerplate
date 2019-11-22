# YourCompany infrastructure repository

This repository implements [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code), and more globally the DevOps mindset.
It includes all the configuration and all the scripts needed to deploy YourCompany stacks either locally or remotely.
This repository should be considered as a single source of truth.
You should also use this repository to set up your development environment.

This project heavily uses Ansible. If you are not familiar with it, you should read the [Ansible Quickstart guide](https://docs.ansible.com/ansible/latest/user_guide/quickstart.html) before getting started.

This project was bootstrapped with [T.A.D.S. boilerplate](https://github.com/Thomvaill/tads-boilerplate).

## Installation

```bash
git clone <YOUR_PROJECT_GIT_URL>
cd <YOUR_PROJECT_NAME>
./tads install-dependencies
```

... this will install project dependencies: Ansible, Vagrant, Virtualbox, and Terraform.

## Development environment

### Commands

The `./tads` executable is a companion CLI which is a wrapper around Ansible, Vagrant and Terraform commands.

```bash
./tads ansible-playbook localhost provision
```

... this will configure your local machine to be able to run YourCompany stacks: it will install Docker and set up a Swarm cluster with one node: your localhost.

```bash
./tads ansible-playbook localhost deploy
```

... this will deploy all YourCompany's stacks. To deploy only specific stacks, use `--tags` option. Example: `./tads ansible-playbook localhost deploy --tags stack-traefik,stack-XXX`.

You should run this command every time you change the configuration of your stacks.

Your application is now accessible on https://yourcompany.localhost/

### Bind mounts

To be able to develop locally, you should bind mount your code into your containers. To do so:

- Copy `ansible/groups_vars/localhost_bindmounts.sample.yml` to `ansible/groups_vars/localhost_bindmounts.yml`
- Specify the correct paths in it
- Run `./tads ansible-playbook localhost deploy` to update changes

You can also override some Ansible variables locally doing the same with the `ansible/groups_vars/localhost_overrides.sample.yml` file (useful for credentials and applicative environment variables).

## Test in a production-like environment with Vagrant

This will deploy your stacks on a 3-nodes production like-environment, locally with Vagrant. To do so, this will create 3 virtual machines.

1. Copy `vagrant/vagrant.sample.yml` to `vagrant/vagrant.yml` and adjust its settings
2. Run `./tads vagrant up`
3. Run `./tads ansible-playbook vagrant all`

Now, you will be able to test your stacks deployed on Vagrant on https://yourcompany.test/

**Tips:**

- To destroy your cluster: `./tads vagrant destroy`
- To SSH into the first node: `./tads vagrant ssh vagrant-1`

## Deploy to production

1. Make sure you have a correct SSH key pair
2. Make sure you have the correct ansible-vault key in `ansible/vault_keys/production`
3. To create the environment with Terraform: `./tads terraform production apply`
4. To provision: `./tads ansible-playbook production provision`
5. To deploy: `./tads ansible-playbook production deploy`
