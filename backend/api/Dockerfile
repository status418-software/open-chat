FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download -x

COPY . .

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -o go-api-server main.go

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/go-api-server .

EXPOSE 8080

CMD ["./go-api-server"]
