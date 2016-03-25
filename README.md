# ProteusThemes OPS (based on [Trellis](https://github.com/roots/trellis))

[![Build Status](https://travis-ci.org/proteusthemes/pt-ops.svg)](https://travis-ci.org/proteusthemes/pt-ops)

Trellis is an end-to-end solution for WordPress environment management.

- Reproducible development environments with Vagrant
- Automate the configuration of high-performance production servers

Configure servers for WordPress sites with a single command:

|                        | Command
| ---------------------- | ------------------------------------------------ |
| **Development**        | `vagrant up`                                     |
| **Sandbox/Production** |`ansible-playbook -i hosts/production server.yml` |

## What's included

Trellis will configure a server with the following and more:

* Ubuntu 14.04 Trusty LTS
* Nginx (with optional FastCGI micro-caching)
* PHP 5.6 (or [HHVM](http://hhvm.com/))
* [MariaDB](https://mariadb.org/) as a drop-in MySQL replacement (but better)
* SSL support (A+ on https://www.ssllabs.com/ssltest/)
* HTTP/2 support (requires SSL)
* Composer
* WP-CLI
* sSMTP (mail delivery)
* Fail2ban
* ferm

## Documentation

Trellis documentation is available at [https://roots.io/trellis/docs/](https://roots.io/trellis/docs/).

## Requirements

* Ansible >= 1.9.2 (**not** 2.0 which is in alpha) - [Install](http://docs.ansible.com/intro_installation.html) • [Docs](http://docs.ansible.com/) • [Windows docs](https://roots.io/trellis/docs/windows/)
* Virtualbox >= 4.3.10 - [Install](https://www.virtualbox.org/wiki/Downloads)
* Vagrant >= 1.5.4 - [Install](http://www.vagrantup.com/downloads.html) • [Docs](https://docs.vagrantup.com/v2/)
* vagrant-bindfs >= 0.3.1 - [Install](https://github.com/gael-ian/vagrant-bindfs#installation) • [Docs](https://github.com/gael-ian/vagrant-bindfs) (Windows users may skip this)
* vagrant-hostsupdater - [Install](https://github.com/cogitatio/vagrant-hostsupdater#installation) • [Docs](https://github.com/cogitatio/vagrant-hostsupdater)

## Installation

1. Download/fork/clone this repo to your local machine.
2. Run `ansible-galaxy install -r requirements.yml` inside your Trellis directory to install external Ansible roles/packages.
3. Download/fork/clone [Bedrock](https://github.com/roots/bedrock) or have an existing Bedrock-based site ready.

You should now have the following directories at the same level somewhere:

```
example.com/    - Primary folder for the project
├── trellis/    - Your clone of repository
└── site/       - A Bedrock-based site (suggested to name this the generic `site` since your project name is already at the top level)
```

- You **do not** need a configured `.env` file. Trellis will automatically create and configure one.
- The full paths to these directories must not contain spaces or else [Ansible will fail](https://github.com/ansible/ansible/issues/8555).
- See a complete working example in the [roots-example-project.com repo](https://github.com/roots/roots-example-project.com).

## Development setup

1. Configure your [WordPress sites](#wordpress-sites) in `group_vars/development/wordpress_sites.yml`
2. Run `vagrant up`

## Remote server setup (sandbox/production)

For remote servers, you'll need to have a base Ubuntu 14.04 server already created.

1. Configure your [WordPress sites](#wordpress-sites) in `group_vars/<environment>/wordpress_sites.yml`. Also see the [Passwords docs](https://roots.io/trellis/docs/passwords/).
2. Add your server IP/hostnames to `hosts/<environment>`.
3. Specify public SSH keys for `users` in `group_vars/all/users.yml`. See the [SSH Keys docs](https://roots.io/trellis/docs/ssh-keys/).
4. Consider setting `sshd_permit_root_login: false` in `group_vars/all/security.yml`. See the [Security docs](https://roots.io/trellis/docs/security/).
5. Run `ansible-playbook -i hosts/<environment> server.yml`.

## Configuration

### HHVM

[HHVM](http://hhvm.com/) can be used instead of PHP 5.6 by setting `hhvm: true` in `group_vars/all/main.yml`.

### WordPress Sites

Before using Trellis, you must configure your WordPress sites.

The `group_vars` directory contains directories for each environment (`development`, `sandbox`, and `production`). Each environment has its own `wordpress_sites.yml` variables file in [YAML](http://en.wikipedia.org/wiki/YAML) format.

For example: configure the sites on your Vagrant development VM by editing `group_vars/development/wordpress_sites.yml`.

`wordpress_sites` is the top-level dictionary used to define the WordPress sites, databases, Nginx vhosts, etc that will be created. Each site's variables are nested under a site "key" (e.g., `example.com`). This key is just a descriptive name and serves as the default value for some variables. See our [example project](https://github.com/roots/roots-example-project.com/blob/master/ansible/group_vars/development/wordpress_sites.yml) for a complete working example.

* `site_hosts` - array of hosts that Nginx will listen on (required, include main domain at least)
* `local_path` - path targeting Bedrock-based site directory (required for development)
* `repo` - URL of the Git repo of your Bedrock project (required, used when deploying)
* `branch` - the branch name, tag name, or commit SHA1 you want to deploy (default: `master`)
* `subtree_path` - relative path to your Bedrock/WP directory in your repo (above) if its not the root (like in the [roots-example-project](https://github.com/roots/roots-example-project.com))
* `ssl` - enable SSL and set paths
  * `enabled` - `true` or `false` (required, set to `false`. Set to `true` without the `key` and `cert` options [to generate a *self-signed* certificate](https://roots.io/trellis/docs/ssl/) )
  * `key` - local relative path to private key
  * `cert` - local relative path to certificate
  * `hsts_max_age` - time, in seconds, that the browser should remember that this site is only to be accessed using HTTPS (default: `31536000`)
  * `hsts_include_subdomains` - if true, the HSTS rules apply to all of the site's subdomains as well (default: `true`)
  * `hsts_preload` - required to opt into [Google's HSTS preload list](https://hstspreload.appspot.com/) (default: `true`)
* `site_install` - whether to install WordPress or not (*development* only, required)
* `site_title` - WP site title (*development* only, default: project name)
* `db_create` - whether to auto create a database or not (default: `true`)
* `db_import` - Path to local `sql` dump file which will be imported (optional)
* `admin_user` - WP admin user name (*development* only, required)
* `admin_email` - WP admin email address (*development* only, required)
* `admin_password` - WP admin user password (*development* only, required)
* `multisite` - hash of multisite options. See the [Multisite docs](https://roots.io/trellis/docs/multisite/).
  * `enabled` - Multisite enabled flag (required, set to `false`)
  * `subdomains` - subdomains option
  * `base_path` - base path/current site path
* `cache` - hash of cache options
  * `enabled` - Cache enabled flag (required, set to `false`)
  * `duration` - Duration of the cache (default: `30s`)
* `env` - environment variables
  * `disable_wp_cron` - Disable WP cron and use system's (default: `true`)
  * `wp_home` - `WP_HOME` constant (required)
  * `wp_siteurl` - `WP_SITEURL` constant (required)
  * `wp_env` - environment (required, matches group name: `development`, `sandbox`, `production`)
  * `db_name` - database name (required)
  * `db_user` - database username (required)
  * `db_password` - database password (required)
  * `db_host` - database hostname (default: `localhost`)
  * `domain_current_site` (required if multisite.enabled is `true`)

### Mail

sSMTP handles outgoing mail. For the `development` environment, emails are sent to MailHog, where you can inspect them. To access MailHog interface, go to `http://yourdevelopmentdomain.dev:8025`. For `sandbox` and `production`, configure credentials in `group_vars/all/mail.yml`. See the [Mail docs](https://roots.io/trellis/docs/mail/).

## SSL

Full SSL support is available for your WordPress sites. Trellis will also *auto-generate* self-signed certificates for development purposes. Our HTTPS implementation utilizes HTTP/2 and has all the best practices for performance and security. (Note: default configuration is HTTPS **only**.) See the [SSL docs](https://roots.io/trellis/docs/ssl/).

## Caching

You can enable FastCGI caching on a per site basis. The cache is a short duration, "micro-cache" type setup. See the [FastCGI micro-caching docs](https://roots.io/trellis/docs/fastcgi-caching/) for configuration options.

## Contributing

Contributions are welcome from everyone. We have [contributing guidelines](CONTRIBUTING.md) to help you get started.

## Community

Keep track of development and community news.

* Participate on the [Roots Discourse](https://discourse.roots.io/)
* Follow [@rootswp on Twitter](https://twitter.com/rootswp)
* Read and subscribe to the [Roots Blog](https://roots.io/blog/)
* Subscribe to the [Roots Newsletter](https://roots.io/subscribe/)

## TODO

This repo should keep it's pace with [Trellis](https://github.com/roots/trellis) itself. Here is the list of commits to future-me that haven't been merged yet, but I hope they will be at some point:

- Refactor hosts files
  - https://github.com/roots/trellis/commit/40cdb5e75f4b83090df3405d3d63829c81d763f0
  - https://github.com/roots/trellis/commit/f48e3d8c8c0381d3f2371ca1972036fe65e8e7a6
  - https://github.com/roots/trellis/commit/170eae84ad513ea1b769e388634aff0e922a1f55
- PHP7: https://github.com/roots/trellis/pull/432

I've cherry-picked till https://github.com/roots/trellis/commit/f0f43d31de05a3924ce8bd402d54fd33aca128db.
