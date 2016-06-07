group-alertmanager:
  group:
    - present
    - name: alertmanager
    - system: True

user-alertmanager:
  user:
    - present
    - name: alertmanager
    - groups:
      - alertmanager
    - home: /srv/alertmanager
    - createhome: True
    - shell: /bin/false
    - system: True

alertmanager-dependencies:
  pkg.installed:
    - pkgs:
      - git
      - golang-go
      - build-essential
      - libc6-dev

git-alertmanager:
  git.latest:
    - name: https://github.com/prometheus/alertmanager.git
    - target: /srv/alertmanager
    - require:
      - pkg: git

  cmd.wait:
    - name: make build
    # - env:
    #   - GOPATH: /usr/share/go
    - cwd: /srv/alertmanager
    - watch:
      - git: git-alertmanager

alertmanager_config:
  file:
    - serialize
    - name: /srv/alertmanager/config.yaml
    - user: alertmanager
    - group: alertmanager
    - mode: 640
    - dataset_pillar: alertmanager:lookup:server:versions:{{ v_id }}:config
    - watch_in:
      - service: alertmanager
 
alertmanager-service:
  file.managed:
    - name: /etc/systemd/system/alertmanager.service
    - user: root
    - group: root
    - contents: |
        [Unit]
        Description=alertmanager
        After=syslog.target network.target

        [Service]
        Type=simple
        RemainAfterExit=no
        WorkingDirectory=/srv/alertmanager
        User=prometheus
        Group=prometheus
        ExecStart=/srv/alertmanager/alertmanager -config.file=/srv/alertmanager/config.yaml

        [Install]
        WantedBy=multi-user.target
    - require_in:
      - service: alertmanager

  service.running:
    - name: alertmanager
    - enable: True
    - require:
      - git: https://github.com/prometheus/alertmanager.git