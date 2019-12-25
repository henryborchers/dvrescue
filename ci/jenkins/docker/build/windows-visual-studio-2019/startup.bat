@echo off
if not defined DevEnvDir (
    CALL C:\BuildTools\Common7\Tools\VsDevCmd.bat  -arch=%VSVSDEVCMD_ARCH%
    )
