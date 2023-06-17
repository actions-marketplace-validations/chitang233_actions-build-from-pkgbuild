FROM archlinux AS builder
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]