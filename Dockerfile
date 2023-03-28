# Build the Go Binary.
FROM golang:1.20 as build_auth_service
ENV CGO_ENABLED 0
ARG BUILD_REF
# Copy the source code into the container.
COPY . /service

# Build the app binary.
WORKDIR /service/cmd/app
RUN go build -ldflags "-X main.build=${BUILD_REF}"


# Run the Go Binary in Alpine.
FROM alpine:3.16
ARG BUILD_DATE
ARG BUILD_REF

RUN addgroup -g 1000 -S auth_service && \
    adduser -u 1000 -h /service -G auth_service -S auth_service
COPY --from=build_auth_service --chown=auth_service:auth_service /service/cmd/app /service
WORKDIR /service
USER auth_service
CMD ["./app"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="auth_service" \
      org.opencontainers.image.authors="Saeed Jalali, Mojtaba Norouzi" \
      org.opencontainers.image.source="" \
      org.opencontainers.image.revision="${BUILD_REF}" \
      org.opencontainers.image.vendor="Saeed Jalali, Mojtaba Norouzi"