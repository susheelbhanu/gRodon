# gRodon
Snakefile and scripts for running [gRodon](https://www.pnas.org/content/118/12/e2016810118.short?rss=1)
- Purpose: To determine maximal growth rates using **codon usage patterns**
- Repo: https://github.com/jlw-ecoevo/gRodon
- Vignette: https://jlw-ecoevo.github.io/gRodon-vignette

- Usage: 
```
conda activate snakemake
snakemake -s snakefile --use-conda --cores 32 -rp 
```

- Note:
  - Requires `snakemake >=5.32.0` to run
