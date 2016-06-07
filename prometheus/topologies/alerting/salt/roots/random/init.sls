golang-go:
  pkg:
    - installed

git:
  pkg:
    - installed

git-client-golang:
  git.latest:
    - name: https://github.com/prometheus/client_golang.git
    - target: /srv/client_golang
    - require:
      - pkg: git

  cmd.wait:
    - name: go get -d && go build
    - env:
      - GOPATH: /usr/share/go
    - cwd: /srv/client_golang/examples/random
    - watch:
      - git: git-client-golang

{% for port in range(8880,8890) %}
random-server-{{port}}:
  file.managed:
    - name: /etc/systemd/system/random-{{ port }}.service
    - user: root
    - group: root
    - contents: |
        [Unit]
        Description=random-{{port}}
        After=syslog.target network.target

        [Service]
        Type=simple
        RemainAfterExit=no
        WorkingDirectory=/srv/client_golang/examples/random
        User=prometheus
        Group=prometheus
        ExecStart=/srv/client_golang/examples/random/random --listen-address=:{{port}}

        [Install]
        WantedBy=multi-user.target
    - require_in:
      - service: random-{{port}}

  service.running:
    - name: random-{{port}}
    - enable: True
    - require:
      - git: https://github.com/prometheus/client_golang.git
{% endfor %}