
FROM node:22-alpine

WORKDIR /app

COPY --chown=node:node server.js ./

ARG GIT_SHA=local

ENV NODE_ENV=production \
    PORT=8080 \
    APP_VERSION=$GIT_SHA

# Remove npm and npx from the runtime image
RUN rm -rf /usr/local/lib/node_modules/npm \
    /usr/local/bin/npm \
    /usr/local/bin/npx

USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["node", "server.js"]
