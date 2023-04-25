# script designed to take DADA2 reads as an input
# export fasta file as an output for taxonomic assignments

import pandas as pd
import sys
input = sys.argv[1]
outPath = sys.argv[2]

def makeFasta(inPath, outPath):
    table = pd.read_table(input)
    with open(outPath, 'w') as f:
        for colname in table.columns:
            f.write(">")
            f.write(colname)
            f.write("\n")
            f.write(colname)
            f.write("\n")

makeFasta(input,outPath)

nog = pd.read_table('/Users/dfrybrum/Documents/FodorLab/gemelli/Noguera-Julian/Noguera-Julian_ForwardReads_DADA2.txt', index_col=0)
