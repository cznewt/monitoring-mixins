local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'blackbox_ping';

dashboard.new(
  'ICMP Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['blackbox_exporter', 'prometheus_ds'],
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
.addPanel(
  row.new(
    title='Host $instance ICMP Probe',
    repeat='instance',
  ), { w: 24, h: 1, x: 0, y: 0 }
)
.addPanel(
  singlestat.new(
    'Actual ICMP Response',
    datasource='-- Mixed --',
    colorBackground=true,
    colors=[
      '#d44a3a',
      'rgba(237, 129, 40, 0.89)',
      '#299c46',
    ],
    thresholds='1,1',
    valueName='current',
    valueMaps=[
      {
        value: 'null',
        op: '=',
        text: 'N/A',
      },
      {
        value: 0,
        op: '=',
        text: 'Ping Failed',
      },
      {
        value: 1,
        op: '=',
        text: 'Ping OK',
      },
    ],
  )
  .addTarget(
    prometheus.target(
      'probe_success{instance=~"$instance", job="$job"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 24, h: 2, x: 0, y: 1 }
)
.addPanel(
  graphPanel.new(
    'Probe Duration History',
    format='s',
    fill=4,
    linewidth=2,
    min=0,
    decimals=2,
    legend_show=false,
    datasource='-- Mixed --',
  )
  .addTarget(
    prometheus.target(
      'probe_duration_seconds{instance=~"$instance", job="$job"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 12, h: 5, x: 0, y: 2 }
)
.addPanel(
  graphPanel.new(
    'ICMP Response History',
    fill=8,
    linewidth=2,
    min=0,
    max=1,
    decimals=2,
    legend_show=false,
    datasource='-- Mixed --',
  )
  .addTarget(
    prometheus.target(
      'probe_success{instance=~"$instance", job="$job"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 12, h: 5, x: 12, y: 2 }
)
