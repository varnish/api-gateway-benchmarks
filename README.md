# API Gateway Benchmarks

Status: Work in progress.

This project aims to provide a complete set of tools needed to do simple performance comparisons in the API manager/gateway space.

It is inspired by the great [Framework Benchmarks project](https://github.com/TechEmpower/FrameworkBenchmarks) by [TechEmpower](https://www.techempower.com/benchmarks/).

## About

The goal of this project is to make it easy to reproduce performance comparisons of different HTTP based API gateway/manager products. The configuration and tests are open source, and contributions are encouraged.

To simplify the tests, three roles are defined: *consumer*, *gateway* and *webserver*. Each of the roles have a simple specification, which makes it easy to swap software components for the different roles.

To run a performance test, each role must be filled by exactly one software component.

For performance comparisons, multiple performance tests are executed where one role switches software component (typically the gateway) between each run.

## Tests

The tests cover a limited set of features which are considered as basic functionality in most API gateways. Each test focuses on a set of very specific features for easy comparison.

**Test 00: Reference**

Requests sent directly from the consumer to the webserver. The gateway is not part of the request handling, and does therefore not affect the results.

| Property    |                            Value |
|-------------|----------------------------------|
| Request     | GET http://webserver:8888/test00 |

**Test 01: HTTP routing**

Proxy consumer requests through the gateway to the upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test01 |

**Test 02: Key based authentication and authorization**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test02 |
| Header      | apikey=key02                   |

**Test 03: Key based auth and rate limiting (high limit)**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver. All requests should be counted, but none should exceed the rate limitation.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test03 |
| Header      | apikey=key03                   |

**Test 04: Key based auth and rate limit of 1 rps**

Authenticate, authorize and proxy consumer requests through the gateway to the upstream webserver. Only one request is allowed per second. The rest of the requests should be rejected.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test04 |
| Header      | apikey=key04                   |

## Roles specification

There are three roles involved; consumers, gateways and webservers.

### Consumers

Configuration for each type of consumer is put in subdirectories in the ``consumers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install and prepare the consumer for load generation.

Wrappers to run the different tests should be put in ``/usr/local/bin/`` inside the consumer instance and named ``test00``, ``test01``, ..., ``textXX``.

**Reference test** (``test00``):

| Property    |     Value |
|-------------|-----------|
| Protocol    |      http |
| Target host | webserver |
| Target port |      8888 |

**Other tests** (``test01, ...``):

| Property    |   Value |
|-------------|---------|
| Protocol    |    http |
| Target host | gateway |
| Target port |    8080 |

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

Three instances running CentOS 7 x86_64 are needed to execute the tests, each which fulfills the role of the *consumer*, *gateway* or *webserver*.

### Deployment examples

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
    sudo /usr/local/bin/test00
    sudo /usr/local/bin/test01
    sudo /usr/local/bin/test02
    sudo /usr/local/bin/test03
    sudo /usr/local/bin/test04
    exit

**5. Interpret results**

Currently this is a manual process. The goal is to automate it.

