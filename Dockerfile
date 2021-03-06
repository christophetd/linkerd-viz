FROM grafana/grafana:3.1.1
MAINTAINER  Buoyant, Inc. <hello@buoyant.io>

EXPOSE 3000 9191

ARG prometheus_version=1.7.0
ARG prometheus_archive_name=prometheus-$prometheus_version.linux-amd64

RUN apt-get update                                       && \
    apt-get -y --no-install-recommends install curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/grafana/dashboards
RUN mkdir -p /etc/prometheus

# prometheus setup

RUN wget https://github.com/prometheus/prometheus/releases/download/v$prometheus_version/$prometheus_archive_name.tar.gz && \
    tar -xf /$prometheus_archive_name.tar.gz                                                               && \
    cp      /$prometheus_archive_name/prometheus        /bin/                                              && \
    cp      /$prometheus_archive_name/promtool          /bin/                                              && \
    cp -a   /$prometheus_archive_name/console_libraries /etc/prometheus/                                   && \
    cp -a   /$prometheus_archive_name/consoles          /etc/prometheus/                                   && \
    rm -rf  /$prometheus_archive_name*

# linkerd-viz setup

COPY linkerd-viz                   /linkerd-viz
COPY */prometheus-*.yml            /etc/prometheus/
COPY linkerd-health-dashboard.json /etc/grafana/dashboards/linkerd-health-dashboard.json
COPY linkerd-viz-dashboard.json    /etc/grafana/dashboards/linkerd-viz-dashboard.json
COPY linkerd-viz-dashboard.json    /usr/share/grafana/public/dashboards/home.json

ENTRYPOINT [ "/linkerd-viz" ]
