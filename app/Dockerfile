FROM golang:latest as builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
WORKDIR /go/src/aws-training/
COPY . .
RUN make

FROM alpine
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/aws-training/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
