# script designed to take gemelli qiime tables as input
# export pcoa table as an output in line with existing format

import pandas as pd
import os

studyList = ['gemelli_ECAM', 'Jones', 'Noguera-Julian', 'Vangay', 'Zeller']

for study in studyList:
    # save dir prefix for ease later
    rootdir = '/Users/dfrybrum/beta_diversity_testing/' + study + '/'

    for root, dirs, files, in os.walk(rootdir+'qiime/'):
        # look at each individual file
        for file in files:
            # if the file is an ordination output
            if file == 'ordination.txt':

                # which gemelli output are we looking at?
                methodList = root.split('/')[6].split('_')[:-1]
                method = '_'.join(methodList)
                print(study + ' ' + method) # sanity check

                # create an empty dataframe for this ordination
                dfOut = pd.DataFrame(columns=['PC1', 'PC2', 'PC3']) # empty dataframe
                index = [] # list for index values

                # write will determine which lines are kept
                write = 0
                with open(root + '/' + file, 'r') as inFile:
                    for line in inFile:

                        # Proportion line has fewer fields than Site lines, treat separately
                        if (write==0) & line.startswith('Proportion'):
                            write = 1
                        elif (write ==0) & line.startswith('Site'):
                            write = 2

                        # save the proportion line and create an index label
                        elif write == 1:
                            line = line.strip() # remove newline character
                            entry = line.split("\t") # split the string into PC1-3 values
                            dfOut = dfOut._append(pd.Series(entry, index=dfOut.columns), ignore_index=True)

                            index.append("PropExplained")
                            write=0 # reset "write" code. go back to ignoring lines

                        # write all Site PCs, stop before Biplot lines
                        elif (write == 2):
                            if line == '\n':
                                write = 0 # ignore lines after the "Site" block.
                            else:
                                line = line.strip() # remove newline character
                                entry = line.split("\t") # split the string into PC1-3 values

                                index.append(entry[0]) # save index value
                                dfOut = dfOut._append(pd.Series(entry[1:4], index=dfOut.columns), ignore_index=True)
                        else:
                            continue

                dfOut.index = index # add indices to finished dataframe
                dfOut.to_csv(rootdir + 'ordinations/' + method + '_ordinations.tsv', sep='\t', index=True)

print('Beam me up, Scotty!')