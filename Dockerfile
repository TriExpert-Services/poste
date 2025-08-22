ARG UPSTREAM=2.3.10
FROM analogic/poste.io:$UPSTREAM
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y less && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Default to listening only on IPs bound to the container hostname
ENV LISTEN_ON=host
ENV SEND_ON=

COPY files /
RUN /patches && rm /patches
