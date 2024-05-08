## Installation

### Option 1: Building Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/<your-github-username>/docker-office-python-core.git
   ```

2. Navigate into the cloned directory:
   ```bash
   cd docker-office-python-core
   ```

3. Build the Docker image using the following command:
   ```bash
   docker build -t docker-office-python-core:v1 .
   ```

4. Once the image is built, you can run it using:
   ```bash
   docker run -it --entrypoint /bin/bash docker-office-python-core:v1
   ```

### Option 2: Pulling from Docker Hub

You can also directly pull the pre-built image from Docker Hub:

```bash
docker pull xeden3/docker-office-python-core:v1
```

Once pulled, you can run the image using:

```bash
docker run -it --entrypoint /bin/bash xeden3/docker-office-python-core:v1
```

Please note that this image only serves as the core environment. If you need to perform secondary development, you may need to encapsulate this image further. For example, if you want to run a macro command `excel-macro-run`, you can create another Docker image that extends from this core image. Below is an example Dockerfile for extending the functionality:

```Dockerfile
FROM xeden3/docker-office-python-core:v1
MAINTAINER JamesChan "JamesChan<james@sctmes.com> (http://www.sctmes.com)"

RUN xvfb-run wine pip install pywin32

RUN apt-get update && apt-get install -y locales
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# Set the working directory to /opt/wineprefix/drive_c/
WORKDIR /opt/wineprefix/drive_c/

COPY libs/tini /tini
COPY code/demo.py /opt/wineprefix/drive_c/app/
COPY code/excel_xlsm.py /opt/wineprefix/drive_c/app/
# COPY example.xlsm /opt/wineprefix/drive_c/

RUN chmod +x /tini 

# Set ENTRYPOINT
ENTRYPOINT ["/tini", "--", "xvfb-run", "-a", "wine", "python", "/opt/wineprefix/drive_c/app/excel_xlsm.py"]
```

This Dockerfile extends the core image by adding the necessary dependencies and setting the appropriate entry point for running the `excel_xlsm.py` script.
