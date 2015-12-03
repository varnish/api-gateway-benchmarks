# API Gateway Benchmarks

Status: Work in progress.

This project aims to provide a complete set of tools needed to do performance comparisons in the API manager/gateway space.

It was inspired by the great [Framework Benchmarks project](https://github.com/TechEmpower/FrameworkBenchmarks) by [TechEmpower](https://www.techempower.com/benchmarks/).

## Test requirements

### Tests

#### 1. HTTP routing

Proxy incoming requests to an upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test01 |

#### 2. Authentication (API-key) and authorization

Authentication and authorization, and proxying to an upstream webserver.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test02 |
| Header      | apikey=key02                   |

#### 3. Rate limiting (high limit)

Rate limiting, authentication and authorization, and proxying to an upstream webserver. None of the requests should exceed the rate limitation.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test03 |
| Header      | apikey=key03                   |

#### 4. Rate limiting (low limit)

Rate limiting, authentication and authorization, and proxying to an upstream webserver. Most of the requests should exceed the rate limitation.

| Property    |                          Value |
|-------------|--------------------------------|
| Request     | GET http://gateway:8080/test04 |
| Header      | apikey=key04                   |

### General requirements

#### Web servers

Configuration for each web server is put in subdirectories in the ``webservers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the web server.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8888 |

#### Gateways

Configuration for each API gateway is put in subdirectories in the ``gateways/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install and start the gateway. The file ``configure`` should exist in the same directory, and when executed it should configure the gateway according to the tests.

The configuration should be according to the specification of one or more of the tests.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8080 |

#### Consumers

## Deployment requirements

* Three instances running CentOS 7 x86_64

## Deployment example (vagrant)

###### Build environment

    cd deployment/vagrant
    vagrant up

###### Deploy components

    vagrant ssh gateway
    cd /vagrant/gateways/kong
    ./deploy
    exit

    vagrant ssh webserver
    cd /vagrant/webservers/dummy-api
    ./deploy
    exit

    vagrant ssh consumer
    cd /vagrant/consumers/boom
    ./deploy
    exit

###### Run tests

    vagrant ssh consumer
    /usr/local/bin/test00
    /usr/local/bin/test01
    /usr/local/bin/test02
    /usr/local/bin/test03
    /usr/local/bin/test04
    exit

