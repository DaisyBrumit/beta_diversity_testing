study=$1
cd ~/beta_diversity_testing_almost_final/${study}/HA

for i in {2..10}
do
  biom convert -i top_${i}_table.txt -o top_${i}_table.biom --table-type="OTU table" --to-hdf5
  qiime tools import --type 'FeatureTable[Frequency]' --input-path top_${i}_table.biom --output-path qiime/top_${i}_table.qza
done
