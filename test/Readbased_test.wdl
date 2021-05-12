import "ReadbasedAnalysis.wdl" as rba

workflow RBA {
  String  container="microbiomedata/nmdc_taxa_profilers:1.0.2"
  String  validate_container="microbiomedata/comparejson"
  Map[String,String]  database={"gottcha2": "/vol_b/nmdc_workflows/data/refdata/database/r90/RefSeq-r90.cg.BacteriaArchaeaViruses.species.fna","kraken2": "/vol_b/nmdc_workflows/data/refdata/database/Kraken2/","centrifuge": "/vol_b/nmdc_workflows/data/refdata/database/centrifuge/p_compressed"}
  Boolean paired=false
  Map[String, Boolean] enabled_tools={"gottcha2": true, "kraken2": true, "centrifuge": true}
  String  prefix="small_test"
  String  outdir="/vol_b/nmdc_workflows/test_nmdc/ReadbasedAnalysis/outdir"
  String? cpu="8"
  File  url="https://portal.nersc.gov/cfs/m3408/test_data/Ecoli_10x-int.fastq.gz"
  String  ref_json="https://raw.githubusercontent.com/microbiomedata/ReadbasedAnalysis/master/test/small_test.json"

  call prepare {
    input: container=container,
           url=url,
           ref_json=ref_json
  }
  call rba.ReadbasedAnalysis as read {
    input: reads=[prepare.fastq],
           cpu=cpu,
           paired=paired,
           db=database,
           enabled_tools=enabled_tools,
           prefix=prefix,
           outdir=outdir

  }
  call validate {
    input: container=validate_container,
           refjson=prepare.refjson,
           user_json=read.summary_json
  }


}

task prepare {
   String container
   String ref_json
   String url
   command{
       wget -O "reads.fastq.gz" ${url}
       wget -O "ref_json.json" ${ref_json}
   }

   output{
      File fastq = "reads.fastq.gz"
      File refjson = "ref_json.json"
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}


task validate {
   String container
   File refjson
   File user_json

   command {
       compare_json.py -i ${refjson} -f ${user_json}
   }
   output {
       Array[String] result = read_lines(stdout())
   }

   runtime {
     memory: "1 GiB"
     cpu:  1
     maxRetries: 1
     docker: "container"
   }
}
