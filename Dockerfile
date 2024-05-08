FROM scottyhardy/docker-wine:stable-8.0.2
MAINTAINER JamesChan "<james@sctmes.com> (http://www.sctmes.com)"

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG='C.UTF-8' \
    LC_ALL='C.UTF-8' \
    WINEDEBUG=-all \
    WINEPREFIX=/opt/wineprefix \
    WINEARCH=win32

WORKDIR /root

RUN apt-get update && \
    apt-get install -y cabextract nano curl && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/*

# umask 0 for permissions
RUN umask 0 && \
    # download winetricks
    # base url -- https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    curl -o /root/winetricks -L https://github.com/xeden3/docker-office-python-core/releases/download/v0.0/winetricks && \
    chmod +x /root/winetricks && \
    # install deps, ref: https://github.com/Winetricks/winetricks/issues/1236
    mkdir -p ~/.cache/wine && \
    curl -o ~/.cache/wine/wine-mono-9.0.0-x86.msi -L https://dl.winehq.org/wine/wine-mono/9.0.0/wine-mono-9.0.0-x86.msi && \
    curl -o ~/.cache/wine/wine-gecko-2.47.4-x86.msi -L https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi && \
    xvfb-run /root/winetricks riched20 gdiplus msxml6 mspatcha mfc100 -q 

# umask 0 for permissions
RUN umask 0 && \
    # download python
    curl -o /root/python-3.8.2.exe -L https://www.python.org/ftp/python/3.8.2/python-3.8.2.exe && \
    # download office2010 4in1
    curl -o /root/Office2010_4in1_20210124.exe -L https://github.com/xeden3/docker-office-python-core/releases/download/v0.0/Office2010_4in1_20210124.exe && \
    # install office2010, https://www.xb21cn.com/267.html
    xvfb-run winecfg -v win8 && \
    curl -o /opt/wineprefix/drive_c/windows/Fonts/simsun.ttc -L https://github.com/xeden3/docker-office-python-core/releases/download/v0.0/simsun.ttc && \
    xvfb-run wine /root/Office2010_4in1_20210124.exe /S && \
    wineserver -w && \
    # install python
    xvfb-run winecfg -v win8 && \
    xvfb-run wine /root/python-3.8.2.exe /quiet InstallAllUsers=1 PrependPath=1 Include_doc=0 && \
    wineserver -w && \
    # ensure the normal running of office2010
    xvfb-run winecfg -v win8 && \
    # clean
    rm -rf /root/python-3.8.2.exe /root/Office2010_4in1_20210124.exe
