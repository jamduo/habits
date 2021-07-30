@echo off

echo (Make sure you have set EMULATOR_PATH and EMULATOR_DEVICE)

: set emulator location
set EMULATOR_PATH=

: set emulator device
set EMULATOR_DEVICE=

%EMULATOR_PATH% -avd %EMULATOR_DEVICE% -dns-server 8.8.8.8
