prometheus:
  lookup:
    server:
      cur_version: 0.16.1
      versions:
        '0.16.1':
          # cd /vagrant/shared/misc && wget https://github.com/prometheus/prometheus/releases/download/0.16.1/prometheus-0.16.1.linux-amd64.tar.gz
          source: salt://files/misc/prometheus-0.16.1.linux-amd64.tar.gz
          source_hash: md5=ae89dcc61ad6b52caa4f9b652bebce36
          config:
            global:
              scrape_interval:     15s # By default, scrape targets every 15 seconds.
              evaluation_interval: 15s # By default, scrape targets every 15 seconds.
              # scrape_timeout is set to the global default (10s).

              # Attach these labels to any time series or alerts when communicating with
              # external systems (federation, remote storage, Alertmanager).
              external_labels:
                monitor: 'codelab-monitor'

            # A scrape configuration containing exactly one endpoint to scrape:
            # Here it's Prometheus itself.
            scrape_configs:
              # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
              - job_name: 'prometheus'

                # Override the global default and scrape targets from this job every 5 seconds.
                scrape_interval: 5s
                scrape_timeout: 10s

                target_groups:
                  - targets: ['localhost:9090']
              - job_name: 'randoms'
                target_groups:
                  - targets: [
                      {% for octet in range(11,12) %}
                        {% for port in range(8880,8890) %}
                          '192.168.33.{{ip}}:{{port}}',
                        {% endfor %}
                      {% endfor %}
                    ]
                    labels: 
                      group: 'production'
            rule_files:
              - 'prometheus.rules'
    node_exporter:
      cur_version: 0.12.0rc1
      versions:
        '0.12.0rc1':
          # cd /vagrant/shared/misc && wget https://github.com/prometheus/node_exporter/releases/download/0.12.0rc1/node_exporter-0.12.0rc1.linux-amd64.tar.gz
          source: salt://misc/node_exporter-0.12.0rc1.linux-amd64.tar.gz
          source_hash: md5=43d253ea664ea446c6c4a42e03400b30
    collectd_exporter:
      cur_version: 0.2.0
      versions:
        '0.2.0':
          # cd /vagrant/shared/misc && wget https://github.com/prometheus/collectd_exporter/releases/download/0.2.0/collectd_exporter-0.2.0.linux-amd64.tar.gz
          source: salt://misc/collectd_exporter-0.2.0.linux-amd64.tar.gz
          source_hash: md5=2e43f4431375aae3afee8ad92f9e0970

alertmanager:
  lookup:
    server:
      global:
        # The smarthost and SMTP sender used for mail notifications.
        smtp_smarthost: 'localhost:25'
        smtp_from: 'alertmanager@example.org'
        smtp_auth_username: 'alertmanager'
        smtp_auth_password: 'password'
        # The auth token for Hipchat.
        hipchat_auth_token: '1234556789'
        # Alternative host for Hipchat.
        hipchat_url: 'https://hipchat.foobar.org/'

      # The directory from which notification templates are read.
      templates: 
      - '/etc/alertmanager/template/*.tmpl'

      # The root route on which each incoming alert enters.
      route:
        # The labels by which incoming alerts are grouped together. For example,
        # multiple alerts coming in for cluster=A and alertname=LatencyHigh would
        # be batched into a single group.
        group_by: ['alertname', 'cluster', 'service']

        # When a new group of alerts is created by an incoming alert, wait at
        # least 'group_wait' to send the initial notification.
        # This way ensures that you get multiple alerts for the same group that start
        # firing shortly after another are batched together on the first 
        # notification.
        group_wait: 30s

        # When the first notification was sent, wait 'group_interval' to send a batch
        # of new alerts that started firing for that group.
        group_interval: 5m

        # If an alert has successfully been sent, wait 'repeat_interval' to
        # resend them.
        repeat_interval: 3h 

        # A default receiver
        receiver: team-X-mails

        # All the above attributes are inherited by all child routes and can 
        # overwritten on each.

        # The child route trees.
        routes:
        # This routes performs a regular expression match on alert labels to
        # catch alerts that are related to a list of services.
        - match_re:
            service: ^(foo1|foo2|baz)$
          receiver: team-X-mails
          # The service has a sub-route for critical alerts, any alerts
          # that do not match, i.e. severity != critical, fall-back to the
          # parent node and are sent to 'team-X-mails'
          routes:
          - match:
              severity: critical
            receiver: team-X-pager
        - match:
            service: files
          receiver: team-Y-mails

          routes:
          - match:
              severity: critical
            receiver: team-Y-pager

        # This route handles all alerts coming from a database service. If there's
        # no team to handle it, it defaults to the DB team.
        - match:
            service: database
          receiver: team-DB-pager
          # Also group alerts by affected database.
          group_by: [alertname, cluster, database]
          routes:
          - match:
              owner: team-X
            receiver: team-X-pager
          - match:
              owner: team-Y
            receiver: team-Y-pager


      # Inhibition rules allow to mute a set of alerts given that another alert is
      # firing.
      # We use this to mute any warning-level notifications if the same alert is 
      # already critical.
      inhibit_rules:
      - source_match:
          severity: 'critical'
        target_match:
          severity: 'warning'
        # Apply inhibition if the alertname is the same.
        equal: ['alertname', 'cluster', 'service']


      receivers:
      - name: 'team-X-mails'
        email_configs:
        - to: 'team-X+alerts@example.org'

      - name: 'team-X-pager'
        email_configs:
        - to: 'team-X+alerts-critical@example.org'
        pagerduty_configs:
        - service_key: <team-X-key>

      - name: 'team-Y-mails'
        email_configs:
        - to: 'team-Y+alerts@example.org'

      - name: 'team-Y-pager'
        pagerduty_configs:
        - service_key: <team-Y-key>

      - name: 'team-DB-pager'
        pagerduty_configs:
        - service_key: <team-DB-key>
      - name: 'team-X-hipchat'
        hipchat_configs:
        - auth_token: <auth_token>
          room_id: 85
          message_format: html
          notify: true
