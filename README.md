# cf-tunnel


Selfhosting ngrok server/client for running on some tunnel.my.domain should be built with certificates - see references below


### Build

Builds docker image for server with CA root certificate for CN=tunnel.my.domain

ca.pem is created in /certs
**ca.key is printed by `docker build` - need to save it somethere and mount for next runs to /certs/ca.key**

 --build-arg NGROK_SERVER_DOMAIN=... is mandatory
```
docker build --build-arg NGROK_SERVER_DOMAIN=tunnel.my.domain -t codefresh/cf-tunnel:my.domain .
```

### Run server
For all ngrokd parameters see help in `docker run -it codefresh/cf-tunnel:my.domain ngrokd -h`

Server certificates are generated in /certs/{server.crt,server.key} and signed by ca.pem + ca.key

the command below will start `ngrokd -domain $NGROK_SERVER_DOMAIN -tlsCrt certs/server.crt -tlsKey certs/server.key $@`
```
docker run -d -v $(pwd)/ca.key:/certs/ca.key codefresh/cf-tunnel:my.domain server [ngrokd paramams]
```


### Run client
Simplified run - your service will be available from http://myservice.tunnel.my.domain :
```
docker run -d codefresh/cf-tunnel:my.domain client [myservice.local.address:]8080 myservice[.tunnel.my.domain]
```

Or run full ngrok command. In this case you need to mount your own config file:
`docker run -v $(pwd)/ngrok.conf:/root/.ngrok -d codefresh/cf-tunnel:my.domain ngrok [parameters]  `


##### References:
We are using open source ngrok 1.0
 https://github.com/inconshreveable/ngrok/blob/master/docs/SELFHOSTING.md
 https://www.svenbit.com/2014/09/run-ngrok-on-your-own-server/