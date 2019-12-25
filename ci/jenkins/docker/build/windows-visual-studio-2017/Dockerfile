# escape=`
ARG FROM_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.7.2-windowsservercore-ltsc2019
FROM ${FROM_IMAGE}

# Reset the shell.
SHELL ["cmd", "/S", "/C"]
RUN mkdir c:\\TEMP
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe

# Download channel for fixed install.
ARG CHANNEL_URL=https://aka.ms/vs/15/release/channel
ADD ${CHANNEL_URL} C:/TEMP/VisualStudio.chman

# Download and install Build Tools for Visual Studio 2017

ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

RUN (C:\\TEMP\\vs_buildtools.exe `
    --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\\TEMP\\VisualStudio.chman `
    --installChannelUri C:\\TEMP\\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.Windows10SDK `
    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64	 `
    --includeRecommended `
    --add Microsoft.VisualStudio.Component.NuGet `
  || IF "%ERRORLEVEL%"=="3010" C:\TEMP\collect.exe -zip:C:\vslogs.zip && EXIT 0 )`
  && dir && cd C:\BuildTools && dir `
  && C:\TEMP\collect.exe -zip:C:\vslogs.zip `
  && @echo Cleaning up temp files`
  && del /S /F /Q %temp% `
  && del /S /F /Q %Windir%\Temp `
  && @echo Done cleaning up files in temp directories


SHELL ["powershell", "-command"]
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

ADD ci/jenkins/docker/build/windows-visual-studio-2017/packages.config packages.config
RUN choco install -y packages.config ; `
    Remove-Item C:\ProgramData\chocolatey\bin\cpack.exe ; `
    Remove-Item C:\Users\ContainerAdministrator\AppData\Local\Temp\chocolatey -Recurse

ARG CMAKE_GENERATOR="Visual Studio 15 2017"
ARG CMAKE_GENERATOR_PLATFORM=Win32
ARG CMAKE_CONFIG_TYPE=Release
ARG VSVSDEVCMD_ARCH=x86
ARG DEPENDENCIES_INSTALL_PATH="C:\Program Files (x86)\dvrescue"


# Reset the shell.
SHELL ["cmd", "/S", "/C"]

ENV CMAKE_GENERATOR=${CMAKE_GENERATOR}
ENV CMAKE_GENERATOR_PLATFORM=${CMAKE_GENERATOR_PLATFORM}
ENV CMAKE_CONFIG_TYPE=${CMAKE_CONFIG_TYPE}
RUN mkdir c:\\deps\\zlib\\build && `
    powershell -Command "Invoke-WebRequest 'https://www.zlib.net/zlib1211.zip' -OutFile c:/deps/zlib.zip" && `
    powershell -Command "Expand-Archive c:\deps\zlib.zip -DestinationPath c:\deps\zlib\source" && `
    cd c:\deps\zlib\build && `
    C:\BuildTools\Common7\Tools\VsDevCmd.bat -arch=%VSVSDEVCMD_ARCH% && `
    cmake -S c:/deps/zlib/source/zlib-1.2.11 -DCMAKE_INSTALL_PREFIX:PATH="%DEPENDENCIES_INSTALL_PATH%" && `
    cmake --build . --config %CMAKE_CONFIG_TYPE% --target install && `
    rmdir c:\deps /s /q

RUN git clone https://github.com/MediaArea/ZenLib.git c:/deps/ZenLib/source && `
    mkdir c:\\deps\\ZenLib\\build && `
    cd c:/deps/ZenLib/build && `
    cmake -S c:/deps/ZenLib/source/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH="%DEPENDENCIES_INSTALL_PATH%" && `
    cmake --build . --config %CMAKE_CONFIG_TYPE%  --target install && `
    rmdir c:\deps /s /q

RUN git clone https://github.com/MediaArea/MediaInfoLib.git c:/deps/MediaInfoLib/source && `
    mkdir c:\\deps\\MediaInfoLib\\build && `
    cd c:/deps/MediaInfoLib/build && `
    cmake -S c:/deps/MediaInfoLib/source/Project/CMake -DCMAKE_INSTALL_PREFIX:PATH="%DEPENDENCIES_INSTALL_PATH%" -DBUILD_ZLIB:BOOL=no -DBUILD_ZENLIB:BOOL=no && `
    cmake --build . --config %CMAKE_CONFIG_TYPE% --target install && `
    rmdir c:\deps /s /q

ADD ci/jenkins/docker/build/windows-visual-studio-2017/startup.bat c:\temp\startup.bat
ENV VSVSDEVCMD_ARCH=${VSVSDEVCMD_ARCH}
RUN REG ADD "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d c:\temp\startup.bat

SHELL ["powershell", "-command"]
RUN $env:PATH = $env:PATH + ';' + $env:DEPENDENCIES_INSTALL_PATH + '\bin' ; `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $env:PATH

SHELL ["cmd", "/S", "/C"]
