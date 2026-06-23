ARG GO_VERSION=1.22.6

FROM golang:${GO_VERSION}-alpine AS builder

ARG VERSION=dev

RUN apk add --no-cache git upx

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux \
    go build -v -ldflags "-X main.VERSION=${VERSION} -s -w -buildid=" \
    -o /out/v2ray-plugin

RUN upx -9 /out/v2ray-plugin 2>/dev/null || true

FROM ghcr.io/shadowsocks/ssserver-rust:latest

COPY --from=builder /out/v2ray-plugin /usr/local/bin/v2ray-plugin

ENTRYPOINT ["v2ray-plugin"]
