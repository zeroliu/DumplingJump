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
rm -rf DumplingJump/DU/Resources/spriteSheets
# ....
# add all files to be removed in clean phase
# ....
else
echo "building..."

mkdir -p DumplingJump/DU/Resources/spriteSheets
${TP} DumplingJump/DU/Assets/objects.tps
${TP} DumplingJump/DU/Assets/background.tps
${TP} DumplingJump/DU/Assets/background-object.tps
${TP} DumplingJump/DU/Assets/effects.tps
${TP} DumplingJump/DU/Assets/ui1.tps
${TP} DumplingJump/DU/Assets/ui2.tps
${TP} DumplingJump/DU/Assets/ui3.tps
${TP} DumplingJump/DU/Assets/ui-achievement.tps
${TP} DumplingJump/DU/Assets/ui-option.tps
fi
exit 0