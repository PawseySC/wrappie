# wrappie

<img src="extras/logo_wrappie.png" alt="logo_wrappie" width="140" height="140"/>

**wrappie** is a tool for automated deployment of applications using containers, bash wrappers and modules.  
Containers are used under the hood while users interact with modules, resulting in the typical user experience of a HPC shared system.

Find it on [GitHub](https://github.com/marcodelapierre/wrappie)


## Software requirements

* [Singularity](http://sylabs.io/singularity) : template installation [script](prereqs/install-singularity.sh)

* A module system, either 
    * [Environment modules](https://modules.readthedocs.io/en/latest/module.html) : template installation [script](prereqs/install-modules.sh)
    * [Lmod](https://lmod.readthedocs.io/en/latest/)


## Quick start

Lines 20-26 of the `wrappie` script provide values for the following variables:
* `basedir`: basename for the following two variables
* `rootdir`: upper level path for the directory tree of packages (containers and wrappers). The tree has the format: `rootdir/tool/tag/`
* `moduledir`: upper level path for the directory tree of modules, format `moduledir/tool/tag`
* `workdir`: work directory for production, where data are stored. Can be comma separated list, only used to display information

You can specify customised values for these variables either in the shell environment, or by editing those lines in `wrappie`.

Write a text file, *e.g.* `dummy_list`, of this form:

```
docker://ubuntu:18.04
- ls
- pwd
```

*i.e.* containing image addresses, followed by a dashed list of commands you will need to run from that image. If the image has GPU capabilities, just add a dashed item `GPU` as the *first* item for the image.  
Lines starting with `#` will be ignored.

Finally run `wrappie`:

```
./wrappie dummy_list
```

At the end of the process (non Pawsey HPC systems only), an output will advise on a couple of variable definitions to be added in your `~/.bash_profile`, something like:

```
For proper functioning of this setup, ensure these two definitions are in your ~/.bash_profile :

##############################
module use [..]
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,[..]
##############################
```


## Pawsey HPC systems

To install `wrappie`, a `maali` cygnet file is available in the `extras/` directory.

At runtime, `wrappie` can recognise if it is being run on Pawsey systems, and adjust the installation paths accordingly:
* for regular users, the `basedir` will be set to `$MYGROUP/software/$PAWSEY_OS`
* for super user `maali`, system paths will be set


## Useful resources

Checkout this alternative tool to install containerised applications, including bash wrappers and modules: [Quay Containers](https://github.com/alexiswl/quay_containers).


## TO-DO

* standardise format for specifying packages? (YAML/JSON)
* move to PawseySC git
* ..


## Authors

Marco De La Pierre <marco.delapierre@pawsey.org.au>  
Audrey Stott <audrey.stott@pawsey.org.au>  
Sarah Beecroft <sarah.beecroft@pawsey.org.au>  
