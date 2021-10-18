# Rules to run gRodon on eukaryote MAGs


#########################
# Dependencies
import os, fnmatch
import glob
import pandas as pd


###########
rule eukaryotes:
    input:
        os.path.join(RESULTS_DIR, "gRodon/gRodon2.installed"),
        expand(os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.{type}"), eukaryote=PROKS, type=["gff", ".codon.fas", "fas"]),
        expand(os.path.join(RESULTS_DIR, "gRodon/{eukaryote}_growth_prediction.txt"), eukaryote=PROKS),
        os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")
    output:
        touch("status/eukaryotes.done")


#################
# Initial Setup #
#################
rule install_gRodon_euk:
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

###########
# MetaEUK #
###########
rule metaeuk:
    input:
        os.path.join(EUK_DIR, "{eukaryote}.fna")
    output:
        GFF=os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.gff"),
        FNA=os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.codon.fas"),
        FAS=os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.fas")
    log:
        os.path.join(RESULTS_DIR, "logs/metaeuk.{eukaryote}.log")
    threads:
        config['metaeuk']['threads']
    conda:
        os.path.join(ENV_DIR, "metaeuk.yaml")
    wildcard_constraints:
        eukaryote="|".join(EUKS)
    params:
        DB=config['metaeuk']['db_path'],
        flags="-e 100 --metaeuk-eval 0.0001 --min-ungapped-score 35 --min-exon-aa 20 --metaeuk-tcov 0.6 --min-length 40 --disk-space-limit 200G"
    message:
        "Running MetaEUK on {wildcards.eukaryote}"
    shell:
        "(date && metaeuk easy-predict {params.flags} {input} {params.DB} $(dirname {output.GFF})/{wildcards.eukaryotes} tmp && date) &> {log}"

#################
# Preprocessing #
#################
rule preprocess_euk:
    input:
        os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.gff")
    output:
        os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}_CDS_names.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/preprocess.{eukaryote}.log")
    wildcard_constraints:
        eukaryote="|".join(EUKS)
    message:
        "Preprocessing GFFs from {wildcards.eukaryote}"
    shell:
        """(date && sed -n '/##FASTA/q;p' {input} | awk '$3=="CDS"' | awk '{{print $9}}' | awk 'gsub(";.*","")' | awk 'gsub("ID=","")' > {output} && date) &> {log}"""

##################
# Running gRodon #
##################
rule euk_gRodon:
    input:
        FFN=os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.ffn"),
        CDS=rules.preprocess.output,
        installed=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        PRED=os.path.join(RESULTS_DIR, "gRodon/{eukaryote}_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.{eukaryote}.log")
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    wildcard_constraints:
        eukaryote="|".join(EUKS)
    message:
        "Growth prediction using gRodon for {wildcards.eukaryote}"
    script:
        os.path.join(SRC_DIR, "euk_gRodon.R")

rule merge_gRodon_euk:
    input:
        PRED=os.path.join(RESULTS_DIR, "gRodon/gRodon.installed")
    output:
        DF=os.path.join(RESULTS_DIR, "gRodon/merged_all_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.merged.log")
    conda:
        os.path.join(ENV_DIR, "r-conda.yaml")
    message:
        "Merging gRodon output for all eukaryotes"
    script:
        os.path.join(SRC_DIR, "merge_gRodon.R") 
