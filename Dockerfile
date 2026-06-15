# build stage
FROM alpine:3.21 AS builder
RUN echo "Compiling software..." && touch /mybinary

# final stage
FROM alpine:3.21
COPY --from=builder /mybinary /usr/local/bin/mybinary

ENV APP_ARGS="--host=0.0.0.0 --port=8080 --verbose"

ENTRYPOINT ["sh", "-c", "/usr/local/bin/mybinary $APP_ARGS"]
