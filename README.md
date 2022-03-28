# Wazuh Manager Container and Helm Chart 🐺

Docker image and Helm chart for Wazuh Manager and Filebeat, configurable for sending alerts to a specific OpenSearch instance

[![Publish Docker image to Docker Hub and GitHub Packages](https://github.com/iosifache/wazuh-manager-filebeat/actions/workflows/publish_image.yml/badge.svg)](https://github.com/iosifache/wazuh-manager-filebeat/actions/workflows/publish_image.yml)
[![Publish Helm Chart to GitHub Pages](https://github.com/iosifache/wazuh-manager-filebeat/actions/workflows/publish_chart.yml/badge.svg)](https://github.com/iosifache/wazuh-manager-filebeat/actions/workflows/publish_chart.yml)

[![GitHub Packages](https://img.shields.io/badge/GitHub%20Packages-iosifache%2Fwazuh--manager--filebeat-informational)](https://github.com/iosifache/wazuh-manager-filebeat/pkgs/container/wazuh-manager-filebeat)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-iosifache%2Fwazuh--manager--filebeat-informational)](https://hub.docker.com/r/iosifache/wazuh-manager-filebeat)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-iosifache.github.io-informational)](https://iosifache.github.io/wazuh-manager-filebeat/index.yaml)
[![Artifact Hub](https://img.shields.io/badge/Artifact%20Hub-wazuh--manager--filebeat-informational)](https://artifacthub.io/packages/helm/wazuh-manager-filebeat/wazuh-manager-filebeat)

## Description 🌄

You have a computer infrastructure up and running, including a Kubernetes cluster and an OpenSearch (or OpenDistro for Elasticsearch or Elasticsearch) instance. Because you want Wazuh agents installed on all workstations and servers, you'll need a Wazuh Manager to receive logs and produce alarms, which will be sent to OpenSearch to be stored and queried (via OpenSearch Dashboard).

All Docker images and Kubernetes deployments (optionally via Helm charts) either don't support OpenSearch or disabling the provided OpenDistro for Elasticsearch cluster.

This repository includes a Docker image and a Helm chart containing a Wazuh Manager instance, whose alarms are sent to OpenSearch via Filebeat. Both are created using workflows and pushed to their respective repositories: Docker Hub and GitHub Packages for the Docker image, and Artifact Hub for the Helm chart.

<details>
<summary><b>Observation about Installing the Wazuh Application in OpenSearch Dashboard 🖱️</b></summary>

Despite the fact that the developers noted in a development-related [pull request](https://github.com/wazuh/wazuh-kibana-app/issues/3794) that this is work in progress, I attempted to install the Wazuh application over OpenSearch Dashboard after installing the entire infrastructure outlined above. There is already a Kibana app available.

To test my assumption, I opened a shell inside a running pod (because to its persistency difficulties). The plugin manager is told to install the Kibana application by running the [command below](https://opensearch.org/docs/latest/dashboards/install/plugins/#install).

```
bash -x bin/opensearch-dashboards-plugin install https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-4.2.5_7.10.2-1.zip
[...]
Attempting to transfer from https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-4.2.5_7.10.2-1.zip
Transferring 33111704 bytes....................
Transfer complete
Retrieving metadata from plugin archive
Plugin installation was unsuccessful due to error "No opensearch-dashboards plugins found in archive
```

The setup is (as expected) unsuccessfully. 

As an aside, once the plugin is accessible, the Kubernetes cluster's persistency can be ensured by:
- At startup, inherit the OpenSearch container and perform `opensearch-dashboards-plugin install`
- If the maintainers add support (as in the [Kibana Helm chart](https://github.com/helm/charts/tree/master/stable/kibana)), the `.plugins.values` should be changed.

</details>

### Exposed Services 🌲

The TCP ports used in the `NodePort` configuration are mapped in the default range (`30000`-`32768`) as following:

| Default Port | Mapped Port | Description                 |
|--------------|-------------|-----------------------------|
| `1514`       | `30000`     | Agents connection service   |
| `1515`       | `30001`     | Agents registration service |
| `1516`       | `30002`     | Wazuh cluster daemon        |
| `55000`      | `30003`     | Wazuh RESTful API           |

<details>
<summary><b>Observation about Using a Proxy 🖱️</b></summary>

A proxy can be used to remap the exposed port to its default value. If you want to use HAProxy, you can use the following configuration excerpt (replacing the meta-labels with the information specific to your infrastructure):

```
[...]

frontend wazuh_connection_frontend
    bind *:1514
    default_backend wazuh_connection_backend

backend wazuh_connection_backend
    balance roundrobin
    server <worker_node_name> <worker_node_ip>:30000 check

frontend wazuh_registration_frontend
    bind *:1515
    default_backend wazuh_registration_backend

backend wazuh_registration_backend
    balance roundrobin
    server <worker_node_name> <worker_node_ip>:30001 check

frontend wazuh_daemon_frontend
    bind *:1516
    default_backend wazuh_daemon_backend

backend wazuh_daemon_backend
    balance roundrobin
    server <worker_node_name> <worker_node_ip>:30002 check

frontend wazuh_api_frontend
    bind *:55000
    default_backend wazuh_api_backend

backend wazuh_api_backend
    balance roundrobin
    server <worker_node_name> <worker_node_ip>:30003 check

[...]
```

</details>

## Requirements 🍖

The OpenSearch cluster must be set up separately or in a Kubernetes cluster in both the image and the chart scenario. Aside from that, Helm must be installed in the latter.

## Usage 🔪

### Docker Image 📦

- Create a `template.env` file using the [provided template](container\template.env), using the details of your OpenSearch instance.
- Run the Docker container: `docker run --rm --env-file template.env --interactive --detach --publish 1514:1514/tcp --publish 1514:1514/udp --publish 1515:1515 --publish 1516:1516 --publish 55000:55000 --name wazuh-manager-filebeat iosifache/wazuh-manager-filebeat`.

### Helm Chart 🎁

- Import the repository, either using Helm's command line interface or via another GUIs, such as Rancher.
- Modify the `values.yaml` file with the details of your OpenSearch instance.
- Run the application.