#!/bin/bash

# =============================================================================
# nf-core/rnaseq Pipeline Script for S3-based RNA-seq Analysis
# =============================================================================
#
# This script runs the nf-core/rnaseq pipeline with S3 input/output support.
# It's configured for paired-end RNA-seq data analysis with comprehensive QC.
#
# Features:
# - HISAT2 alignment with insert size metrics
# - RNA biotype analysis and quantification
# - Salmon pseudo-alignment
# - FeatureCounts quantification
# - Comprehensive quality control
# - S3 storage integration
#
# Requirements:
# - Nextflow (22.10.x or later, or use DSL2)
# - Docker
# - AWS CLI configured with S3 access
# - Input CSV file with sample information
#
# Usage:
#   bash script.sh
#
# Configuration:
#   Edit the S3_OUTPUT_DIR variable below to match your S3 bucket
#   Modify resource limits (CPU, memory, time) as needed
#   Adjust pipeline parameters based on your analysis needs
#
# Author: [Your Name]
# Date: [Current Date]
# =============================================================================

# Configuration - Edit these variables as needed
S3_OUTPUT_DIR="s3://covaris-nextseq-data/20250730_RNASeq/KT_nfcore_Analysis/No_subsample/"
INPUT_CSV="spreadsheet_nfcore_RNASeq_073125.csv"
GENOME="GRCh38"
MAX_CPUS=8
MAX_MEMORY="16.GB"
MAX_TIME="72.h"

# Error handling
set -e
trap 'echo "Error occurred. Check the logs above." >&2' ERR

# Check if required files exist
if [[ ! -f "$INPUT_CSV" ]]; then
    echo "Error: Input CSV file '$INPUT_CSV' not found!"
    echo "Please ensure the file exists in the current directory."
    exit 1
fi

echo "=== nf-core/rnaseq with S3 input and output ==="
echo "Input file: $INPUT_CSV"
echo "Output directory: $S3_OUTPUT_DIR"
echo "Genome: $GENOME"
echo "Resource limits: ${MAX_CPUS} CPUs, ${MAX_MEMORY}, ${MAX_TIME}"
echo ""

echo "2. Running nf-core/rnaseq with S3 input and output..."
nextflow run nf-core/rnaseq \
    --input "$INPUT_CSV" \
    --outdir "$S3_OUTPUT_DIR" \
    --genome "$GENOME" \
    -profile docker \
    --max_cpus "$MAX_CPUS" \
    --max_memory "$MAX_MEMORY" \
    --max_time "$MAX_TIME" \
    --aligner hisat2 \
    --skip_fastqc false \
    --skip_trimming false \
    --skip_qualimap false \
    --skip_dupradar false \
    --skip_preseq true \
    --skip_rseqc false \
    --skip_biotype_qc false \
    --skip_deseq2_qc false \
    --skip_multiqc false \
    --pseudo_aligner salmon \
    --quantification_method featurecounts \
    --save_trimmed false \
    --save_unaligned false \
    --save_intermediates false \
    --save_reference false \
    --save_align_intermeds true \
    --save_merged_fastq true \
    --save_unaligned_fastq false \
    --save_trimmed_fastq true \
    --insert_size_metrics true \
    --biotype_annotation true \
    --biotype_gff_suffix .gtf \
    --biotype_gff_version 3

echo "3. Pipeline completed successfully!"
echo "Results are saved to: $S3_OUTPUT_DIR"

echo "=== Analysis complete! ==="
