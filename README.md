[README.md](https://github.com/user-attachments/files/21922146/README.md)
# nf-core/rnaseq S3 Pipeline Script

A bash script for running the nf-core/rnaseq pipeline with S3 input/output support, specifically configured for comprehensive RNA-seq analysis including insert size metrics and RNA biotype analysis.

## Features

- **HISAT2 alignment** with insert size metrics
- **RNA biotype analysis** and quantification
- **Salmon pseudo-alignment** for transcript-level quantification
- **FeatureCounts** for gene-level quantification
- **Comprehensive quality control** including FastQC, Qualimap, RSeQC, and MultiQC
- **S3 storage integration** for both input and output
- **Docker support** for reproducible analysis
- **Automated input generation** from S3 folders

## Requirements

- **Nextflow**: Version 22.10.x or later (or use DSL2 syntax)
- **Docker**: For containerized execution
- **AWS CLI**: Configured with S3 access permissions
- **Input CSV**: Sample information file (see format below)

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. **Generate input CSV from S3** (Recommended):
   ```bash
   # Install dependencies
   pip3 install -r requirements.txt
   
   # Generate CSV from S3 folder
   bash create_input.sh s3://your-bucket/fastq-folder/ samples.csv
   ```

3. **Configure your settings**:
   - Edit `script.sh` and modify the configuration variables
   - Update `S3_OUTPUT_DIR` to point to your S3 bucket
   - Adjust resource limits as needed

4. **Run the pipeline**:
   ```bash
   bash script.sh
   ```

## Configuration

Edit these variables in `script.sh`:

```bash
S3_OUTPUT_DIR="s3://your-bucket/your-analysis-folder/"
INPUT_CSV="your_samples.csv"
GENOME="GRCh38"
MAX_CPUS=8
MAX_MEMORY="16.GB"
MAX_TIME="72.h"
```

## Input CSV Generation

### Automatic Generation (Recommended)

Use the included scripts to automatically generate your input CSV from an S3 folder:

```bash
# Generate CSV from S3 folder (default strandedness: auto)
bash create_input.sh s3://your-bucket/fastq-folder/ samples.csv

# Generate CSV with specific strandedness
bash create_input.sh s3://your-bucket/fastq-folder/ samples.csv --strandedness forward

# Or use Python directly
python3 create_rnaseq_input.py s3://your-bucket/fastq-folder/ -o samples.csv
python3 create_rnaseq_input.py s3://your-bucket/fastq-folder/ --strandedness reverse -o samples.csv

# Test without writing file
python3 create_rnaseq_input.py s3://your-bucket/fastq-folder/ --dry-run
```

### Manual CSV Format

If creating manually, your CSV file should contain columns for:
- `sample` (sample name)
- `fastq_1` (path to R1 fastq file)
- `fastq_2` (path to R2 fastq file, for paired-end)
- `strandedness` (library strandedness: auto, forward, reverse, or unstranded)

Example:
```csv
sample,fastq_1,fastq_2,strandedness
sample1,s3://bucket/fastq/sample1_R1.fastq.gz,s3://bucket/fastq/sample1_R2.fastq.gz,auto
sample2,s3://bucket/fastq/sample2_R1.fastq.gz,s3://bucket/fastq/sample2_R2.fastq.gz,forward
```

### Supported FastQ Naming Patterns

The script automatically detects these common naming patterns:
- `sample_R1.fastq.gz` / `sample_R2.fastq.gz`
- `sample_1.fastq.gz` / `sample_2.fastq.gz`
- `sample.1.fastq.gz` / `sample.2.fastq.gz`
- `sample_R1.fq.gz` / `sample_R2.fq.gz`

### Strandedness Options

The script automatically adds a `strandedness` column to your CSV with configurable values:

- **`auto`** (default) - Pipeline will automatically detect strandedness
- **`forward`** - Forward stranded library (first read is sense strand)
- **`reverse`** - Reverse stranded library (first read is antisense strand)  
- **`unstranded`** - Unstranded library preparation

**Usage examples:**
```bash
# Default (auto-detection)
bash create_input.sh s3://bucket/folder/ samples.csv

# Force forward stranded
bash create_input.sh s3://bucket/folder/ samples.csv --strandedness forward

# Force reverse stranded
bash create_input.sh s3://bucket/folder/ samples.csv --strandedness reverse
```

## Output

The pipeline will generate:
- Alignment files (BAM)
- Quantification results (counts, TPM)
- Quality control reports
- Insert size metrics
- RNA biotype analysis
- MultiQC summary report

All results are saved to your specified S3 output directory.

## Pipeline Parameters

The script includes these key configurations:
- **Alignment**: HISAT2 with insert size metrics
- **QC**: FastQC, Qualimap, RSeQC, MultiQC
- **Quantification**: Salmon + FeatureCounts
- **Biotype analysis**: Enabled for RNA categorization
- **Resource limits**: Configurable CPU, memory, and time limits

## Troubleshooting

- **S3 access issues**: Ensure AWS CLI is configured with proper permissions
- **Resource limits**: Adjust CPU/memory limits based on your system
- **Input file errors**: Check CSV format and file paths
- **Nextflow version**: Use DSL2 syntax or Nextflow 22.10.x+

## Utility Scripts

This repository includes additional scripts to streamline your workflow:

### `create_rnaseq_input.py`
Python script that scans S3 folders and generates nf-core/rnaseq input CSV files.

**Features:**
- Automatically detects paired-end FastQ files
- Supports multiple naming conventions
- Generates S3 URLs for pipeline input
- Includes strandedness column (configurable: auto, forward, reverse, unstranded)
- Includes dry-run mode for testing

### `create_input.sh`
Bash wrapper script that provides a user-friendly interface for the Python script.

**Features:**
- Automatic dependency checking and installation
- Colored output and progress indicators
- AWS credential validation
- Helpful usage examples

### `requirements.txt`
Python package dependencies for the utility scripts.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this script.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Citation

If you use this script in your research, please cite:
- nf-core/rnaseq: [https://doi.org/10.1038/s41587-020-0439-x](https://doi.org/10.1038/s41587-020-0439-x)
- Nextflow: [https://doi.org/10.1038/nbt.3820](https://doi.org/10.1038/nbt.3820)
