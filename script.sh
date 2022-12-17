#Edit these paths
file1=/path/to/file1.txt
file2=/path/to/file2.txt
pathOut=/path/to/output/folder/
pathSpouseR=/path/to/Spouse.R

#Extract individuals reporting living with their spouse
grep -w 1 ${file1} | awk '{print $1}' > ${pathOut}file3.txt

Rscript ${pathSpouseR} ${file2} ${pathOut}file3.txt ${pathOut}couples.txt
