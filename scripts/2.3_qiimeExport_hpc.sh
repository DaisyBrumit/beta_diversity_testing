#!/bin/bash
##SBATCH --partition=Orion
##SBATCH --time=00:30:00
##SBATCH --job-name=q2Export
##SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       #
# sbatch --output=slurm_out/2.3_studyname 2.3_qiimeExport_hpc.sh $1 $2 #
########################################################################

### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# cml inputs
study=$1
method=$2

# load module
module load qiime2/2021.2

### EXECUTE CODE: EXPORT QIIME ARTIFACTS ###
echo "Changing study to ~/beta_diversity_testing/${study}/qiime"
cd ~/beta_diversity_testing/${study}/qiime

echo ""
if [ ${method} == "ctf" ]
then
	# EXPORT CTF ORDINATION FILES
	echo "Exporting ctf state_subject_ordination.qza"
	qiime tools export \
		--input-path ctf_out/state_subject_ordination.qza \
		--output-path ../ordinations/

	mv ../ordinations/trajectory.tsv ../ordinations/ctf_ords_with_meta.tsv
	echo "ctf ordinations saved as ctf_ords_with_meta.tsv in ordinations dir"

	echo "Exporting ctf subject_biplot.qza"
	qiime tools export \
		--input-path ctf_out/subject_biplot.qza \
		--output-path ../ordinations

	mv ../ordinations/ordination.txt ../ordinations/ctf_ordinations_fromBiplot.tsv
	echo "ctf prop explained saved as ctf_ordinations_fromBiplot.tsv"

	# EXPORT PHYLO CTF ORDINATION FILES
	echo "Exporting phylo ctf state_subject_ordination.qza"
	qiime tools export \
		--input-path phylo_ctf_out/state_subject_ordination.qza \
		--output-path ../ordinations/

	mv ../ordinations/trajectory.tsv ../ordinations/phylo_ctf_ords_with_meta.tsv
	echo "phylo ctf ordinations saved as phylo_ctf_ords_with_meta.tsv"

	echo "Exporting phylo ctf subject_biplot.qza"
	qiime tools export \
		--input-path phylo_ctf_out/subject_biplot.qza \
		--output-path ../ordinations

	mv ../ordinations/ordination.txt ../ordinations/phylo_ctf_ordinations_fromBiplot.tsv
	echo "phylo_ctf prop explained saved as phylo_ctf_ordinations_fromBiplot.tsv"

	# EXPORT CTF & PHYLO CTF DISTANCE MATRICES
	echo "exporting ctf distance_matrix.qza"
	qiime tools export \
		--input-path ctf_out/distance_matrix.qza \
		--output-path ../distance_matrices
	mv ../distance_matrices/distance-matrix.tsv ../distance_matrices/ctf_distance_matrix.tsv
	echo "ctf distance matrix saved as ctf_distance_matrix.tsv"

	echo "exporting phylo ctf distance_matrix.qza"
	qiime tools export \
		--input-path phylo_ctf_out/distance_matrix.qza \
		--output-path ../distance_matrices

	mv ../distance_matrices/distance-matrix.tsv ../distance_matrices/phylo_ctf_distance_matrix.tsv
	echo "phylo_ctf distance matrix saved as phylo_ctf_distance_matrix.tsv"

else
	# EXPORT RPCA AND PHYLO RPCA DISTANCE MATRICES
	echo "Exporting rpca distance_matrix.qza"
        qiime tools export \
                --input-path rpca_out/distance_matrix.qza \
                --output-path ../distance_matrices

	mv ../distance_matrices/distance-matrix.tsv ../distance_matrices/rpca_distance_matrix.tsv
        echo "rpca distance matrix saved as rpca_distance_matrix.tsv"

	echo "Exporting phylo rpca distance_matrix.qza"
        qiime tools export \
                --input-path phylo_rpca_out/distance_matrix.qza \
                --output-path ../distance_matrices

	mv ../distance_matrices/distance-matrix.tsv ../distance_matrices/phylo_rpca_distance_matrix.tsv
        echo "phylo rpca distance matrix saved as phylo_rpca_distance_matrix.tsv"

	# EXPORT RPCA AND PHYLO RPCA ORDINATIONS
	echo "Exporting rpca biplot.qza"
        qiime tools export \
                --input-path rpca_out/biplot.qza \
                --output-path ../ordinations

	mv ../ordinations/ordination.txt ../ordinations/rpca_ordinations_fromBiplot.tsv
        echo "rpca ordinations saved as rpca_ordinations_fromBiplot.tsv"

	echo "Exporting phylo rpca biplot.qza"
        qiime tools export \
                --input-path phylo_rpca_out/biplot.qza \
                --output-path ../ordinations

	mv ../ordinations/ordination.txt ../ordinations/phylo_rpca_ordinations_fromBiplot.tsv
        echo "phylo rpca ordinations saved as rpca_ordinations_fromBiplot.tsv"
	
fi

echo "SCRIPT COMPLETE"

### REPORT JOB METRICS ###
# record end time
#end_time=$(date +"%Y-%m-%d %H:%M:%S")

# Calculate total runtime
#start_seconds=$(date -d "$start_time" +"%s")
#end_seconds=$(date -d "$end_time" +"%s")
#total_seconds=$((end_seconds - start_seconds))

# Convert total_seconds to HH:MM:SS format
#total_runtime=$(date -u -d @$total_seconds +"%T")

# Print metrics
#echo ""
#echo "Start Time: $start_time"
#echo "End Time: $end_time"
#echo "Total Runtime: $total_runtime"
#echo "Memory Usage as per sstat:"
#sstat -j $SLURM_JOBID --all