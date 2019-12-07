@echo off
if not defined DevEnvDir (
    dir C:\
    CALL C:\BuildTools\Common7\Tools\VsDevCmd.bat  -arch=amd64
    echo HERE
    )
