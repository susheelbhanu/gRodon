"""
Author: Susheel Bhanu BUSI
Affiliation: ESB group LCSB UniLU
Date: [2021-03-16]
Run: snakemake -s Snakefile --configfile config/config.yaml --use-conda --cores 36 -rp
Latest modification: [2021-10-17]
"""

# Pipeline for running gRodon (v2) for growth prediction

# Includes both prokaryote and eukaryote modes
# Example call: snakemake -s Snakefile --configfile config/config.yaml --use-conda --conda-prefix ${CONDA_PREFIX}/pipeline --cores 1 -rpn


##############################
# MODULES
import os, re
import glob
import pandas as pd


##############################
# CONFIG
# can be overwritten by using --configfile <path to config> when calling snakemake
# configfile: "config/config.yaml"

include:
    "workflow/rules/init.smk"


##############################
# TARGETS & RULES
# List of (main) targets to be created
TARGETS = []


# Prokaryotes
if "prokaryotes" in STEPS:
    include:
        "workflow/rules/prokaryote_gRodon.smk"
    TARGETS += [
        "status/prokaryotes.done"
    ]

## Eukaryotes
if "eukaryotes" in STEPS:
    include:
        "workflow/rules/eukaryote_gRodon.smk"
    TARGETS += [
        "status/eukaryotes.done"
    ]


# No targets
if len(TARGETS) == 0:
    raise Exception("You are not serious. Nothing to be done? Really?")

rule all:
    input:
        TARGETS


