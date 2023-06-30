# pilot-image

Files for creating a pilot image. The Dockerfile also sets up the rucio-client (pip installed).

### Build instruction

1. Copy the pilot source code into the build area, as the Dockerfile assumes the existance of a pilot3 directory there
2. Build <code>docker build -t image_name . --build-arg RUCIO_VERSION=1.30.5 --build-arg DASK_VERSION=2023.6.1</code> (or other rucio/dask versions)

### Test instruction

Test image with <code>docker run image_name:latest</code>