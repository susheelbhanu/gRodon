# Rules to run gRodon on prokaryote MAGs


#########################
# Dependencies
import os, fnmatch
import glob
import pandas as pd


###########
rule prokaryotes:
    input:
        os.path.join(RESULTS_DIR, "gRodon/gRodon2.installed"),
        expand(os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}.{type}"), prokaryote=PROKS, type=["gff", "ffn"]),
        expand(os.path.join(RESULTS_DIR, "gRodon/{prokaryote}_growth_prediction.txt"), prokaryote=PROKS),
        os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")
    output:
        touch("status/prokaryotes.done")


#################
# Initial Setup #
#################
rule install_gRodon:
    output:
        done=os.path.join(RESULTS_DIR, "gRodon/gRodon2.installed")
    log:
        out=os.path.join(RESULTS_DIR, "logs/setup.gRodon.log")
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    message:
        "Setup: install R-package gRodon2, i.e. version2"
    script:
        os.path.join(SRC_DIR, "install_gRodon.R")

##########
# Prokka #
##########
rule prokka:
    input:
        os.path.join(MAG_DIR, "{prokaryote}.fna")
    output:
        GFF=os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}.gff"),
        FFN=os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}.ffn")
    log:
        os.path.join(RESULTS_DIR, "logs/prokka.{prokaryote}.log")
    threads:
        config['prokka']['threads']
    conda:
        os.path.join(ENV_DIR, "prokka.yaml")
    wildcard_constraints:
        prokaryote="|".join(PROKS)
    message:
        "Running Prokka on {wildcards.prokaryote}"
    shell:
        "(date && prokka --outdir $(dirname {output.GFF}) --prefix {wildcards.prokaryote} {input} --cpus {threads} --force && date) &> {log}"

#################
# Preprocessing #
#################
rule preprocess:
    input:
        os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}.gff")
    output:
        os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}_CDS_names.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/preprocess.{prokaryote}.log")
    wildcard_constraints:
        prokaryote="|".join(PROKS)
    message:
        "Preprocessing GFFs from {wildcards.prokaryote}"
    shell:
        """(date && sed -n '/##FASTA/q;p' {input} | awk '$3=="CDS"' | awk '{{print $9}}' | awk 'gsub(";.*","")' | awk 'gsub("ID=","")' > {output} && date) &> {log}"""

##################
# Running gRodon #
##################
rule gRodon:
    input:
        FFN=os.path.join(RESULTS_DIR, "prokka/{prokaryote}/{prokaryote}.ffn"),
        CDS=rules.preprocess.output,
        installed=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        PRED=os.path.join(RESULTS_DIR, "gRodon/{prokaryote}_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.{prokaryote}.log")
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    wildcard_constraints:
        prokaryote="|".join(PROKS)
    message:
        "Growth prediction using gRodon for {wildcards.prokaryote}"
    script:
        os.path.join(SRC_DIR, "gRodon.R")

rule merge_gRodon:
    input:
        PRED=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        DF=os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.merged.log")
    conda:
        os.path.join(ENV_DIR, "r-conda.yaml")
    message:
        "Merging gRodon output for all prokaryotes"
    script:
        os.path.join(SRC_DIR, "merge_gRodon.R") 
