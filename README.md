# OpenPaaS ticketing 08000linux 

> Docker is available [here](https://www.docker.com/products/docker) and docker-compose [here](https://docs.docker.com/compose).
> Make sure that these are installed on your system before starting. NB: you can
> also install docker-compose using Python pip tool, see above :

```bash
# Using python package (you shoud use python virtualenv, cf virtualenvwrapper)
$ pip install docker-compose
```
## Presentation

Deploy an ticketing 08000linux base on OpenPaaS with ease using Docker and docker-compose.

By default, the version used is the latest stable release of the OpenPaaS products, but you can also try the currently under-development version of components (activating the `preview` mode)

    Disclaimer: this repository is intended for 2 use cases only: **running a demo** and **developping / debugging**.
    You should never use it to run a production instance as it misses significant configurations to have your data secured and the produict sustainable.