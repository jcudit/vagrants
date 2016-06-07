base:
  'global':
    - .prometheus.server
    - .alertmanager
  'dc*':
    - .random