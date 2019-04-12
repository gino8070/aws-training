# NAME := aws-training
# VERSION := piyo

all: setup build

setup:
	go get -u github.com/golang/dep/cmd/dep
	dep ensure

build:
	go build -o app
