FROM alpine:latest

MAINTAINER Yellow <yellow.cybertan@gmail.com>

# User config
ENV UID="1000" \
	 UNAME="developer" \
	 GID="1000" \
	 GNAME="developer" \
	 SHELL="/bin/bash" \
	 UHOME=/home/developer

# User
 RUN apk --no-cache add sudo \
# Create HOME dir
	&& mkdir -p "${UHOME}" \
	&& chown "${UID}":"${GID}" "${UHOME}" \
# Create user
	&& echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
	>> /etc/passwd \
	&& echo "${UNAME}::17032:0:99999:7:::" \
	>> /etc/shadow \
# No password sudo
	&& echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
	> "/etc/sudoers.d/${UNAME}" \
	&& chmod 0440 "/etc/sudoers.d/${UNAME}" \
# Create group
	&& echo "${GNAME}:x:${GID}:${UNAME}" \
	>> /etc/group

RUN apk add --update --virtual build-deps \
    build-base \
    ctags \
    git \
    make \
    ncurses-dev \
    flex byacc \
# Build Vim
    && cd /tmp \
    && git clone https://github.com/portante/cscope.git \
    && cd /tmp/cscope \
    && ./configure \
    && make \
    && make install \
    && apk del build-deps \
    && apk add \
    ctags ncurses-libs \
# Cleanup
    && rm -rf \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && mkdir /var/cache/apk

COPY run /usr/local/bin/

ENTRYPOINT ["sh", "/usr/local/bin/run"]
