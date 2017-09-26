# Prometheus + Grafana Stack
Monitoring deployment with Prometheus, Alertmanager, Grafana, PostgreSQL

Requirements
------------
* Ansible 2.3.0

## Ansible deployment
### Install requirements
```
$ ansible-galaxy install -r requirements.yml
```
### Variables
```
prometheus_hosts: {}                       ### Key=value /etc/hosts entries for prometheus container
prometheus_targets: []                     ### Prometheus target hosts list
postgres_variables: []                     ### PostgreSQL container variables (env) USER,PASSWD,etc
grafana_variables: []                      ### Grafana Container variables (env)
prometheus_targets_label: nodeexporter     ### Prometheus targets job label
blackbox_targets_label: blackbox           ### Blackbox targets job label
```

### Run playbook
```
ansible-playbook playbook.yml
```
# Blackbox rules
```
modules:
# Simple GET-request probe
    prober: http
    timeout: 5s
    http:
      valid_status_codes: []
      method: GET
      no_follow_redirects: true
      fail_if_ssl: false
      fail_if_not_ssl: false
# Authentication check   
  http_basic_auth:
    prober: http
    timeout: 5s
    http:
      method: POST
      basic_auth:
        username: "username"
        password: "mysecret"
# POST-request probe      
  http_post_2xx:
    prober: http
    timeout: 5s
    http:
      method: POST
      headers:
        Content-Type: application/json
      body: '{}'
```
### Prometheus configuration Blackbox part 
```
  - job_name: 'blackbox_http'
    metrics_path: /probeу
    scrape_interval: 60s
    params:
        module: [http_2xx]

    file_sd_configs:
        - files:
          - /etc/prometheus/blackbox_http.yml

    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: blackbox:9115

  - job_name: 'blackbox_http_post'
    metrics_path: /probe
    scrape_interval: 60s
    params:
        module: [http_post_2xx]

    file_sd_configs:
        - files:
          - /etc/prometheus/blackbox_http_post.yml

    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: blackbox:9115

  - job_name: 'blackbox_http_auth'
    metrics_path: /probe
    scrape_interval: 60s
    params:
        module: [http_basic_auth]

    file_sd_configs:
        - files:
          - /etc/prometheus/blackbox_http_auth.yml

    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: blackbox:9115
```
## Example Blackbox target lists:
```
# file: blackbox_http.yml
---
- targets:
    - www.example.com
    - blog.example.com
    - wiki.example.com
  labels:
      job: "blackbox_http"
```
```
# file: blackbox_http_post.yml
---
- targets:
    - api.example.com
    - api-v2.example.com
    - api-v3.example.com
  labels:
      job: "blackbox_http_post"
```
```
# file: blackbox_http_auth.yml
---
- targets:
    - portal.example.com
    - team.example.com
  labels:
      job: "blackbox_http_auth"
```
