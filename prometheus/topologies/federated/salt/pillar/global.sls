prometheus:
  lookup:
    server:
      versions:
        '0.16.1':
          config:
            scrape_configs:
              - job_name: 'federate'
                scrape_interval: 15s
                honor_labels: true
                metrics_path: '/federate'
                params:
                  'match[]':
                    - '{job="randoms"}'
                    - '{__name__=~"^job:"}'
                target_groups:
                  - targets:
                    - '192.168.33.11:9090'
                    - '192.168.33.12:9090'
              - job_name: 'prometheus'
                scrape_interval: 5s
                scrape_timeout: 10s
                target_groups:
                  - targets: ['localhost:9090']