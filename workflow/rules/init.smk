##############################
# MODULES
import os, re
import glob
import pandas as pd


# ##############################
# # Parameters
# CORES=int(os.environ.get("CORES", 4))


##############################
# Paths
SRC_DIR = srcdir("../scripts")
ENV_DIR = srcdir("../envs")


##############################
# Dependencies 
PERL5LIB="/home/users/sbusi/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
PERL_LOCAL_LIB_ROOT="/home/users/sbusi/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
PERL_MB_OPT="--install_base \"/home/users/sbusi/perl5\""
PERL_MM_OPT="INSTALL_BASE=/home/users/sbusi/perl5"


##############################
# default executable for snakemake
shell.executable("bash")


##############################
# working directory
workdir:
    config["work_dir"]


##############################
# Relevant directories
DATA_DIR = config["data_dir"]
PROK_DIR = config["prokaryotes_dir"]
RESULTS_DIR = config["results_dir"]


##############################
# Steps
STEPS = config["steps"]


##############################
# Input
PROKS = [line.strip() for line in open("data/prokaryotes.txt").readlines()]
EUKS = [line.strip() for line in open("data/eukaryotes.txt").readlines()]

# Working directory path
data_dir: "/mnt/internal/sbusi/growth_rates"

# Path to MAG directory
mag_dir: "/mnt/md1200/sbusi/metabolisHMM/data"

# Path to results directory
results_dir: "/mnt/internal/sbusi/growth_rates/results"

# Path to conda environments' directory
env_dir: "/mnt/internal/sbusi/growth_rates/envs"

# Path to directory with auxilliary scripts
scripts_dir: "/mnt/internal/sbusi/growth_rates/scripts"

################################
# Prokka
prokka:
    threads: 4

    MAFFT:
        threads: 24

        IQTREE:
            threads: 4
