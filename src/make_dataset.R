# Load raw data, normalize, and filter low quality cells

require(data.table)
require(ggplot2)
require(reshape2)
require(RColorBrewer)
require(plyr)

QC_DIR = 'reports/original_submission/qc'
DATA_DIR = 'data'
REF_DIR = 'references'

data.all <- fread(file.path(DATA_DIR, "lepto_met.gene_counts.df"))
setnames(data.all,c("cell.name","gene","counts"))
data.all[,gene.type:='hg38']
data.all[gene %like% 'ERCC-',gene.type:='ERCC']
data.all[,counts.cell:=sum(counts),by=c("cell.name","gene.type")]
data.all[,num.genes:=sum(counts>0),by=c("cell.name","gene.type")]
setkey(data.all)



data.all[,experiment:=substr(cell.name,1,regexpr("_",cell.name)-1)]
sort(unique(data.all[,experiment]))

expt <- sort(unique(data.all[,experiment])); col <- brewer.pal(length(expt),'Paired')
expt.col <- data.table(cbind(expt, col))
setnames(expt.col,c("experiment","experiment_color")); 
expt2col <- expt.col[['experiment_color']]; names(expt2col) <- expt.col[['experiment']]

data.all[,experiment_color:=NULL]
data.all=merge(data.all,expt.col,by='experiment')
setkey(data.all)
stats.cell <- unique(data.all[,.(cell.name,counts.cell,num.genes,experiment,gene.type)])
stats.counts=dcast.data.table(stats.cell,cell.name+experiment~gene.type,value.var = 'counts.cell')
stats.counts=merge(stats.counts, unique(stats.cell[gene.type=='hg38',.(cell.name, num.genes)]),by='cell.name')

ggplot(stats.counts,aes(hg38,num.genes,color=experiment))+scale_x_log10()+geom_point()+scale_color_manual(values=expt2col)+
  theme_bw()+geom_vline(xintercept = 1e5)
ggsave(file.path(QC_DIR, 'num.genes_counts.cell.pdf'),height=3,width = 4.5)

ggplot(stats.counts[hg38>1e5],aes((hg38/ERCC),num.genes,color=experiment))+scale_x_log10()+geom_point()+scale_color_manual(values=expt2col)+
  theme_bw()
ggsave(file.path(QC_DIR,'num.genes_hg38-ERCC_filtered.pdf'),height=3,width = 4.5)

data.all=data.all[!gene %like% 'ERCC-']
data.all[,counts.cell:=sum(counts),by=c("cell.name")]
data.all[,num.genes:=sum(counts>0),by=c("cell.name")]
setkey(data.all); data.all=data.all[counts.cell>1e5]


geneid.genename=fread(file.path(REF_DIR,'../references/hg38_geneID_geneName.txt'))#,sep=';')
setnames(geneid.genename,c('gene','gene.name'));setkey(geneid.genename)
geneid.genename=unique(geneid.genename)
data.all=merge(data.all,geneid.genename,by='gene')
data.all[,gene:=gene.name];data.all[,gene.name:=NULL]
# sum duplicate gene names
cast.melt <- dcast.data.table(data.all,cell.name~gene,value.var = 'counts',fill=NA,fun.aggregate = sum)
data.all <- melt(cast.melt,value.name = 'counts',id.vars = 'cell.name',variable.name = 'gene',na.rm=T)

data.all[,experiment:=substr(cell.name,1,regexpr("_",cell.name)-1)]
sort(unique(data.all[,experiment]))
data.all=merge(data.all,expt.col,by='experiment')
# 
data.all[,counts.cell:=sum(counts),by=c("cell.name")]
data.all[,num.genes:=sum(counts>0),by=c("cell.name")];setkey(data.all)
data.all[,cpm:=1e6*counts/counts.cell];data.all[,log10.cpm:=log10(1+cpm)]
data.all[,cpm:=NULL];data.all[,counts.cell:=NULL]
cast.melt <- dcast.data.table(data.all,cell.name~gene,value.var = 'log10.cpm',fill=0)
data.melt <- melt(cast.melt,value.name = 'log10.cpm',id.vars = 'cell.name',variable.name = 'gene')

setkey(data.all); stats.all <- unique(data.all[,.(cell.name,experiment,experiment_color,num.genes)])
data.all <- merge(data.melt, stats.all,by='cell.name')

save(data.all,file=file.path(DATA_DIR,'lepto_met.data.RData'))

# Create metadata file
expt <- sort(unique(data.all[,experiment])); col <- brewer.pal(length(expt),'Paired')
expt.col <- data.table(cbind(expt, col))
setnames(expt.col,c("experiment","experiment_color")); 
expt2col <- expt.col[['experiment_color']]; names(expt2col) <- expt.col[['experiment']]

lepto_met.cell.info = unique(data.all[,.(cell.name, experiment, experiment_color, num.genes)])

save(lepto_met.cell.info, file = file.path(DATA_DIR,'lepto_met.cell.info.RData'))
