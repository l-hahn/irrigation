library(gplots)
setwd("./data/")

FlankLength = 30
Steps = 30
MinS = -1
MaxS = 1

CorCols = colorRampPalette(c('blue','grey','green'))(n=Steps)
CorBreaks = seq(from=MinS,to=MaxS,length.out=(Steps+1))
Date = paste(format(Sys.Date()-1,c("%Y","%m","%d")),collapse="-")
Data = read.table(paste("filter/soilair_",Date,".dat",sep=""),head=T)
pdf(file=paste("pdf/soilair_",Date,".pdf",sep=""))

MeanData = data.frame(
  DailySecond = Data$DailySecond,
  GPIO_C = rep(NA,nrow(Data)),
  GPIO_PY = rep(NA,nrow(Data)),
  Humidity = rep(NA,nrow(Data)),
  Temperature = rep(NA,nrow(Data)),
  Pressure = rep(NA,nrow(Data))
)

MedData = data.frame(
  DailySecond = Data$DailySecond,
  GPIO_C = rep(NA,nrow(Data)),
  GPIO_PY = rep(NA,nrow(Data)),
  Humidity = rep(NA,nrow(Data)),
  Temperature = rep(NA,nrow(Data)),
  Pressure = rep(NA,nrow(Data))
)

for(idx in seq(FlankLength,(nrow(Data)-FlankLength),FlankLength)){
  MeanData$GPIO_C[idx] = mean(Data$GPIO_C[ (idx-FlankLength+1) : (idx+FlankLength)])
  MeanData$GPIO_PY[idx] = mean(Data$GPIO_PY[ (idx-FlankLength+1) : (idx+FlankLength)])
  MeanData$Humidity[idx] = mean(Data$Humidity[ (idx-FlankLength+1) : (idx+FlankLength)])
  MeanData$Temperature[idx] = mean(Data$Temperature[ (idx-FlankLength+1) : (idx+FlankLength)])
  MeanData$Pressure[idx] = mean(Data$Pressure[ (idx-FlankLength+1) : (idx+FlankLength)])
  
  MedData$GPIO_C[idx] = median(Data$GPIO_C[ (idx-FlankLength+1) : (idx+FlankLength)])
  MedData$GPIO_PY[idx] = median(Data$GPIO_PY[ (idx-FlankLength+1) : (idx+FlankLength)])
  MedData$Humidity[idx] = median(Data$Humidity[ (idx-FlankLength+1) : (idx+FlankLength)])
  MedData$Temperature[idx] = median(Data$Temperature[ (idx-FlankLength+1) : (idx+FlankLength)])
  MedData$Pressure[idx] = median(Data$Pressure[ (idx-FlankLength+1) : (idx+FlankLength)])
}

MeanData = na.omit(MeanData)
rownames(MeanData) = 1:nrow(MeanData)
MedData = na.omit(MedData)
rownames(MedData) = 1:nrow(MedData)

write.table(MeanData,file=paste("filter/soilair-mean_",Date,".dat",sep=""),col.names = T,row.names = F)
write.table(MedData,file=paste("filter/soilair-median_",Date,".dat",sep=""),col.names = T,row.names = F)


heatmap.2(
  main="Pearson Correlation - Original",
  cor(Data,method="pearson"),
  Colv=F,
  Rowv=F,
  dendrogram="none",
  breaks=CorBreaks,
  col=CorCols
)

heatmap.2(
  main=paste("Pearson Correlation - Mean of",FlankLength,"+1"),
  cor(MeanData,method="pearson"),
  Colv=F,
  Rowv=F,
  dendrogram="none",
  breaks=CorBreaks,
  col=CorCols
)

heatmap.2(
  main=paste("Pearson Correlation - Median of",FlankLength,"+1"),
  cor(MeanData,method="pearson"),
  Colv=F,
  Rowv=F,
  dendrogram="none",
  breaks=CorBreaks,
  col=CorCols
)

###### PLOT DAILY SECOND; VIEW DATA ######

plot(GPIO_C~DailySecond,Data,main=paste("GPIO_C",Date),xlab="Daily Second [s]",ylab="Frequency [Hz]",pch=19,cex=0.2)
points(GPIO_C~DailySecond,MeanData,col="red",pch=19,cex=0.2)
points(GPIO_C~DailySecond,MedData,col="green",pch=19,cex=0.2)
abline(h=mean(Data$GPIO_C),col="red")
abline(h=median(Data$GPIO_C),col="green")

plot(GPIO_PY~DailySecond,Data,main=paste("GPIO_PY",Date),xlab="Daily Second [s]",ylab="Frequency [Hz]",pch=19,cex=0.2)
points(GPIO_PY~DailySecond,MeanData,col="red",pch=19,cex=0.2)
points(GPIO_PY~DailySecond,MedData,col="green",pch=19,cex=0.2)
abline(h=mean(Data$GPIO_PY),col="red")
abline(h=median(Data$GPIO_PY),col="green")



