local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'cadvisor';

dashboard.new(
  std.join('', [
    'Docker Metrics (',
    prometheus_ds,
    ')'
  ]),
  refresh='1m',
  editable=true,
  tags=['cadvisor', 'prometheus_ds'],
)
.addTemplate(
  grafana.template.datasource(
    'PROMETHEUS_DS',
    'prometheus',
    prometheus_ds,
    label='Data Source',
  )
)
.addTemplate(
  template.new(
    'job',
    '$PROMETHEUS_DS',
    'label_values(container_cpu_user_seconds_total, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(container_cpu_user_seconds_total{job="$job"}, instance)',
    label='Host',
    regex='(.+):.*',
    refresh='time',
  )
)
.addTemplate(
  template.interval(
    'interval',
    'auto,1m,5m,15m,1h,6h,1d',
    'auto',
    label='Interval'
  )
)
.addPanel(
  graphPanel.new(
    'CPU Usage',
    fill=5,
    min=0,
    format='percent',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
  )
  .addTarget(
    prometheus.target(
      'rate(container_cpu_user_seconds_total{job=~"$job", instance=~"$instance.+", image!=""}[5m]) * 100',
      datasource='$PROMETHEUS_DS',
      legendFormat='{{name}}',
    )
  ),
  { w: 12, h: 6, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Memory Usage',
    fill=5,
    min=0,
    format='bytes',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
  )
  .addTarget(
    prometheus.target(
      'container_memory_usage_bytes{job=~"$job", instance=~"$instance.+", image!=""}',
      datasource='$PROMETHEUS_DS',
      legendFormat='{{name}}',
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Incoming Network Traffic',
    fill=5,
    min=0,
    format='Bps',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
  )
  .addTarget(
    prometheus.target(
      'irate(container_network_receive_bytes_total{job=~"$job", instance=~"$instance.+", image!=""}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='{{name}}',
    )
  ),
  { w: 12, h: 6, x: 0, y: 6 }
)
.addPanel(
  graphPanel.new(
    'Outgoing Network Traffic',
    fill=5,
    min=0,
    format='Bps',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
  )
  .addTarget(
    prometheus.target(
      'irate(container_network_transmit_bytes_total{job=~"$job", instance=~"$instance.+", image!=""}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='{{name}}',
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
