local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'dns';

dashboard.new(
  'DNS Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['dns_exporter', 'prometheus_ds'],
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
    'label_values(up, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(probe_duration_seconds{job="$job"}, instance)',
    label='Targets',
    refresh='time',
    multi=true,
    includeAll=true,
  )
)
.addTemplate(
  template.interval(
    'interval',
    'auto,5m,15m,1h,6h,1d',
    'auto',
    label='Interval'
  )
)
