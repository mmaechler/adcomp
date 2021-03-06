##' Compile and run a test example (\code{runExample()} shows all available examples).
##'
##' @title Run one of the test examples.
##' @param name Character name of example.
##' @param all Run all the test examples?
##' @param thisR Run inside this R?
##' @param clean Cleanup before compile?
##' @param exfolder Alternative folder with examples.
##' @param ... Passed to \code{compile}.
runExample <- function(name=NULL,all=FALSE,thisR=TRUE,
                       clean=FALSE,exfolder=NULL,...){
  cwd <- getwd()
  on.exit(setwd(cwd))
  if(is.null(exfolder))exfolder <- system.file("examples",package="TMB")
  setwd(exfolder)
  validExamples <- function(){
    f1 <- sub("\\.[^\\.]*$","",dir(pattern=".R$"))
    f2 <- sub("\\.[^\\.]*$","",dir(pattern=".cpp$"))
    intersect(f1,f2)
  }
  exnames <- validExamples()
  cppnames <- paste0(exnames,".cpp")
  ## Format info as text
  M <- max(nchar(exnames))
  info <- sapply(cppnames,function(x){readLines(x)[[1]]})
  info[substring(info,1,2)!="//"] <- ""
  info <- sub("^// *","",info)
  tmp <- gsub(" ","@",format(paste("\"",exnames,"\"",":",sep=""),width=M+4))
  info <- paste(tmp,info,sep="")
  info <- strwrap(info, width = 60, exdent = M+4)
  info <- gsub("@"," ",info)
  if(all){
    lapply(exnames,runExample,thisR=thisR,clean=clean,...)
    return(NULL)
  }
  if(is.null(name)){
    txt <- paste("Examples in " ,"\'",exfolder,"\':","\n\n",sep="")
    cat(txt)
    writeLines(info)
    return(invisible(exnames))
  }
  if(clean){
    cat("Cleanup:\n")
    file.remove(dynlib(name))
    file.remove(paste0(name,".o"))
  }
  cat("Building example",name,"\n")
  time <- system.time(compile(paste0(name,".cpp"),...))
  cat("Build time",time["elapsed"],"seconds\n\n")
  cat("Running example",name,"\n")
  if(!thisR){
    system(paste("R --vanilla < ",name,".R",sep=""))
  } else {
    source(paste(name,".R",sep=""),echo=TRUE)
  }
}
