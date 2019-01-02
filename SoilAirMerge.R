setwd("/home/pi/Desktop/SoilAirSensors/data/")
Date = format(Sys.Date()-1,c("%Y","%-m","%-d"))

DataA = read.table(paste("raw/airdata_",Date[1],"-",Date[2],"-",Date[3],".dat",sep=""),head=T)
DataSC = read.table(paste("raw/soildata-c_",Date[1],"-",Date[2],"-",Date[3],".dat",sep=""),head=T)
colnames(DataSC)[2] = "GPIO_C"
DataSP = read.table(paste("raw/soildata-py_",Date[1],"-",Date[2],"-",Date[3],".dat",sep=""),head=T)
colnames(DataSP)[2] = "GPIO_PY"

Data = merge(DataSP,DataSC,by="DailySecond")
Data = merge(Data,DataA,by="DailySecond")

write.table(Data,file=paste("merge/soilairdata_",Date[1],"-",Date[2],"-",Date[3],".dat",sep=""),col.names = T,row.names = F,sep=" ")
SubData = subset(Data,select=c("DailySecond","GPIO_PY","GPIO_C","Humidity","Temperature","Pressure"))
write.table(SubData,file=paste("filter/soilair_",Date[1],"-",Date[2],"-",Date[3],".dat",sep=""),col.names = T,row.names = F,sep=" ")
