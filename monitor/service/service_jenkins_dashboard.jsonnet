local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

local prometheus_ds = 'default';
local prometheus_job = 'jenkins';

dashboard.new(
  'Jenkins Metrics (default)',
  refresh='1m',
  editable=true,
  tags=['jenkins_client', 'prometheus_ds'],
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
    'label_values(jenkins_job_building_duration_count, job)',
    label='Job',
    current=prometheus_job,
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(jenkins_job_building_duration_count{job="$job"}, instance)',
    label='Master',
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
    'Job Process Rate',
    datasource='-- Mixed --',
    valueName='current',
    postfix=' jobs/min',
  )
  .addTarget(
    prometheus.target(
      'rate(jenkins_job_building_duration_count{job=~"$job", instance=~"$instance.+"}[1m])',
      datasource='$PROMETHEUS_DS',
    )
  ),
  { w: 4, h: 6, x: 0, y: 0 }
)
.addPanel(
  singlestat.new(
    'Queued Job Rate',
    datasource='-- Mixed --',
    valueName='current',
    postfix=' jobs/min',
  )
  .addTarget(
    prometheus.target(
      'rate(jenkins_job_queuing_duration_count{job=~"$job", instance=~"$instance.+"}[1m])',
      datasource='$PROMETHEUS_DS',
    )
  ),
  { w: 4, h: 6, x: 4, y: 0 }
)
.addPanel(
  singlestat.new(
    'Queue Size',
    datasource='-- Mixed --',
    valueName='current',
    postfix=' jobs',
  )
  .addTarget(
    prometheus.target(
      'jenkins_queue_size_value{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
    )
  ),
  { w: 4, h: 6, x: 8, y: 0 }
)
.addPanel(
  graphPanel.new(
    'Job Queue Duration',
    fill=5,
    min=0,
    format='s',
    linewidth=2,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'jenkins_job_queuing_duration{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Quantile {{quantile}}',
    )
  ),
  { w: 12, h: 6, x: 12, y: 0 }
)
.addPanel(
  graphPanel.new(
    'CPU Usage',
    fill=2,
    min=0,
    linewidth=2,
    format='percent',
    decimals=1,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'vm_cpu_load{job=~"$job", instance=~"$instance.+"} * 100',
      datasource='$PROMETHEUS_DS',
      legendFormat='CPU usage'
    )
  ),
  { w: 12, h: 6, x: 0, y: 6 }
)
.addPanel(
  graphPanel.new(
    'Executors',
    fill=2,
    min=0,
    linewidth=2,
    decimals=0,
    datasource='-- Mixed --',
    legend_values=true,
    legend_max=true,
    legend_current=true,
  )
  .addTarget(
    prometheus.target(
      'jenkins_executor_in_use_value{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='In use'
    )
  )
  .addTarget(
    prometheus.target(
      'jenkins_executor_free_value{job=~"$job", instance=~"$instance.+"}',
      datasource='$PROMETHEUS_DS',
      legendFormat='Free'
    )
  ),
  { w: 12, h: 6, x: 12, y: 6 }
)
