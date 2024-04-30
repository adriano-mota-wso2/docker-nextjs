# Stage 1: install dependencies
FROM node:latest as deps
RUN addgroup -g 10014 choreo && adduser  --disabled-password  --no-create-home --uid 10014 --ingroup choreo choreouser
USER 10014

RUN apk add --no-cache g++ make py3-pip libc6-compat
RUN mkdir /app
WORKDIR /app
COPY package*.json .

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
RUN npm install

# Stage 2: build
FROM node:latest AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY src ./src
COPY public ./public
COPY package.json next.config.js jsconfig.json ./
RUN npm run build

# Stage 3: run
FROM node:latest
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
CMD ["npm", "run", "start"]
