local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'snmp';

dashboard.new(
  'SNMP Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['snmp_exporter', 'prometheus_ds'],
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
    'label_values(ifInOctets, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(ifHighSpeed{job="$job"}, instance)',
    label='Device',
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'interface',
    '$PROMETHEUS_DS',
    'label_values(ifHighSpeed{job="$job",instance="$instance"}, ifIndex)',
    label='Interface',
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
    'Incoming Traffic',
    fill=5,
    min=0,
    linewidth=2,
    format='Bps',
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    prometheus.target(
      'rate(ifHCInOctets{job=~"$job", instance="$instance"}[5m]) or rate(ifInOctets{job=~"$job", instance="$instance"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Port {{ifIndex}}',
    )
  ),
  { w: 12, h: 6, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Outgoing Traffic',
    fill=5,
    min=0,
    linewidth=2,
    format='Bps',
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    prometheus.target(
      'rate(ifHCOutOctets{job=~"$job", instance="$instance"}[5m]) or rate(ifOutOctets{job=~"$job", instance="$instance"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Port {{ifIndex}}',
    )
  ),
  { w: 12, h: 6, x: 0, y: 6 }
)
.addPanel(
  graphPanel.new(
    'Incoming Packets',
    fill=5,
    min=0,
    linewidth=2,
    format='Bps',
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    prometheus.target(
      'rate(ifHCInUcastPkts{job=~"$job", instance="$instance"}[5m]) or rate(ifInUcastPkts{job=~"$job", instance="$instance"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Port {{ifIndex}}',
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Outgoing Packets',
    fill=5,
    min=0,
    linewidth=2,
    format='Bps',
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    prometheus.target(
      'rate(ifHCOutUcastPkts{job=~"$job", instance="$instance"}[5m]) or rate(ifOutUcastPkts{job=~"$job", instance="$instance"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Port {{ifIndex}}',
    )
  ),
  { w: 12, h: 6, x: 12, y: 6 }
)
