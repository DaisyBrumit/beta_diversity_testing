# apply ml to ordinations and aggregate data
import pandas as pd

studyList = ['Jones', 'Zeller', 'Vangay', 'Noguera-Julian']


for study in studyList:
    # load in metadata
    meta = pd.read_table('/Users/dfrybrum/Documents/FodorLab/',study,'/meta.txt')

    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    for 

