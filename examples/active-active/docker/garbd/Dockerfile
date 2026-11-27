FROM percona/percona-xtradb-cluster:8.4

# L'arbitre Galera est livré dans un paquet séparé.
USER root
RUN microdnf install -y percona-xtradb-cluster-garbd && microdnf clean all
USER mysql

ENTRYPOINT ["garbd"]
