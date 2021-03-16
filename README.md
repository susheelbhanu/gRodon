# gRodon
Snakefile and scripts for running [gRodon](https://www.pnas.org/content/118/12/e2016810118.short?rss=1)
- Purpose: To determine maximal growth rates using **codon usage patterns**
- Repo: https://github.com/jlw-ecoevo/gRodon
- Vignette: https://jlw-ecoevo.github.io/gRodon-vignette

- Note: requires `Snakemake` to run
- Usage: 
```
conda activate snakemake
snakemake -s snakefile --use-conda --cores 32 -rp -k
```
- Note: if running with MAGs, some may have fewer genes and jobs may fail requiring the `-k` flag with snakemake
