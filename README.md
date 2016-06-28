# puppet-rethinkdb 
<!-- [![Build Status](https://travis-ci.org/lowi-yeah/puppet-mpsquitto.png?branch=master)](https://travis-ci.org/lowi-yeah/puppet-mpsquitto) -->

[Wirbelsturm](https://github.com/miguno/wirbelsturm)-compatible [Puppet](http://puppetlabs.com/) module to deploy
[RethinkDB](https://rethinkdb.com/).

You can use this Puppet module to deploy RethinkDB to physical and virtual machines, for instance via your existing
internal or cloud-based Puppet infrastructure and via a tool such as [Vagrant](http://www.vagrantup.com/) for local
and remote deployments.

---
Table of Contents

* <a href="#quickstart">Quick start</a>
* <a href="#features">Features</a>
* <a href="#requirements">Requirements and assumptions</a>
* <a href="#installation">Installation</a>
* <a href="#configuration">Configuration</a>
* <a href="#usage">Usage</a>
    * <a href="#configuration-examples">Configuration examples</a>
        * <a href="#hiera">Using Hiera</a>
        * <a href="#manifests">Using Puppet manifests</a>
    * <a href="#service-management">Service management</a>
    * <a href="#log-files">Log files</a>
* <a href="#custom-zk-root">Custom ZooKeeper chroot (experimental)</a>
* <a href="#development">Development</a>
* <a href="#todo">TODO</a>
* <a href="#changelog">Change log</a>
* <a href="#contributing">Contributing</a>
* <a href="#license">License</a>
* <a href="#references">References</a>

---

<a name="quickstart"></a>

# Quick start

See section [Usage](#usage) below.


<a name="features"></a>

# Features
* Decouples code (Puppet manifests) from configuration data ([Hiera](http://docs.puppetlabs.com/hiera/1/)) through the
  use of Puppet parameterized classes, i.e. class parameters.  Hence you should use Hiera to control how Kafka is
  deployed and to which machines.
* Supports RHEL OS family (e.g. RHEL 6, CentOS 6, Amazon Linux).
    * Code contributions to support additional OS families are welcome!
* Supports tuning of system-level configuration such as the maximum number of open files (cf.
  `/etc/security/limits.conf`) to optimize the performance of your Mosquitto deployments.
* Mosquitto is run under process supervision via [supervisord](http://www.supervisord.org/) version 3.0+.


<a name="requirements"></a>

# Requirements and assumptions

* This module requires that the target machines to which you are deploying Mosquitto have **yum repositories configured**
  for pulling the Mosquitto package (i.e. RPM).
    * Because we run Mosquitto via supervisord through [puppet-supervisor](https://github.com/miguno/puppet-supervisor), the
      supervisord RPM must be available, too.  See [puppet-supervisor](https://github.com/miguno/puppet-supervisor)
      for details.
* This module requires the following **additional Puppet modules**:

    * [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
    * [puppet-limits](https://github.com/miguno/puppet-limits)
    * [puppet-supervisor](https://github.com/miguno/puppet-supervisor)

  It is recommended that you add these modules to your Puppet setup via
  [librarian-puppet](https://github.com/rodjek/librarian-puppet).  See the `Puppetfile` snippet in section
  _Installation_ below for a starting example.
* **When using Vagrant**: Depending on your Vagrant box (image) you may need to manually configure/disable firewall
  settings -- otherwise machines may not be able to talk to each other.  One option to manage firewall settings is via
  [puppetlabs-firewall](https://github.com/puppetlabs/puppetlabs-firewall).


<a name="installation"></a>

# Installation

It is recommended to use [librarian-puppet](https://github.com/rodjek/librarian-puppet) to add this module to your
Puppet setup.

Add the following lines to your `Puppetfile`:

```
# Add the stdlib dependency as hosted on public Puppet Forge.
#
# We intentionally do not include the stdlib dependency in our Modulefile to make it easier for users who decided to
# use internal copies of stdlib so that their deployments are not coupled to the availability of PuppetForge.  While
# there are tools such as puppet-library for hosting internal forges or for proxying to the public forge, not everyone
# is actually using those tools.
mod 'puppetlabs/stdlib', '>= 4.1.0'

# Add the puppet-kafka module
mod 'mosquitto',
  :git => 'https://github.com/lowi-yeah/puppet-mosquitto.git'

# Add the puppet-limits and puppet-supervisor module dependencies
mod 'limits',
  :git => 'https://github.com/miguno/puppet-limits.git'

mod 'supervisor',
  :git => 'https://github.com/miguno/puppet-supervisor.git'
```

Then use librarian-puppet to install (or update) the Puppet modules.


<a name="configuration"></a>

# Configuration

* See [init.pp](manifests/init.pp) for the list of currently supported
  configuration parameters.  These should be self-explanatory.
* See [params.pp](manifests/params.pp) for the default values of those configuration parameters.

<a name="usage"></a>

# Usage

**IMPORTANT: Make sure you read and follow the [Requirements and assumptions](#requirements) section above.**
**Otherwise the examples below will of course not work.**


<a name="configuration-examples"></a>

## Configuration examples


<a name="hiera"></a>

### Using Hiera


A "full" single-node example that includes the deployment of [supervisord](http://www.supervisord.org/) via
[puppet-supervisor](https://github.com/miguno/puppet-supervisor).
The Mosquitto broker will listen on port `1883/tcp`.


```yaml
---
classes:
  - mosquitto::service
  - supervisor
```

<a name="manifests"></a>

### Using Puppet manifests

_Note: It is recommended to use Hiera to control deployments instead of using this module in your Puppet manifests_
_directly._

TBD


<a name="service-management"></a>

## Service management

To manually start, stop, restart, or check the status of the Kafka broker service, respectively:

    $ sudo supervisorctl [start|stop|restart|status] mosquitto

Example:

    $ sudo supervisorctl status
    mosquitto                          RUNNING    pid 16461, uptime 3 days, 09:22:38


<a name="log-files"></a>

## Log files

_Note: The locations below may be different depending on the Kafka RPM you are actually using._

* Kafka log files: `/var/log/mosquitto/*.log`
* Supervisord log files related to Kafka processes:
    * `/var/log/supervisor/mosquitto/mosquitto.out`
    * `/var/log/supervisor/kafka-broker/kafka-broker.err`
* Supervisord main log file: `/var/log/supervisor/supervisord.log`


<a name="custom-zk-root"></a>


<a name="development"></a>

# Development

It is recommended run the `bootstrap` script after a fresh checkout:

    $ ./bootstrap

You have access to a bunch of rake commands to help you with module development and testing:

    $ bundle exec rake -T
    rake acceptance          # Run acceptance tests
    rake build               # Build puppet module package
    rake clean               # Clean a built module package
    rake coverage            # Generate code coverage information
    rake help                # Display the list of available rake tasks
    rake lint                # Check puppet manifests with puppet-lint / Run puppet-lint
    rake module:bump         # Bump module version to the next minor
    rake module:bump_commit  # Bump version and git commit
    rake module:clean        # Runs clean again
    rake module:push         # Push module to the Puppet Forge
    rake module:release      # Release the Puppet module, doing a clean, build, tag, push, bump_commit and git push
    rake module:tag          # Git tag with the current module version
    rake spec                # Run spec tests in a clean fixtures directory
    rake spec_clean          # Clean up the fixtures directory
    rake spec_prep           # Create the fixtures directory
    rake spec_standalone     # Run spec tests on an existing fixtures directory
    rake syntax              # Syntax check Puppet manifests and templates
    rake syntax:hiera        # Syntax check Hiera config files
    rake syntax:manifests    # Syntax check Puppet manifests
    rake syntax:templates    # Syntax check Puppet templates
    rake test                # Run syntax, lint, and spec tests

Of particular interest are:

* `rake test` -- run syntax, lint, and spec tests
* `rake syntax` -- to check you have valid Puppet and Ruby ERB syntax
* `rake lint` -- checks against the [Puppet Style Guide](http://docs.puppetlabs.com/guides/style_guide.html)
* `rake spec` -- run unit tests


<a name="todo"></a>

TBD

<a name="changelog"></a>

# Change log

See [CHANGELOG](CHANGELOG.md).


<a name="contributing"></a>

# Contributing to puppet-mosquitto

Code contributions, bug reports, feature requests etc. are all welcome.

If you are new to GitHub please read [Contributing to a project](https://help.github.com/articles/fork-a-repo) for how
to send patches and pull requests to puppet-kafka.


<a name="license"></a>

# License

Copyright © 2014 Stephan Lohwasser

See [LICENSE](LICENSE) for licensing information.


<a name="references"></a>

# References

This Puppet module is basically just an adaption of [miguno/puppet-kafka](https://github.com/miguno/puppet-kafka) 
