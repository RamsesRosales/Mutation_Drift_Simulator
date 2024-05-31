#function to simulate the process of mutation drif equilibrium, 
#the function is a modification from the coalescent.plot function from learnpopgen package
#the difference is that simulate a population of constant size moving forward in time
#introducing the posibility of new alleles to be generated given mutation.

library(ggplot2)

mutation_drift.plot<-function(n=10,ngen=20,nallels=2,mutation=0.01,colors=NULL,...){
  if(hasArg(sleep)) sleep<-list(...)$sleep
  else sleep<-0.2
  if(is.null(colors)) colors<-rainbow(n=3*n)
  popn<-matrix(NA,ngen+1,n)
  parent<-matrix(NA,ngen,n)
  popn[1,]<-sample(1:nallels,size = n,replace=TRUE)
  allels<-1:nallels
  allels_new<- nallels
  for(i in 1:ngen){
    parent[i,]<-sort(sample(1:n,size = n,replace=TRUE))
    popn[i+1,]<-popn[i,parent[i,]]
    mut<-runif(n)
    for(j in 1:n){
      if(mut[j] < mutation ){
        popn[i+1,j]<-allels_new + 1
        allels_new<- allels_new + 1
      }
    }
  }
  plot.new()
  par(mar=c(2.1,4.1,2.1,1.1))
  plot.window(xlim=c(0.5,n+0.5),ylim=c(ngen,0))
  axis(2)
  title(ylab="time (generations)")
  cx.pt<-2*25/max(n,ngen)
  points(1:n,rep(0,n),bg=colors,pch=21,cex=cx.pt)
  for(i in 1:ngen){
    dev.hold()
    for(j in 1:n){
      lines(c(parent[i,j],j),c(i-1,i),lwd=2,
            col=colors[popn[i+1,j]])
    }
    points(1:n,rep(i-1,n),bg=colors[popn[i,]],pch=21,
           cex=cx.pt)
    points(1:n,rep(i,n),bg=colors[popn[i+1,]],pch=21,
           cex=cx.pt)
    dev.flush()
#    Sys.sleep(sleep)
  }
}


#mutation_drift.plot(mutation = 0.03,n=50,ngen = 100)


mutation_drift_matrix<-function(n=10,ngen=30,nallels=2,mutation=0.02,colors=NULL,ordered=TRUE,...){
  popn<-matrix(NA,ngen+1,n)
  parent<-matrix(NA,ngen,n)
  popn[1,]<-sample(1:nallels,size = n,replace=TRUE)
  allels<-1:nallels
  allels_new<- nallels
  for(i in 1:ngen){
    if(ordered){
      parent[i,]<-sort(sample(1:n,size = n,replace=TRUE))
    }else{
      parent[i,]<-sample(1:n,size = n,replace=TRUE)
    }
    popn[i+1,]<-popn[i,parent[i,]]
    mut<-runif(n)
    for(j in 1:n){
      if(mut[j] < mutation ){
        popn[i+1,j]<-allels_new + 1
        allels_new<- allels_new + 1
      }
    }
  }
  output <- list("parent"=parent,"popn"=popn)
  return(output)
}

#test<-mutation_drift_matrix()

mde_plot<-function(mut_mat,colors=NULL,...){
  n<-ncol(mut_mat[[1]])
  ngen<-nrow(mut_mat[[1]])
  if(is.null(colors)) colors<-rainbow(n=length(unique(as.vector(mut_mat[[2]]))))
  popn<-mut_mat[[2]]
  parent<-mut_mat[[1]]
  plot.new()
  par(mar=c(2.1,4.1,2.1,1.1))
  plot.window(xlim=c(0.5,n+0.5),ylim=c(ngen,0))
  axis(2)
  title(ylab="time (generations)")
  cx.pt<-2*25/max(n,ngen)
  points(1:n,rep(0,n),bg=colors,pch=21,cex=cx.pt)
  for(i in 1:ngen){
    dev.hold()
    for(j in 1:n){
      lines(c(parent[i,j],j),c(i-1,i),lwd=2,
            col=colors[popn[i+1,j]])
    }
    points(1:n,rep(i-1,n),bg=colors[popn[i,]],pch=21,
           cex=cx.pt)
    points(1:n,rep(i,n),bg=colors[popn[i+1,]],pch=21,
           cex=cx.pt)
    dev.flush()
  }
}

