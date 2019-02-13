FROM node:8.15.0-alpine as build

# install build dependencies
RUN apk add --update git \
    make \
    g++ \
    python

RUN npm install -g ember-cli bower

RUN mkdir /ui  
WORKDIR /ui

COPY package.json .
COPY package-lock.json .
COPY bower.json .
COPY .npmrc .

RUN rm -rf node_modules
RUN rm -rf bower_components

RUN npm install
RUN bower install --allow-root

COPY . .

RUN npm install
RUN bower install --allow-root

RUN ember build --environment=production

FROM nginx:alpine

EXPOSE 80

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /ui/dist /usr/share/nginx/html