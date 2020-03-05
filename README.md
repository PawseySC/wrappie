# container-wrappers

Prototype for automated deployment of applications as bash wrappers around containers.

Assumes [Singularity](http://sylabs.io/singularity) is available in the system.

Find us on [GitHub](https://github.com/marcodelapierre/container-wrappers)


## Quick start

Edit the first few lines of the `setup.sh` script to provide values for the following variables:
* `imagedir`: location for downloaded container images
* `wrapdir`: location for application wrapper scripts
* `workdir`: work directory for production, where data are stored (can be comma separated list)

Write a text file, *e.g.* `list_apps`, of this form:

```
docker://ubuntu:18.04
- ls
- pwd
```

with image addresses, followed by a dashed list of commands you will need to run from that image. Lines starting with `#` will be ignored.

Finally run the script:

```
./setup.sh list_apps
```

At the end of the setup, the script will advise on a couple of variable definitions to be added in your `~/.bash_profile`, something like:

```
For proper functioning of this setup, ensure these two definitions are in your ~/.bash_profile :

##############################
export PATH=$PATH:[..]
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,[..]
##############################
```


## Current known limitations

The script does not setup modules, so maintaining multiple version of the same package can be challenging.


## Useful resources

Checkout this tool to install containerised applications, including bash wrappers and modules: [Quay Containers](https://github.com/alexiswl/quay_containers).

