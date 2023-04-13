#############################################################################
# RESOLVING METADATA GAPS VIA SRA/BIOPROJECT INFORMATION
# AUTHOR: DAISY FRY BRUMIT
#############################################################################
# script intended for resolving subject ID assignment in Jones dataset by
# parsing a BioProject collection file
# retaining sample identifiers and subject identifiers
# creating a subject-to-sample map for a target metadata file
#
# This should enable repeated measures grouping in gemelli phylo-CTF protocol
#############################################################################
import pandas as pd

def sra_parser(path):
    # initialize variables
    map = {}
    sampleID = ''
    studyID = ''

    with open(path, 'r') as f:
        for line in f.readlines():
            strip = line.strip() # strip newline characters

            # generate sample ID (per observation ID)
            if strip.startswith("Identifiers:"):
                split = strip.split()
                sampleID = split[5]

            # generate study ID (per subject ID)
            elif strip.startswith("/study_id"):
                split = strip.split('\"')
                print(split)
                studyID = split[1]

            # if both ID values are present...
            if (sampleID and studyID != ''):
                map[sampleID] += studyID # add them to the map
                # (using ^^^ unique IDs as keys so I don't have to append unique values to a shared key)

                # reset ID values so only corresponding pairs are mapped to each other
                sampleID = ''
                studyID = ''
        return map

map = sra_parser('/Users/dfrybrum/Downloads/biosample_result.txt')

print('Beam me up, Scotty!')