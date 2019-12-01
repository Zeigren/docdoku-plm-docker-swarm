# DocDoku, Professional Open Source
# Copyright 2006 - 2017 DocDoku SARL
#
# This file is part of DocDokuPLM.
#
# DocDokuPLM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DocDokuPLM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with DocDokuPLM.  If not, see <http://www.gnu.org/licenses/>.

FROM nginx:alpine

ENV NGINX_HOST plm.zeigren.com
ARG DOMAIN
ARG EMAIL

RUN apk update && apk add openssl
RUN mkdir /etc/nginx/ssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY v3.ext /etc/nginx/ssl/v3.ext
COPY key.conf /etc/nginx/ssl/key.conf
COPY webapp.properties.json /webapp.properties.json

RUN sed -i -e 's/mydomain/'${DOMAIN}'/g' /webapp.properties.json
RUN sed -i -e 's/mydomain/'${DOMAIN}'/g' /etc/nginx/conf.d/default.conf
RUN sed -i -e 's/mydomain/'${DOMAIN}'/g' /etc/nginx/ssl/v3.ext
RUN sed -i -e 's/mydomain/'${DOMAIN}'/g' /etc/nginx/ssl/key.conf
RUN sed -i -e 's/myemail/'${EMAIL}'/g' /etc/nginx/ssl/key.conf

RUN cat /etc/nginx/ssl/*
RUN openssl genrsa -des3 -passout pass:"changeit" -out /etc/nginx/ssl/rootCA.key 2048
RUN openssl req -x509 -new -nodes -passin pass:"changeit" -key /etc/nginx/ssl/rootCA.key -sha256 -days 1024 -out /etc/nginx/ssl/rootCA.pem -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=${DOMAIN}"
RUN openssl req -new -sha256 -nodes  -passin pass:"changeit" -out /etc/nginx/ssl/cert.crt -newkey rsa:2048 -keyout /etc/nginx/ssl/cert.key -config /etc/nginx/ssl/key.conf
RUN openssl x509 -req -passin pass:"changeit" -in /etc/nginx/ssl/cert.crt -CA /etc/nginx/ssl/rootCA.pem -CAkey /etc/nginx/ssl/rootCA.key -CAcreateserial -out /etc/nginx/ssl/cert.crt -days 500 -sha256 -extfile /etc/nginx/ssl/v3.ext

# Expose volumes
VOLUME ["/usr/share/nginx/html", "/var/log/nginx"]

# Entry point
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
