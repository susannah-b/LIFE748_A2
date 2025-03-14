#!/bin/bash

# Alignment for E. coli data
# Note: this script is intended for a specific use case/folder setup for the data provided as part of UoL's LIFE748 module.
# Assumes that:
   # a conda environment exists called 'align' exists, and this contains mummer4
   # a conda environment exists called 'panaroo' which contains Python 3.9 and panaroo
   # The 'main folder' contains an 'assemblies' folder containg the assembled genomes
   # An EcoliK12 folder exists, containg the EcoliK12_GCA_000005845.2_ASM584v2_genomic.fna reference
   # You are working in WSL

# Set filepath for main folder
main_folder= # Set custom file path here

# File setup
cd "$main_folder"
mkdir alignment

# Align each with mummer
nucmer -p alignment/GN3_align EcoliK12/EcoliK12_GCA_000005845.2_ASM584v2_genomic.fna  assemblies/GN3_hifix_assembled.fasta
nucmer -p alignment/GN6_align EcoliK12/EcoliK12_GCA_000005845.2_ASM584v2_genomic.fna  assemblies/GN6_hifix_assembled.fasta
nucmer -p alignment/GN9_align EcoliK12/EcoliK12_GCA_000005845.2_ASM584v2_genomic.fna  assemblies/GN9_hifix_assembled.fasta

# Run dnadiff
mkdir alignment/dnadiff
dnadiff -p alignment/dnadiff/GN3_dnadiff -d alignment/GN3_align.delta
dnadiff -p alignment/dnadiff/GN6_dnadiff -d alignment/GN6_align.delta
dnadiff -p alignment/dnadiff/GN9_dnadiff -d alignment/GN9_align.delta

### Panaroo
# Setup
source ####/conda.sh # Source conda - set to custom location
conda activate panaroo

# Run panaroo
mkdir panarooresults
# Copy files over
cp prokka/GN3/*.gff panarooresults
cp prokka/GN6/*.gff panarooresults
cp prokka/GN9/*.gff panarooresults

panaroo -i panarooresults/GN3_hifix_assembled.gff panarooresults/GN3_hifix_assembled.gff panarooresults/GN3_hifix_assembled.gff -o panarooresults/output --clean-mode strict
