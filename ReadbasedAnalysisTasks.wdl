task profilerGottcha2 {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    String? RELABD_COL = "ROLLUP_DOC"
    String DOCKER
    Int? CPU = 4

    command <<<
        mkdir -p ${OUTPATH}

        gottcha2.py -r ${RELABD_COL} \
                    -i ${sep=' ' READS} \
                    -t ${CPU} \
                    -o ${OUTPATH} \
                    -p ${PREFIX} \
                    --database ${DB}
        
        grep "^species" ${OUTPATH}/${PREFIX}.tsv | ktImportTaxonomy -t 3 -m 9 -o ${OUTPATH}/${PREFIX}.krona.html -
    >>>
    output {
        Map[String, String] results = {
            "tool": "gottcha2",
            "orig_out_tsv": "${OUTPATH}/${PREFIX}.full.tsv",
            "orig_rep_tsv": "${OUTPATH}/${PREFIX}.tsv",
            "krona_html": "${OUTPATH}/${PREFIX}.krona.html"
        }
    }
    runtime {
        docker: DOCKER
        memory: "50G"
        cpu: CPU
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

task profilerCentrifuge {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    Int? CPU = 4
    String DOCKER

    command <<<
        mkdir -p ${OUTPATH}

        centrifuge -x ${DB} \
                   -p ${CPU} \
                   -U ${sep=',' READS} \
                   -S ${OUTPATH}/${PREFIX}.classification.tsv \
                   --report-file ${OUTPATH}/${PREFIX}.report.tsv
        
        ktImportTaxonomy -m 4 -t 2 -o ${OUTPATH}/${PREFIX}.krona.html ${OUTPATH}/${PREFIX}.report.tsv
    >>>
    output {
        Map[String, String] results = {
            "tool": "centrifuge",
            "orig_out_tsv": "${OUTPATH}/${PREFIX}.classification.tsv",
            "orig_rep_tsv": "${OUTPATH}/${PREFIX}.report.tsv",
            "krona_html": "${OUTPATH}/${PREFIX}.krona.html"
        }
    }
    runtime {
        docker: DOCKER
        memory: "50G"
        cpu: CPU
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

task profilerKraken2 {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    Boolean? PAIRED = false
    Int? CPU = 4
    String DOCKER

    command <<<
        mkdir -p ${OUTPATH}
        
        kraken2 ${true="--paired" false='' PAIRED} \
                --threads ${CPU} \
                --db ${DB} \
                --output ${OUTPATH}/${PREFIX}.classification.tsv \
                --report ${OUTPATH}/${PREFIX}.report.tsv \
                ${sep=' ' READS}

        ktImportTaxonomy -m 3 -t 5 -o ${OUTPATH}/${PREFIX}.krona.html ${OUTPATH}/${PREFIX}.report.tsv
    >>>
    output {
        Map[String, String] results = {
            "tool": "kraken2",
            "orig_out_tsv": "${OUTPATH}/${PREFIX}.classification.tsv",
            "orig_rep_tsv": "${OUTPATH}/${PREFIX}.report.tsv",
            "krona_html": "${OUTPATH}/${PREFIX}.krona.html"
        }
    }
    runtime {
        docker: DOCKER
        memory: "50G"
        cpu: CPU
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

task generateSummaryJson {
    Array[Map[String, String]?] TSV_META_JSON
    String OUTPATH
    String PREFIX
    String DOCKER

    command {
        outputTsv2json.py --meta ${write_json(TSV_META_JSON)} > ${OUTPATH}/${PREFIX}.json
    }
    output {
        File summary_json = "${OUTPATH}/${PREFIX}.json"
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