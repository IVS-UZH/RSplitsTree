#' TODO add docs
#'
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  # set up platform-dependent splitstree.path default
  if(is.null(getOption('splitstree.path'))) {
    splitstree.path <- switch(Sys.info()["sysname"], 
      Darwin = '/Applications/SplitsTree/SplitsTree.app/Contents/MacOS/JavaApplicationStub',
      Linux = '/usr/local/bin/SplitsTree',
      ''
    )
    options(splitstree.path = splitstree.path)
  }
}