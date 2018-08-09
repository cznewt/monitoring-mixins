
=======================
Basic Monitoring Mixins
=======================

The goal of this repo is to collect reusable fragments (mixins) of monitoring
metadata that is usable across container or server based infrastructures. The
idea is similar to concept of ``support metadata`` in salt-formulas project
(http://salt-formulas.readthedocs.io/en/latest/). For example the linux formula
that is responsible for configuring the base system, also defines following
support metadata that external formulas pick up through mine and react
accordingly.

* Prometheus alerts - https://github.com/salt-formulas/salt-formula-linux/blob/master/linux/meta/prometheus.yml
* Telegraf export rules - https://github.com/salt-formulas/salt-formula-linux/blob/master/linux/meta/telegraf.yml
* Fluentd formatters, etc - https://github.com/salt-formulas/salt-formula-linux/blob/master/linux/meta/fluentd.yml
* Grafana dashboards - https://github.com/salt-formulas/salt-formula-linux/blob/master/linux/meta/grafana.yml

And about 10 more definition of metadata for support services. The scope of
mixins in my opinion should grow to cover the full lifecycle of metric and
possibly more domains as log processing, etc.


Coverage
========

What metrics are supporter at the moment, links lead to the appropriate metric
exporter.


System Monitoring
-----------------

* Linux - https://github.com/prometheus/node_exporter
* Docker - https://github.com/google/cadvisor


Network Monitoring
------------------

* DNS - https://github.com/cznewt/domain_exporter
* HTTP - https://github.com/prometheus/blackbox_exporter
* ICMP - https://github.com/prometheus/blackbox_exporter
* SNMP - https://github.com/prometheus/snmp_exporter


Service Monitoring
------------------

Home Assistant - https://www.home-assistant.io/components/prometheus/
Jenkins - https://wiki.jenkins.io/display/JENKINS/Prometheus+Plugin
Prometheus - https://github.com/prometheus/blackbox_exporter
Robophery - https://github.com/prometheus/statsd_exporter


Miscellaneous Monitoring
------------------------

Solar Wind - https://github.com/cznewt/nasa-swpc-exporter


Requirements
============

Install ``jsonnet`` binary. The grafonnet library is copied locally in vendor
directory.
