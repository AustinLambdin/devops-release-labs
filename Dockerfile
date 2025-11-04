# Build stage
FROM gcr.io/distroless/nodejs20-debian11:nonroot AS builder
WORKDIR /app

# Add security headers and restrict permissions
ENV NODE_ENV=production \
    NPM_CONFIG_LOGLEVEL=warn \
    NPM_CONFIG_AUDIT=true

# Copy only package files first to leverage Docker cache
COPY --chown=nonroot:nonroot package*.json ./

# Use a temporary debian image to install dependencies
FROM debian:bullseye-slim AS deps
WORKDIR /app
COPY --from=builder /app/package*.json ./
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    ca-certificates \
    && npm ci --only=production \
    --audit=true \
    --no-optional \
    --no-cache \
    --prefer-offline \
    && npm audit fix --force \
    && npm cache clean --force

# Production stage - Use distroless as runtime image
FROM gcr.io/distroless/nodejs20-debian11:nonroot
WORKDIR /app

# Copy only the necessary files from the deps stage
COPY --from=deps --chown=nonroot:nonroot /app/node_modules ./node_modules
# Copy application code
COPY --chown=nonroot:nonroot . .

# Expose port
EXPOSE 8080

# The nonroot user is already set in the distroless image
# Start the application directly with node instead of npm
CMD ["node", "index.js"]