prometheus:
  lookup:
    server:
      versions:
        '0.16.1':
          config:
            scrape_configs:
              - job_name: 'randoms'
                target_groups:
                  - targets: [{% for port in range(8880,8890) %}'localhost:{{port}}',{% endfor %}]
                    labels: 
                      group: 'production'
              - job_name: 'prometheus'
                scrape_interval: 5s
                scrape_timeout: 10s
                target_groups:
                  - targets: ['localhost:9090']