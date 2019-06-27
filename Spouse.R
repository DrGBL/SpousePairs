#Package requirements
require(data.table)
require(plyr)

#Arguments
file2 <- as.character(args[1])
file3 <- as.character(args[2])

#Main file
input1<-fread("file2")
names(input1)<-c("ID", "Sex", "DoB", "Centre", "AccoType", "OwnRent","LengthOfTime",
"NumberInHousehold","Vehicles","AliveF", "AgeDeathF", "AliveM", "AgeDeathM","HomeEW", "HomeNS")

#List of potential spouses
input2<-fread("file3")
names(input2)<-c("ID")

#Restrict to potential spouses
data<-input1[which(input1$ID%in%input2$ID),]

#Restrict data-set to individuals with complete data on accomodation type,
#rental status, length of time in house, number in household, number of vehicles
#and home coordinates as these will be used to derive spouse-pairs. 

datacomplete<-data[which(data$AccoType>0 & data$OwnRent>0 & data$LengthOfTime>0 & data$NumberInHousehold>1 & data$Vehicles>0 & !is.na(data$HomeEast)
				   & !is.na(data$HomeNorth) & !is.na(data$LengthOfTime) & !is.na(data$NumberInHousehold)),]


#Define the matching criteria for spouses: 
#UKB assessment centre, Accomodation type, Ownership status, Length of time in household, number in household, 
#vehicles, home EW coordinate, home NS coordinate.

criteria<-datacomplete[c(4:9,14,15)]

#Identify criteria that are duplicated between different individuals
duplicates<-duplicated(criteria)
criteriadf<-unique(criteria[duplicated(criteria),])

#Give each sequence of duplicated criteria an identifier number
criteriadf$Couple<-1:nrow(criteriadf)

#Merge the identifier numbers with the main data-set
merge<-merge(datacomplete,criteriadf, by=c("Centre", "AccoType", "OwnRent", "LengthOfTime", "NumberInHousehold", "Vehicles", "HomeEast", "HomeNorth"))

#Count the number of individuals with identical information and restrict to couples only rather than trios etc
count<-ddply(merge,.(Couple),nrow)
count2<-count[which(count$V1==2),]
merge2<-merge[which(merge$Couple %in% count2$Couple),]

#Restrict to opposite-sex couples only
sex<-merge2[c(10,16)]
duplicates2<-duplicated(sex)
duplicates2df<-sex[duplicated(sex),]
merge3<-merge2[which(!merge2$Couple %in% duplicates2df$Couple),]

#Output as preliminary couples
write.table(merge3, "", quote=F, row.names=F)



