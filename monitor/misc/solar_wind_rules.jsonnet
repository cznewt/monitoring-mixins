{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'weather-space',
        rules: [
          {
            expr: |||
              solar_wind_speed{job=~"$job"} > 500
            ||| % $._config,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Minor increase in solar wind speed',
            },
            'for': '15m',
            alert: 'solar_wind_speed_warning',
          },
          {
            expr: |||
              solar_wind_speed{job=~"$job"} > 1000
            ||| % $._config,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Major increase in solar wind speed',
            },
            'for': '3m',
            alert: 'solar_wind_speed_critical',
          },
          {
            expr: |||
              solar_wind_density{job=~"$job"} > 30
            ||| % $._config,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Minor increase in solar wind density',
            },
            'for': '15m',
            alert: 'solar_wind_density_warning',
          },
          {
            expr: |||
              solar_wind_density{job=~"$job"} > 100
            ||| % $._config,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Major sun burst',
            },
            'for': '3m',
            alert: 'solar_wind_density_critical',
          },
        ],
      },
    ],
  },
}
