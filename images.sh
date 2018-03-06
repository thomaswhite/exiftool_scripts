#!/bin/bash


set -e          # short for errexitmodifies the behavior of the shell that will exit whenever a command exits with a non zero status
set -u          # this makes the shell to treat undefined variables as errors.
set -o nounset
#set -o pipefail # the pipe will be considered successful if all the commands involved are executed without errors


unset -f header
function header(){
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    echo "$(basename $0) - an exiftool utility wrapper, by Thomas White"
    echo "---------------------------------------------------------------"
}

# Usage info
unset -f show_help
function show_help() {
 header
 cat << EOF
 Usage: $(basename $0) [<options>] -e extension [-s source-directory] [--imagesRoot images-root-directory]" # ${0##*/}
   -n | --newimages   new images: copy and rename
   -r | --rename      rename images in place YYYY-MM-DD_HH-MM-SS.msec_<camera>_<lens>.<ext>
   -m | --move        move images to <root_image_dir>/<ext>/YYYY/MM/YYYY-MM-DD
   -c | --copy        copy images to <root_image_dir>/<ext>/YYYY/MM/YYYY-MM-DD
   -e | --ext         file extension, required ${1:-}
   -s | --sourceDir   image directory to be processed
   -? | -h
        --imagesRoot  root image directory
        --debug       display the commands without executing
        --dryrun      use TestName instead of FileName for file rename
---
EOF
}

unset -f print_parameters
print_parameters(){
    header
    if [ "$dryrun" ]; then echo " dry run                  : yes, debug, tag=TestName" ; fi
    echo " images root              : $imagesRoot"
    echo " images with extensions   : $xmp_flag $extensions"
    echo " located in and under     : ${sourceDir}"
    if   [ "$move" ]; then echo " will be moved to         : $imagesRoot/$image_directory";
    elif [ "$copy" ]; then echo " will be copied to        : $imagesRoot/$image_directory ";  fi
    if [ "$rename" ]; then echo " will be renamed to       : $image_name"'_<camera>_<lens>.<ext>'; fi
    if [ "$xmp_flag" ]; then echo " xmp_flag                 : $xmp_flag"; fi
    echo "- "
#    echo  " exif_param               : $exif_param"
#    echo  " name                     : $name"
}

# pass a tag in $1, suffux in $2
unset -f make_date_tags
function make_date_tags(){
   echo '-'${1}'<${FileModifyDate}'"${2}" '-'${1}'<${CreateDate}'"${2}" '-'${1}'<${DateTimeOriginal}'"${2}"
   # echo '-'${1}'<${DateTimeOriginal}'"${2}"
}

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
sourceDir="$SCRIPTPATH"
imagesRoot=${IMAGES_ROOT:-}
imagesRoot=${imagesRoot:-/media/tom/4Tb_Seagate/Images}
exif_param=" -m -r -progress "

debug=''
dryrun=''
TAG=FileName
extensions=''
copy=""
move=""
rename=""
new=""
extra_param=''
xmp_flag=''
xmp_extra_param=''

name=''
dateExpr=''

# >>> getopt -----------
SHORT=hnrmce:d:
LONG=dryrun,copy,help,debug,new,move,camera,ext:,sourceDir:,imagesRoot:

# read the options
OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
eval set -- "$OPTS"
#echo "$OPTS"

