# This script is called after making insertion trees in Qiime2
# Tasks performed include:
# - filtering table and metadata by shared samples
# - removing zero sum data (empty samples)

def zero_sum_filter(table):
    # Remove samples with zero counts
    return table.loc[:, (table != 0).any(axis=0)]

def sample_filter(meta, table):
    shared_ids = set(table.columns) & set(meta.index)

    table = table.filter(shared_ids)
    meta = meta[meta.index.isin(shared_ids)]

    return [meta, table]

def gemelli_meta(meta):
    # THIS CODE IS USED IN GEMELLI'S BENCHMARKING
    # JUPYTER NOTEBOOK: CELL 2, BLOCK 2 "remove controls"
    # LINK HERE
    meta = meta[~meta.month.isin([0,15,19])]
    meta = meta[meta.mom_child == 'C']
    meta['host_subject_id_str'] = 'subject_' + meta['host_subject_id'].astype(int).astype(str)

    return meta

def main():
    import pandas as pd
    import sys

    # take args from bash script
    study = sys.argv[1]
    t_in_path = "~/beta_diversity_testing/" + study + "/filtered_table.txt"
    m_in_path = "~/beta_diversity_testing/" + study + "/meta.txt"

    t_out_path = "~/beta_diversity_testing/" + study + "/refiltered_table.txt"
    m_out_path = "~/beta_diversity_testing/" + study + "/refiltered_meta.txt"

    # clean up table
    table = pd.read_table(t_in_path, sep='\t', skiprows=1, index_col=0)
    table = zero_sum_filter(table)

    # address metadata if needed
    meta = pd.read_table(m_in_path, sep='\t', index_col=0)
    if study == "gemelli_ECAM":
        meta = gemelli_meta(meta)

    # filter on shared id's
    metaOut, tableOut = sample_filter(meta, table)

    metaOut.to_csv(m_out_path, sep='\t')
    tableOut.to_csv(t_out_path, sep='\t')

if __name__ == "__main__":
    main()
