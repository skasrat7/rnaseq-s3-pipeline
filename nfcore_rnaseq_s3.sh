# Configuration - Edit these variables as needed
# Updated on 091025 to accommodate biotype classification for sample RNA and ERCC
S3_OUTPUT_DIR="XXX" ## output directory
INPUT_CSV=XXX  ## input csv file
GENOME=GRCh38 ## genome
MAX_CPUS=8 ## number of CPUs
MAX_MEMORY="256.GB" ## memory
MAX_TIME="24.h" ## time limit

# ERCC Configuration - NEW
S3_GENOME_DIR=XXX  ## S3 path to your reference files
GENOME_FASTA=Homo_sapiens.GRCh38.dna.primary_assembly.fa
GENOME_GTF=Homo_sapiens.GRCh38.110.gtf
ERCC_FASTA=ERCC92.fa  ## your ERCC fasta filename
ERCC_GTF=ERCC_biotypes.gtf   ## your ERCC gtf filename
COMBINED_FASTA=GRCh38_ERCC_combined.fa
COMBINED_GTF=GRCh38_ERCC_combined.gtf
LOCAL_REF_DIR=./references  ## local directory for combined references

# Error handling
set -e
trap 'echo "Error occurred. Check the logs above." >&2' ERR

# Check if required files exist
if [[ ! -f "$INPUT_CSV" ]]; then
    echo "Error: Input CSV file '$INPUT_CSV' not found!"
    echo "Please ensure the file exists in the current directory."
    exit 1
fi

echo "=== nf-core/rnaseq with ERCC spike-ins ==="
echo "Input file: $INPUT_CSV"
echo "Output directory: $S3_OUTPUT_DIR"
echo "Genome: $GENOME"
echo "Resource limits: ${MAX_CPUS} CPUs, ${MAX_MEMORY}, ${MAX_TIME}"
echo ""

# Create local reference directory
mkdir -p "$LOCAL_REF_DIR"

echo "1. Preparing combined genome + ERCC references..."

# Download reference files from S3
echo "   Downloading genome files from S3..."
aws s3 cp "${S3_GENOME_DIR}${GENOME_FASTA}" "${LOCAL_REF_DIR}/"
aws s3 cp "${S3_GENOME_DIR}${GENOME_GTF}" "${LOCAL_REF_DIR}/"
aws s3 cp "${S3_GENOME_DIR}${ERCC_FASTA}" "${LOCAL_REF_DIR}/"
aws s3 cp "${S3_GENOME_DIR}${ERCC_GTF}" "${LOCAL_REF_DIR}/"

# Combine FASTA files
echo "   Combining FASTA files..."
cat "${LOCAL_REF_DIR}/${GENOME_FASTA}" "${LOCAL_REF_DIR}/${ERCC_FASTA}" > "${LOCAL_REF_DIR}/${COMBINED_FASTA}"

# Combine GTF files
echo "   Combining GTF files..."
cat "${LOCAL_REF_DIR}/${GENOME_GTF}" "${LOCAL_REF_DIR}/${ERCC_GTF}" > "${LOCAL_REF_DIR}/${COMBINED_GTF}"

# Upload combined files back to S3 (optional - for reuse)
echo "   Uploading combined references to S3..."
aws s3 cp "${LOCAL_REF_DIR}/${COMBINED_FASTA}" "${S3_GENOME_DIR}"
aws s3 cp "${LOCAL_REF_DIR}/${COMBINED_GTF}" "${S3_GENOME_DIR}"

echo "2. Running nf-core/rnaseq with combined genome+ERCC references..."
nextflow run nf-core/rnaseq \
    --input "$INPUT_CSV" \
    --outdir "$S3_OUTPUT_DIR" \
    --fasta "${LOCAL_REF_DIR}/${COMBINED_FASTA}" \
    --gtf "${LOCAL_REF_DIR}/${COMBINED_GTF}" \
    -profile singularity \
    --max_cpus "$MAX_CPUS" \
    --max_memory "$MAX_MEMORY" \
    --max_time "$MAX_TIME" \
    --strandedness reverse \
    --aligner star_salmon \
    --clip_r2 16 \
    --extra_trimgalore_args "--length 50" \
    --skip_fastqc false \
    --skip_trimming false \
    --skip_qualimap false \
    --skip_dupradar false \
    --skip_preseq true \
    --skip_rseqc false \
    --skip_biotype_qc false \
    --skip_deseq2_qc false \
    --skip_multiqc false \
    --quantification_method featurecounts \
    --save_trimmed false \
    --save_unaligned false \
    --save_intermediates false \
    --save_reference true \
    --save_align_intermeds true \
    --picard_metrics true \
    --extra_picard_args "COLLECT_INSERT_SIZE_METRICS=true VALIDATION_STRINGENCY=LENIENT" \
    --save_merged_fastq true \
    --save_unaligned_fastq false \
    --save_trimmed_fastq true \
    --biotype_annotation true \
    --save_salmon_tpm true \
    --save_salmon_counts true

echo "3. Pipeline completed successfully!"
echo "Results are saved to: $S3_OUTPUT_DIR"
echo ""
echo "=== Post-processing ERCC analysis suggestions ==="
echo "After pipeline completion, consider running these analyses:"
echo "1. Separate ERCC counts from gene counts in the output files"
echo "2. Calculate ERCC spike-in metrics (correlation, efficiency)"
echo "3. Generate ERCC-specific QC plots"
echo "4. Use ERCC for normalization if appropriate for your experimental design"
echo ""
echo "=== Analysis complete! ==="

# Cleanup local reference files (optional)
# rm -rf "$LOCAL_REF_DIR"