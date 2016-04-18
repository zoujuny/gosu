FROM golang:1.6-alpine

RUN apk add --no-cache ca-certificates openssl

ENV RUNC_VERSION v0.0.5

RUN mkdir -p /go/src/github.com/opencontainers \
	&& wget -O- "https://github.com/opencontainers/runc/archive/${RUNC_VERSION}.tar.gz" \
		| tar -xzC /go/src/github.com/opencontainers \
	&& mv "/go/src/github.com/opencontainers/runc-${RUNC_VERSION#v}" /go/src/github.com/opencontainers/runc

ENV GOPATH $GOPATH:/go/src/github.com/opencontainers/runc/Godeps/_workspace

# disable CGO for ALL THE THINGS (to help ensure no libc)
ENV CGO_ENABLED 0

ENV BUILD_FLAGS="-v -ldflags '-d -s -w'"

COPY *.go /go/src/github.com/tianon/gosu/
WORKDIR /go/src/github.com/tianon/gosu

# gosu-$(dpkg --print-architecture)
RUN set -x && GOARCH=amd64 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-amd64" \
	&& /go/bin/gosu-amd64 nobody id \
	&& /go/bin/gosu-amd64 nobody ls -l /proc/self/fd
RUN set -x && GOARCH=386 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-i386" \
	&& /go/bin/gosu-i386 nobody id \
	&& /go/bin/gosu-i386 nobody ls -l /proc/self/fd
RUN set -x && GOARCH=arm GOARM=5 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-armel"
RUN set -x && GOARCH=arm GOARM=6 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-armhf"
#RUN set -x && GOARCH=arm GOARM=7 \
#		eval "go build $BUILD_FLAGS -o /go/bin/gosu-armhf" # boo Raspberry Pi, making life hard
RUN set -x && GOARCH=arm64 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-arm64"
RUN set -x && GOARCH=ppc64 \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-ppc64"
RUN set -x && GOARCH=ppc64le \
		eval "go build $BUILD_FLAGS -o /go/bin/gosu-ppc64el"
