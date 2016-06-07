# base:
#   '*':
#     - stuff
base:
  '*':
    - mesos
    # - consul


  # 'G@roles:master or G@roles:slave':
    # - match: compound
    # - mesos
    # - consul


    # - match: grain
  'roles:master':
    - match: grain
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