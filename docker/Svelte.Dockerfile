FROM node:19.7.0-buster-slim AS builder
COPY ./ui /app
WORKDIR /app
RUN npm run build

FROM node:19.7.0-buster-slim
COPY --from=builder /app /app
RUN chown -R 1000 /app
USER 1000
WORKDIR /app
CMD ["bash", "./init.sh"]
