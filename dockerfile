FROM node:16.16.0-slim as node_env
WORKDIR /client
COPY client/ /client/
RUN rm -rf /dist/
RUN npm install & npm run build:prod
COPY /client/dist/ /dist/

FROM nginx as nginx_env

RUN rm -rf /etc/nginx/conf.d/default.conf
RUN rm -rf /etc/nginx/nginx.conf
COPY /docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY /docker/nginx/nginx.conf /etc/nginx/nginx.conf

# COPY --from=python_env /scanner/ /scanner/ 
# COPY --from=python_env /usr/local /usr/local
COPY --from=node_env /dist/ /usr/share/nginx/html/

FROM python:3.9.16-slim as python_env

COPY backend/ /scanner/
WORKDIR /scanner/

RUN pip install -r /scanner/requirements.txt

RUN mkdir /var/cache/nginx

COPY --from=nginx_env /etc/nginx/ /etc/nginx/
COPY --from=nginx_env /usr/share/nginx/ /usr/share/nginx/
COPY --from=nginx_env /usr/lib/nginx/ /usr/lib/nginx/
COPY --from=nginx_env /usr/sbin/nginx /usr/sbin/nginx
COPY --from=nginx_env /var/log/nginx/ /var/log/nginx/

# nginx 端口
EXPOSE 80

# ENTRYPOINT ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD /bin/sh -c "useradd nginx; nginx; python manage.py runserver 0.0.0.0:8000"