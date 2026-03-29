# signoz-mcp-docker

Docker images for [SigNoz/signoz-mcp-server](https://github.com/SigNoz/signoz-mcp-server), built from upstream **release tags** so you get reproducible binaries on **linux/amd64** and **linux/arm64** without installing Go locally. The upstream server already supports **streamable HTTP** MCP; this repo only packages it with HTTP as the default transport.

## Quickstart (GHCR)

Set `SIGNOZ_URL` and `SIGNOZ_API_KEY` from your SigNoz workspace ([API key](https://signoz.io/docs/ai/signoz-mcp-server/) in the SigNoz UI).

```bash
docker run --rm -it \
  -e SIGNOZ_URL=https://your-signoz-instance.com \
  -e SIGNOZ_API_KEY=your-api-key \
  -e TRANSPORT_MODE=http \
  -e MCP_SERVER_PORT=8000 \
  -p 8000:8000 \
  ghcr.io/<your-github-username>/signoz-mcp-docker:latest
```

MCP endpoint: `http://localhost:8000/mcp`  
Unauthenticated health check: `http://localhost:8000/healthz`

### Client config (URL only, credentials on the server)

```json
{
  "mcpServers": {
    "signoz": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

If you prefer passing the API key from the client, omit `SIGNOZ_API_KEY` on the server and use client `headers` as described in the [upstream README](https://github.com/SigNoz/signoz-mcp-server).

## Local development

1. Copy `.env.example` to `.env` and set `SIGNOZ_URL` / `SIGNOZ_API_KEY` when you want live tool calls.
2. Build and run:

```bash
docker compose up --build
```

3. Check health: `curl -fsS http://127.0.0.1:8000/healthz`

Optional: override the upstream tag used at build time (must match a [release tag](https://github.com/SigNoz/signoz-mcp-server/releases)):

```bash
SIGNOZ_MCP_REF=v0.1.0 docker compose build
```

The pinned tag in this repo is stored in `.upstream-version` and updated by the publish workflow when a new upstream release appears.

## CI/CD

- **CI** — builds the image and checks `GET /healthz`.
- **Docker Publish** — on pushes to `main`, on a weekly schedule, or via `workflow_dispatch`, builds multi-arch images and pushes to GHCR. The workflow also bumps `.upstream-version` when the latest GitHub release tag changes.

New repositories may need the GHCR package visibility set to **public** if you want anonymous `docker pull`.

## License

Packaging metadata and workflows in this repository are MIT unless noted otherwise. SigNoz MCP Server is licensed by its authors (see `THIRD_PARTY_NOTICES.md`).
