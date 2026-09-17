FROM ghcr.io/prefix-dev/pixi:0.81.0 AS pixi-bin

FROM nvidia/cuda:13.2.0-devel-ubuntu24.04 AS builder
COPY --from=pixi-bin /usr/local/bin/pixi /usr/local/bin/pixi
WORKDIR /app
COPY pixi.toml pixi.lock ./
RUN pixi install --locked


FROM nvidia/cuda:13.2.0-runtime-ubuntu24.04 AS runtime
COPY --from=pixi-bin /usr/local/bin/pixi /usr/local/bin/pixi
COPY --from=builder /app/.pixi /app/.pixi
WORKDIR /app

RUN useradd -m appuser
COPY --chown=appuser:appuser . .
USER appuser
ENTRYPOINT ["pixi", "run"]
CMD ["start"]