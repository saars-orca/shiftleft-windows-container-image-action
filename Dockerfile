FROM ghcr.io/orcasecurity/orca-cli:1

WORKDIR C:/Users/ContainerAdministrator
COPY entrypoint.bat .

ENTRYPOINT ["/entrypoint.bat"]

