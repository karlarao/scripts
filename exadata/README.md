
Summary of the tools: 

- [exadata disk topology](https://github.com/karlarao/scripts/tree/master/exadata/exadata_disk_topology) - collects end to end cell mapping info (disk, grid disk, asm), storage space, cell config details (version, IORM, WBFC, etc.). This tool is useful to a full view of your Exadata Storage cells. 
- [cellmetricstoolkit](https://github.com/karlarao/scripts/tree/master/exadata/cellmetricstoolkit) - easily pull the cell metrics history data. This is a low footprint data collection. The --serial allows running serially for each of the storage cells and the bzip2 is for compressing the data set on the fly which makes the space usage footprint on the filesystem very small. 
- [hcc_testcase](https://github.com/karlarao/scripts/tree/master/exadata/hcc_testcase) - quick guide on how to do HCC compression


