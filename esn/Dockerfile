FROM docker-registry.linagora.com:5000/openpaas-releases/openpaas-esn:1.6.2
COPY ticketing08000linux.backend/ /var/www/node_modules/linagora.esn.ticketing
RUN cd /var/www/node_modules/linagora.esn.ticketing && npm install --production
