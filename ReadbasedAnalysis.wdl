import "ReadbasedAnalysisTasks.wdl" as tp

workflow ReadbasedAnalysis {
    Map[String, Boolean] enabled_tools
    Map[String, String] db
    Array[File] reads
    Int cpu
    String prefix
    String outdir
    Boolean? paired = false
    String? docker = "microbiomedata/nmdc_taxa_profilers:1.0.0"

    if (enabled_tools["gottcha2"] == true) {
        call tp.profilerGottcha2 {
            input: READS = reads,
                   DB = db["gottcha2"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/gottcha2",
                   CPU = cpu,
                   DOCKER = docker
        }
    }
    if (enabled_tools["kraken2"] == true) {
        call tp.profilerKraken2 {
            input: READS = reads,
                   PAIRED = paired,
                   DB = db["kraken2"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/kraken2",
                   CPU = cpu,
                   DOCKER = docker
        }
    }
    if (enabled_tools["centrifuge"] == true) {
        call tp.profilerCentrifuge {
            input: READS = reads,
                   DB = db["centrifuge"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/centrifuge",
                   CPU = cpu,
                   DOCKER = docker
        }
    }
    call generateSummaryJson {
        input: TSVFILES = [profilerGottcha2.orig_rep_tsv, profilerCentrifuge.orig_rep_tsv, profilerKraken2.orig_rep_tsv],
               PREFIX = prefix,
               OUTPATH = outdir,
               DOCKER = docker
    }
    output {
        File summary_json = generateSummaryJson.summary_json
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
        version: "1.0.0"
    }
}

task generateSummaryJson {
    Array[File] TSVFILES
    String OUTPATH
    String PREFIX
    String DOCKER

    command {
        outputTsv2json.py --tsvfile ${sep=' --tsvfile ' TSVFILES} --prefix ${PREFIX} > ${OUTPATH}/${PREFIX}.summary.json
    }
    output {
        File summary_json = "${OUTPATH}/${PREFIX}.summary.json"
    }
    runtime {
        docker: DOCKER
        cpu: 1
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}