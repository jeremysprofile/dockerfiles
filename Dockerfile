FROM bitnamilegacy/kafka:3.9.0-debian-12-r9
COPY kafka.sh /
USER root
RUN apt-get update && apt-get install -y dnsutils netcat
ENTRYPOINT ["/bin/bash", "-c", "source /kafka.sh && /bin/bash"]
# Lives in jeremydr2/kafka:latest
