import "ReadbasedAnalysisTasks.wdl" as tasks

workflow ReadbasedAnalysis {
    Map[String, Boolean] enabled_tools
    Map[String, String] db
    Array[File] reads
    Int cpu
    String prefix
    Boolean? paired = false
    #String? docker = "microbiomedata/nmdc_taxa_profilers:1.0.2"
    String docker = "microbiomedata/nmdc_taxa_profilers@sha256:a56c3b2978869dd26e98daeb60ca9f2432dedb11c191cd3b0316a1827956c3a2"

    if (enabled_tools["gottcha2"] == true) {
        call tasks.profilerGottcha2 {
            input: READS = reads,
                   DB = db["gottcha2"],
                   PREFIX = prefix,
                   CPU = cpu,
                   DOCKER = docker
        }
    }

    if (enabled_tools["kraken2"] == true) {
        call tasks.profilerKraken2 {
            input: READS = reads,
                   PAIRED = paired,
                   DB = db["kraken2"],
                   PREFIX = prefix,
                   CPU = cpu,
                   DOCKER = docker
        }
    }

    if (enabled_tools["centrifuge"] == true) {
        call tasks.profilerCentrifuge {
            input: READS = reads,
                   DB = db["centrifuge"],
                   PREFIX = prefix,
                   CPU = cpu,
                   DOCKER = docker
        }
    }

    output {
        File? gottcha2_report_tsv = profilerGottcha2.report_tsv
        File? gottcha2_full_tsv = profilerGottcha2.full_tsv
        File? gottcha2_krona_html = profilerGottcha2.krona_html
        File? centrifuge_classification_tsv = profilerCentrifuge.classification_tsv
        File? centrifuge_report_tsv = profilerCentrifuge.report_tsv
        File? centrifuge_krona_html = profilerCentrifuge.krona_html
        File? kraken2_classification_tsv = profilerKraken2.classification_tsv
        File? kraken2_report_tsv = profilerKraken2.report_tsv
        File? kraken2_krona_html = profilerKraken2.krona_html
    }

    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
        version: "1.0.2"
    }
}

