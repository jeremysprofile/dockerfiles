FROM wurstmeister/kafka:2.13-2.7.0
COPY kafka.sh /
ENTRYPOINT ["/bin/bash", "-c", "source /kafka.sh && /bin/bash"]
# Lives in jeremydr2/kafka:latest
