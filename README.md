## Docker Swarm Stack For [DocDokuPLM](https://www.docdokuplm.com/)
### Based on [docdoku-plm-docker](https://github.com/docdoku/docdoku-plm-docker)

## Current Version: 2.5.6

### Stack

- DocDokuPLM using payara/server-full:4.181
- Nginx Alpine
- MariaDB 10/latest
- elasticsearch:6.6.1
- DocDokuPLM-build using ubuntu:16.04 for building DocDokuPLM

## Configuration

This is designed to be run under [Docker Swarm](https://docs.docker.com/engine/swarm/) mode, don't know why you can't use secrets with just compose but it is what it is.

I like using [Portainer](https://www.portainer.io/) since it makes all the swarm configuration and tinkering easier, but it's not necessary.

I personally use this with [Traefik](https://traefik.io/) as a reverse proxy, but also not necessary.

You'll need to create these [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/):

- YOURDOMAIN.com.crt = The SSL certificate for your domain (you'll need to create/copy this)
- YOURDOMAIN.com.key = The SSL key for your domain (you'll need to create/copy this)
- dhparam.pem = Diffie-Hellman parameter (you'll need to create/copy this)
- docdokuplmsql_root_password = Root password for your SQL database
- docdokuplmsql_password = DocDokuPLM user password for your SQL database
- AS_ADMIN_PASSWORD
- JWT_KEY
- ES_SERVER_PWD
- KEYSTORE_PASS
- KEYSTORE_KEY_PASS

You'll also need to create these [Docker Configs](https://docs.docker.com/engine/swarm/configs/):

- plm_vhost = The nginx vhost file for DocDokuPLM (template included, simply replace all instances of 'YOURDOMAIN')
- webapp.properties = template included, simply replace all instances of 'YOURDOMAIN'

Make whatever changes you need to docker-stack.yml (replace all instances of 'YOURDOMAIN').

Run with `docker stack deploy --compose-file docker-swarm.yaml docdokuplm`

You'll want to uncomment:
`command: "init && build && deploy"`
in the build container the first time you run the stack.

### [Main Repository](https://projects.zeigren.com/diffusion/28/)
### [Project](https://projects.zeigren.com/project/view/42/)