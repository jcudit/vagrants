base:
  '*':
    - mesos
    - consul


  # 'G@roles:master or G@roles:slave':
    # - match: compound
    # - mesos
    # - consul


    # - match: grain
  'roles:master':
    - mesos-master
    # - marathon
    # - registry

  'roles:slave':
    - match: grain
    - mesos-slave
    # - docker
    # - weave
    # - nginx
    # - cadvisor
    # - registrator
    # - schub