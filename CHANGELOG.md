# Changelog

All notable user-visible changes to the Smokeping TOS application package.

## 2.9.0-1 — 2026-11-11

### Added
- First release. Smokeping (`linuxserver/smokeping:2.9.0`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8084 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/smokepingdocker/`.
