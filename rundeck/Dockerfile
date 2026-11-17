FROM docker:29-cli AS docker
FROM hashicorp/terraform:1.17 AS terraform

FROM rundeck/rundeck:6.3.0

USER root

COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose
COPY --from=terraform /bin/terraform /usr/local/bin/terraform

USER rundeck
