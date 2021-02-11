import "ReadbasedAnalysisTasks.wdl" as tasks

workflow ReadbasedAnalysis {
    Map[String, Boolean] enabled_tools
    Map[String, String] db
    Array[File] reads
    Int cpu
    String prefix
    String outdir
    Boolean? paired = false
    String? docker = "microbiomedata/nmdc_taxa_profilers:1.0.2"

    if (enabled_tools["gottcha2"] == true) {
        call tasks.profilerGottcha2 {
            input: READS = reads,
                   DB = db["gottcha2"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/gottcha2",
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
                   OUTPATH = outdir+"/kraken2",
                   CPU = cpu,
                   DOCKER = docker
        }
    }

    if (enabled_tools["centrifuge"] == true) {
        call tasks.profilerCentrifuge {
            input: READS = reads,
                   DB = db["centrifuge"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/centrifuge",
                   CPU = cpu,
                   DOCKER = docker
        }
    }

    call tasks.generateSummaryJson {
        input: TSV_META_JSON = [profilerGottcha2.results, profilerCentrifuge.results, profilerKraken2.results],
               PREFIX = prefix,
               OUTPATH = outdir,
               DOCKER = docker
    }

    output {
        Map[String, Map[String, String]?] results = {
            "gottcha2": profilerGottcha2.results,
            "centrifuge": profilerCentrifuge.results,
            "kraken2": profilerKraken2.results
        }
        File summary_json = generateSummaryJson.summary_json
    }

    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
        version: "1.0.1"
    }
}
