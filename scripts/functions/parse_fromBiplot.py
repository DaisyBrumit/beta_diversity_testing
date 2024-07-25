import pandas as pd
import re

def parse_ords(filepath):
    # create an empty dataframe for this ordination
    df = pd.DataFrame(columns=['PC1', 'PC2', 'PC3'])  # empty dataframe
    index = []  # list for index values

    # write will determine which lines are kept
    write = 0
    with open(filepath) as inFile:
        for line in inFile:

            # Only start storing data after 'Site' label
            if (write == 0) & line.startswith('Site'):
                write = 1

            elif write == 1:
                # write all Site PCs, stop before Biplot lines
                if line == '\n':
                    write = 0  # ignore lines after the "Site" block.
                else:
                    line = line.strip()  # remove newline character
                    entry = line.split("\t")  # split the string into PC1-3 values

                    index_value = re.sub(r'\.0$', '', entry[0]) # extract site value with no decimal
                    try:
                        index.append(int(index_value))  # save site value as index value
                    except:
                        index.append(index_value)
                    df = df._append(pd.Series(entry[1:4], index=df.columns), ignore_index=True)

            else:
                continue

    df.index = index  # add indices to finished dataframe
    return df