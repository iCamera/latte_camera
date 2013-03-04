#!/bin/bash
# Downsamples all retina ...@2x.png images.

echo "Downsampling retina images..."

dir=$(pwd)/Resources
find "$dir" -name "*@2x.jpg" | while read image; do

    outfile=$(dirname "$image")/$(basename "$image" @2x.jpg).jpg

    if [ "$image" -nt "$outfile" ]; then
        basename "$outfile"

        width=$(sips -g "pixelWidth" "$image" | awk 'FNR>1 {print $2}')
        height=$(sips -g "pixelHeight" "$image" | awk 'FNR>1 {print $2}')
        sips -z $(($height / 2)) $(($width / 2)) "$image" --out "$outfile"

        test "$outfile" -nt "$image" || exit 1
    fi
done
