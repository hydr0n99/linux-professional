FROM alpine:3.23.4

RUN apk update && apk add nginx

COPY ./index.html /var/lib/nginx/html/
COPY ./default.conf /etc/nginx/http.d/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
