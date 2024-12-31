# Docker-Office-Python-Core

This project combines a Docker image containing Wine 8, Microsoft Office 2010, and Python 3.8. It provides a convenient environment for secondary development based on this setup.

## Installation

### Option 1: Building Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/xeden3/docker-office-python-core.git
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

# Extending Functionality

If you require additional functionality beyond the core environment provided by this image, you can create another Docker image that extends from it. This allows you to encapsulate specific development requirements while maintaining the core setup intact. 

For instance, if you need to run a macro command like `excel-macro-run`, you can create a Docker image that builds upon the core image. Below is an example Dockerfile demonstrating how to extend the functionality:

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

Feel free to modify and customize this Dockerfile according to your specific development needs.

# Acknowledgements

Special thanks to the following contributors and projects:

- [Akkuman](https://github.com/akkuman/docker-msoffice2010-python) for the initial inspiration and the `docker-msoffice2010-python` project.
- Akkuman for providing technical support.

# Additional notes:

### 1. Wine Environment Pull Issue
The first issue is that the Wine environment might not be pulled correctly when you build the iamge. This can be fixed by running:

```bash
docker pull scottyhardy/docker-wine:stable-8.0.2
```

to pull the image locally.

![pull wine manual](https://github.com/user-attachments/assets/2f0fa96b-f750-46f8-b5e2-a7d08f9a1825)

### 2. Wine Environment Setup for Python 3.9 Installation

When you want to update python verion and rebuild the image, you may get error on running following command:
```bash
xvfb-run wine /root/python-3.9.9.exe /quiet InstallAllUsers=1 PrependPath=1 Include_doc=0
```

You need to set the Wine environment to **Windows 10** instead of **Windows 8**, as mentioned in the [Python documentation](https://docs.python.org/3.9/using/windows.html).

> **Note**: Python release only supports a Windows platform while Microsoft considers the platform under extended support. This means that Python 3.9 supports Windows 8.1 and newer. If you require Windows 7 support, please install Python 3.8.

Since Python 3.9 only supports Windows 8.1 and newer, Wine’s **Windows 8** environment might not be fully compatible with Windows 8.1. To fix this, you need to switch the Wine environment to **Windows 10** using the following command:

```bash
xvfb-run winecfg -v win10
```

This will allow the installation to work correctly.

![python 3.9 install](https://github.com/user-attachments/assets/e8a76fb4-e5f8-4a12-8c89-fc6735da950d)

### 3. Performance Considerations with Wine
I should mention that running Python and Office macros in Wine has very poor performance. While it may be fine for smaller macros, it becomes unbearable when dealing with larger computations. Therefore, using Wine should be considered carefully for such use cases.



