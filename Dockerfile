FROM node:10
RUN mkdir -p /docker/quest/node_modules && chown -R node:node /docker/quest
WORKDIR /docker/quest
COPY package*.json ./
USER node
RUN npm install
COPY --chown=node:node . .
ENV SECRET_WORD="TwelveFactor"
EXPOSE 3000
CMD [ "node", "src/000.js" ]
