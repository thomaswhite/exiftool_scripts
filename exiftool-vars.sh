#!/bin/bash

dir=${1:-.}
images_root="${2:-.}"	#  /media/tom/4Tb_Seagate/Images/
TAG="${3:-FileName}"    #  TestName
exif_extra_params=''
extensions=''           # loop through the extension and add for each (lowercase uppercase)  -ext ${1,,} -ext {1^^}
debug=0

ms='${SubSectimeOriginal;$_.=0x(3-length);s/$_/.$_/}' # TODO: if the msec are missing defaults to an empty string
ms2='${SubSectimeOriginal;$_.=0x(3-length);s/$_/(.x( length > 0 ? 1:0))$_/}' # TODO: if the msec are missing defaults to an empty string

camera='${Model;s/EOS//;s/910G/910F/;s/920G/910F/;s/PowerShot//;s/DIGITAL //;s/ IS//;tr/ /_/;s/__+/_/g;s/$_/__$_/}'
lens='${LensID;s/ f\/.*$//;s/ DC HSM//;s/AF-S DX VR Zoom-//;tr/ /_/;s/$_/~~$_/;s/Unknown_17-35mm/Canon_EF_17-35mm/;s/Unknown_35-350mm/Canon_EF_35-350mm/;s/Unknown_28-70mm/Canon_EF_28-70mm/;s/Canon_G10~~Unknown_/Canon_G10~~/}'


## camera defines: file extensions, extra params
#   Nikon,
#   Canon       ext: -ext crw -ext CRW  -ext _crw -ext _CRW,  ms=''
#   Fuji
#   Samsung phone
#   iPhone


##  file extensions:
#   crw/_crw
#   nef/xmp
#   jpg

## command:
#   copy      exif_extra_params=" ${exif_extra_params} -o "
#   rename
#   move



camera_lens_ext="${camera}${lens}"'%+c.%le'
ms_camera_lens_ext="${ms}${camera}${lens}"'%+c.%le'
ms_camera_lens_ext_xmp="${ms}${camera}${lens}"'%+c.nef.xmp'

image_name="%Y-%m-%d_%H-%M-%S"
image_directory='%%le/%Y/%m/%Y-%m-%d'
image_full_directory="${images_root}/${image_directory}"
image_full_directory_name="${images_root}/${image_directory}/${image_name}"

exif_param="$exif_extra_params -m -r -progress "
exif_param_NAME_ONLY="-m -r -progress -d ${image_name}"
exif_param_FULL_PATH="-m -r -progress -d ${image_full_directory_name}"

# exiftool -ext crw -ext CRW  ${exif_param_NAME_ONLY}  '-'"${TAG}"'<${DateTimeOriginal}'"${camera_lens_ext}"  ${dir}
# ext exif_param

echo "Usage: $0  <source-dir> <dest-images_root> [testname]"
echo "  source        : ${dir}"
echo "  destination   : ${image_full_directory_name}"
echo "  exif_NAME_ONLY: ${exif_param_NAME_ONLY}"
echo "  exif_FULL_PATH: ${exif_param_FULL_PATH}"
echo "  suffix        : ${ms_camera_lens_ext}"


# pass a tag in $1
unset -f make_date_tags
function make_date_tags(){
   echo '-'${1}'<${FileModifyDate}'"${ms_camera_lens_ext}" '-'${1}'<${CreateDate}'"${ms_camera_lens_ext}" '-'${1}'<${DateTimeOriginal}'"${ms_camera_lens_ext}"
}

#exif_rename  ${exit_param}, "-d ${image_name}"
unset -f exif_rename
function exif_move_rename(){
  local dateExpr=''
  if( $debug == 1 ); then
     dateExpr = ${make_date_tags TestName }
  else
     dateExpr = ${make_date_tags FileName }
  fi
  exiftool ${extensions} ${exif_param} -d ${image_full_directory_name} ${dateExpr} "${dir}"
}

unset -f exif_rename
function exif_rename(){
  local dateExpr=''
  if( $debug == 1 ); then
     dateExpr = ${make_date_tags TestName }
  else
     dateExpr = ${make_date_tags FileName }
  fi
  exiftool ${extensions} ${exif_param} -d ${image_name} ${dateExpr} "${dir}"
}

#exif_move 'jpg', ${exit_param}, "-d ${image_full_directory}"
unset -f exif_move
function exif_move(){
  local  dateExpr = ${make_date_tags directory }
  exiftool ${extensions} ${exif_param} -d ${image_full_directory}  ${dateExpr}  "${dir}"
}
