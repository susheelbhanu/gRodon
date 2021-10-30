# Rules to run gRodon on eukaryote MAGs


#########################
# Dependencies
import os, fnmatch
import glob
import pandas as pd

###########
rule eukaryotes:
    input:
        os.path.join(RESULTS_DIR, "euk_gRodon/gRodon2_euk.installed"),
        expand(os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.{type}"), eukaryote=EUKS, type=["gff", "codon.fas", "fas"]),
        expand(os.path.join(RESULTS_DIR, "blast/{eukaryote}/{eukaryote}.riboprot"), eukaryote=EUKS),
        expand(os.path.join(RESULTS_DIR, "euk_gRodon/{eukaryote}_growth_prediction.txt"), eukaryote=EUKS),
        os.path.join(RESULTS_DIR, "euk_gRodon/merged_EUK_growth_prediction.txt")
    output:
        touch("status/eukaryotes.done")

#################
# Initial Setup #
#################
rule install_gRodon_euk:
    output:
        done=os.path.join(RESULTS_DIR, "euk_gRodon/gRodon2_euk.installed")
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
        os.path.join(EUK_DIR, "{eukaryote}.fa")
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
        "(date && metaeuk easy-predict {params.flags} {input} {params.DB} $(dirname {output.GFF})/{wildcards.eukaryote} tmp && date) &> {log}"


#################
# Preprocessing #
#################
rule blast:
    input:
        os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.fas")
    output:
        blast=os.path.join(RESULTS_DIR, "blast/{eukaryote}/{eukaryote}.riboblast"),
        prot=os.path.join(RESULTS_DIR, "blast/{eukaryote}/{eukaryote}.riboprot")
    log:
        os.path.join(RESULTS_DIR, "logs/blast.{eukaryote}.log") 
    wildcard_constraints:
        eukaryote="|".join(EUKS)
    conda:
        os.path.join(ENV_DIR, "blast.yaml")
    threads:
        config['blast']['threads']
    params:
        DB=config['blast']['db_path'],
        FMT=config['blast']['outfmt']
    message:
        "Running BLAST using the ribosomal database on {wildcards.eukaryote}"
    shell:
        "(date && blastp -db {params.DB} -query {input} -num_threads {threads} -outfmt {params.FMT} -out {output.blast} && "
        "awk '$11<1e-10' {output.blast} | awk '{{print $1}}' | sort | uniq > {output.prot} && date) &> {log}"

##############
# Running gRodon #
##################
rule euk_gRodon:
    input:
        FFN=os.path.join(RESULTS_DIR, "metaeuk/{eukaryote}/{eukaryote}.codon.fas"),
        CDS=rules.blast.output.prot,
        installed=os.path.join(RESULTS_DIR, "euk_gRodon/gRodon2_euk.installed")
    output:
        PRED=os.path.join(RESULTS_DIR, "euk_gRodon/{eukaryote}_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.{eukaryote}.log")
    conda:
        os.path.join(ENV_DIR, "gRodon.yaml")
    wildcard_constraints:
        eukaryote="|".join(EUKS)
    params:
        TEMPERATURE=config['gRodon']['temperature']
    message:
        "Growth prediction using gRodon for {wildcards.eukaryote}"
    script:
        os.path.join(SRC_DIR, "euk_gRodon.R")

rule euk_merge_gRodon:
    output:
        DF=os.path.join(RESULTS_DIR, "euk_gRodon/merged_EUK_growth_prediction.txt")
    log:
        os.path.join(RESULTS_DIR, "logs/gRodon.merged.log")
    conda:
        os.path.join(ENV_DIR, "r-conda.yaml")
    message:
        "Merging gRodon output for all eukaryotes"
    script:
        os.path.join(SRC_DIR, "merge_gRodon.R") 