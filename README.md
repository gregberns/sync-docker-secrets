# Continuously Deploy Docker Secrets

## Purpose

Manage and update Secrets in Docker Swarm with LastPass.

## Attribution

This project was inspired by this article about managing Kubernetes secrets with LastPass:

https://engineering.upside.com/synchronizing-kubernetes-secrets-with-lastpass-584d564ba176

## Setup

Steps we'll take to get things working:

* Create LastPass note
* Update `config` file
* Run
* Validate secrets have been added
* Start services requiring secrets

### Create LastPass Notes

First create a LastPass note formatted like:

```
[secret name].[env name].secret
```

Example:

```
database_password.dev.secret
```

### Update Config

Once the note is created, modify the `/config/dev.json` file and add the name of the secret to the list, in the example above add `database_password`. 

Remove any other secret names from the config you do not have set up in LastPass.

## Run - Locally

To make testing easier, you can run 'locally' which means you have to manually supply your LastPass credentials.

By default, the scripts will use `dev` as the default environment. To change this, supply an environment variable: `env=prod`.

```bash
$ docker build -t deploy-secrets . && echo "Build Complete" && docker run -it -v /var/run/docker.sock:/var/run/docker.sock deploy-secrets bash
$ ./run.sh
# Add your LastPass credentials when prompted
```

## Run - Using Swarm Secrets

When running in swarm, you need to add your credentials as swarm secrets before starting the 'secret manager' as a stack.

Here's how:

```bash
# Set the secrets
$ echo "<TheUsername>" | docker secret create lastpass_username -
$ echo "<ThePassword>" | docker secret create lastpass_password -

# Start the stack
$ docker stack deploy -c docker-compose.create.yml secret-mgr

# See the logs
$ docker service ls
$ docker service logs jl
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Start
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Start LastPass login
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Please enter the LastPass master password for <email@dot.com>.
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | 
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Master Password: 
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Success: Logged in as email@dot.com.
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Starting LastPass sync...
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Sync complete.
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Start processing secret: example
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | Looking for note: example.dev.secret
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | bjms5xdawlp5ekpjr453vfhu9
secret-mgr_mgr.1.w4j6f99dddw6@linuxkit-025000000001    | End
```

## Validate With Service

The project includes a small node service that will respond to HTTP requests with a 200 if the service has the correct secret configured.

Required secret name: `lp_token`

Required secret value: `s0meSuperSecr3tP@SSw0rd`

```bash
$ docker stack deploy -c docker-compose.api.yml api

# open new terminal
$ curl -i http://localhost:3000/

# To see service logs
$ docker service ls # get service id
$ docker service logs <service_id>
```
