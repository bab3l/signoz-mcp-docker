# syntax=docker/dockerfile:1

# Pin upstream release: https://github.com/SigNoz/signoz-mcp-server/releases
ARG SIGNOZ_MCP_REF=v0.1.0

FROM golang:1.26-alpine AS builder
ARG SIGNOZ_MCP_REF
ARG TARGETARCH

RUN apk add --no-cache git ca-certificates tzdata wget

WORKDIR /tmp
RUN wget -qO /tmp/upstream.tgz "https://github.com/SigNoz/signoz-mcp-server/archive/refs/tags/${SIGNOZ_MCP_REF}.tar.gz" \
    && tar -xzf /tmp/upstream.tgz \
    && mv signoz-mcp-server-* /src

WORKDIR /src
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o /out/signoz-mcp-server \
    ./cmd/server/

FROM alpine:3.23

RUN apk add --no-cache ca-certificates \
    && addgroup -g 1001 -S appgroup \
    && adduser -u 1001 -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /out/signoz-mcp-server .

RUN chown appuser:appgroup /app/signoz-mcp-server
USER appuser

ENV TRANSPORT_MODE=http \
    MCP_SERVER_PORT=8000 \
    LOG_LEVEL=info

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8000/healthz > /dev/null || exit 1

CMD ["./signoz-mcp-server"]
