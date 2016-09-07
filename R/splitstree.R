#' Convert an object to SplitsTree-compatible NEXUS input
#' and launch SplitsTree if required
#' @export
#' 
#' @param dist A distance object (usually of class 'dist')
#' @param nexus.file A name of the file where the NEXUS file will be written to (see notes)
#' @param plot Set this to 'PDF' or 'SVG' to automatically invoke SplitsTree4 and generate a graphics file
#' @param splitstree.path Path to the SplitsTree4 binary (see notes)
#' @return The name of the generated NEXUS file
#'
#' @note If the name of the output file (\code{nexus.file}) is omitted, the function attempts to derive
#' the file name automatically. Beware that if the file with this name already exists, it will be 
#' overwritten without a warning — so extra care needs to be taken if you have extra `.nex` files 
#' in the output directory.
#'
#' If you are generating graphical output, the \code{splitstree.path} neeeds to point to the
#' command-line
#' executable of the SplitsTree4 package. The location and name of the executable is system- and 
#' installation-dependent. The package attempts to guess the standard location for your system, but
#' if it fails, please provide the path explicitly. Note that on as OS X, a suitable executable is
#' located within the SpltisTree.app application bundle, with the path
#'`SplitsTree.app/Contents/MacOS/JavaApplicationStub` (or alternatively, you can install the Linux 
#' SplitsTree4 package on Mac to get an executable in /usr/local/bin/SplitsTree)
#' 
#' @examples
#' library(cluster)
#' data(agriculture)
#' agriculture.dist <- daisy(agriculture)
#' splitstree(agriculture.dist, plot='PDF')
splitstree <- function(dist, nexus.file = NULL, plot = FALSE, splitstree.path = getOption('splitstree.path', NULL)) {
  # -----------------------------------------------------
  # Validate the input
  # -----------------------------------------------------
  
  # generate an appropriate file name, if none is provided
  if(missing(nexus.file)) {
    if(is.symbol(substitute(dist)))
      nexus.file <- paste0(gsub("\\.", "-", deparse(substitute(dist))), '.nex')
    else
      nexus.file <- 'splitstree-output.nex'
  }
  
  # check if plot is a correct value
  if(!identical(plot, FALSE)) {
    plot <- match.arg(plot, c('PDF', 'SVG'))
    if(!file.exists(splitstree.path)) {
      stop("'splitstree.path' needs to point to SplitsTree4 unix executable file!")
    }
  }
  
  # -----------------------------------------------------
  # Generate the NEXUS file
  # -----------------------------------------------------
  
  # clean up the labels (SplitsTree can't deal with certain characters)
  attr(dist, "Labels") <- local({
    labels <- attr(dist, "Labels")
    
    labels <- gsub("(?!/)[[:punct:]]", "_", labels, perl=T)
    labels <- gsub("[[:space:]]", "_", labels, perl=T)
    labels <- gsub("\\_\\_", "-", labels, perl=T)
    labels <- gsub("\\_$", "", labels, perl=T)
    labels <- gsub("á", "a", labels, perl=T)
    labels <- gsub("à", "a", labels, perl=T)
    labels <- gsub("â", "a", labels, perl=T)
    labels <- gsub("ã", "a", labels, perl=T)
    labels <- gsub("é", "e", labels, perl=T)
    labels <- gsub("è", "e", labels, perl=T)
    labels <- gsub("ê", "e", labels, perl=T)
    labels <- gsub("ẽ", "e", labels, perl=T)
    labels <- gsub("í", "i", labels, perl=T)
    labels <- gsub("ì", "i", labels, perl=T)
    labels <- gsub("î", "i", labels, perl=T)
    labels <- gsub("ĩ", "i", labels, perl=T)
    labels <- gsub("ó", "o", labels, perl=T)
    labels <- gsub("ò", "o", labels, perl=T)
    labels <- gsub("ô", "o", labels, perl=T)
    labels <- gsub("õ", "o", labels, perl=T)
    labels <- gsub("ñ", "ny", labels, perl=T)
    
    labels
  })

  # generate the NEXUS data (as a text string)
  nexus.data <- capture.output({
    taxa.labels <- attr(dist, "Labels")
    n.taxa <- attr(dist, "Size")
    
    # write the NEXUS header
    cat('#nexus\n\n')
    
    # write the Taxa block
    cat('BEGIN Taxa;\n')
    cat('DIMENSIONS ntax=', n.taxa, ';\n', sep='')
    cat('TAXLABELS\n')
    cat(paste0("  [", seq_along(taxa.labels), "] '", taxa.labels, "'"), sep='\n')
    cat(';\n')
    cat('END;\n')
    
	  # write the Distances block
    cat('BEGIN Distances;\n')
    cat('DIMENSIONS ntax=', n.taxa, ';\n', sep='')
    cat('FORMAT labels=no diagonal triangle=both;\n')
    cat('MATRIX\n')
    write.table(as.matrix(dist), row.names = F, col.names=F, sep='\t')
    cat(';\n')
    cat('END;\n')
  })
  
  # save the nexus file
  writeLines(nexus.data, nexus.file)
  
  if(!identical(plot, FALSE)) {
    # get the name of the plot file
    plot.file <- paste0(gsub('\\.nex$', '', nexus.file), '.', tolower(plot))
    
    # plotting commands to be passed to splitstree
    splitstree_script <- paste0(
    'EXECUTE file=', nexus.file, '\n',
    'UPDATE\n',
    'EXPORTGRAPHICS format=', plot, ' file=', plot.file, ' REPLACE=YES\n',
     'QUIT')
    
     # run splitstree
     system(paste(splitstree.path, ' -g -S -i', nexus.file),
            input = splitstree_script)    
  }

  invisible(nexus.file)
}