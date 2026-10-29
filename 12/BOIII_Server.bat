@echo off

set GamePort=27017

set ModIdNumber=

set ServerFilename=server.cfg

start boiii.exe -headless +set fs_game "%ModIdNumber%" +set net_port "%GamePort%"  +set logfile 2 +exec %ServerFilename%
