# API Gateway Benchmarks

This project aims to provide a complete set of tools needed to do simple performance comparisons in the API manager/gateway space. It is inspired by the great [Framework Benchmarks project](https://github.com/TechEmpower/FrameworkBenchmarks) by [TechEmpower](https://www.techempower.com/benchmarks/).

## About

This repository contains configuration that makes it easy for everyone to reproduce performance comparisons of different HTTP based API gateway/manager products. The configuration and tests are open source, and contributions are encouraged.

To simplify the tests suite, three roles are defined: *consumer*, *gateway* and *webserver*. To run a performance test, each role must be filled by exactly one software component.

For performance comparisons, multiple performance tests are executed where one role switches software component (typically the gateway) between each run.

## Tests

The tests cover a limited set of features which are considered as basic functionality in most API gateways. Each test focuses on a set of very specific features for easy comparison.

**Test 00: Reference**

Requests sent directly from the consumer to the webserver. The gateway is not part of the request handling, and does therefore not affect the results.

The requests should be sent according to the following specifications.

| Property       |        Value |
|----------------|--------------|
| Request method |          GET |
| Protocol       |         http |
| Host           |    webserver |
| Port           |         8888 |
| Request path   |      /test00 |
| Headers        |       *none* |

The webserver should accept the requests and reply with ``200 OK``.

**Test 01: HTTP routing**

Proxy consumer requests through the gateway to the upstream webserver.

The requests should be sent from the consumer according to the following specifications.

| Property       |        Value |
|----------------|--------------|
| Request method |          GET |
| Protocol       |         http |
| Host           |      gateway |
| Port           |         8080 |
| Request path   |      /test01 |
| Headers        |       *none* |

The gateway should accept the requests and proxy them to ``http://webserver:8888/test01``. The webserver should accept the requests and reply with ``200 OK``.

**Test 02: Key based authentication and authorization**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver.

The requests should be sent from the consumer according to the following specifications.

| Property       |        Value |
|----------------|--------------|
| Request method |          GET |
| Protocol       |         http |
| Host           |      gateway |
| Port           |         8080 |
| Request path   |      /test02 |
| Headers        | apikey=key02 |

The gateway should verify the specified key, accept the requests and proxy them to ``http://webserver:8888/test02``. The webserver should accept the requests and reply with ``200 OK``.

**Test 03: Key based auth and rate limiting (high limit)**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver. All requests should be counted, but none should exceed the rate limitation.

The requests should be sent from the consumer according to the following specifications.

| Property       |        Value |
|----------------|--------------|
| Request method |          GET |
| Protocol       |         http |
| Host           |      gateway |
| Port           |         8080 |
| Request path   |      /test03 |
| Headers        | apikey=key03 |

The gateway should verify the specified key, accept the requests, count them and proxy them to ``http://webserver:8888/test03``. The webserver should accept the requests and reply with ``200 OK``.

**Test 04: Key based auth and rate limit of 1 rps**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver. Only one request is allowed per second. The rest of the requests should be rejected.

The requests should be sent from the consumer according to the following specifications.

| Property       |        Value |
|----------------|--------------|
| Request method |          GET |
| Protocol       |         http |
| Host           |      gateway |
| Port           |         8080 |
| Request path   |      /test04 |
| Headers        | apikey=key04 |

The gateway should verify the specified key, and allow only one request per second. This one request per second should be proxied to ``http://webserver:8888/test04``. The webserver should accept the requests and reply with ``200 OK``. The requests exceeding the rate limit should be rejected.

## Roles specification

### Consumers

Configuration for each type of consumer is put in subdirectories in the ``consumers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install and prepare the consumer for load generation.

Wrappers to run the different tests should be put in ``/usr/local/bin/`` inside the consumer instance and named ``test00``, ``test01``, ..., ``textXX``. The wrappers should execute requests according to the test specifications.

### Gateways

Configuration for each API gateway is put in subdirectories in the ``gateways/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the gateway. It should also define the APIs and policies needed for the tests.

| Property    |   Value |
|-------------|---------|
| Protocol    |    http |
| Listen host | 0.0.0.0 |
| Listen port |    8080 |

### Webservers

Configuration for each web server is put in subdirectories in the ``webservers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the web server.

| Property    |   Value |
|-------------|---------|
| Protocol    |    http |
| Listen host | 0.0.0.0 |
| Listen port |    8888 |

## Execution

### Environment specifications

* Three instances running CentOS 7 x86_64. Each of them service the purpose of ``consumer``, ``gateway`` or ``webserver``.
* Each host should be configured with ``/etc/hosts`` properly set with entries for ``consumer``, ``gateway`` and ``webserver`` for consistent host mapping in different environments.
* Selinux should be disabled.
* The EPEL7 repository should be enabled.
* Root access is required.
* This git repository cloned to */opt/benchmarks*.

### Deployment example

#### Vagrant and VirtualBox

**1. Install dependencies**

* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads).
* Install [Virtualbox guest additions](https://www.virtualbox.org/wiki/Downloads).
* Install [Vagrant](https://www.vagrantup.com/).
* Clone this git repository (``git clone https://github.com/varnish/api-gateway-benchmarks``).

**2. Prepare virtual environment**

Build the three virtual instances using Vagrant.

    cd deployment/vagrant
    vagrant up

**3. Deploy components**

    vagrant ssh gateway
    # Using Kong in this example. Tyk is also available in the tyk directory.
    cd /vagrant/gateways/kong
    sudo ./deploy
    exit

    vagrant ssh webserver
    cd /vagrant/webservers/dummy-api
    sudo ./deploy
    exit

    vagrant ssh consumer
    cd /vagrant/consumers/boom
    sudo ./deploy
    exit

**4. Run tests**

    vagrant ssh consumer
    /usr/local/bin/test00
    /usr/local/bin/test01
    /usr/local/bin/test02
    /usr/local/bin/test03
    /usr/local/bin/test04
    exit

**5. Interpret results**

Currently this is a manual process. The goal is to automate it.

