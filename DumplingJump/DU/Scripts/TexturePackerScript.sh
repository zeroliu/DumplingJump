#! /bin/sh

TP="/usr/local/bin/TexturePacker"
RESOURCES_PATH="${SRCROOT}/DumplingJump/DU/Resources"
ASSETS_PATH="${SRCROOT}/DumplingJump/DU/Assets"

if [ "${ACTION}" = "clean" ]
then
    echo "cleaning..."
    rm DumplingJump/DU/Resources/spriteSheets/*.png
    rm DumplingJump/DU/Resources/spriteSheets/*.pvr
    rm DumplingJump/DU/Resources/spriteSheets/*.plist
    
    # ....
    # add all files to be removed in clean phase
    # ....
else
    echo "building..."
    
    ${TP} DumplingJump/DU/Assets/hero.tps
    ${TP} DumplingJump/DU/Assets/background.tps
fi
exit 0