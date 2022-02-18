FROM alpine:latest

#RUN apt-get update \

# Copy our static content in place
COPY apprise_api/static /usr/share/nginx/html/s/
COPY ./requirements.txt /etc/requirements.txt

RUN apk add --no-cache python3 py3-pip nginx supervisor openssl-dev python3-dev libffi-dev g++  \
&& pip install -U --no-cache-dir -q -r /etc/requirements.txt gunicorn apprise \
&& apk del --purge openssl-dev python3-dev libffi-dev g++ 

# set work directory
 WORKDIR /opt/apprise

# Copy over Apprise API
 COPY apprise_api/ webapp

# Configuration Permissions (to run nginx as a non-root user)
 RUN umask 0002 && \
    mkdir -p /config /run/apprise && \
    chown nginx:nginx -R /run/apprise /var/lib/nginx /config

# Handle running as a non-root user (www-data is id/gid 33)
USER nginx
VOLUME /config
EXPOSE 8000
CMD ["/usr/bin/supervisord", "-c", "/opt/apprise/webapp/etc/supervisord.conf"]