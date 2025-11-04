# Stage 1 – install dependencies
FROM node:20-bullseye-slim AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production && npm cache clean --force

# Stage 2 – run application with distroless
FROM gcr.io/distroless/nodejs20-debian11:nonroot
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
EXPOSE 8080
CMD ["index.js"]