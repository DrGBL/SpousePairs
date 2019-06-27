require(data.table)

data<-fread("input")
names(data)<-c("phenID", "Sex", "DoB", "Centre", "AccoType", "OwnRent","LengthOfTime",
"NumberInHousehold","Vehicles","AliveF", "AgeDeathF", "AliveM", "AgeDeathM","HomeEW", "HomeNS")
 
#Restrict data-set to individuals with complete data on accomodation type, rental status, length of time in house, number in household, number of vehicles and home coordinates as these will be used to derive spouse-pairs. 
datacomplete<-data[which(data$AccoType>0 & data$OwnRent>0 & data$LengthOfTime>0 & data$NumberInHousehold>1 & data$Vehicles>0 & !is.na(data$HomeEast)
				   & !is.na(data$HomeNorth) & !is.na(data$LengthOfTime) & !is.na(data$NumberInHousehold)),]

#Read in list of IDs of individuals of European descent to restrict the sample to
include<-read.table("~/Inflammatory/data.less_stringent_europeans_inclusions.txt")
include$V2<-NULL
names(include)<-c("genID")

#Read in the linker file linking genotype and phenotype IDs for matching
linker<-read.csv("~/HeightVitD/data.7445.csv", header=TRUE)
names(linker)<-c("phenID", "genID")
match<-merge(include,linker,by="genID")
matcheddata <- merge(datacomplete, match, by="phenID")

#Define the matching criteria: Biobank Centre, Accomodation type, Ownership status, length of time, number in household, vehicles, home east coordinate, home north coordinate
criteria<-matcheddata[c(4,7:11,16,17)]

#Identify individuals with duplicate information for the matching criteria
duplicates<-duplicated(criteria)

#Restrict to matching criteria with duplicates
criteriadf<-criteria[duplicated(criteria),]

#Give each couple an identifier number
criteriadf$Couple<-1:nrow(criteriadf)

#Merge the couple and data-set
merge<-merge(matcheddata,criteriadf, by=c("Centre", "AccoType", "OwnRent", "LengthOfTime", "NumberInHousehold", "Vehicles", "HomeEast", "HomeNorth"))


#Count the number of individuals with identical information and restrict to couples only rather than trios etc
library(plyr)
count<-ddply(merge,.(Couple),nrow)
count2<-count[which(count$V1==2),]
merge2<-merge[which(merge$Couple %in% count2$Couple),]

#Restrict to opposite-sex couples only
sex<-merge2[c(10,19)]
duplicates2<-duplicated(sex)
duplicates2df<-sex[duplicated(sex),]
merge3<-merge2[which(!merge2$Couple %in% duplicates2df$Couple),]

#Output as preliminary couples
write.table(merge3, "~/Assortative/PrelimCouples.txt", quote=F, row.names=F)

c) Read in Genotype and linker file

#Read in ADH1B SNP genotype file
snp<-read.table("~/Assortative/linkedADH1b.ped")
snp<-snp[c(1,8,9)]
names(snp)<-c("genID","A1", "A2")

#Count the number of alleles
snp$Geno[snp$A1=='C'&snp$A2=='C']<-0
snp$Geno[snp$A1=='C'&snp$A2=='T']<-1
snp$Geno[snp$A1=='T'&snp$A2=='C']<-1
snp$Geno[snp$A1=='T'&snp$A2=='T']<-1

#Remove couples that have been identified as related by GRM (see other file)
relateds<-read.table("~/Assortative/RelatedCouples.txt")
norelateds<-snp[which(!snp$genID%in%relateds$V1 & !snp$genID%in%relateds$V2),]

#Merge the genotype and phenotype files 
temp3<-merge(norelateds,merge3,by="genID")

#Set up the couple data-set ID/Couple number
temp4<-temp3[c(1,22)]

#Merging with genotype data may have removed some individuals, therefore need to check for complete pairs
temp5<-duplicated(temp4$Couple)

#Define complete and incomplete pairs
temp6<-temp4[duplicated(temp4$Couple),]
temp7<-temp4[!duplicated(temp4$Couple),]
temp8<-temp3[which(temp3$genID %in% temp6$genID),]
temp9<-temp3[which(temp3$genID %in% temp7$genID),]

#Extract couple number and genotype info
temp10<-temp8[c(22,4)]
temp11<-temp9[c(22,4)]
names(temp10)<-c("Couple", "Gene1")
names(temp11)<-c("Couple", "Gene2")

#Merge by couple removing incomplete pairs 
temp12<-merge(temp10,temp11, by="Couple")
#47,552 pairs at this point

#Remove couples with same ages for parental deaths as a further check for siblings.
check<-temp8[c(22,4,5,19,21)]
check2<-temp9[c(22,4,5,19,21)]
names(check)<-c("Couple", "Gene1", "FatherA", "MotherA")
names(check2)<-c("Couple", "Gene2","FatherB", "MotherB")
check3<-merge(check,check2,by="Couple")
check3$test1<-check3$FatherA-check3$FatherB
check3$test2<-check3$MotherA-check3$MotherB
check3$remove<-0
check3$remove[check3$test1==0 & check3$test2==0]<-1
check4<-check3[which(check3$remove==0),]

merge4<-merge3[which(merge3$Couple %in% check4$Couple),]
output<-merge4[c(9,18,19,1,10,11)]

#Remove couples 18137, 44454 and 69102 for same parental age of death so 47,549 pairs

write.table(output, "~/Assortative/Spouse-pairs.txt", quote=F, row.names=F)

