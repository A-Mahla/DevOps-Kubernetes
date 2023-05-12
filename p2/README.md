# Part II
- Three web applications are run in one K3s server instance and accessible depending on the `Host` used when making a request to the IP address `192.168.42.11`.

    **Application 1** has 1 replica and is accessible if request includes a header `Host: app1.com`<br/>
    **Application 2** has 3 replicas and is accessible if request includes a header `Host: app2.com`<br/>
    **Application 3** has 1 replica and is accessible by default or contains undefined value of request header `Host: app3.com`.

## View diagram of p2's environment

   <img alt="Diagram of p2 environment" src="https://user-images.githubusercontent.com/22397481/163712753-c335cd0d-fedc-404e-b83c-f6b37a02a2ee.png">


## Start and provision the vagrant environment of p2

   ```shell
   cd p2
   vagrant up
   Bringing machine 'amahlaS' up with 'virtualbox' provider...
   ==> amahlaS: Importing base box 'bento/debian-11'...
      [...]
      amahlaS: [INFO]  systemd: Starting k3s
      amahlaS: service/app-one created
      amahlaS: deployment.apps/app-one created
      amahlaS: service/app-two created
      amahlaS: deployment.apps/app-two created
      amahlaS: service/app-three created
      amahlaS: deployment.apps/app-three created
      amahlaS: ingress.networking.k8s.io/ingress-applications created
   ```


## Check created resources such as pods, services, deployments and replicas


```sh
vagrant ssh amahlaS --command "kubectl get all"
NAME                             READY   STATUS    RESTARTS   AGE
pod/app-one-7454877f6d-ndx7f     1/1     Running   0          36m
pod/app-two-867df7fb47-8rb9b     1/1     Running   0          36m
pod/app-two-867df7fb47-tsrdt     1/1     Running   0          36m
pod/app-three-5467985dbb-cg2n7   1/1     Running   0          36m
pod/app-two-867df7fb47-tzk98     1/1     Running   0          36m

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/app-one      ClusterIP   10.43.0.1      <none>        80/TCP    37m
service/app-two      ClusterIP   10.43.229.156  <none>        80/TCP    37m
service/app-three    ClusterIP   10.43.193.160  <none>        80/TCP    37m
service/kubernetes   ClusterIP   10.43.171.213  <none>        443/TCP   37m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app-one     1/1     1            1           37m
deployment.apps/app-three   1/1     1            1           37m
deployment.apps/app-two     3/3     3            3           37m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/app-one-7454877f6d     1         1         1       36m
replicaset.apps/app-three-5467985dbb   1         1         1       36m
replicaset.apps/app-two-867df7fb47     3         3         3       36m
Connection to 127.0.0.1 closed.
```
</details>

## Browse to check that the virtual machine is correctly configured

> <details>
> <summary>app1 with one replica</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app1.com" 192.168.56.110 | grep app
>   Hello from app1.
>       <td>app-one-7454877f6d-ndx7f</td>
> ```
> </details>
> <details>
> <summary>app2 with three replicas</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app2.com" 192.168.56.110 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-tsrdt</td>
> [~]$ curl -sH "Host:app2.com" 192.168.56.110 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-8rb9b</td>
> [~]$ curl -sH "Host:app2.com" 192.168.56.110 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-tzk98</td>
> ```
> </details>
> <details>
> <summary>app3 with one replica as default application</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app3.com" 192.168.56.110 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> [~]$ curl -sH "Host:42.fr" 192.168.56.110 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> [~]$ curl -s  192.168.56.110 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> ```
> </details>
> 
> Now, just search domain on your Browser: `app1.com`, `app2.com`, `app3.com`, `192.168.56.110`


