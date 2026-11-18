FROM node:22-alpine

WORKDIR /app

COPY package.json server.js ./

# The git commit is passed in at build time so the running version is visible
ARG GIT_SHA=local
ENV NODE_ENV=production \
    PORT=8080 \
    APP_VERSION=$GIT_SHA

# Run as the unprivileged user that ships with the Node image
USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["node", "server.js"]
