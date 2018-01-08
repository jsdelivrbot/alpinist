FROM golang:alpine as golang

RUN apk add --update --no-cache ca-certificates \
  git

RUN go get github.com/jessfraz/apk-file
RUN go get github.com/motemen/ghq
RUN go get github.com/direnv/direnv

FROM alpine:edge as git

RUN apk add --update --no-cache ca-certificates \
  perl \
  make \
  git

RUN git clone --depth=1 https://github.com/git/git /usr/src/git

WORKDIR /usr/src/git/contrib/diff-highlight

RUN make

FROM alpine:edge

ENV EDITOR /usr/bin/nvim
WORKDIR /root

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories

RUN apk update
RUN apk upgrade

RUN apk add --no-cache ca-certificates \
  alpine-sdk

RUN apk add --no-cache tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apk add --no-cache \
  coreutils \
  findutils \
  file \
  git \
  docker \
  bash

# add user app
RUN adduser -D -s /bin/bash app
RUN addgroup app abuild
RUN addgroup app wheel
RUN addgroup app docker

RUN apk add --no-cache sudo
RUN sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# golang
COPY --from=golang /go/bin/apk-file /usr/bin/
COPY --from=golang /go/bin/ghq /usr/bin/
COPY --from=golang /go/bin/direnv /usr/bin/
# copy diff-highlight
COPY --from=git /usr/src/git/contrib/diff-highlight/diff-highlight /usr/bin/

RUN apk add --no-cache \
  neovim \
  vimdiff

RUN apk add --no-cache \
  openssh \
  libressl-dev \
  ncurses-dev

RUN apk add --no-cache \
  the_silver_searcher \
  tmux \
  rcm

# require to build ruby, python, nodejs
RUN apk add --no-cache \
  linux-headers \
  jpeg-dev \
  zlib-dev \
  readline-dev \
  bzip2-dev \
  sqlite-dev \
  gnupg \
  perl-utils

RUN apk add --no-cache \
  ctags \
  less \
  jq

# ocaml
RUN apk add --no-cache \
  m4 \
  opam

WORKDIR /home/app
