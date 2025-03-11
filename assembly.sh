#!/bin/bash

# Assembly script for E coli samples
# Note: this script is intended for a specific use case/folder setup for the data provided as part of UoL's LIFE748 module.
# Assumes that:
   # a conda environment exists called genomics_env exists, and this contains:
      # fastqc
      # flye
      # quast
   # The 'main folder' contains a '/raw' folder containing E coli read files
   # You are working in WSL



# Set filepath for main folder
main_folder=# Set custom file path here

rm -rf "$main_folder/assemblies" # Remove if preexisting
mkdir -p "$main_folder/assemblies" # To store assemblies

cd "$main_folder/raw" # To find raw files

# Activate conda environment
source ####/conda.sh # Source conda - set to custom location
conda activate genomics_env  || { echo "Failed to activate Conda environment"; exit 1; }

# Run fastqc on read file
fastqc GN3_hifix30.fastq
fastqc GN6_hifix30.fastq
fastqc GN9_hifix30.fastq

# Flye assembly
flye --pacbio-hifi GN3_hifix30.fastq --out-dir GN3_hifix_assembled
flye --pacbio-hifi GN6_hifix30.fastq --out-dir GN6_hifix_assembled
flye --pacbio-hifi GN9_hifix30.fastq --out-dir GN9_hifix_assembled

# Move and rename assembled files
for sample in GN3_hifix_assembled GN6_hifix_assembled GN9_hifix_assembled; do
    # Check if the assembly file exists
    if [ -f "$sample/assembly.fasta" ]; then
        # Rename the assembly file
        mv "$sample/assembly.fasta" "$sample/${sample}.fasta"
        
        # Move the renamed file to the assemblies folder
        mv "$sample/${sample}.fasta" "$main_folder/assemblies/"
    else
        echo "Warning: assembly.fasta not found in $sample"
    fi
done

cd ../
cd assemblies

# Run quast
mkdir -p quast_output
quast.py ./*.fasta -o quast_output