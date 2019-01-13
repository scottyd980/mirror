FROM node:8.9.4

RUN npm install -g ember-cli bower

RUN mkdir /ui  
COPY . /ui
WORKDIR /ui

RUN rm -rf node_modules
RUN rm -rf bower_components

RUN npm install
RUN bower install --allow-root