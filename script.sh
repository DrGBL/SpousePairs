file1=INSERT FILE1 FILE PATH
file2=INSERT FILE2 FILE PATH

#Extract individuals reporting living with their spouse
grep -w 1 ${file1} | awk '{print $1}' > file3.txt

Rscript Spouse.R \
${file2} \
${file3}
