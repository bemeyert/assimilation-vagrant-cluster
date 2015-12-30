# assimilation-vagrant-cluster

Runs [Assimilation](http://linux-ha.org/source-doc/assimilation/html/index.html)
in a cluster. Control Vagrant with a YAML file. Start as many boxes as you
like. They all run in the same private network (using DHCP, name resolution
included).

**Caveat no. 1**: Works only with the Virtualbox provider.

**Caveat no.2**: Only used and tested with CentOS 7.

### Usage

Edit `hosts.yaml` according to your needs and run `vagrant up`.

### Format of `hosts.yaml`

```yaml
domain: local
boxes:
    # this is the CMA
    - name: &name1 cma
      box: centos-7.1-x86_64 
      hostname: *name1 
      provision:
          - name: 'provision/multicast.sh'
            run: 'always'
          - name: 'provision/update_c7.sh'
          - name: 'provision/cma.sh'
      triggers:
          - "systemctl start neo4j.service ; sleep 10"
          - "systemctl start assimilation-cma.service ; sleep 10"
          - "systemctl start assimilation-nanoprobe.service"
    # This is one "client" running nanoprobe
    - name: &name2 box1
      box: centos-7.1-x86_64 
      hostname: *name2 
      provision:
          - name: 'provision/multicast.sh'
            run: 'always'
          - name: 'provision/update_c7.sh'
          - name: 'provision/nano.sh'
      triggers:
          - "systemctl start assimilation-nanoprobe.service"
```
* `domain` is optional. Default is `.local`.
* CPU and memory are optional. Their default values are 1024MB and 1 CPU.
* `box_url` is optional. 
* `provision` is an array with paths to scripts which get executed inside the
  VM. `name` contains the path to the script. If `run` is set to "always", the
  script will always run as described in the
  [Vagrant documentation](https://docs.vagrantup.com/v2/provisioning/basic_usage.html)

### Requirements

You must install the Vagrant plugins `vagrant-hostmanager` and
`vagrant-triggers`. It is recommended to install `vagrant-cachier`.

### Accessing the neo4j webconsole

`ssh root@172.28.128.3 -L 7474:127.0.0.1:7474 -N`

* 172.28.128.3 is at the moment the IP of my CMA.
