#!/bin/bash

# A better version of the nf-core/rnaseq execution script with ERCC spike-ins
# Uses proper Nextflow configuration instead of command-line parameters

set -e
trap 'echo "Error occurred. Check the logs above." >&2' ERR

echo "=== nf-core/rnaseq with ERCC spike-ins ==="
echo "Using Nextflow configuration files for better reproducibility"
echo ""

# Step 1: Prepare combined references (only run if not already done)
if [[ ! -f "./references/GRCh38_ERCC_combined.fa" ]]; then
    echo "1. Preparing combined genome + ERCC references..."
    nextflow run prep_references.nf
    echo "   Reference preparation complete!"
    echo ""
else
    echo "1. Combined references already exist, skipping preparation..."
    echo ""
fi

# Step 2: Run the main nf-core/rnaseq pipeline
echo "2. Running nf-core/rnaseq pipeline..."
echo "   Using configuration from nextflow.config"
echo ""

nextflow run nf-core/rnaseq \
    -c nextflow.config \
    -profile local \
    -resume

echo ""
echo "3. Pipeline completed successfully!"
echo ""

# Step 3: Post-processing suggestions
echo "=== Post-processing ERCC analysis suggestions ==="
echo "After pipeline completion, consider running these analyses:"
echo "1. Separate ERCC counts from gene counts in the output files"
echo "2. Calculate ERCC spike-in metrics (correlation, efficiency)"
echo "3. Generate ERCC-specific QC plots"
echo "4. Use ERCC for normalization if appropriate for your experimental design"
echo ""

# Optional: Run ERCC-specific analysis
read -p "Would you like to run ERCC-specific post-processing? (y/n): " run_ercc
if [[ $run_ercc == "y" || $run_ercc == "Y" ]]; then
    echo "Running ERCC post-processing..."
    # Add your ERCC analysis script here
    # python ercc_analysis.py --input ${params.outdir}
    echo "ERCC analysis placeholder - implement as needed"
fi

echo "=== Analysis complete! ==="