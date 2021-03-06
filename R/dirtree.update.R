# Format ballot count
formatCount <- function(ballotStr){
    split <- strsplit(ballotStr, " : ")[[1]]
    ballot <- split[1]
    count <- strtoi(split[2])
    out <- list()
    out$ballot <- ballot
    out$count <- count
    return(out)
}

# Update the parameters of a tree given a ballot and a count
update <- function(node, ballot, count){
    if(!require('stringr')){
        stop("Requires `stringr` package to navigate dirtrees.")
    }

    n_children <- length(node$children)

    if(n_children>0){
        for( i in 1:n_children){
            # Check that the ballot path matches
            child <- node$children[[i]]
            if( startsWith(ballot, child$name) ){
                # update appropriate alpha parameter
                child$alpha <- child$alpha + count
                child$ballots <- child$ballots + count
                # Continue down the subtree
                update(child, ballot, count)
                break
            }
        }

    }
}

dirtree.update <- function(
    tree,              # Tree to update
    data = c(),        # ballot data, as a vector of ".1st.2nd.3rd...last:count" strings
    format = 'counts', # Indicates whether unique ballots have a ':count' appended,
                       # or if it is a list with duplicated ballots. Can be 'counts' or 'duplicated'.
    filepath = ''      # Alternatively, a file path to load data from. Overwrites the 'data' parameter.
){
    if (format!='counts' && format!='duplicated') {
        stop("Expected one of 'counts' or 'duplicated' for `format` parameter.")
    }
    if (filepath!='') {
        if (!require('readr')) {
            print("Ballot IO requires the `readr` library.")
        }
        data = read_lines(filepath)
    }

    ballot.counts <- list()

    if (format=='counts'){
        for (count in data) {
            ballot.data = formatCount(count)
            ballot.counts[[ballot.data$ballot]] <- ballot.data$count
        }
    } else if (format=='duplicated') {
        for( ballot in data ){
            if( length(ballot.counts[[ballot]])>0 ){
                ballot.counts[[ballot]] <- ballot.counts[[ballot]] + 1
            } else {
                ballot.counts[[ballot]] <- 1
            }
        }
    }

    for( ballot in names(ballot.counts) ){
        update(
            node=tree,
            ballot=ballot,
            count=ballot.counts[[ballot]]
        )
    }
}
