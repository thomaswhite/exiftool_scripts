#!/bin/bash


camera='${Model;s/EOS//;s/910G/910F/;s/920G/910F/;s/PowerShot//;s/DIGITAL //;s/ IS//;tr/ /_/;s/__+/_/g;s/$_/__$_/}'
lens='${LensID;s/ f\/.*$//;s/ DC HSM//;s/AF-S DX VR Zoom-//;tr/ /_/;s/$_/~~$_/;s/Unknown_17-35mm/Canon_EF_17-35mm/;s/Unknown_35-350mm/Canon_EF_35-350mm/;s/Unknown_28-70mm/Canon_EF_28-70mm/;s/Canon_G10~~Unknown_/Canon_G10~~/}' 
# 
# ;s/Unknown/Embedded/;     
ms='${SubSectimeOriginal;$_.=0 x(3-length);s/$_/.$_/}'
suffix="${ms}${camera}${lens}"'%+c.%le'
suffix_xmp="${ms}${camera}${lens}"'%+c.nef.xmp'
suffix_noms="${camera}${lens}"'%+c.%le'

format_file_name="%Y-%m-%d_%H-%M-%S"
images_dirirectory='%%le/%Y/%m/%Y-%m-%d'

dir=${1:-.}
images_root="${2:-.}"	      #  /media/tom/4Tb_Seagate/Images/
TAG_filename="${3:-FileName}" #  testname  

full_name="${images_root}/${images_dirirectory}/${format_file_name}"

exif_param_FULL_PATH="-m -r -progress -d ${full_name}" 
exif_param_NAME_ONLY="-m -r -progress -d ${format_file_name}"

echo "Usage: $0  <source-dir> <dest-images_root> [testname]"
echo "  source        : ${dir}"
echo "  destination   : ${full_name}"
echo "  exif_NAME_ONLY: ${exif_param_NAME_ONLY}"
echo "  exif_FULL_PATH: ${exif_param_FULL_PATH}"
echo "  suffix        : ${suffix}"


#exif_rename 'jpg', ${exit_param}, ${TAG_filename}, ${suffix} ${dir}
function exif_rename(){
  exiftool -ext ${1,,} -ext {1^^} ${2} '-'"${3}"'<${FileModifyDate}'"${4}" '-'"${3}"'<${CreateDate}'"${4}" '-'"${3}"'<${DateTimeOriginal}'"${4}"  "${5}"
}

