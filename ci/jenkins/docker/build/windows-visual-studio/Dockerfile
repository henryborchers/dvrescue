# escape=`
ARG FROM_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:3.5
FROM ${FROM_IMAGE}

# Reset the shell.
SHELL ["cmd", "/S", "/C"]
RUN mkdir c:\\TEMP
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe

# Download channel for fixed install.
ARG CHANNEL_URL=https://aka.ms/vs/16/release/channel
ADD ${CHANNEL_URL} C:/TEMP/VisualStudio.chman

# Download and install Build Tools for Visual Studio 2019

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

RUN (C:\\TEMP\\vs_buildtools.exe `
    --quiet --wait --norestart --nocache `
    --channelUri C:\\TEMP\\VisualStudio.chman `
    --installChannelUri C:\\TEMP\\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.Windows10SDK `
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362 `
    --add Microsoft.VisualStudio.Component.VC.CMake.Project `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64	 `
    --includeRecommended `
    --add Microsoft.VisualStudio.Component.NuGet `
    --installPath C:\BuildTools `
  || IF "%ERRORLEVEL%"=="3010" C:\TEMP\collect.exe -zip:C:\vslogs.zip && EXIT 0 )`
  && cd C:\BuildTools && dir `
  && C:\TEMP\collect.exe -zip:C:\vslogs.zip `
  && @echo Cleaning up temp files`
  && del /S /F /Q %temp% `
  && del /S /F /Q %Windir%\Temp `
  && @echo Done cleaning up files in temp directories


#RUN setx path "%path%;C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin
RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" `
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

RUN choco install -y nsis wixtoolset ninja`
    && choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System' `
    && del /S /F /Q %ChocolateyInstall%"

SHELL ["powershell", "-command"]
RUN $ErrorActionPreference = 'Stop'; `
    Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-64-bit.zip' -OutFile MinGit.zip ; `
    Expand-Archive c:\MinGit.zip -DestinationPath c:\MinGit; `
    $env:PATH = $env:PATH + ';C:\MinGit\cmd\;C:\MinGit\cmd'; `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $env:PATH

RUN $ErrorActionPreference = 'Stop'; `
    mkdir deps ; `
    Invoke-WebRequest 'https://www.zlib.net/zlib1211.zip' -OutFile c:/deps/zlib.zip ; `
    Expand-Archive c:\deps\zlib.zip -DestinationPath c:\deps\zlib\source

# Reset the shell.
SHELL ["cmd", "/S", "/C"]
ADD ci/jenkins/docker/build/windows-visual-studio/starup.bat c:\temp\startup.bat
RUN REG ADD "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d c:\temp\startup.bat

# TODO. unzip zlib and compile and install it
RUN mkdir c:\\deps\\zlib\\build && `
    cd c:\deps\zlib\source && `
    cmake -S c:/deps/zlib/source/zlib-1.2.11 -G Ninja -DCMAKE_INSTALL_PREFIX:PATH=C:/deps && `
    cmake --build . --target install

RUN git clone https://github.com/MediaArea/ZenLib.git c:/deps/ZenLib/source && `
    mkdir c:\\deps\\ZenLib\\build && `
    cd c:/deps/ZenLib/build && `
    cmake -S c:/deps/ZenLib/source/Project/CMake -G Ninja -DCMAKE_INSTALL_PREFIX:PATH=C:/deps && `
    cmake --build . --target install

RUN git clone https://github.com/MediaArea/MediaInfoLib.git c:/deps/MediaInfoLib/source && `
    mkdir c:\\deps\\MediaInfoLib\\build && `
    cd c:/deps/MediaInfoLib/build && `
    cmake -S c:/deps/MediaInfoLib/source/Project/CMake -G Ninja -DCMAKE_INSTALL_PREFIX:PATH=C:/deps -DBUILD_ZLIB:BOOL=no -DBUILD_ZENLIB:BOOL=no && `
    cmake --build . --target install