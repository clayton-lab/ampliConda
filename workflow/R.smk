import pandas as pd

configfile: "config/config.yaml"

rule establish_metadata:
    script: "scripts/establish_metadata.R"

rule forward_reverse_variables:
    script: "scripts/fnFs_fnRs.R"

rule alphadivR: 
    input: 
    output: 
    script: "scripts/alpha divR.R"

    