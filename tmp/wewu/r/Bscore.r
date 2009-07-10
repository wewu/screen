cutoff = 0.0 
func = "Bscore" 
path = "C:/Chen/screen/config/environments/../../tmp/wewu/r/" 
precision = 2 
isserver =FALSE 
aid_vec=c('0_31_32')
 
 ##========================================================================= 
 #cutoff = 5 
 #func = "Bscore" 
 #path = "C:/Chen/screen/config/../config/environments/../../tmp/wewu/r/" 
 #precision = 2 
 #isserver = TRUE 
 #aid_vec=c("1_2_3_4", "5_6") 
  
 ## ============ small functions ====================== 
 eq <- function(s1, s2) 
 { 
   if (is.na(match(s1, s2))) { ret = FALSE } else { ret = TRUE } 
   ret 
 } 
  
 ne <- function(s1, s2) 
 { 
   !eq(s1, s2) 
 } 
  
 get_aidarr <- function(aidarr_str) 
 { 
    aidarr <- unlist(strsplit(aidarr_str, "_"))  
    aidarr 
 } 
  
 search_well <- function(ctrlarr, label) 
 { 
    ret = FALSE 
    len = length(ctrlarr)    
    for (i in 1:len) 
    { 
       if (eq(ctrlarr[i], label)) 
       { 
          ret = TRUE 
          i = len 
       } 
    } 
    ret 
 } 
  
 arr_to_matrix <- function(y, ctrl) 
 { 
    ymat <- matrix(NA, nrow=rows, ncol=cols)    
    for (i in 1:rows)   
    {   
       for (j in 1:cols)   
       {    
          n = (i-1)*cols+j  
          if (eq("sample", ctrl[n])) 
          {   
             ymat[i,j] <- y[n]  
          }  else  
          {  
             y[n] <- NA  
             ymat[i,j] <- ctrl[n]  
          }  
       }  
    }   
    ymat 
 } 
  
 arr_index_to_matrix_index <- function(idx) 
 { 
    rowidx = 0 
    colidx = 0 
    for (i in 1:rows)   
    {   
       for (j in 1:cols)   
       {    
          if (idx == (i-1)*cols+j ) 
          { 
             rowidx = i 
             colidx = j 
             break 
          } 
       } 
    }   
    rowlabarr <- c("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"); 
    pos = paste("(", rowlabarr[rowidx], ",", colidx, ")", sep="") 
    pos 
 } 
  
 arr_indexes_to_matrix_indexes <- function(idxarr) 
 { 
    len = length(idxarr) 
    posarr = c(1:len) 
    k = 0 
    for (idx in idxarr) 
    { 
       posarr[k] = arr_index_to_matrix_index(idxarr[k]) 
       k = k + 1 
    } 
    posarr 
 } 
  
 open_dev <- function(fname, isserver) 
 { 
    if (isserver) 
    { 
       pdf(file = paste(fname, ".pdf", sep=""), encoding="ISOLatin2") 
    } 
    else 
    { 
       jpeg(filename = paste(fname, ".jpg", sep=""), width = 400, height = 400)   
    } 
 }    
  
 open_dev2 <- function(fname, isserver) 
 { 
    if (isserver) 
    { 
       pdf(file = paste(fname, ".pdf", sep=""), encoding="ISOLatin2") 
    } 
    else 
    { 
       jpeg(filename = paste(fname, ".jpg", sep="")) 
    } 
 }    
  
 ## ============ major functions ====================== 
 get_x <- function(path, aid) 
 { 
    hlist = paste(path, "hmap_list_",       aid, ".txt", sep="")  
    hconf = paste(path, "hmap_conf_",       aid, ".txt", sep="")  
    hdesc = paste(path, "hmap_desc_notuse_",aid, ".txt", sep="")  
    hlog  = paste(path, "hmap_log_notuse_", aid, ".txt", sep="")  
    x <- readPlateData(hlist, name="exp")  
    x <- configure(x, hconf, hlog, hdesc)  
    x 
 } 
     
 get_ctrl <- function(x) 
 { 
    ctrl <- t(t(x$plateConf[3])) 
    ctrl 
 } 
  
 check_ctrl_well <- function(func, ctrl) 
 {   
    ret = TRUE 
    if (eq(func, "POC")) 
    {   
       haspos <- search_well(ctrl, "pos") 
       if (haspos) 
       { 
          ret = TRUE 
       }else 
       {  
          ret = FALSE 
       } 
    } 
    if ( eq(func, "negatives") || eq(func, "negmean")) 
    {   
       hasneg <- search_well(ctrl, "neg") 
       if (hasneg) 
       { 
          ret = TRUE 
       }else 
       {  
          ret = FALSE 
       } 
    } 
    ret 
 } 
  
 write_error <- function(fname, aid, func) 
 { 
    if (eq(func, "POC")) 
    { 
       errormsg = "No positive control wells." 
    } 
    if (eq(func, "negatives")) 
    { 
       errormsg = "No negative control wells." 
    } 
    if (eq(func, "negmean")) 
    { 
       errormsg = "No negative control wells." 
    } 
    write(paste("## Assay Id = ", aid, sep=""), fname, 1, append=TRUE, sep="")   
    write(paste("#_# error = Error:", errormsg, sep=""), fname, 1, append=TRUE, sep="")   
 } 
  
           
 append_output <- function(fname, aid, yw)  
 { 
    write(paste("## Assay Id = ", aid, sep=""), fname, 1, append=TRUE, sep="")   
    write(t(yw), fname, 24, append=TRUE, sep="\t")   
 } 
  
 gen_plot_hist <- function(aidarr_str, y) 
 { 
    plotfname = paste(path, func, "_plot_avg_", aidarr_str, sep="")  
    histfname = paste(path, func, "_hist_avg_", aidarr_str, sep="")  
     
    open_dev(plotfname, isserver) 
    narr <- c(1:tot)   
    plot(narr, y, pch=19, main="Plot")   
     
    label_arr = rep("", tot) 
    for (i in narr) 
    { 
       if ((y[i] > cutoff) || (y[i] < -cutoff)) 
       { 
          label_arr[i] <- arr_index_to_matrix_index(i) 
       } 
       else 
       { 
          label_arr[i] <- "" 
       } 
    } 
    text(x=narr+15, y, cex = 0.5, labels=label_arr)  
     
    abline(a=cutoff, b=0)   
    abline(a=-cutoff, b=0)   
    dev.off()   
            
    open_dev(histfname, isserver) 
    hist(y, prob=T, main="Histogram")   
    dev.off()   
 } 
  
 gen_hmap <- function(aid, func, yobj) 
 { 
    hmapfname = paste(path, func, "_hmap_", aid, sep="")  
     
    open_dev2(hmapfname, isserver) 
    if (eq(func, "POC") || eq(func, "negatives") || eq(func, "negmean")) 
    {   
       imageScreen(yobj) 
    } else 
    {   
       plotSpatialEffects(yobj)   
    } 
    dev.off()    
 } 
  
 run <- function(x, func) 
 { 
    if (eq(func, "zscore")) 
    {  
       yobj <- normalizePlates(x, normalizationMethod="Bscore", save.model = TRUE)  
       yobj <- summarizeReplicates(yobj) 
        
       xarr = x$xraw[1:tot]   
       mea <- mean(xarr, na.rm=TRUE)   
       std <- sd(xarr, na.rm=TRUE)   
       y <- (xarr - mea)/std 
       yobj$xnorm <- y 
       yobj$score <- y 
    }  
    if (eq(func, "negmean")) 
    { 
       yobj <- normalizePlates(x, normalizationMethod="negatives", save.model = TRUE)  
       yobj <- summarizeReplicates(yobj) 
  
       neg_ctrl_vec <- which(as.character(yobj$wellAnno) == "neg") 
       mea <- mean(yobj$xraw[neg_ctrl_vec], na.rm=TRUE) 
       y <- round(x$xraw[1:tot]/mea * 100) 
       yobj$xnorm <- y 
       yobj$score <- y 
    } 
    if (eq(func, "negatives")) 
    { 
       yobj <- normalizePlates(x, normalizationMethod=func, save.model = TRUE)  
       yobj <- summarizeReplicates(yobj) 
        
       y <- yobj$xnorm * 100 
       yobj$xnorm <- y 
       yobj$score <- y 
    } 
    if (eq(func, "Bscore")) 
    {    
       yobj <- normalizePlates(x, normalizationMethod=func, save.model = TRUE)  
       yobj <- summarizeReplicates(yobj) 
    }  
    yobj 
 } 
  
 comp_replicates <- function(aidarr) 
 {    
    len <- length(aidarr) 
    yarr <- matrix(NA, nrow=len, ncol=tot) 
  
    y_avg <- rep(NA, tot)  
    yavgobj <- NA 
    ln <- 1 
     
    for (repli in aidarr) 
    { 
       x <- get_x(path, repli) 
       ctrl <- get_ctrl(x) 
       succ <- check_ctrl_well(func, ctrl) 
  
       if (succ) 
       { 
          yobj <- run(x, func)       
          y <- round(yobj$xnorm, precision)  
          yw <- arr_to_matrix(y, ctrl)    
          yarr[ln,] <- y     
          gen_hmap(repli, func, yobj) 
           
          if (is.na(yavgobj[1])) 
          { 
             yavgobj <- yobj 
          } 
           
          append_output(outfname, repli, yw)  
          ln <- ln + 1 
       }  else 
       { 
          write_error(outfname, repli, func) 
       } 
    } 
    for (i in 1:tot) 
    { 
       y_avg[i] <- round(mean(yarr[,i], na.rm=TRUE), precision) 
    } 
    if (!(is.na(yavgobj[1]))) 
    { 
       yavgobj$xnorm <- y_avg 
    } 
    yavgobj 
 } 
  
 ##-------- main ---------- 
 library("cellHTS")  
 rows = 16  
 cols = 24  
 tot = rows*cols  
 outfname = paste(path, func, ".out", sep="")  
  
 for (aidarr_str in aid_vec)  
 {  
    aidarr <- get_aidarr(aidarr_str) 
    aidavg_str <-  paste("avg_", aidarr_str, sep="")   
     
    yobj_avg <- comp_replicates(aidarr) 
     
    if (!(is.na(yobj_avg[1]))) 
    { 
       y_avg <- yobj_avg$xnorm 
       ctrl_avg <- get_ctrl(yobj_avg) 
       yw_avg <- arr_to_matrix(y_avg, ctrl_avg) 
     
       gen_plot_hist(aidarr_str, y_avg) 
       append_output(outfname, aidavg_str, yw_avg)  
    } else 
    { 
       write_error(outfname, aidavg_str, func)  
    } 
 } 
  
 ##========================================================================= 
 
