# gRodon
Snakefile and scripts for running [gRodon](https://www.pnas.org/content/118/12/e2016810118.short?rss=1)
- Purpose: To determine maximal growth rates using **codon usage patterns (CUB)**
- Repo: https://github.com/jlw-ecoevo/gRodon2
- Vignette: https://jlw-ecoevo.github.io/gRodon-vignette
- Updated on: 2021-10-17

## Update notes
- Added rules for both prokaryote and eukaryotes growth rate prediction using CUB

- Usage: 
```
conda activate snakemake
snakemake -s snakefile --configfile config/config.yaml --use-conda --cores 32 -rp 
```

- Note:
  - Requires `snakemake >=5.32.0` to run
