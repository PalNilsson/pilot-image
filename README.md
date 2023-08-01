# pilot-image

Files for creating a pilot image, using the AlmaLinux9 base image. The Dockerfile also sets up ROOT, dask and the rucio-client.

### Build instruction

1. Copy the pilot source code into the build area, as the Dockerfile assumes the existance of a pilot3 directory there
2. Build <code>docker build --no-cachedir -t image_name . --build-arg RUCIO_VERSION=1.31.5 --build-arg DASK_VERSION=2023.4.1</code> (or other rucio/dask versions)

### Test instruction

Test image with <code>docker run image_name:latest</code>