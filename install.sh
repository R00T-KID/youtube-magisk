
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

ui_print2 () { echo "    $1"; sleep 0.005; }
ui_print () { echo "$1"; sleep 0.005; }


Getp () { grep_prop $1 $TMPDIR/module.prop; }

if [ "$ARCH" == "x86" ] || [ "$ARCH" == "x64" ];then
device=x86
chontm=x86
elif [ "$ARCH" == "arm64" ];then
device=arm64_v8a
chontm=arm
else
device=armeabi_v7a
chontm=arm
fi


sed () { toybox sed "$@"; }
cut () { toybox cut "$@"; }


print_modname() {

ui_print
ui_print2 "Name: $(Getp name)"
ui_print
ui_print2 "Version: $(Getp version) | Author: $(Getp author)"
ui_print
ui_print
}


on_install() {

[ "$ARCH" == "arm64" ] || abort "    This module only supports arm64 devices
"

ui_print2 "Extracting Module File"
ui_print



cp -f $TMPDIR/sqlite3 $MODPATH/sqlite3 >&2
unzip -qo "$ZIPFILE" "system/*" -d $MODPATH >&2
chmod -R 755 $MODPATH/sqlite3

ui_print2 "Replacing File"
ui_print

for Tkvi in $( find /data/app | grep com.google.android.youtube | grep 'base.apk' ); do
[ "$Tkvi" ] && umount -l "$Tkvi"
done
pm uninstall com.google.android.youtube >&2
for Vhkdd in $(find /data/app -name *com.google.android.youtube*); do
[ "$Vhkdd" ] && rm -fr "$Vhkdd"
done

ui_print2 "Start Installation"
ui_print

apks=/data/local/tmp/apks
rm -rf $apks && mkdir -p $apks
cd $apks
unzip -qoj "$ZIPFILE" "apks/*" -d $apks

id=$(pm install-create -r | grep -oE '[0-9]+')

for ALL in $(ls -1); do
pm install-write $id $ALL $apks/$ALL >&2
done

pm install-commit $id >&2

cp -f $TMPDIR/black.apk $MODPATH/black.apk >&2
chcon u:object_r:apk_data_file:s0 "$MODPATH/black.apk"
su -mm -c mount -o bind "$MODPATH/black.apk" "$( pm path com.google.android.youtube | grep base | sed 's/package://g' )"

ui_print2 "Setting Permission"
ui_print

Sqlite3=$MODPATH/sqlite3
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
PK=com.google.android.youtube
GET_LDB=$($Sqlite3 $LDB "SELECT doc_id,doc_type FROM ownership" | grep $PK | head -n 1 | grep -o 25)

if [ "$GET_LDB" != "25" ]; then
cmd appops set --uid $PS GET_USAGE_STATS ignore
pm disable $PS >&2
sqlite3 $LDB "UPDATE ownership SET doc_type = '25' WHERE doc_id = '$PK'";
sqlite3 $LADB "UPDATE appstate SET auto_update = '2' WHERE package_name = '$PK'";
rm -rf /data/data/$PS/cache/*
pm enable $PS >&2
fi

ui_print2 "Done"
ui_print
rm -rf /data/adb/vanced
rm -rf /data/adb/service.d/vanced.sh
rm -rf /data/adb/post-fs-data.d/vanced.sh
rm -rf /data/adb/revanced
rm -rf /data/adb/service.d/revanced.sh
rm -rf /data/adb/post-fs-data.d/revanced.sh
ui_print2 "https://github.com/R00T-KID"
su -c settings put system min_refresh_rate 120
sleep 0.5
ui_print "* Optimizing com.google.android.youtube"
nohup cmd package compile --reset com.google.android.youtube >/dev/null 2>&1 &

if [ -z "$(pm path com.google.android.youtube)" ];then
ui_print2 "Reboot is Required"
ui_print
abort
fi
}

set_permissions() { 
set_perm_recursive $MODPATH 0 0 0755 0644
chmod -R 755 $MODPATH/sqlite3
}
