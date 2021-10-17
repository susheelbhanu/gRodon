"""
Author: Susheel Bhanu BUSI
Affiliation: ESB group LCSB UniLU
Date: [2021-03-16]
Run: snakemake -s snakefile --use-conda --cores 72 -rp
Latest modification:
"""

import os, fnmatch
import glob
import pandas as pd

configfile:"config.yaml"
DATA_DIR=config['data_dir']
MAG_DIR=config['mag_dir']
RESULTS_DIR=config['results_dir']
ENV_DIR=config['env_dir']
SRC_DIR=config['scripts_dir']
SAMPLES=[line.strip() for line in open("mag_list", 'r')]    # if using a sample list instead of putting them in a config file

###########
rule all:
    input:
        os.path.join(RESULTS_DIR, "gRodon/gRodon.installed"),
        expand(os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}.{type}"), sample=SAMPLES, type=["gff", "ffn"]),
        expand(os.path.join(RESULTS_DIR, "gRodon/{sample}_growth_prediction.txt"), sample=SAMPLES),
        os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")

#################
# Initial Setup #
#################
rule install_gRodon:
    output:
        done=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    log:
        out="logs/setup.gRodon.log"
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    message:
        "Setup: install R-package gRodon"
    script:
        os.path.join(SRC_DIR, "install_gRodon.R")

##########
# Prokka #
##########
rule prokka:
    input:
        os.path.join(MAG_DIR, "{sample}.fna")
    output:
        GFF=os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}.gff"),
        FFN=os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}.ffn")
    log:
        "logs/prokka.{sample}.log"
    threads:
        config['prokka']['threads']
    conda:
        os.path.join(ENV_DIR, "prokka.yaml")
    message:
        "Running Prokka on {wildcards.sample}"
    shell:
        "(date && prokka --outdir $(dirname {output.GFF}) --prefix {wildcards.sample} {input} --cpus {threads} --force && date) &> {log}"

#################
# Preprocessing #
#################
rule preprocess:
    input:
        os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}.gff")
    output:
        os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}_CDS_names.txt")
    log:
        "logs/preprocess.{sample}.log"
    message:
        "Preprocessing GFFs from {wildcards.sample}"
    shell:
        """(date && sed -n '/##FASTA/q;p' {input} | awk '$3=="CDS"' | awk '{{print $9}}' | awk 'gsub(";.*","")' | awk 'gsub("ID=","")' > {output} && date) &> {log}"""

##################
# Running gRodon #
##################
rule gRodon:
    input:
        FFN=os.path.join(RESULTS_DIR, "prokka/{sample}/{sample}.ffn"),
        CDS=rules.preprocess.output,
        installed=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        PRED=os.path.join(RESULTS_DIR, "gRodon/{sample}_growth_prediction.txt")
    log:
        "logs/gRodon.{sample}.log"
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    message:
        "Growth prediction using gRodon for {wildcards.sample}"
    script:
        os.path.join(SRC_DIR, "gRodon.R")

rule merge_gRodon:
    input:
        PRED=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        DF=os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")
    log:
        "logs/gRodon.merged.log"
    conda:
        os.path.join(ENV_DIR, "r-conda.yaml")
    message:
        "Merging gRodon output for all samples"
    script:
        os.path.join(SRC_DIR, "merge_gRodon.R") 
