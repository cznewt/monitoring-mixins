local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'hass';

dashboard.new(
  'Home Assistant Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['hass_client', 'prometheus_ds'],
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
    'label_values(hass_automation_triggered_count, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(hass_automation_triggered_count{job="$job"}, instance)',
    label='Server',
    regex='(.+):.*',
    refresh='time',
  )
)
.addPanel(
  graphPanel.new(
    'Total CPU Seconds',
    fill=2,
    min=0,
    linewidth=2,
    decimals=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(process_cpu_seconds_total{job=~"$job", instance=~"$instance.+"}[1m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Total CPU seconds'
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
