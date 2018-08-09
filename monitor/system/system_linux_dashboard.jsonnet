local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'node';

dashboard.new(
  'Linux Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['node_exporter', 'prometheus_ds'],
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
    'label_values(node_boot_time_seconds, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(node_boot_time_seconds{job="$job"}, instance)',
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
  singlestat.new(
    'System Uptime',
    format='s',
    datasource='-- Mixed --',
    valueName='current',
  )
  .addTarget(
    prometheus.target(
      'time() - node_boot_time_seconds{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
    )
  ),
  { w: 6, h: 4, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Load Average',
    fill=5,
    min=0,
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    prometheus.target(
      'node_load1{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Load 1m',
    )
  )
  .addTarget(
    prometheus.target(
      'node_load5{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Load 5m',
    )
  )
  .addTarget(
    prometheus.target(
      'node_load15{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Load 15m',
    )
  )
  .addSeriesOverride(
    { alias: 'Load 1m', color: '#E24D42' },
  )
  .addSeriesOverride(
    { alias: 'Load 5m', color: '#E0752D' },
  )
  .addSeriesOverride(
    { alias: 'Load 15m', color: '#E5AC0E' },
  ),
  { w: 24, h: 6, x: 0, y: 4 }
)
.addPanel(
  graphPanel.new(
    'CPU Usage',
    fill=6,
    min=0,
    max=100,
    linewidth=2,
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
      'sum(rate(node_cpu_seconds_total{job=~"$job", instance=~"$instance.+"}[$interval])) by (mode) * 100 / count(node_cpu_seconds_total{job=~"$job", instance=~"$instance.+"}) by (mode) or sum(irate(node_cpu_seconds_total{job=~"$job", instance=~"$instance.+"}[5m])) by (mode) * 100 / count(node_cpu_seconds_total{job=~"$job", instance=~"$instance.+"}) by (mode)',
      datasource='$PROMETHEUS_DS',
      legendFormat='{{ mode }}',
    )
  ),
  { w: 24, h: 6, x: 0, y: 10 }
)
.addPanel(
  graphPanel.new(
    'Memory Usage',
    fill=6,
    min=0,
    format='bytes',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'node_memory_MemTotal_bytes{job=~"$job", instance=~"$instance.+"} - (node_memory_MemAvailable_bytes{job=~"$job", instance=~"$instance.+"} or (node_memory_MemFree_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Buffers_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Cached_bytes{job=~"$job", instance=~"$instance.+"}))',
      datasource='$PROMETHEUS_DS',
      legendFormat='Used',
    )
  )
  .addTarget(
    prometheus.target(
      'node_memory_MemAvailable_bytes{job=~"$job", instance=~"$instance.+"} or (node_memory_MemFree_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Buffers_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Cached_bytes{job=~"$job", instance=~"$instance.+"})',
      datasource='$PROMETHEUS_DS',
      legendFormat='Available',
    )
  )
  .addTarget(
    prometheus.target(
      'node_memory_MemTotal_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Total',
    )
  )
  .addSeriesOverride(
    { alias: 'Used', color: '#0A437C' },
  )
  .addSeriesOverride(
    { alias: 'Available', color: '#5195CE' },
  )
  .addSeriesOverride(
    { alias: 'Total', color: '#052B51', legend: false, stack: false },
  ),
  { w: 12, h: 6, x: 0, y: 16 }
)
.addPanel(
  graphPanel.new(
    'Memory Distribution',
    fill=6,
    min=0,
    format='bytes',
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'node_memory_MemTotal_bytes{job=~"$job", instance=~"$instance.+"} - (node_memory_MemFree_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Buffers_bytes{job=~"$job", instance=~"$instance.+"} + node_memory_Cached_bytes{job=~"$job", instance=~"$instance.+"})',
      datasource='$PROMETHEUS_DS',
      legendFormat='Used',
    )
  )
  .addTarget(
    prometheus.target(
      'node_memory_MemFree_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Free',
    )
  )
  .addTarget(
    prometheus.target(
      'node_memory_Buffers_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Buffers',
    )
  ).addTarget(
    prometheus.target(
      'node_memory_Cached_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Cached',
    )
  ),
  { w: 12, h: 6, x: 12, y: 16 }
)
.addPanel(
  graphPanel.new(
    'Forks',
    fill=6,
    min=0,
    linewidth=0,
    bars=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_forks_total{job=~"$job", instance=~"$instance.+"}[$interval]) or irate(node_forks_total{job=~"$job", instance=~"$instance.+"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Forks',
    )
  )
  .addSeriesOverride(
    { alias: 'Forks', color: '#EF843C' },
  ),
  { w: 12, h: 6, x: 0, y: 22 }
)
.addPanel(
  graphPanel.new(
    'Processes',
    fill=2,
    min=0,
    linewidth=0,
    bars=true,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'node_procs_running{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Processes in runnable state',
    )
  )
  .addTarget(
    prometheus.target(
      'node_procs_blocked{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Processes blocked waiting for I/O to complete',
    )
  )
  .addSeriesOverride(
    { alias: 'Processes in runnable state', color: '#6ED0E0' },
  )
  .addSeriesOverride(
    { alias: 'Processes blocked waiting for I/O to complete', color: '#E24D42' },
  ),
  { w: 12, h: 6, x: 12, y: 22 }
)
.addPanel(
  graphPanel.new(
    'Context Switches',
    fill=6,
    min=0,
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_context_switches_total{job=~"$job", instance=~"$instance.+"}[$interval]) or irate(node_context_switches_total{job=~"$job", instance=~"$instance.+"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Context Switches',
    )
  ),
  { w: 12, h: 6, x: 0, y: 28 }
)
.addPanel(
  graphPanel.new(
    'Interrupts',
    fill=2,
    min=0,
    linewidth=2,
    stack=true,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_intr_total{job=~"$job", instance=~"$instance.+"}[$interval]) or irate(node_intr_total{job=~"$job", instance=~"$instance.+"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Interrupts',
    )
  )
  .addSeriesOverride(
    { alias: 'Interrupts', color: '#D683CE' },
  ),
  { w: 12, h: 6, x: 12, y: 28 }
)
.addPanel(
  graphPanel.new(
    'Swap Size',
    fill=6,
    min=0,
    format='bytes',
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'node_memory_SwapFree_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Free',
    )
  )
  .addTarget(
    prometheus.target(
      'node_memory_SwapTotal_bytes{job=~"$job", instance=~"$instance.+"} - node_memory_SwapFree_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Used',
    )
  ),
  { w: 12, h: 6, x: 0, y: 34 }
)
.addPanel(
  graphPanel.new(
    'Swap Activity',
    fill=2,
    min=0,
    linewidth=2,
    stack=true,
    format='Bps',
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_vmstat_pswpin{job=~"$job", instance=~"$instance.+"}[$interval]) * 4096 or irate(node_vmstat_pswpin{job=~"$job", instance=~"$instance.+"}[5m]) * 4096',
      datasource='$PROMETHEUS_DS',
      legendFormat='Write',
    )
  )
  .addTarget(
    prometheus.target(
      'rate(node_vmstat_pswpout{job=~"$job", instance=~"$instance.+"}[$interval]) * 4096 or irate(node_vmstat_pswpout{job=~"$job", instance=~"$instance.+"}[5m]) * 4096',
      datasource='$PROMETHEUS_DS',
      legendFormat='Read',
    )
  )
  .addSeriesOverride(
    { alias: 'Write', color: '#D683CE' },
  ),
  { w: 12, h: 6, x: 12, y: 34 }
)
.addPanel(
  graphPanel.new(
    'Incoming Network Traffic',
    fill=6,
    min=0,
    format='Bps',
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_network_receive_bytes_total{job=~"$job", instance=~"$instance.+", device!="lo"}[$interval]) or irate(node_network_receive_bytes_total{job=~"$job", instance=~"$instance.+", device!="lo"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Free',
    )
  ),
  { w: 12, h: 6, x: 0, y: 40 }
)
.addPanel(
  graphPanel.new(
    'Outcoming Network Traffic',
    fill=6,
    min=0,
    format='Bps',
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'rate(node_network_transmit_bytes_total{job=~"$job", instance=~"$instance.+", device!="lo"}[$interval]) or irate(node_network_transmit_bytes_total{job=~"$job", instance=~"$instance.+", device!="lo"}[5m])',
      datasource='$PROMETHEUS_DS',
      legendFormat='Free',
    )
  ),
  { w: 12, h: 6, x: 12, y: 40 }
)
