FROM ubuntu
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libguestfs-tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-4.4.0-45-generic
WORKDIR /data
