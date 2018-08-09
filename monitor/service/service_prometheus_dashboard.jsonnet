local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'prometheus';

dashboard.new(
  'Prometheus Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['prometheus_client', 'prometheus_ds'],
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
    'label_values(prometheus_tsdb_head_series, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(prometheus_tsdb_head_series{job="$job"}, instance)',
    label='Server',
    regex='(.+):.*',
    refresh='time',
  )
)
.addPanel(
  singlestat.new(
    'Time Series Total',
    datasource='-- Mixed --',
    valueName='current',
  )
  .addTarget(
    prometheus.target(
      'prometheus_tsdb_head_series{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 3, h: 4, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Time Series History',
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
      'prometheus_tsdb_head_series{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Time series'
    )
  ),
  { w: 12, h: 6, x: 0, y: 4 }
)
