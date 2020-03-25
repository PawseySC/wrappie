#!/bin/bash


# relevant variables - can be customised
# root directory for applications (images+wrappers)
rootdir=${rootdir:-"/data/work/wrappers-sgl/apps"}
# root directory for modules
moduledir=${moduledir:-"/data/work/wrappers-sgl/modules"}
# production directory for data/analyses. only used for final output. can be a comma separated list 
workdir=${workdir:-"/data/work,/data/db"}


# prompt for list file
if [ $# -eq 0 ] ; then
 echo Please provide the name of the list file as an argument. Exiting.
 exit
elif [ ! -s $1 ] ; then
 echo List file $1 not found or empty. Exiting.
 exit
fi
listfile=$1

# create directories for applications and modules
echo Creating root directory for applications $rootdir ..
mkdir -p $rootdir
echo Creating root directory for modules $moduledir ..
mkdir -p $moduledir

# initialise list of tool directories
appdir_list=""


# main loop
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
  siftmp=${image##*/}
  tool=${siftmp%:*}
  tag=${siftmp#*:}
  appdir="$rootdir/$tool/$tag"
  appdir_list+="${appdir}:"
  sif=${siftmp/:/_}.sif
  # pull image
  echo Pulling container image $image ..
  mkdir -p $appdir
  singularity pull --dir $appdir $sif $image
  # create module
  echo Creating module for tool $tool tag $tag ..
  mkdir -p $moduledir/$tool
  cat << EOM >$moduledir/$tool/$tag
#%Module1.0######################################################################
##
## $tool modulefile
##
proc ModulesHelp { } {
    puts stderr "\tModule for tool $tool , tag $tag\n"
    puts stderr "\tThis module uses the container image $image."
}

module-whatis   "edits the PATH to use the tool $tool , tag $tag"

prepend-path     PATH            $appdir

EOM


 # it's a command, so create the wrapper script
 elif [ $type -eq 1 ] ; then
  cmd=${line##* }
  echo - Creating wrapper for command $cmd
  cat << EOW >$appdir/$cmd
#!/bin/bash

singularity exec $appdir/$sif $cmd "\$@"
EOW
  chmod +x $appdir/$cmd
 fi 

done < $listfile


# display information on how to configure shell environment
cat << EOD

All done!

For proper functioning of this setup, ensure these two definitions are in your ~/.bash_profile :

##############################
module use $moduledir   #hpc-containers-wrappers
export SINGULARITY_BINDPATH=\$SINGULARITY_BINDPATH,$workdir   #hpc-containers-wrappers
##############################

EOD
