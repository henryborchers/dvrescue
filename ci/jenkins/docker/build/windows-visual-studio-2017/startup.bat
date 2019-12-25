@echo off
if not defined DevEnvDir (
    REM C:\BuildTools\VC\Auxiliary\Build\vcvars32.bat
    CALL C:\BuildTools\Common7\Tools\VsDevCmd.bat  -arch=%VSVSDEVCMD_ARCH%
    )
