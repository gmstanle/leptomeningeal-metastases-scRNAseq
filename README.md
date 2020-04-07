To run this analysis, download the [gene count data](https://figshare.com/articles/Raw_gene_counts/12089430) and the
Ensembl ID - Gene name [translation table](https://figshare.com/account/home#/projects/78399).

In the root directory of the project, create the `data/` folder and move the data to the `data/` folder:
```
mkdir data
mv <path/to/genecounts> data/
```

In the root directory of the project, create the `references/` folder and move the translation table there
```
mkdir references
mv <path/to/translationTable> references/
```

Install the necessary packages in an R console
```
install.packages(c('Seurat','dplyr','data.table','ggplot2','reshape2','RColorBrewer','plyr',
		   'foreach','doMC','Matrix','ggrepel','cowplot','Rmisc'))
```

Then run the script to normalize and qc the raw data:

```
Rscript src/make_raw_data.R`
```

Make sure you run this from the root directory of the project. 

The analyses can then be run from the `notebooks/` folder. 
