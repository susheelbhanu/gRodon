# gRodon
Snakefile and scripts for running [gRodon](https://www.pnas.org/content/118/12/e2016810118.short?rss=1)
- Purpose: To determine maximal growth rates using **codon usage patterns**
- Repo: https://github.com/jlw-ecoevo/gRodon
- Vignette: https://jlw-ecoevo.github.io/gRodon-vignette

- Usage: 
```
conda activate snakemake
snakemake -s snakefile --use-conda --cores 32 -rp -k
```

- Note:
  - Requires `snakemake >=5.32.0` to run
  - When running with MAGs, some may have fewer genes and jobs may fail requiring the `-k` flag with snakemake
