#!/usr/bin/env nextflow

/*
 * ERCC Reference Preparation Pipeline
 * Combines genome and ERCC references for nf-core/rnaseq
 */

nextflow.enable.dsl = 2

// Parameters
params.s3_genome_dir = 's3://your-bucket/references/'
params.genome_fasta = 'Homo_sapiens.GRCh38.dna.primary_assembly.fa'
params.genome_gtf = 'Homo_sapiens.GRCh38.110.gtf'
params.ercc_fasta = 'ERCC92.fa'
params.ercc_gtf = 'ERCC_biotypes.gtf'
params.outdir = './references'

// Processes
process DOWNLOAD_REFERENCES {
    publishDir params.outdir, mode: 'copy'
    
    output:
    path "${params.genome_fasta}", emit: genome_fasta
    path "${params.genome_gtf}", emit: genome_gtf
    path "${params.ercc_fasta}", emit: ercc_fasta
    path "${params.ercc_gtf}", emit: ercc_gtf
    
    script:
    """
    echo "Downloading reference files from S3..."
    aws s3 cp ${params.s3_genome_dir}${params.genome_fasta} .
    aws s3 cp ${params.s3_genome_dir}${params.genome_gtf} .
    aws s3 cp ${params.s3_genome_dir}${params.ercc_fasta} .
    aws s3 cp ${params.s3_genome_dir}${params.ercc_gtf} .
    """
}

process COMBINE_FASTA {
    publishDir params.outdir, mode: 'copy'
    
    input:
    path genome_fasta
    path ercc_fasta
    
    output:
    path "GRCh38_ERCC_combined.fa", emit: combined_fasta
    
    script:
    """
    echo "Combining FASTA files..."
    cat ${genome_fasta} ${ercc_fasta} > GRCh38_ERCC_combined.fa
    """
}

process COMBINE_GTF {
    publishDir params.outdir, mode: 'copy'
    
    input:
    path genome_gtf
    path ercc_gtf
    
    output:
    path "GRCh38_ERCC_combined.gtf", emit: combined_gtf
    
    script:
    """
    echo "Combining GTF files..."
    cat ${genome_gtf} ${ercc_gtf} > GRCh38_ERCC_combined.gtf
    """
}

process UPLOAD_COMBINED {
    input:
    path combined_fasta
    path combined_gtf
    
    script:
    """
    echo "Uploading combined references to S3..."
    aws s3 cp ${combined_fasta} ${params.s3_genome_dir}
    aws s3 cp ${combined_gtf} ${params.s3_genome_dir}
    """
}

// Workflow
workflow {
    // Download reference files
    DOWNLOAD_REFERENCES()
    
    // Combine FASTA files
    COMBINE_FASTA(
        DOWNLOAD_REFERENCES.out.genome_fasta,
        DOWNLOAD_REFERENCES.out.ercc_fasta
    )
    
    // Combine GTF files
    COMBINE_GTF(
        DOWNLOAD_REFERENCES.out.genome_gtf,
        DOWNLOAD_REFERENCES.out.ercc_gtf
    )
    
    // Upload combined files back to S3
    UPLOAD_COMBINED(
        COMBINE_FASTA.out.combined_fasta,
        COMBINE_GTF.out.combined_gtf
    )
}

workflow.onComplete {
    println "Reference preparation completed successfully!"
    println "Combined files are ready for nf-core/rnaseq pipeline"
}