while true; do
  case $1 in
    -e | --ext       )
         if [ ${2,,} = "xmp" ]; then
           xmp_flag="-ext ${2,,} -ext ${2^^} "
           xmp_extra_param=" -tagsfromfile %d%f -overwrite_original "
         else
           extensions="$extensions -ext ${2,,} -ext ${2^^}";
         fi
        shift 2 ;;
    -s | --sourceDir )  sourceDir="${2}";            shift 2 ;;
         --imagesRoot)  imagesRoot="${2}";           shift 2 ;;
         --debug     )  debug=yes;                   shift ;;
         --dryrun    )  dryrun=yes; TAG=TestName;    shift ;;
    -n | --newimages )  new=yes;                     shift  ;;
    -r | --rename    )  rename=yes;                  shift ;;
    -m | --move      )  move=yes;  exif_param="$exif_param -o "; shift ;;
    -c | --copy      )  copy=yes;                    shift;;
    -h | --help      )  show_help;                   shift ;     exit 1 ;;
    --               )                               shift;      break ;;
    * )  if [ -z "$1" ]; then break; else echo "$1 is not a valid option"; shift; fi;; # exit 1;
  esac
done
shift "$(($OPTIND -1))"
# getopt <<< --------------

ms='${SubSectimeOriginal;$_.=0x(3-length);s/$_/.$_/}' # TODO: if the msec are missing defaults to an empty string
ms2='${SubSectimeOriginal;$_.=0x(3-length);s/$_/( length > 0 ? '.':'')$_/}' # TODO: if the msec are missing defaults to an empty string

camera='${Model;s/EOS//;s/910G/910F/;s/920G/910F/;s/PowerShot//;s/DIGITAL //;s/ IS//;tr/ /_/;s/__+/_/g;s/$_/__$_/}'
lens='${LensID;s/ f\/.*$//;s/ DC HSM//;s/AF-S DX VR Zoom-//;tr/ /_/;s/$_/~~$_/;s/Unknown_17-35mm/Canon_EF_17-35mm/;s/Unknown_35-350mm/Canon_EF_35-350mm/;s/Unknown_28-70mm/Canon_EF_28-70mm/;s/Canon_G10~~Unknown_/Canon_G10~~/}'

image_name="%Y-%m-%d_%H-%M-%S"
image_directory='%%le/%Y/%m/%Y-%m-%d'
image_full_directory="${imagesRoot}/${image_directory}"

file_siffix="${camera}${lens}"'%+c.%le'
ms_file_siffix="${ms}${camera}${lens}"'%+c.%le'
ms_file_siffix_xmp="${ms}${camera}${lens}"'%+c.nef.xmp'


if [ ! "$extensions"  ] && [ ! "$xmp_flag" ];   then show_help ;  echo  ">>> Error: At least one file extension is expected";  exit 1; fi
if [ ! $move ] && [ ! $copy ] && [ ! $rename ]; then show_help ;  echo  ">>> Error: At least one operation is expected -rename, -copy or -move"; exit 1; fi
if [   $move ] && [   $copy ];                  then show_help ;  echo  ">>> Error: Either -copy OR -move is expected"; exit 1; fi


if [ $rename ]; then
   dateExpr=$(make_date_tags $TAG $ms_file_siffix)
   name=$image_name
   if [  $move ] || [ $copy ]; then
       name="$image_full_directory/$image_name"
   fi
elif [  $move ] || [ $copy ]; then
   name="$image_full_directory"'/$f'
   dateExpr=$(make_date_tags 'directory' '' )
fi

print_parameters

if [ $debug ]; then
   echo Debugging :-:-:-:-:-:-:-:-:-:-:-:-:-:-:

   if [ "$xmp_flag" ]; then
       echo ' '
       echo "exiftool ${xmp_flag}  \ "
       echo  "     ${xmp_extra_param} ${exif_param}  \ "
       echo  "      -d ${name}  \ "
       echo  "      ${dateExpr} \ "
       echo  "      $sourceDir"
   fi

   if [ "$extensions" ]; then
       echo "exiftool ${extensions}  \ "
       echo "      ${exif_param}  \ "
       echo  "      -d ${name}  \ "
       echo  "      ${dateExpr} \ "
       echo  "      $sourceDir"
   fi

   echo ' '
   exit 0
else
   echo "Execution:"
   echo  exiftool ${extensions} ${exif_param} -d "${name}"  ${dateExpr}    "$sourceDir"

fi


exit 0



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


