#!/bin/bash


set -e          # short for errexitmodifies the behavior of the shell that will exit whenever a command exits with a non zero status
set -u          # this makes the shell to treat undefined variables as errors.
set -o nounset
#set -o pipefail # the pipe will be considered successful if all the commands involved are executed without errors


unset -f header
function header(){
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    echo "$(basename $0) - an exiftool utility, by Thomas White"
    echo "---------------------------------------------------------"
}

# Usage info
unset -f show_help
function show_help() {
 header
 cat << EOF
 Usage: $(basename $0) [<options>] -e extension [-s source-directory] [--imagesRoot images-root-directory]" # ${0##*/}
   -e | --ext         file extension, required ${1:-}
   -s | --sourceDir   image directory to be processed
        --imagesRoot  root image directory
        --debug       debug mode
   -n | --newimages   new images: copy and rename
   -r | --rename      rename images in place yyyy-mm-dd_hh-mm-ss.msec_<camera>_<lens>
   -m | --move        move the images to the datetime directory structure root_image_dir/ext/yyyy/mm/yyyy-mm-dd
   -c | --copy        copy images to root_image_dir/ext/yyyy/mm/yyyy-mm-dd
   -? | -h
EOF
}

unset -f print_parameters
print_parameters(){
    header
    if [ "$dryrun" ]; then echo " dry run               : ON, debug, rename, tag=TestName" ; fi
    if [ "$debug" ];  then echo " debugging             : $debug "; fi
    echo " file tag used         : $TAG";
    echo " images with extensions:$extensions"
    echo " located in and under  : ${sourceDir}"
    if [ "$rename" ]; then  echo " will be renamed to    : $image_name"'_<camera>_<lens>.<ext>'; fi
    if   [ "$move" ]; then  echo " will be moved to      : $imagesRoot/$image_directory";
    elif [ "$copy" ]; then  echo " will be copied to     : $imagesRoot/$image_directory ";  fi
    echo "=== "
}

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
  exiftool ${extensions} ${exif_param} -d ${image_full_directory_name} ${dateExpr} "$sourceDir"
}

unset -f exif_rename
function exif_rename(){
  local dateExpr=''
  if( $debug == 1 ); then
     dateExpr = ${make_date_tags TestName }
  else
     dateExpr = ${make_date_tags FileName }
  fi
  exiftool ${extensions} ${exif_param} -d ${image_name} ${dateExpr} "$sourceDir"
}

#exif_move 'jpg', ${exit_param}, "-d ${image_full_directory}"
unset -f exif_move
function exif_move(){
  local  dateExpr = ${make_date_tags directory }
  exiftool ${extensions} ${exif_param} -d ${image_full_directory}  ${dateExpr}  "$sourceDir"
}

ms='${SubSectimeOriginal;$_.=0x(3-length);s/$_/.$_/}' # TODO: if the msec are missing defaults to an empty string
ms2='${SubSectimeOriginal;$_.=0x(3-length);s/$_/( length > 0 ? '.':'')$_/}' # TODO: if the msec are missing defaults to an empty string

camera='${Model;s/EOS//;s/910G/910F/;s/920G/910F/;s/PowerShot//;s/DIGITAL //;s/ IS//;tr/ /_/;s/__+/_/g;s/$_/__$_/}'
lens='${LensID;s/ f\/.*$//;s/ DC HSM//;s/AF-S DX VR Zoom-//;tr/ /_/;s/$_/~~$_/;s/Unknown_17-35mm/Canon_EF_17-35mm/;s/Unknown_35-350mm/Canon_EF_35-350mm/;s/Unknown_28-70mm/Canon_EF_28-70mm/;s/Canon_G10~~Unknown_/Canon_G10~~/}'
camera_lens_ext="${camera}${lens}"'%+c.%le'

exif_param=" -m -r -progress "
image_name="%Y-%m-%d_%H-%M-%S"
image_directory='%%le/%Y/%m/%Y-%m-%d'

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
imagesRoot=${IMAGES_ROOT:-}
imagesRoot=${imagesRoot:-/media/tom/4Tb_Seagate/Images}

debug=''
dryrun=''
TAG=FileName
exif_extra_params=''
extensions=''
copy=""
move=""
rename=""
new=""
sourceDir="$SCRIPTPATH"

# >>> getopt
SHORT=hnrmce:s:d:
LONG=dryrun,copy,help,debug,new,move,camera,ext:,sourceDir:,imagesRoot:

# read the options
OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
eval set -- "$OPTS"
#echo "$OPTS"

while true; do
  case $1 in
    -e | --ext       )  extensions="$extensions -ext ${2,,} -ext ${2^^}"; shift 2 ;;
    -s | --sourceDir )  sourceDir="${2}";            shift 2 ;;
    -d | --imagesRoot)  imagesRoot="${2}";           shift 2 ;;
         --debug     )  debug='yes'; TAG=TestName;   shift ;;
         --dryrun    )  debug='yes'; dryrun=yes; TAG=TestName; rename=yes;   shift ;;
    -n | --newimages )  new=yes;                     shift  ;;
    -r | --rename    )  rename=yes;                  shift ;;
    -m | --move      )  move=yes;                    shift ;;
    -c | --copy      )  copy=yes;                    shift;;
    -h | --help      )  show_help;                   shift ;     exit 1 ;;
    --               )                               shift;      break ;;
    * )  if [ -z "$1" ]; then break; else echo "$1 is not a valid option"; shift; fi;; # exit 1;
  esac
done
shift "$(($OPTIND -1))"
# getopt <<<


if [ ! "$extensions"  ]; then show_help ;  echo  "Error: At least one file extension is required"; exit 1; fi

print_parameters

ms_camera_lens_ext="${ms}${camera}${lens}"'%+c.%le'
ms_camera_lens_ext_xmp="${ms}${camera}${lens}"'%+c.nef.xmp'

image_full_directory="${imagesRoot}/${image_directory}"
image_full_directory_name="${imagesRoot}/${image_directory}/${image_name}"

exif_param="$exif_extra_params -m -r -progress "
exif_param_NAME_ONLY="-m -r -progress -d ${image_name}"
exif_param_FULL_PATH="-m -r -progress -d ${image_full_directory_name}"

exit 1


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

dir=${1:-.}
#TAG="${3:-FileName}"    #  TestName
TAG="TestName"
# exiftool -ext crw -ext CRW  ${exif_param_NAME_ONLY}  '-'"${TAG}"'<${DateTimeOriginal}'"${camera_lens_ext}"  $sourceDir
# ext exif_param


