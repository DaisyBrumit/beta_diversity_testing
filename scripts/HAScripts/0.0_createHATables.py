import pandas as pd

studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'ECAM']
taxaCount = [2,3,4,5,6,7,8,9,10] # want tables with top N most abundant taxa ONLY

for study in studyList:
    for i in taxaCount:
        fileIn = '~/beta_diversity_testing_almost_final/'+study+'/filtered_table.txt'
        fileOut = '~/beta_diversity_testing_almost_final/'+study+'/HA/top_'+str(i)+'_table.txt'

        table = pd.read_table(fileIn, delimiter='\t', index_col=0, skiprows=[0]).T

        # Calculate column sums
        sum_table = table.sum()

        # Sort the columns by their sums in descending order
        sorted_table = sum_table.sort_values(ascending=False)

        # Select the top i columns with the highest sums
        top_taxa = sorted_table.head(i).index

        # Keep only the top i columns in the original DataFrame
        tableOut = table[top_taxa].T

        tableOut.to_csv(fileOut, sep='\t', index=True)
        print("beam me up, scotty!")
