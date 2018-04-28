# kalaspuff/python-nginx-proxy – docker image
Docker base-image using nginx proxy to backend on port 8080.

* GitHub: https://github.com/kalaspuff/docker-python-nginx-proxy
* DockerHub: https://hub.docker.com/r/kalaspuff/python-nginx-proxy/

To make nginx service start when running the Docker container, make sure
to start the CMD section with `start-service`.

The base-image will expose port 80, where nginx is configured to forward
to your running code on port 8080. WebSockets may be used on the HTTP routes
`/ws/*` and/or `/websocket/*`


### Pull from registry

```
$ docker pull kalaspuff/python-nginx-proxy
```


### Use in Dockerfile

_ENTRYPOINT for images build from this base-image will use the custom-built `start-service` script._

```
FROM kalaspuff/python-nginx-proxy:1.1.0
...
```


## Package / tools versions

| Software | Version  | Extra                                |
| -------- | -------- | ------------------------------------ |
| Python   | 3.6.5    |                                      |
| nginx    | 1.14.0   |                                      |
| Debian   | stretch  | Image based on `debian:stretch-slim` |

Also included are the Debian packages for `git`, `curl`, `vim`, `ps`, `nano`, `netcat`, `netstat` and `unzip`.


## Logging

`nginx` is configured to store logs in the `/logs/` directory which could be mounted
 as a volume for external access.


---

### Build Docker image

The latest versions are already pushed to the Docker registry for use. If you want to 
build the image yourself run:

```
$ make build
```

---

### Example

*Starting docker container with netcat listening on port 8080*

```
$ docker run -p 4711:80 -ti kalaspuff/python-nginx-proxy:1.1.0 nc -lp 8080
```

*curl to connect to container forwarded to nginx proxy at port 80*

```
$ curl http:/localhost:4711/
```

*Output from netcat on container*
```
GET / HTTP/1.0
Host: localhost
X-Real-IP: 172.17.0.1
X-Forwarded-For: 172.17.0.1
X-Forwarded-Proto: http
Connection: close
User-Agent: curl/7.54.0
Accept: */*
```
