local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'blackbox_http';

dashboard.new(
  'HTTP Metrics (default)',
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
    title='Host $instance HTTP Probe',
    repeat='instance',
  ), { w: 24, h: 1, x: 0, y: 0 }
)
.addPanel(
  singlestat.new(
    'Actual HTTP Response',
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
      { value: 'null', op: '=', text: 'N/A' },
      { value: 0, op: '=', text: 'Failed' },
      { value: 1, op: '=', text: 'Response OK' },
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
  singlestat.new(
    'SSL Certificate Expiry',
    datasource='-- Mixed --',
    format='s',
    colorBackground=true,
    colors=[
      '#d44a3a',
      'rgba(237, 129, 40, 0.89)',
      '#299c46',
    ],
    thresholds='1,1',
    valueName='current',
  )
  .addTarget(
    prometheus.target(
      'probe_ssl_earliest_cert_expiry{instance=~"$instance", job="$job"} - time()',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 6, h: 2, x: 0, y: 3 }
)
.addPanel(
  singlestat.new(
    'SSL Certificate Status',
    datasource='-- Mixed --',
    colorBackground=true,
    colors=[
      '#d44a3a',
      'rgba(237, 129, 40, 0.89)',
      '#299c46',
    ],
    thresholds='0,1209600',
    valueName='current',
    valueMaps=[
      { value: 'null', op: '=', text: 'No SSL' },
      { value: 0, op: '=', text: 'Cert OK' },
      { value: 1, op: '=', text: 'Failure' },
    ],
  )
  .addTarget(
    prometheus.target(
      'probe_http_ssl{instance=~"$instance", job="$job"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 6, h: 2, x: 0, y: 5 }
)
.addPanel(
  singlestat.new(
    'HTTP Status Code',
    datasource='-- Mixed --',
    colorBackground=true,
    colors=[
      '#d44a3a',
      'rgba(237, 129, 40, 0.89)',
      '#299c46',
    ],
    thresholds='200,299,300',
    valueName='current',
    valueMaps=[
      { value: 'null', op: '=', text: 'No SSL' },
      { value: 0, op: '=', text: 'Cert OK' },
      { value: 1, op: '=', text: 'Failure' },
    ],
  )
  .addTarget(
    prometheus.target(
      'probe_http_status_code{instance=~"$instance", job="$job"}',
      datasource='$PROMETHEUS_DS',
    )
  ), { w: 6, h: 2, x: 0, y: 7 }
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
  ), { w: 9, h: 6, x: 6, y: 3 }
)
.addPanel(
  graphPanel.new(
    'HTTP Response History',
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
  ), { w: 9, h: 6, x: 15, y: 3 }
)
