# OpenPaaS ticketing08000linux

> Docker is available [here](https://www.docker.com/products/docker) and docker-compose [here](https://docs.docker.com/compose).
> Make sure that these are installed on your system before starting. NB: you can
> also install docker-compose using Python pip tool, see above :

```bash
# Using python package (you shoud use python virtualenv, cf virtualenvwrapper)
$ pip install docker-compose
```
## Presentation

Deploy an ticketing08000linux base on OpenPaaS with ease using Docker and docker-compose.

By default, the version used is the latest stable release of the OpenPaaS products, but you can also try the currently under-development version of components (activating the `preview` mode)

    Disclaimer: this repository is intended for 2 use cases only: **running a demo** and **developping / debugging**.
    You should never use it to run a production instance as it misses significant configurations to have your data secured and the produict sustainable.

## Table of contents
* [How to use](#how-to-use)
* [Available modes](#available-modes)
  + [Run Demo mode](#run-test-demo-mode)
  + [Preview mode](#preview-mode)
  + [Dev mode](#dev-mode)
* [Quick start](#quick-start)


### Vhosts declaration

As there won't be any DNS resolving to your local environment, you must edit your /etc/hosts file to add new entries.
That way, accessing http://frontend.ticketing.local with your browser will resolve to your local machine.

Add the following into your `/etc/hosts` file:
```
172.99.0.1      frontend.ticketing.local backend.ticketing.local
```  

## How to use

### Clone this repository:
```bash
$ git clone ssh://git@ci.linagora.com:7999/linagora/lgs/openpaas/ticketing-docker-dev.git
$ cd ticketing-docker-dev
```

### Choose the portion of the platform you want to run:
By default, the `docker-compose` commands will look for a file named `docker-compose.yml` in the current directory. In this repository, this will start the basic common services needed for an OpenPaaS ticketing08000linux (LDAP, OpenPaaS...) but will not start the whole platform, so you will be missing most interfaces and applications.

This is meant to let you what part of the platform you want to run, since the whole platform can be quite heavy to run on a single machine.

To choose what to run or not, you will need to use a `.env` file, that specifies your [`COMPOSE_FILE`](https://docs.docker.com/compose/reference/envvars/#compose_file) env variable.

To do that easily, you can simply run:
```
cp .env.sample .env
```

In this file, you will find some setup examples commented. You can just uncomment the line you want to use, or create your own.

Notes:
- You should run `docker-compose down --volumes --remove-orphans` and `docker-compose up -d` when changing setup, to avoid orphan containers.
- You must have to have only 1 line uncommented in this file to avoid unwanted setup override

### Start playing

You are now all set!
You can now use all the commands provided by the `docker-compose` tool.
See: https://docs.docker.com/compose/reference/

To access the platform, check the URL set up in section [Vhosts declaration](#vhosts-declaration).
Test user accounts are in the file `users.created.txt`.

#### Basic docker-compose survival commands

##### For the initial fetch or to update local images
```bash
$ docker-compose pull
```

##### "Up & Down" vs "Start & Stop"

By default, running `docker-compose up` will create & start all containers in front.
But when you exit the command, containers will be destroyed and data won't be kept (equivalent of running `docker-compose down --volumes`).

If you want to keep your containers and the data they contain temporarily, you can use start & stop:
```
$ docker-compose up -d   # Create containers and start them in background
$ docker-compose stop    # Stop all containers, but keep them
$ docker-compose start   # Restart existing containers that were stopped
$ docker-compose down -v # Stop & Remove all containers, local volumes and networks
```

    Note: containers should be considered expendable. This mean that you should not rely on start & stop to save data you want to keep in the long run!
    See the `Data persistence` section below.

##### Monitor the state of your containers:
```bash
$ docker-compose ps
```

Init containers must end up with exit 0. If no, launch again : `$ docker-compose up`

##### See logs for all containers
```bash
$ docker-compose logs    # Display logs
$ docker-compose logs -f # Watch logs
$ docker-compose logs -f esn # Watch logs for the ESN service
```

##### Delete previously created containers
```bash
$ docker-compose down -v
```
**Tip**: If you want a quick command to tear down your environment and bring it completely fresh again, add the following to your `~/.bashrc` or `~/.zshrc`:
```bash
alias sarra="docker-compose pull && docker-compose down --volumes && docker-compose up -d"
```

## Available modes
We rely on compose to provide some custom setups, by overriding the base compose files using the `COMPOSE_FILE` env variable.

To activate a mode, your `COMPOSE_FILE` has to reference the following files, **in this order**:
1. `docker-compose.yml`, mandatory for all setups
2. `docker-compose.[mode].yml`, can't be used alone, they only override some part of the `docker-compose.yml`

The available modes are the following:
* [`Run, Test, Demo`](#run-test-demo-mode): use the released version of products
* [`Preview`](#preview-mode): use the unreleased version of products, currently in development, instead of the latest stable released version
* [`Development mode`](#development-mode): unplug one product of the platform from docker, to use your locally running development environment outside of docker

Your ESN instance is accessible at the URL http://backend.ticketing.local
Your ticketing08000linux instance is accessible at the URL http://frontend.ticketing.local

### Run Test Demo mode

This mode allows you to use the recent released version of ticketing08000linux products.

You need to export in your `COMPOSE_FILE` env the `docker-compose.yml`.
Example of `.env` content with ESN:
```
COMPOSE_FILE=docker-compose.yml
```

That way, you get the recent released version of ticketing08000linux frontend and backend.

### Preview mode
This mode allows you to use the most recent images of ticketing08000linux products, meaning the unreleased version currently under development.

You need to export in your `COMPOSE_FILE` env the `docker-compose.preview.yml` **in addition to** the basic `docker-compose.yml`.
Example of `.env` content with ESN:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.preview.yml
```

That way, you get the most recent version of ticketing frontend and backend.


### Development mode

To use dev mode, you need to export dev docker-compose, to add `backend` and `frontend` module, to create & start all containers, to configure ESN and ticketing08000linux to be able to run it  **in this order**:

You need to export in your `COMPOSE_FILE` env the `dev docker-compose`  for `backend` and `frontend`  **in addition to** the basic `docker-compose.esn.yml`
Example of `.env` content with ESN:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.dev-backend.yml:docker-compose.dev-frontend.yml
```

That way, you get LDAP running in docker and a lightweight reverse-proxy instead of ESN, that forwards all trafic to your ESN nodejs server running locally.

2. * You need to do others steps for [`Backend development mode`](#dev-backend-delopment-mode) and for [`Frontend development mode`](#dev-frontend-delopment-mode)

#### Backend development mode

To use dev mode, you need to export dev docker-compose, to add `ticketing08000linux.backend` module, to create & start all containers, to configure ESN and ticketing08000linux to be able to run it  **in this order**:

1. You need to export in your `COMPOSE_FILE` env the `docker-compose.dev-backend.yml` **in addition to** the basic `docker-compose.esn.yml`
Example of `.env` content with ESN:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.dev-backend.yml
```

That way, you get LDAP running in docker and a lightweight reverse-proxy instead of ESN, that forwards all trafic to your ESN nodejs server running locally.

2. You need also to add `ticketing08000linux.backend` module locally.
```bash
$ cd ../
$ git clone ssh://git@ci.linagora.com:7999/linagora/lps/studio/ticketing08000linux.backend.git
$ cd ticketing08000linux.backend
$ npm i
```

3. You need to add `esn` locally and to create `ticketing08000linux.backend` symbolic link.
```bash
$ cd ../
$ git clone ssh://git@ci.linagora.com:7999/linagora/lgs/openpaas/esn.git
$ cd esn
$ npm i
```

```bash
$ cd modules
ln -s ../../ticketing08000linux.backend/ ticketing08000linux.backend
```

4. Declare  `ticketing08000linux.backend` module to esn modules list.

you will need to use a `default.dev.json` file, that specifies your modules list for development environment.To do that easily, you can simply run:
```
cd ../config
cp default.json default.dev.json
```

Add `ticketing08000linux.backend` to the modules list
```bash
  ...
  "modules": [
  ...,
  "ticketing08000linux.backend"
  ],
  ...
```

5. You need to run `docker-compose up -d` to create & start all containers.
```bash
$ docker-compose up -d 
```

6. Go into the `ESN` folder to add some configuration so that OpenPaaS will know how to to connect to its MongoDB database running in docker. This is possible with the OpenPaaS CLI.


Generate the `config/db.json` file first. This will be used by the nodejs application to connect to its MongoDB database running in docker. Add some configuration so that OpenPaaS will know how to access services :
```bash
$ cd ../
$ export ELASTICSEARCH_HOST=localhost
$ export REDIS_HOST=localhost
$ export MONGO_HOST=localhost
$ export AMQP_HOST=localhost
$ export CURRENT_DOMAIN_ADMIN=admin@open-paas.org
$
$ node ./bin/cli.js db --host 172.17.0.1
$ node ./bin/cli configure
$ node ./bin/cli elasticsearch --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT
$ node ./bin/cli domain create --email ${CURRENT_DOMAIN_ADMIN} --password secret --ignore-configuration
$ node ./bin/cli platformadmin init --email "${CURRENT_DOMAIN_ADMIN}"
```
> 172.17.0.1 is for linux. It's the IP where MongoDB launched by docker-compose above can be reached. You will have to set your docker-machine IP on OS X or Windows.

> Only need to be done for the first time or after a `docker-compose down -v`


7. Run ESN & ticketing08000linux.backend locally.

Start the ESN server in development mode:

```bash
$ cd ../
$ grunt dev
```

Your local ESN server needs to:
- Listen on port `8080`
- Connect to MongoDB running in docker, exposed on `localhost:27017`
- Connect to Redis running in docker, exposed on `localhost:6379`
- Connect to Rabbitmq running in docker, exposed on `localhost:5672`
- Connect to ElasticSearch running in docker, exposed on `localhost:9200`
- Have a the `admin@open-paas.org` platform admin account configured (for that, see `node ./bin/cli.js db --host 172.17.0.1` section)


8. Run the `esn-init` job

Once ESN up & running, the `esn-init` job running in docker will call its API and configure other parameters like domain, LDAP connection...
```bash
$ docker-compose up -d esn-init
```

#### Frontend development mode

To use dev mode, you need to export dev docker-compose, to add frontend `ticketing08000linux` module, to create & start all containers, to configure ESN and ticketing08000linux to be able to run it  **in this order**:

1. You need to export in your `COMPOSE_FILE` env the `docker-compose.dev-frontend.yml` **in addition to** the basic `docker-compose.esn.yml`
Example of `.env` content with ESN:
```
COMPOSE_FILE=docker-compose.yml:docker-compose.dev-frontend.yml
```

That way, you get LDAP running in docker and a lightweight reverse-proxy instead of ESN, that forwards all trafic to your ESN nodejs server running locally.

2. You need to add  frontend `ticketing08000linux` module locally.
```bash
$ cd ../
$ git clone ssh://git@ci.linagora.com:7999/linagora/lps/studio/ticketing08000linux.git
$ npm i
```

3. Start the frontend ticketing08000linux server in development mode:

```bash
$ npm run serve
```

###  Quick start

Once everything is running, you can start using ticketing08000linux [home page](http://frontend.ticketing.local).

Your ESN can now be browse to [backend.ticketing.local](http://backend.ticketing.local).

You can connect with the default admin user :
> Username: `admin@open-paas.org`
> Password: `secret`

You can also log in as any other demo user, user accounts are in the file `users.created.txt`.

#### Types and Roles

there is two type of user :

- **Beneficiary** is a customer linked to a client and can create, see tickets
- **Expert** is part of the team handling the ticket

User roles are explain in the table :

|          TYPE         |                 |             Beneficiary            |               Expert               | Admin OP |         |               |                |
|:---------------------:|:---------------:|:----------------------------------:|:----------------------------------:|:--------:|:-------:|:-------------:|:--------------:|
|          ROLE         |                 |               Viewer               |             Beneficiary            |  Expert  | Manager | Administrator | Platform Admin |
|        TICKETS        |    List / Get   |                                    | Only those linked to its contracts |     ✓    |         |       ✓       |        ✓       |
|                       |      Create     |                                    |                  ✓                 |     ✓    |         |       ✓       |        ✓       |
|                       |      Update     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |     Comment     |                                    |                  ✓                 |     ✓    |         |       ✓       |        ✓       |
|                       | Comment private |                                    |                  X                 |     ✓    |         |       ✓       |        ✓       |
|                       |     Archive     |                                    |                  X                 |     X    |         |       X       |        X       |
|                       |                 |                                    |                                    |          |         |               |                |
| USERS /TEAMS /CLIENTS |    List / Get   | Only those linked to its contracts | Only those linked to its contracts |     ✓    |         |       ✓       |        ✓       |
|                       |      Create     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |      Update     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |      Delete     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |                 |                                    |                                    |          |         |               |                |
|       SOFTWARES       |    List / Get   | Only those linked to its contracts | Only those linked to its contracts |     ✓    |         |       ✓       |        ✓       |
|                       |      Create     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |      Update     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |      Delete     |                                    |                  X                 |     X    |         |       ✓       |        ✓       |
|                       |                 |                                    |                                    |          |         |               |                |
|       CONTRACTS       |    List / Get   |         Only his contracts         |         Only his contracts         |     ✓    |         |       ✓       |        X       |
|                       |      Create     |                                    |                  X                 |     X    |         |       ✓       |        X       |
|                       |      Update     |                                    |                  X                 |     X    |         |       ✓       |        X       |
|                       |      Delete     |                                    |                  X                 |     X    |         |       ✓       |        X       |
|                       |                 |                                    |                                    |          |         |               |                |
|        Profile        | Get own profile |                                    |                  ✓                 |     ✓    |         |       ✓       |        ✓       |

#### Manually setup (Workflow to populate)

You can setup the ticketing08000linux manually with the following guide:
Browse to [administration page](http://frontend.ticketing.local/administration/) and log in using
    - mail : **admin@open-paas.org**
    - password : **secret**

##### Create Software, Client, Contract

1. Select **Software** &rarr; **create new software**
    - Click on the '**+**' icon
    - Fill the fields **Name**
    - Hit **Create**
2. Select **Clients** &rarr; **create new client**
    - Click on the '**+**' icon
    - Fill the fields **Name**
    - Hit **Create**
3. Select **Contracts** &rarr; **create new contracts**
    - Click on the '**+**' icon
    - Fill the field **Name**
    - In **Client** choose the  **client created before**
    - Fill fields **Timezone**, **Business hours**, **Start date** and **End date**
    - Hit **Create**
4. In **Contract detail** page,fill **Supported software**
    - Click on the '**&#x270E;**' icon and on the '**+ ADD**' button
    - Fill fields **Software**, **Start date**, **Critical**, **Version** and **OS**
    - Hit **Create**
5. Go back &#x2190; to the **Contract detail** page, fill each **Contractual commitments**
    - Click on the '**&#x270E;**' icon and on the '**+ ADD**' button
    - Fill fields **Request type**, **Severity**, **Ossa identifier** and **Treatment time range of Business hours**
    - Hit **Create**

##### Create User

Select **Users** &rarr; **create new user**
    - Click on the '**+**' icon
    - Choose the field **Type**
    - In the **Search users** field, found an LDAP user among this file `users.created.txt`.
    - Choose the field **Role**
    - If **Beneficiary** type &rarr; you need also to select **Client** and **Contracts**
    - Hit **Create**


##### Create Issue

1. Browse to [home page](http://frontend.ticketing.local/)
2. Select **New issue** in the menu
    - Fill the field **Title**
    - Select the  **Contract**
    - Fill fields **Type**, **Software**, **Severity** and ***Description**
    - Hit **Submit**
