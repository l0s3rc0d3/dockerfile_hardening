# dockerfile_hardening
 
A demo showing how to enforce Dockerfile best practices using **Hadolint** (linting) and **Conftest + OPA** (policy-as-code).
 
## What it does
 
- **Hadolint** — static analysis on the Dockerfile
- **Conftest** — validates the Dockerfile against custom OPA/Rego policies in `policy/`
- 
## Policies enforced
 
| # | Check | Description |
|---|-------|-------------|
| 1a | Presence | `APP_ARGS` env var must exist |
| 1b | Content | `APP_ARGS` must contain `--` parameters |
| 2 | Format | `ENTRYPOINT` must use JSON array (exec form) |
| 3 | Shell | `ENTRYPOINT` must invoke `sh -c` |
| 4a | Binary | `ENTRYPOINT` must execute `/usr/local/bin/mybinary` |
| 4b | Args | `ENTRYPOINT` must pass `$APP_ARGS` |
| 4c | Sequence | `$APP_ARGS` must come after the binary path |
 
## Requirements
 
- `podman`

## Usage
 
```bash
make all    # run lint + test
make lint   # Hadolint only
make test   # Conftest only
```
