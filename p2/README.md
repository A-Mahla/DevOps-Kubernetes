# Summary
- Three web applications are run in one K3s server instance and accessible depending on the `Host` used when making a request to the IP address `192.168.42.11`.

    **Application 1** has 1 replica and is accessible if request includes a header `Host: app1.com`<br/>
    **Application 2** has 3 replicas and is accessible if request includes a header `Host: app2.com`<br/>
    **Application 3** has 1 replica and is accessible by default or contains undefined value of request header `Host: app3.com`.

## View diagram of p2's environment

<img alt="Diagram of p2 environment" src="https://user-images.githubusercontent.com/22397481/163712753-c335cd0d-fedc-404e-b83c-f6b37a02a2ee.png">
</details>

## Start and provision the vagrant environment of p2
<details>
<summary>Expand</summary>

```shell
vagrant up
Bringing machine 'suchoS' up with 'virtualbox' provider...
==> amahlaS: Importing base box 'bento/debian11'...
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
</details>

## Check created resources such as pods, services, deployments and replicas
<details>
<summary>Expand</summary>

```sh
vagrant ssh suchoS --command "kubectl get all"
NAME                             READY   STATUS    RESTARTS   AGE
pod/app-one-7454877f6d-ndx7f     1/1     Running   0          36m
pod/app-two-867df7fb47-8rb9b     1/1     Running   0          36m
pod/app-two-867df7fb47-tsrdt     1/1     Running   0          36m
pod/app-three-5467985dbb-cg2n7   1/1     Running   0          36m
pod/app-two-867df7fb47-tzk98     1/1     Running   0          36m

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/app-one      ClusterIP   10.43.246.0   <none>        80/TCP    37m
service/app-two      ClusterIP   10.43.99.33   <none>        80/TCP    37m
service/app-three    ClusterIP   10.43.77.88   <none>        80/TCP    37m
service/kubernetes   ClusterIP   10.43.0.1     <none>        443/TCP   37m

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

## View Ingress
<details>
<summary>Expand</summary>

```shell
vagrant ssh suchoS --command "kubectl describe ingress"
Name:             ingress-applications
Namespace:        default
Address:          192.168.42.110
Default backend:  app-three:80 (10.42.0.9:8080)
Rules:
  Host        Path  Backends
  ----        ----  --------
  app1.com
              /   app-one:80 (10.42.0.2:8080)
  app2.com
              /   app-two:80 (10.42.0.11:8080,10.42.0.5:8080,10.42.0.6:8080)
  *
              /   app-three:80 (10.42.0.9:8080)
Annotations:  <none>
Events:       <none>
Connection to 127.0.0.1 closed.
```
</details>

## Browse to check that the virtual machine is correctly configured
<details>
<summary>Using curl</summary>

> <details>
> <summary>app1 with one replica</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app1.com" 164.92.153.174 | grep app
>   Hello from app1.
>       <td>app-one-7454877f6d-ndx7f</td>
> ```
> </details>
> <details>
> <summary>app2 with three replicas</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app2.com" 164.92.153.174 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-tsrdt</td>
> [~]$ curl -sH "Host:app2.com" 164.92.153.174 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-8rb9b</td>
> [~]$ curl -sH "Host:app2.com" 164.92.153.174 | grep app
>   Hello from app2.
>       <td>app-two-867df7fb47-tzk98</td>
> ```
> </details>
> <details>
> <summary>app3 with one replica as default application</summary>
> 
> ```shell
> [~]$ curl -sH "Host:app3.com" 164.92.153.174 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> [~]$ curl -sH "Host:42.fr" 164.92.153.174 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> [~]$ curl -s  164.92.153.174 | grep app
>   Hello from app3.
>       <td>app-three-5467985dbb-cg2n7</td>
> ```
> </details>
</details>

<details>
<summary>Using Firefox</summary>

Install a plugin [ModHeader](https://addons.mozilla.org/en-US/firefox/addon/modheader-firefox/) for Firefox and add `Host` header to the request.
> <details>
> <summary>app1 with one replica</summary>
>
> <img width="2048" alt="app1" src="https://user-images.githubusercontent.com/22397481/163831710-74ff5b91-9f0d-41a2-9f61-68bb89311702.png">
> </details>
> <details>
> <summary>app2 with three replicas</summary>
> 
>> <details>
>> <summary>app1 replica 1</summary>
>> <img alt="app2r1" src="https://user-images.githubusercontent.com/22397481/163832259-54143e6f-b93a-4c6a-a2ae-fa952e4b18db.png">
>> </details>
>> <details>
>> <summary>app1 replica 2</summary>
>> <img alt="app2r2" src="https://user-images.githubusercontent.com/22397481/163832274-1ec4421c-3321-43b9-bfe8-455c3ee1815d.png">
>> </details>
>> <details>
>> <summary>app1 replica 3</summary>
>> <img alt="app2r3" src="https://user-images.githubusercontent.com/22397481/163832275-45921b0e-2d4f-4769-8670-625ce935651c.png">
>> </details>
> </details>
> <details>
> <summary>app3 with one replica as default application</summary>
> <img alt="app3" src="https://user-images.githubusercontent.com/22397481/163832594-3871431d-e29e-4eb5-b662-dd1bdd005d46.png">
> <img alt="app3default" src="https://user-images.githubusercontent.com/22397481/163832620-1bb64445-8a08-4b72-a523-cb511e412079.png">
> </details>
</details>
