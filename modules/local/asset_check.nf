process ASSET_CHECK {
    label 'process_low'
    container 'staphb/gamma:2.1'

    input:
    path(directory)

    when:
    task.ext.when == null || task.ext.when

    shell:
    """
    mash_sketch=\$(find ${directory}/ -type f -name "REFSEQ*")
    if [[ \$mash_sketch == *.gz ]]
    then
        gunzip --force \$mash_sketch
    else
        :
    fi
    """
}