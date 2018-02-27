#!/bin/bash

dir=${1:-.}
images_root="${2:-.}"

#/media/tom/4Tb_Seagate/Images/

image_directory='%%le/%Y/%m/%Y-%m-%d'
file_name="%Y-%m-%d_%H-%M-%S"
image_full_directory_name="${images_root}/${image_directory}/${file_name}"

exit_param="-m -r -progress -d ${image_full_directory_name}"

camera='${Model;s/EOS//;s/910G/910F/;s/920G/910F/;s/PowerShot//;s/DIGITAL //;s/ IS//;tr/ /_/;s/__+/_/g;s/AF-S_DX_VR_Zoom-//;s/$_/__$_/}'
lens='${LensID;s/ f\/.*$//;s/ DC HSM//;tr/ /_/;s/$_/~~$_/}' # ;s/Unknown/Embedded/;
ms='${SubSectimeOriginal;$_.=0 x(3-length);s/$_/.$_/}'
suffix="${ms}${camera}${lens}"'%+c.%le'


filename="FileName" #  testname  
 
exiftool -ext jpg -ext JPG ${exit_param} '-'"${filename}"'<${FileModifyDate}'"${ms_camera_lens_ext}" '-'"${filename}"'<${CreateDate}'"${ms_camera_lens_ext}" '-'"${filename}"'<${DateTimeOriginal}'"${ms_camera_lens_ext}"  "${dir}"

