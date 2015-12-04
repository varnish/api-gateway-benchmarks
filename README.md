# API Gateway Benchmarks

Status: Work in progress.

This project aims to provide a complete set of tools needed to do performance comparisons in the API manager/gateway space.

It was inspired by the great [Framework Benchmarks project](https://github.com/TechEmpower/FrameworkBenchmarks) by [TechEmpower](https://www.techempower.com/benchmarks/).

## About

## Tests

### Test 00: Reference

Requests sent directly from the consumer to the webserver.

| Property    |                            Value |
|-------------|----------------------------------|
| Request     | GET http://webserver:8888/test00 |

### Test 01: HTTP routing

Proxy incoming requests to an upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test01 |

### Test 02: Authentication (API-key) and authorization

Authentication and authorization, and proxying to an upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test02 |
| Header      | apikey=key02                   |

### Test 03: Rate limiting (high limit)

Rate limiting, authentication and authorization, and proxying to an upstream webserver. None of the requests should exceed the rate limitation.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test03 |
| Header      | apikey=key03                   |

### Test 04: Rate limiting (low limit)

Rate limiting, authentication and authorization, and proxying to an upstream webserver. Most of the requests should exceed the rate limitation.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test04 |
| Header      | apikey=key04                   |

## Setup requirements

### Web servers

Configuration for each web server is put in subdirectories in the ``webservers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the web server.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8888 |

### Gateways

Configuration for each API gateway is put in subdirectories in the ``gateways/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the gateway. It should also define the APIs and policies needed for the tests.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8080 |

### Consumers

Configuration for each consumer is put in subdirectories in the ``consumers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install and prepare the consumer.

Wrappers to run the different tests should be put in ``/usr/local/bin/`` and named ``test00``, ``test01``, ...

###### Reference test (``test00``)

| Property    |     Value |
|-------------|-----------|
| Target host | webserver |
| Target port |      8888 |

###### Tests (``test01, ...``)

| Property    |   Value |
|-------------|---------|
| Target host | gateway |
| Target port |    8080 |

## Execution

Three instances running CentOS 7 x86_64 are needed to execute the tests, each which fulfills the role of the *consumer*, *gateway* or *webserver*.

### Deployment example (vagrant)

###### 1. Install dependencies

* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads).
* Install [Virtualbox guest additions](https://www.virtualbox.org/wiki/Downloads).
* Install [Vagrant](https://www.vagrantup.com/).
* Clone this git repository (``git clone https://github.com/varnish/api-gateway-benchmarks``).

###### 2. Preapre virtual environment

Build the three virtual instances using Vagrant.

    cd deployment/vagrant
    vagrant up

###### 3. Deploy components

    vagrant ssh gateway
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

###### 4. Run tests

    vagrant ssh consumer
    sudo /usr/local/bin/test00
    sudo /usr/local/bin/test01
    sudo /usr/local/bin/test02
    sudo /usr/local/bin/test03
    sudo /usr/local/bin/test04
    exit

###### 5. Interpret results

Currently this is a manual process. The goal is to automate it.