#mde_plot(test)

mde_frec<-function(mut_mat){
   allele_pool<-c("A","B","C","D","E","F","G",
                  "H","I","J","K","L","M","N","O",
                  "P","Q","R","S","T","U","V","W",
                  "X","Y","Z","a","b","c","d","e",
                  "f","g","h","i","j","k","l","m",
                  "n","o","p","q","r","s","t","u",
                  "v","w","x","y","z")
   if(hasArg(sleep)) sleep<-list(...)$sleep
   else sleep<-0.2
   n<-ncol(mut_mat[[1]])
   ngen<-nrow(mut_mat[[1]])
   if(is.null(colors)) colors<-rainbow(n=3*n)
   popn<-mut_mat[[2]]
   freq<-data.frame("Generation"=NA,"Allele"=NA,"Freq"=NA)
   n_r <- 1
   for(i in 1:nrow(popn)){
    for(j in (unique(popn[i,]))){
      new_row<-c(i,allele_pool[j],(length(which(popn[i,] == j))/ncol(popn)))
      freq[n_r,]<-new_row
      n_r<-n_r+1
    } 
   }
   return(freq)
 }
 
#test_f<- mde_frec(test)

mde_fplot<-function(freq_mat){
#     colors<-rainbow(length(unique(freq_mat$Allele)))
     colors<-rainbow(length(unique(freq_mat$Allele)))
     p<- ggplot(freq_mat,aes(as.numeric(Generation),as.numeric(Freq),color=Allele)) +
     geom_path()+
     geom_point()+
     theme_classic()+
     xlab("time(generations)")+
     ylab("Allele frequencies")+
     scale_color_manual(values = (colors))
   
   return(p)
 }

#mde_fplot(test_f) 
#p

#a<-test_f[which(test_f$Allele == unique(test_f$Allele)[1]),]
#plot(a$Generation,a$Freq,type="b")
#for (i in (unique(test_f$Allele)[2:length(unique(test_f$Allele))])){
#  a<-test_f[which(test_f$Allele == i),]
#  lines(a$Generation,a$Freq, pch = 18, col = "blue", type = "l", lty = 2)
#}
 
mde_hz_frec<-function(mut_mat){
  n<-ncol(mut_mat[[1]])
  ngen<-nrow(mut_mat[[1]])
  popn<-mut_mat[[2]]
  freq<-data.frame("Generation"=NA,"Phenotype"=NA,"freq"=NA)
  for( i in 1:nrow(popn)){
    hz <- c(0,0)
    for( j in 1:(ncol(popn)/2)){
      ind<-(j*2)-1  
      if( popn[i,ind] == popn[i,(ind+1)] ){
        hz[1]<- hz[1]+1
      }else{
        hz[2]<-hz[2]+1
      }
    }
    k<-c(i*2)
    m<-c(k-1)
    freq[m,]<-c(i,"Homozygous",(hz[1]/(n/2)))
    freq[k,]<-c(i,"Heterozygous",(hz[2]/(n/2)))
  }
  return(freq)
}

#test_h<-mde_hz_frec(test)

mde_hz_plot<-function(hz_mat){
  p<- ggplot(hz_mat,aes(as.numeric(Generation),as.numeric(freq),color=Phenotype)) +
    geom_path()+
    geom_point()+
    theme_classic()+
    xlab("time(generations)")+
    ylab("Phenotype frequencies")+
    scale_color_manual(values = c("blue","red"))
  return(p)
}

#mde_fplot(test_h)

test<-mutation_drift_matrix()
test_h<-mde_hz_frec(test)
mde_hz_plot(test_h)
summary(test_h)
