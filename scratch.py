# scratch file: start by assessing jones data dimensions between Aaron and Jone's data

import pandas as pd
import DADA_to_fasta
import numpy as np
import re

# Ytable = pd.read_table('~/Downloads/Daisy_16S/Jones_ForwardReads_DADA2.txt', index_col=None)
# Ymeta = pd.read_csv('jones/jones_meta.csv')
# JtableNoTax = pd.read_table('/Users/dfrybrum/Documents/GitHub/swabVsStool/data/otu_table_withouttax.txt', index_col=None)
# JtableTax = pd.read_table('/Users/dfrybrum/Documents/GitHub/swabVsStool/data/otu_table_wtax.txt', index_col=None)

# DADA_to_fasta.makeFasta('jones/Jones_ForwardReads_DADA2.txt', 'jones/Jones_DADA2_toFasta.fa')

# table = pd.read_table('~/Documents/FodorLab/gemelli/Jones/freqTable_grouped.txt', sep='\t')
# table = table.reset_index()
# table.columns = table.iloc[0,:]
# table = table.iloc[1:,:]

# taxa = pd.read_table('~/Documents/FodorLab/gg_13_8_otus/taxonomy/99_otu_taxonomy.txt', sep='\t', header=None)

# THIS DOES NOT WORK AS INTENDED: SOME TAXA DO NOT GET MAPPED TO OTU IDs
# dict = dict(zip(taxa[1], taxa[0]))
# table['#OTU ID'] = table['#OTU ID'].replace(dict)

# with open('~/Documents/FodorLab/gg_13_8_otus/trees/99_otus.tree')
# for key in otu_dict:
#    if key == 'k__Bacteria; p__Firmicutes; c__Clostridia; o__Clostridiales':
#        print('taxon found')

# table.iloc[0,0] = 'Taxon'

dict = {}  # initialize dictionary

# open the target fasta file for reading
with open('/Users/dfrybrum/Documents/FodorLab/gg_13_8_otus/rep_set/99_otus.fasta', 'r') as file:
    # initialize sequence and header as empty strings
    header = ''
    seq = ''

    # loop line by line
    for line in file:
        # ID headers by >
        if line.startswith('>'):
            header = line.strip()  # strip for newline formatting
            header = header.strip('>')
        # If line != header, it must be a sequence
        else:
            if header:
                seq = line.strip()
                dict[header] = seq

dict = {'A': '1', 'B': '2', 'C': '3', 'D': '4', 'E': '5', 'F': '6', 'G': '7', 'H': '8',
        'I': '9', 'J': '10', 'K': '11', 'L': '12', 'M': '13', 'N': '14', 'O': '15',
        'P': '16', 'Q': '17', 'R': '18', 'S': '19', 'T': '20', 'U': '21', 'V': '22',
        'W': '23', 'X': '24', 'Y': '25', 'Z': '26', 'a': '27', 'b': '28', 'c': '29',
        'd': '30', 'e': '31', 'f': '32', 'g': '33', 'h': '34', 'i': '35', 'j': '36'}


def newick_parser(filepath):
    # start by getting a simple string of the full file
    with open(filepath, 'r') as f:
        for line in f:
            print(line)
            newick_string = line.strip()

    # subset the string into nodes, subset by level of nesting
    nested_parentheses = []
    level = 0
    for i, char in enumerate(newick_string):
        if char == '(':
            if level == 0:
                nested_parentheses.append('')
            nested_parentheses[-1] += char
            level += 1
        elif char == ')':
            nested_parentheses[-1] += char
            level -= 1
        else:
            nested_parentheses[-1] += char

    # define function to recursively traverse nested sets of parentheses and extract node names
    def extract_node_names(nested_set):
        node_names = []
        for node in nested_set.split(','):
            if '(' in node:
                node_names += extract_node_names(node.strip('('))
            elif ';' in node:
                node_names += extract_node_names(node.strip(';'))
            elif ')' in node:
                node_names += extract_node_names(node.strip(')'))
            else:
                node_names.append(node.strip(';'))
        return node_names

    # extract node names from nested sets of parentheses
    all_node_names = []
    for nested_set in nested_parentheses:
        all_node_names += extract_node_names(nested_set)

    # return list of unique node names
    for i,name in enumerate(all_node_names):
        if name is in dict.keys():



# define function to rename node names in Newick file
def rename_newick_nodes(filename, name_dict):
    # open file and read in data
    with open(filename, 'r') as f:
        newick_string = f.read().strip()

    # define function to recursively traverse nested sets of parentheses and replace node names with new names
    def replace_node_names(nested_set):
        for old_name, new_name in name_dict.items():
            nested_set = nested_set.replace(old_name, new_name)
        return nested_set

    # replace node names with new names
    newick_string = replace_node_names(newick_string)

    # return modified newick string
    return newick_string


# define function to write modified Newick file
def write_newick_file(filename, newick_string):
    # open file and write out modified newick string
    with open(filename, 'w') as f:
        f.write(newick_string)


node_names = newick_parser('/Users/dfrybrum/Downloads/sampleTree.tree')

print('Beam me up, Scotty!')
