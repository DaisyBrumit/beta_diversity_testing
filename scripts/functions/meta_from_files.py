

def get_beta(file:str):
    # isolate the beta diversity method by slicing the filename
    string_elements = file.split('_')

    if file.endswith('distance_matrix.tsv') or file.endswith('fromBiplot.tsv'):
        string_elements = string_elements[:-2]  # remove last two items
    elif file.endswith('ordinations.tsv'):
        string_elements = string_elements[:-1] # remove "ordinations.tsv"
    else:
        string_elements = string_elements[:-3]  # remove "distance", "matrix", and "#.tsv"

    beta_method = "_".join(string_elements)  # rejoin remaining strings in the list
    return beta_method

def get_n_taxa(file:str):
    # isolate the beta diversity method by slicing the filename
    string_elements = file.split('_')

    # use an index to find "#.tsv" --> split into ['#','tsv'] --> and isolate '#'
    index = (len(string_elements) - 1)
    ntaxa = string_elements[index].split('.')[0]

    return ntaxa
