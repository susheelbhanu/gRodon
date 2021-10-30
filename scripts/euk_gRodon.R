#!/usr/bin/Rscript

# logging
sink(file=file(snakemake@log[[1]], open="wt"), type="message")

# Message about the run
print("Running gRodon on EUK mags")

# Running gRodon on MAGs
suppressMessages(library(Biostrings))
suppressMessages(library(coRdon))
suppressMessages(library(matrixStats))
library(gRodon)

# Load your *.ffn file and temperature values into R
genes <- readDNAStringSet(snakemake@input[["FFN"]])
temp <- as.numeric(snakemake@params[["TEMPERATURE"]])

# Subset your sequences to those that code for proteins
ribogenes <- readLines(snakemake@input[["CDS"]])

# Search for genes annotated as ribosomal proteins based on the BLAST output
highly_expressed <- names(genes) %in% ribogenes

# Since some MAGs are not very complete the Growth Prediction is run using "tryCatch"
# Example usage: https://statisticsglobe.com/using-trycatch-function-to-handle-errors-and-warnings-in-r
# Running growth prediction
pred_growth <- tryCatch({
    print("Running growth prediction")
    result <- predictGrowth(genes, highly_expressed, mode="eukaryote", temperature=temp)
}, error = function(e) {
    print("Creating empty file if errors are thrown")
    result <- NULL
})

# pred_growth <- predictGrowth(genes, highly_expressed, mode="eukaryote")

# Writing the output to file
if(!is.null(pred_growth)){ write.table(pred_growth, file = snakemake@output[["PRED"]], sep="\t", row.names=FALSE, quote=FALSE) } else { write.table(pred_growth, file = snakemake@output[["PRED"]], sep="\t", row.names=FALSE, quote=FALSE) }
