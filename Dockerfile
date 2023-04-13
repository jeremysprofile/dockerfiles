FROM bitnami/kafka:3.4.0
COPY kafka.sh /
ENTRYPOINT ["/bin/bash", "-c", "source /kafka.sh && /bin/bash"]
# Lives in jeremydr2/kafka:latest
