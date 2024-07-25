# script designed to take DADA2 reads as an input
# export fasta file as an output for taxonomic assignments

import pandas as pd
import sys
input = sys.argv[1]
outPath = sys.argv[2]
def makeFasta(input, outPath):
    table = pd.read_table(input, index_col=0)
    with open(outPath, 'w') as f:
        for seq in table.index:
            f.write(">")
            f.write(seq)
            f.write("\n")
            f.write(seq)
            f.write("\n")

makeFasta(input,outPath)
