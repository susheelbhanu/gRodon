# gRodon
Snakefile and scripts for running [gRodon](https://www.pnas.org/content/118/12/e2016810118.short?rss=1)
- Purpose: To determine maximal growth rates using **codon usage patterns (CUB)**
- Repo: https://github.com/jlw-ecoevo/gRodon2
- Vignette: https://jlw-ecoevo.github.io/gRodon-vignette
- Updated on: 2021-10-31


## Update notes
- Created two running modes: `prokaryotes` and `eukaryotes`
- Added rules for both prokaryote and eukaryotes growth rate prediction using CUB


## Usage: 
- Edit the `config/config.yaml` file to specify the `steps`, i.e. running mode
- Example: `["prokaryotes", "eukaryotes"]`
```
conda activate snakemake
snakemake -s Snakefile --configfile config/config.yaml --use-conda --cores 32 -rp 
```

- Notes:
  - Requires `snakemake >=5.32.0` to run
  - Update the following files prior to running
    - `config/config.yaml`: adjust paths for the individual directories
    - `data/prokaryotes.txt`: filenames for Prokaryote MAGs without the extension (eg: .fa or .fasta or .fna)
    - `data/eukaryotes.txt`: filenames for Eukaryote MAGs without the extension (eg: .fa or .fasta or .fna)
