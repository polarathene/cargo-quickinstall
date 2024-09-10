FROM rust:1-bookworm as builder

WORKDIR /usr/src/app
COPY . .
# Will build and cache the binary and dependent crates in release mode
RUN --mount=type=cache,target=/usr/local/cargo,from=rust:latest,source=/usr/local/cargo \
    --mount=type=cache,target=target \
    cargo build --release && mv ./target/release/cargo-quickinstall-stats-server /tmp/app

# Runtime image
# Implicit defaults: USER 65532 + WORKDIR /home/nonroot
FROM gcr.io/distroless/static-debian12:nonroot

# Get compiled binaries from builder
COPY --from=builder /tmp/app /app

# Run the app
ENTRYPOINT ["/app"]
