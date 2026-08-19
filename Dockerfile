# ============================
# Stage 1: Build frontend
# ============================
FROM oven/bun:1 AS frontend-builder

WORKDIR /src

COPY frontend/package.json frontend/bun.lock* ./frontend/

WORKDIR /src/frontend

RUN bun install

COPY frontend/ ./

RUN bun run build


# ============================
# Stage 2: Build Go
# ============================
FROM golang:1.26-bookworm AS go-builder

WORKDIR /src

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 \
    go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /free-proxy \
    ./cmd/free-proxy


# ============================
# Stage 3: Runtime
# ============================
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openvpn \
        iproute2 \
        iptables \
        ca-certificates \
        curl \
        bash \
        procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=go-builder /free-proxy /usr/local/bin/free-proxy

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/free-proxy /entrypoint.sh && \
    mkdir -p /var/lib/free-proxy

VOLUME ["/var/lib/free-proxy"]

EXPOSE 9527
EXPOSE 39527

ENTRYPOINT ["/entrypoint.sh"]
