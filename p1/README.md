#Part I
## Vagrantfile
- The environmental variable `VAGRANT_VAGRANTFILE` allows to specify the filename of the [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile) that [Vagrant](https://learn.hashicorp.com/tutorials/vagrant/getting-started-index?in=vagrant/getting-started) searches for. By default, this is "Vagrantfile".<br/>
It is useful where a single folder may contain multiple Vagrantfiles representing different configurations. Note that this is not a file path, but just a filename. [⧉](https://www.vagrantup.com/docs/other/environmental-variables#vagrant_vagrantfile)

- To use a different filename, either export the variable :
    ```shell
    export VAGRANT_VAGRANTFILE=Vagrantfile_one
    vagrant up
    [...]
    export VAGRANT_VAGRANTFILE=Vagrantfile_two
    vagrant up
    ```
	or set it at run time :
 	```shell
	VAGRANT_VAGRANTFILE=Vagrantfile_one vagrant up
	VAGRANT_VAGRANTFILE=Vagrantfile_one vagrant ssh
	[...]
	VAGRANT_VAGRANTFILE=Vagrantfile_two vagrant up
	VAGRANT_VAGRANTFILE=Vagrantfile_two vagrant ssh
	```

## K3s

- we have to install K3S on our server. To do that, we have to connect to our server machine and run the following command:

    ```bash
    curl -sfL https://get.k3s.io | sh -
    ```
    You can also specify some options to install K3S, by example if you want to be in server or agent mode. You can find more information about the options [here](https://docs.k3s.io/installation/configuration).

    ```bash
    export K3S_INSTALL_K3S_EXEC="--server --node-ip 192.42.42.42"
    ```


## On run time

- The IP addresses are dedicated on the eth1 interface.<br/>
- The IP of the first machine (Server) is 192.168.56.110/24<br/>
- The IP of the second machine (ServerWorker) is 192.168.56.111/24

	```shell
	cd p1
	vagrant up
	Bringing machine 'amahlaS' up with 'virtualbox' provider...
	Bringing machine 'amahlaSW' up with 'virtualbox' provider...
	[...]
	vagrant ssh amahlaS --command "kubectl get node -o wide"
	NAME      STATUS   ROLES                  AGE   VERSION        INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION           CONTAINER-RUNTIME
	amahlasw   Ready    <none>                 10m   v1.22.7+k3s1   192.168.56.111   <none>        Debian 11 (Core)   3.10.0-1127.el7.x86_64   containerd://1.5.9-k3s1
	amahlas    Ready    control-plane,master   15m   v1.22.7+k3s1   192.168.56.110   <none>        Debian 11 (Core)   3.10.0-1127.el7.x86_64   containerd://1.5.9-k3s1
	Connection to 127.0.0.1 closed.
	```
