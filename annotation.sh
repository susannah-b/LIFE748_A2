#!/bin/bash

# Assembly script for E coli samples
# Note: this script is intended for a specific use case/folder setup for the data provided as part of UoL's LIFE748 module.
# Assumes that:
   # There are three conda environments called bakta, prokka, and artemis, with the corresponding python modules installed
   # The 'main folder' contains a 'raw' folder containing E coli read files
   # You are working in WSL
   # In the $main_folder/bakta, have run 'bakta_db download --output ~/tmp_data/ --type light'


# Set filepath for main folder
main_folder= ###### Set custom file path here

# Activate conda environment
source #####conda.sh # Source conda - set to custom location
conda activate bakta || { echo "Failed to activate Conda environment"; exit 1; }

# Run bakta
bakta --db ./bakta/tmp_data/db-light ./assemblies/GN3_hifix_assembled.fasta --output ./bakta/GN3
bakta --db ./bakta/tmp_data/db-light ./assemblies/GN6_hifix_assembled.fasta --output ./bakta/GN6
bakta --db ./bakta/tmp_data/db-light ./assemblies/GN9_hifix_assembled.fasta --output ./bakta/GN9

# Run prokka for comparison
mkdir -p "$main_folder/prokka"
conda activate prokka || { echo "Failed to activate Conda environment"; exit 1; }
prokka --outdir ./prokka/GN3 --prefix GN3_hifix_assembled --genus Escherichia --species coli ./assemblies/GN3_hifix_assembled.fasta
prokka --outdir ./prokka/GN6 --prefix GN6_hifix_assembled --genus Escherichia --species coli ./assemblies/GN6_hifix_assembled.fasta
prokka --outdir ./prokka/GN9 --prefix GN9_hifix_assembled --genus Escherichia --species coli ./assemblies/GN9_hifix_assembled.fasta

# To compare in Artemis -- not run as part of the script but left in as an example for manual investigation
#conda activate artemis || { echo "Failed to activate Conda environment"; exit 1; }
#art ./bakta/GN3/GN3_hifix_assembled.embl ./prokka/GN3/GN3_hifix_assembled.gbk
#art ./bakta/GN3/GN6_hifix_assembled.embl ./prokka/GN3/GN6_hifix_assembled.gbk
#art ./bakta/GN3/GN9_hifix_assembled.embl ./prokka/GN3/GN9_hifix_assembled.gbk
