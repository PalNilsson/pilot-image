# pilot-image

Files for creating a PanDA Pilot image. The Dockerfile, based on the official AlmaLinux base image,
also sets up ROOT and the rucio-client. The PanDA Pilot source is git installed.

### Build instruction

<code>docker build -t image_name . --build-arg RUCIO_VERSION=1.31.5 --build-arg DASK_VERSION=2023.4.1</code> (or other rucio/dask versions)

### Test instruction

Test image with <code>docker run -it image_name:latest</code>
