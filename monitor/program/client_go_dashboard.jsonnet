local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';

dashboard.new(
  'Go Client Metrics',
  refresh='1m',
  editable=true,
  tags=['go_client', 'prometheus_ds'],
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
    'label_values(go_goroutines, job)',
    label='Job',
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(go_goroutines{job="$job"}, instance)',
    label='App',
    regex='(.+):.*',
    refresh='time',
  )
)
.addPanel(
  graphPanel.new(
    'Program Memory',
    fill=2,
    min=0,
    linewidth=2,
    decimals=2,
    format='bytes',
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'process_resident_memory_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Resident'
    )
  )
  .addTarget(
    prometheus.target(
      'process_virtual_memory_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Virtual'
    )
  ),
  { w: 12, h: 6, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Garbage Collection Duration',
    fill=2,
    min=0,
    linewidth=2,
    format='s',
    decimals=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'go_gc_duration_seconds{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Quantile {{quantile}}'
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Open File Descriptors',
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
      'process_open_fds{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Open file descriptors'
    )
  ),
  { w: 12, h: 6, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Memory',
    fill=2,
    min=0,
    linewidth=2,
    format='bytes',
    stack=true,
    decimals=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'go_memstats_stack_inuse_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Stack'
    )
  )
  .addTarget(
    prometheus.target(
      'go_memstats_alloc_bytes{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Allocated'
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Total Goroutines',
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
      'go_goroutines{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Goroutines'
    )
  ),
  { w: 12, h: 6, x: 0, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Total Threads',
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
      'go_threads{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Threads'
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
