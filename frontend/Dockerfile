FROM node:20-alpine AS base
WORKDIR /app

FROM base AS dependencies
COPY package.json package-lock.json* ./
RUN npm ci --only=production

FROM base AS builder
COPY package.json package-lock.json* ./
RUN npm ci
COPY next.config.js ./
COPY src/ ./src/
RUN npm run build

FROM base AS production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
RUN chown -R node:node /app
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:3000 || exit 1
CMD ["node", "server.js"]