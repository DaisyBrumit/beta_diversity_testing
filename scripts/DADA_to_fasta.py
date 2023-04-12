# script designed to take DADA2 reads as an input
# export fasta file as an output for taxonomic assignments

import pandas as pd

def makeFasta(inPath, outPath):
    table = pd.read_table(inPath)
    with open(outPath, 'w') as f:
        for colname in table.columns:
            f.write(">")
            f.write(colname)
            f.write("\n")
            f.write(colname)
            f.write("\n")