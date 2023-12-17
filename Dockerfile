# Build stage
FROM golang:1.21.5-bullseye AS builder
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y ca-certificates openssl

ARG cert_location=/usr/local/share/ca-certificates

## Get certificate from "github.com"
RUN openssl s_client -showcerts -connect github.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > ${cert_location}/github.crt
# Get certificate from "proxy.golang.org"
RUN openssl s_client -showcerts -connect proxy.golang.org:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/proxy.golang.crt
# Update certificates
RUN update-ca-certificates

# cross platform compilation building a GO executable
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on GOOS=linux go build main.go

RUN apt-get install curl
RUN curl --insecure \
    -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM golang:1.21.5-bullseye
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
RUN apt-get update && apt-get install -y netcat
RUN find / -name "start.sh"
RUN cat start.sh
COPY db/migration ./migration

EXPOSE 8080
CMD ["/app/main"]
ENTRYPOINT ["/app/start.sh"]