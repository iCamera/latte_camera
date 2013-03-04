#!/bin/sh
PROJ=`find . -name '*.xib' -o -name '*.[mh]' -o -name '*.storyboard'`
 
for png in `find . -name '*.png'`
do
   name=`basename -s .png $png`
   name=`basename -s @2x $name`
   if ! grep -q $name $PROJ; then
        echo "$png"
   fi
done
