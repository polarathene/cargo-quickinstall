FROM rust:slim AS base

ARG ZIG_VERSION=0.13.0

RUN apt-get update && \
    apt-get install -y curl wget libssl-dev jq tar gzip build-essential lsb-release wget software-properties-common gnupg && \
    wget -O - https://apt.llvm.org/llvm.sh | bash && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/* && \
    curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-$ZIG_VERSION.tar.xz | tar -xJf - && \
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash && \
    cargo binstall -y cargo-auditable cargo-zigbuild

ENV PATH="${PATH}:/zig-linux-x86_64-$ZIG_VERSION" CARGO=cargo-zigbuild PKG_CONFIG="/root/pkg-config-cross.sh"

ADD pkg-config-cross.sh build-version.sh /root/

CMD /root/build-version.sh

FROM base AS fetching

ARG crate
ARG version
ARG target_arch

RUN rustup target add "$target_arch" && \
    cd /tmp/ && \
    curl -L https://crates.io/api/v1/crates/$crate/$version/download | tar -xzf - && \
    cd $crate-$version && \
    ( \
    cargo fetch --target $target_arch --locked || \
    cargo fetch --target $target_arch \
    ) && \
    cargo new --lib dummy && \
    cd dummy && \
    echo "$crate = \"=$version\"" >> Cargo.toml && \
    cargo fetch --target $target_arch
