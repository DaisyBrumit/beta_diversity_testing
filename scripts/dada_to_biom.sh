#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=0:10:00
#SBATCH --job-name=dada2biom

biom convert -i Jones/Jones_ForwardReads_DADA2.txt -o Jones/dada2_forward_reads.biom --table-type="OTU table" --to-hdf5

biom convert -i Vangay/Vangay_ForwardReads_DADA2.txt -o Vangay/dada2_forward_reads.biom --table-type="OTU table" --to-hdf5

biom convert -i Zeller/Zeller_ForwardReads_DADA2.txt -o Zeller/dada2_forward_reads.biom --table-type="OTU table" --to-hdf5

biom convert -i Noguera-Julian/Noguera-Julian_ForwardReads_DADA2.txt -o Noguera-Julian/dada2_forward_reads.biom --table-type="OTU table" --to-hdf5
