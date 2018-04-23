# kalaspuff/python-nginx-proxy – docker image
Docker base-image using nginx proxy to backend on port 8080.

* GitHub: https://github.com/kalaspuff/docker-python-nginx-proxy
* DockerHub: https://hub.docker.com/r/kalaspuff/python-nginx-proxy/

To make nginx service start when running the Docker container, make sure
to start the CMD section with `start-service`.

The base-image will expose port 80, where nginx is configured to forward
to your running code on port 8080.


### Pull from registry

```
$ docker pull kalaspuff/python-nginx-proxy
```


### Use in Dockerfile

```
FROM kalaspuff/python-nginx-proxy:1.0.0
...
CMD start-service <...>
```
