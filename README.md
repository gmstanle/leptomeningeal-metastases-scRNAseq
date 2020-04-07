To run this analysis, download the [gene count data](https://figshare.com/articles/Raw_gene_counts/12089430) and the
Ensembl ID - Gene name [translation table](https://figshare.com/account/projects/78399/articles/12090480).

In the root directory of the project, create the `data/` folder and move the data to the `data/` folder:
```
cd leptomeningeal-metastases-scRNAseq
mkdir data
mv <path/to/genecounts> data/lepto_met.gene_counts.df
```

In the root directory of the project, create the `references/` folder and move the translation table there
```
mkdir references
mv <path/to/translationTable> references/hg38_geneID_geneName.txt
```

Install the necessary packages in an R console
```
install.packages(c('Seurat','dplyr','data.table','ggplot2','reshape2','RColorBrewer','plyr',
		   'foreach','doMC','Matrix','ggrepel','cowplot','Rmisc'))
```

Then run the `make_raw_data.R` script in the project root directory to normalize and qc the raw data:

```
Rscript src/make_raw_data.R
```

You should now have 3 files total in the root directory:
```
├── lepto_met.cell.info.RData
├── lepto_met.data.RData
└── lepto_met.gene_counts.df
```

The analyses can then be run from the `notebooks/` folder. 
