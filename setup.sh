#!/bin/bash
# assuming singularity is available in the system


# relevant variables - can be customised
rootdir="/data/work/wrappers-sgl/apps"
# production directory where all data/analyses are
# can also be a comma separated list 
workdir="/data/work,/data/db"


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

 # it's an image, so save the name and pull it 
 if [ $type -eq 0 ] ; then
  image=$line
  siftmp=${image##*/}
  tool=${siftmp%:*}
  ver=${siftmp#*:}
  sif=${siftmp/:/_}.sif
  echo Creating directory for tool $tool version $ver ..
  appdir="$rootdir/$tool/$ver"
  mkdir -p $appdir
  appdir_list+="${appdir}:"
  echo Pulling container image $image for tool $tool version $ver ..
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

cat << EOM

All done!

For proper functioning of this setup, ensure these two definitions are in your ~/.bash_profile :

##############################
export PATH=$appdir_list\$PATH #mycatisawesome
export SINGULARITY_BINDPATH=\$SINGULARITY_BINDPATH,$workdir #mycatisawesome
##############################

EOM
