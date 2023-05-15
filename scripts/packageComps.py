# apply ml to ordinations and aggregate data
import randForest as rf
import pandas as pd
import os # for walking through directory

rootdir = '/Users/dfrybrum/Documents/FodorLab/gemelli/' # reference directory where ALL files are stored
studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian'] # study names, also subdirs for rootdir
gemelliList = ['ctf', 'rpca', 'phylo'] # list of gemelli prefixes, data need to be read in differently

for study in studyList:
    # load in metadata
    meta = pd.read_table(rootdir+study+'/meta.txt', index_col=0) # look for meta.txt in all study subdirs of the root dir

    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # walk through all files under rootdir
    for root, dirs, files, in os.walk(rootdir+study+'/'):
        # look at each individual file
        for file in files:
            # if file is an ordination textfile...
            if file.endswith('ordination.txt'):
                # isolate the beta diversity method by slicing the filename
                # this will serve as an identifier in final dataframes
                string_elements = file.split("_")
                #string_elements = string_elements[:-3] # remove pcoa, results, ord.txt
                beta_method = "_".join(string_elements) # now we can ID our current method

                # read in the appropriate data file and get qual and quant RF output
                if string_elements[0] not in gemelliList:
                    dat = pd.read_table(rootdir + study + '/' + file, skiprows=range(0, 11), header=None, index_col=0)
                else:
                    dat = pd.read_table(rootdir+study+'/'+file, skiprows=range(0,9), header=None, index_col=0)
                    dat = dat.T

                catRF = rf.qualitativeRF(meta, dat)
                quantRF = rf.quantitativeRF(meta, dat)

                # expand dictionary contents
                acc_expand = pd.DataFrame(catRF[0]) # 0 == dictionary w/ accuracy scores to features
                roc_expand = pd.DataFrame(catRF[1]) # 1 == {roc_auc scores : features}
                r2_expand = pd.DataFrame(quantRF[0]) # 0 == {r2 scores : features}

                length = len(acc_expand) # all 'expand' lists should == 100, but just in case RF iterations change later...
                method_expand = pd.DataFrame({'method':[beta_method] * length})

                    # append contents to dataframes
                acc_merge = method_expand.join(acc_expand)
                roc_merge = method_expand.join(roc_expand)
                r2_merge = method_expand.join(r2_expand)

                accuracy_df = accuracy_df.append(acc_merge, ignore_index=True)
                roc_df = roc_df.append(roc_merge, ignore_index=True)
                r2_df = r2_df.append(r2_merge, ignore_index=True)

            elif file.endswith('distance_matrix.tsv'):
                pass

    # print the collection of scores for every method associated with this study in the study's directory
    accuracy_df.to_csv(rootdir + study + '/Gaccuracy_table.txt', sep='\t', index=False)
    roc_df.to_csv(rootdir + study + '/Groc_auc_table.txt', sep='\t', index=False)
    r2_df.to_csv(rootdir + study + '/Gr2_table.txt', sep='\t', index=False)

print("Beam me up, Scotty!")


