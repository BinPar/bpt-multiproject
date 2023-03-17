# -- Base Node ---
FROM registry.access.redhat.com/ubi8/nodejs-16:latest AS base
COPY --chown=1001:root package*.json ./

# -- Build Base ---
FROM base AS build-base
COPY --chown=1001:root ["./jest.config.js","./tsconfig.json", "./.eslintrc", "./.eslintignore", "./"]

# -- Dependencies Node ---
FROM build-base AS dependencies
RUN npm set progress=false && npm config set depth 0 && \
  npm ci --production && \
  cp -R node_modules prod_node_modules && \
  npm ci --production=false

# ---- Compile  ----
FROM build-base AS compile
COPY --chown=1001:root ./src ./src
COPY --from=dependencies --chown=1001:root /opt/app-root/src/node_modules ./node_modules
RUN npm run build

# ---- Release  ----
FROM registry.access.redhat.com/ubi8/nodejs-16-minimal:latest AS release
COPY --chown=1001:root package*.json ./
COPY --from=dependencies --chown=1001:root /opt/app-root/src/prod_node_modules ./node_modules
COPY --from=compile --chown=1001:root /opt/app-root/src/dist ./dist

# Expose port and define CMD
ENV NODE_ENV production
ENV PORT 8080
CMD npm run start
