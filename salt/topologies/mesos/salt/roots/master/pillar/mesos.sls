# mesos config
mesos:
  # interface for running mesos on
  interface: eth1

# mesos-slave config
# mesos-slave:
  # attributes which are saved to /etc/mesos-slave/attributes and can be queried by marathon
  # attributes:
    # rack: a
    # foo: bar
    # customer: customer-{{ salt['grains.get']('customer_id', 0) }}