plot(Humidity~DailySecond,Data,pch=19,cex=0.2,main=Date)
points(Humidity~DailySecond,MeanData,pch=19,cex=0.2,col="red")
points(Humidity~DailySecond,MedData,pch=19,cex=0.2,col="green")

plot(Temperature~DailySecond,Data,pch=19,cex=0.2,main=Date)
points(Temperature~DailySecond,MeanData,pch=19,cex=0.2,col="red")
points(Temperature~DailySecond,MedData,pch=19,cex=0.2,col="green")

plot(Pressure~DailySecond,Data,pch=19,cex=0.2,main=Date)
points(Pressure~DailySecond,MeanData,pch=19,cex=0.2,col="red")
points(Pressure~DailySecond,MedData,pch=19,cex=0.2,col="green")



###### PLOT ENVIRONMENT AGAINST ENVIRONMENT; VIEW DATA ######

plot(Humidity~Temperature,Data,pch=19,cex=0.2,main=Date)
points(Humidity~Temperature,MeanData,pch=19,cex=0.2,col="red")
points(Humidity~Temperature,MedData,pch=19,cex=0.2,col="green")
plot(Temperature~Humidity,Data,pch=19,cex=0.2,main=Date)
points(Temperature~Humidity,MeanData,pch=19,cex=0.2,col="red")
points(Temperature~Humidity,MedData,pch=19,cex=0.2,col="green")

plot(Humidity~Pressure,Data,pch=19,cex=0.2,main=Date)
points(Humidity~Pressure,MeanData,pch=19,cex=0.2,col="red")
points(Humidity~Pressure,MedData,pch=19,cex=0.2,col="green")
plot(Pressure~Humidity,Data,pch=19,cex=0.2,main=Date)
points(Pressure~Humidity,MeanData,pch=19,cex=0.2,col="red")
points(Pressure~Humidity,MedData,pch=19,cex=0.2,col="green")


plot(Pressure~Temperature,Data,pch=19,cex=0.2,main=Date)
points(Pressure~Temperature,MeanData,pch=19,cex=0.2,col="red")
points(Pressure~Temperature,MedData,pch=19,cex=0.2,col="green")
plot(Temperature~Pressure,Data,pch=19,cex=0.2,main=Date)
points(Temperature~Pressure,MeanData,pch=19,cex=0.2,col="red")
points(Temperature~Pressure,MedData,pch=19,cex=0.2,col="green")

###### PLOT GPIO AGAINST ENVIRONMENT; VIEW DATA ######

plot(GPIO_C~Humidity,Data,pch=19,cex=0.2,main=Date)
points(GPIO_C~Humidity,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_C~Humidity,MedData,pch=19,cex=0.2,col="green")

plot(GPIO_PY~Humidity,Data,pch=19,cex=0.2,main=Date)
points(GPIO_PY~Humidity,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_PY~Humidity,MedData,pch=19,cex=0.2,col="green")



plot(GPIO_C~Temperature,Data,pch=19,cex=0.2,main=Date)
points(GPIO_C~Temperature,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_C~Temperature,MedData,pch=19,cex=0.2,col="green")

plot(GPIO_PY~Temperature,Data,pch=19,cex=0.2,main=Date)
points(GPIO_PY~Temperature,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_PY~Temperature,MedData,pch=19,cex=0.2,col="green")



plot(GPIO_C~Pressure,Data,pch=19,cex=0.2,main=Date)
points(GPIO_C~Pressure,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_C~Pressure,MedData,pch=19,cex=0.2,col="green")

plot(GPIO_PY~Pressure,Data,pch=19,cex=0.2,main=Date)
points(GPIO_PY~Pressure,MeanData,pch=19,cex=0.2,col="red")
points(GPIO_PY~Pressure,MedData,pch=19,cex=0.2,col="green")



###### PLOT GPIO AGAINST GPIO; VIEW DATA ######

plot(GPIO_PY~GPIO_C,Data,pch=19,cex=0.2,main=Date)

plot(GPIO_PY~GPIO_C,MedData,pch=19,cex=0.2,main=paste("Median",Date))
abline(lm(GPIO_PY~GPIO_C,MedData),col="red")


###### Missing Data Analysis ######

MissingTimePoint = c()
for(i in 2:nrow(Data)){
  if(Data$DailySecond[i] - Data$DailySecond[i-1] != 1){
    MissingTimePoint[length(MissingTimePoint)+1] = i
  }
}
plot(1:length(MissingTimePoint),MissingTimePoint,pch=19,cex=0.2)
MaxDiff = 0
for( i in 2:length(MissingTimePoint)){
  MaxDiff = max(MaxDiff, MissingTimePoint[i] - MissingTimePoint[i-1] )
}
MisDist = rep(0,length(MissingTimePoint)-1)
for( i in 2:length(MissingTimePoint)){
  MisDist[i-1] = MissingTimePoint[i] - MissingTimePoint[i-1]
}
hist(MisDist)
plot(1:length(MisDist),MisDist,type="b",pch=19,cex=0.2)

dev.off()
