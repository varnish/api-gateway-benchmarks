# api-gateway-benchmarks

Status: Work in progress.

This project aims to provide a complete set of tools needed to do performance comparisons in the API manager/gateway space.

It was inspired by the great [Framework Benchmarks project](https://github.com/TechEmpower/FrameworkBenchmarks) by [TechEmpower](https://www.techempower.com/benchmarks/).

## Test requirements

### General requirements

#### Web servers

Configuration for each web server is put in subdirectories in the ``webservers/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the web server.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8888 |

#### Gateways

Configuration for each API gateway is put in subdirectories in the ``gateways/`` directory. Each subdirectory should contain a ``deploy`` file that can be executed to install, configure and start the gateway.

The configuration should be according to the specification of one or more of the tests.

| Property    |   Value |
|-------------|---------|
| Listen host | 0.0.0.0 |
| Listen port |    8080 |

#### Consumers

### Tests
XXX: List of tests

## Deployment requirements

* Three instances running CentOS 7 x86_64

## Deployment

### Gateways

#### Kong

    cd gateways/kong
    ./deploy

### Webservers

#### Dummy API

    cd webservers/dummy-api
    ./deploy
