#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`


## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
	./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit
else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# OxideMod has been replaced with uMod
if [ -f OXIDE_FLAG ] || [ "${OXIDE}" = 1 ] || [ "${UMOD}" = 1 ]; then
    echo "Updating uMod..."
    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
    unzip -o -q umod.zip
    rm umod.zip
    echo "Done updating uMod!"
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"
