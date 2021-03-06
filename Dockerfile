# Build Stage
FROM rust:1.43.1-slim AS builder
WORKDIR /usr/src/
RUN apt-get update && apt-get install -y libnice-dev clang libssl-dev

WORKDIR /usr/src/mumble-web-proxy
RUN USER=root cargo new mumble-web-proxy
COPY Cargo.toml Cargo.toml ./
COPY Cargo.lock Cargo.lock ./
COPY src ./src
RUN rustup update nightly
RUN rustup update stable
RUN cargo build --release

# Bundle Stage
FROM rust:1.43.1-slim AS bundle
WORKDIR /app
RUN apt-get update && apt-get install -y libnice10 libglib2.0 && apt-get -qq clean

COPY --from=builder /usr/src/mumble-web-proxy/target/release/mumble-web-proxy .
COPY docker/start.sh .

USER 1000
EXPOSE 64737

ENV LISTEN_WS=64737
ENV MUMBLE_SERVER=mumbleserver:64738
ENV ICE_PORT_MIN=
ENV ICE_PORT_MAX=
ENV ICE_IPV4=
ENV ICE_IPV6=
ENV ACCEPT_INVALID_CERTIFICATE=

CMD ./start.sh
