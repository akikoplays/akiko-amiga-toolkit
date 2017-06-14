
# based on http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash

filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"
path=$(dirname "$1")/

echo base: $filename
echo ext: $extension
echo path: $path

output="${path}""${filename}"."rgb"
echo Converting "$1" to "$output"
convert $1 -depth 8 "$output"

echo converting rgb to .h
header="${path}""${filename}"."h"
xxd -i "$output" > "$header"
ls $path
#xxd -i $"{filename}.rgb" > "${filename}.h"
