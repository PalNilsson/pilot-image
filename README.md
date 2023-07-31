# pilot-image

Files for creating a PanDA Pilot image. The Dockerfile, based on the official AlmaLinux base image,
also sets up ROOT and the rucio-client.

### Build instruction

1. Copy the pilot source code into the build area, as the Dockerfile assumes the existance of a pilot3 directory there
2. Build <code>docker build -t image_name . --build-arg RUCIO_VERSION=1.31.5 --build-arg DASK_VERSION=2023.4.1</code> (or other rucio/dask versions)

### Test instruction

Test image with <code>docker run image_name:latest</code>
