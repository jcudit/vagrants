base:
  'global':
    - .prometheus.server
  'dc*':
    - .prometheus.server
    - .random