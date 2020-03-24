#!/bin/bash


# relevant variables - can be customised
rootdir="/data/work/wrappers-sgl/apps"
# production directory where all data/analyses are
# can also be a comma separated list 
workdir="/data/work,/data/db"


# prompt for list file
if [ $# -eq 0 ] ; then
 echo Please provide the name of the list file as an argument. Exiting.
 exit
elif [ ! -s $1 ] ; then
 echo List file $1 not found or empty. Exiting.
 exit
fi
listfile=$1

# create directories for images and wrapper scripts
echo Creating image directory $rootdir ..
mkdir -p $rootdir

# initialise list of tool directories
appdir_list=""

# read the list of requirements and do stuff
while read line ; do

 # skip empty and # commented lines
 skip=$(echo $line | grep -e '^$' -e '^#' -c)
 if [ $skip -gt 0 ] ; then
  continue
 fi

 # is this line an image (0) or a command (1)?
 type=$(echo $line | grep '^-' -c)

 # it's an image
 if [ $type -eq 0 ] ; then
  # save name&infos
  image=$line
  echo Saving infos for image $image ..
  siftmp=${image##*/}
  tool=${siftmp%:*}
  tag=${siftmp#*:}
  appdir="$rootdir/$tool/$tag"
  appdir_list+="${appdir}:"
  sif=${siftmp/:/_}.sif
  # create directory
  echo Creating directory for tool $tool tag $tag ..
  mkdir -p $appdir
  # pull image
  echo Pulling container image $image ..
  singularity pull --dir $appdir $sif $image
 
 # it's a command, so create the wrapper script
 elif [ $type -eq 1 ] ; then
  cmd=${line##* }
  echo - Creating wrapper for command $cmd
  cat << EOF >$appdir/$cmd
#!/bin/bash

singularity exec $appdir/$sif $cmd "\$@"
EOF
  chmod +x $appdir/$cmd
 fi 

done < $listfile

# display information on how to configure shell environment
cat << EOM

All done!

For proper functioning of this setup, ensure these two definitions are in your ~/.bash_profile :

##############################
export PATH=$appdir_list\$PATH   #hpc-containers-wrappers
export SINGULARITY_BINDPATH=\$SINGULARITY_BINDPATH,$workdir   #hpc-containers-wrappers
##############################

EOM
