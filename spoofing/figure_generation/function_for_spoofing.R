library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(readxl)
library(grid)
library(scales)
library(lubridate)
# Preprocessing part, currently support three files preprocess:
# 1. n_depth csv
# 2. four_size increase by algorithm
# 3. actual trade 

# read the data for n level depth for each row and do some preprocessing
read_prepro<-function(path){
  a<- fread(path,header=T)
  a<-as.data.frame(a)
  a<-a[,colSums(is.na(a))<nrow(a)]
  a<- tbl_df(a)
  a<-shift_time(a)
  temp<-a[1,]
  bid_index<-match(FALSE,temp[-1]>=0)
  first_bid<-as.numeric(names(a)[-1][bid_index])
  upper<-first_bid*1.01
  lower<- first_bid*0.99
  df<-gather(a,price,depth_size,-Time,-number,-Shift)
  df<-df[!is.na(df$depth_size),]
  op <- options(digits.secs=3)
  #df$Time <- strptime(df$Time, "%H:%M:%OS")
  #df$Shift <- strptime(df$Shift, "%H:%M:%OS")
  df$Time<-as.POSIXct(df$Time,format="%H:%M:%OS",tz="GMT")
  df$Shift <-as.POSIXct(df$Shift,format="%H:%M:%OS",tz="GMT")
  df$price<-as.numeric(df$price)
  return (list(df=subset(df, price >=lower & price<=upper),upper=upper,lower=lower))
}

prepro_four_size<- function(df){
  df<- tbl_df(df)
  op <- options(digits.secs=3)
  df$Time<-as.POSIXct(df$Time,format="%H:%M:%OS",tz="GMT")
  df
}

# in the raw csv, use 1 to represent this trade is a buy and 0 means it is a sell.
# this function also transfer 1 and 0 to Buy and Sell in order to make legend more pretty. 
prepro_trade<-function(path){
  df<- fread(path,header=T)
  op <- options(digits.secs=3)
  df$Time<-as.POSIXct(df$Time,format="%H:%M:%OS",tz="GMT")
  df$buy<-factor(df$buy,levels=c(1,0))
  df[df$buy==1,"buy"]="Buy"
  df[df$buy==0,"buy"]="Sell"
  names(df)[names(df)=="buy"] <- "Trade"
  df$Trade<-factor(df$Trade,levels=c("Buy","Sell"))
  df
}


#df_40_50<-df[(df$Time>= "2016-09-10 06:40:00.000 CDT" & df$Time <= "2016-09-10 06:50:00.000 CDT"),]

# plot
# compared with archive,some update:
# 1. fix the hour problem, now no longer need to store the hour and label it.
# 2. dynamicly change the range of depth
#.3. Add trade data using triangle
#.4. Change the theme and change the save size.

n_depth_plot_dynamic_size<-function(df,trade=data.frame(),output=FALSE,re,bl,future){
  range<- max(abs(df$depth_size))
  range<- range+(5-range%%5)
  level<-c(0.8,1.5,3,6)
  
  # based on different type of future, we apply different transform.
  # Currently, we have 5 types of future: 'fCC', 'fCT', 'fGC', 'fKC', 'fSB'
  # fCC      most seen diff: 1     norm_size*6
  # fCT      most seen diff: 0.01     norm_size*600
  # fGC gold most seen diff:0.1    norm_size*60
  # fKC      most seen diff:0.05    norm_size*120
  # fSB      most seen diff:0.01    norm_size*600
  future_list<-list(fCC=6,fCT=600,fGC=60,fKC=120,fSB=600)
  constant<-future_list[[future]]
  norm_size<-Mode(diff(unique(df$price)))
  
  figure<-ggplot(df,aes(x=Time,y=price))+
  geom_segment(aes(x=Time,y=price,xend=Shift,yend=price,col=depth_size),size=norm_size*constant,alpha=0.9)+
  scale_colour_gradientn(colours=c(re,"white",bl),limits=c(-range,range))

  if(nrow(trade)!=0){
    trade$shape<-factor(trade$shape,levels=level)
    figure<-figure+geom_point(data=trade,aes(x=Time,y=Price,shape=Trade,size=shape,fill=Trade))+
    scale_size_manual(values=level,name='trade_size',breaks = level,labels=size_label_log(trade),drop=FALSE)+
    scale_shape_manual(values=c(24,25))+
    scale_fill_manual(values=c("green", "orange"))+
    guides(col=guide_colorbar(),shape=guide_legend(),size = guide_legend(override.aes = list(shape = 24)))+
    scale_x_datetime(date_labels = "%H:%M:%S")+
    theme_bw()+theme(aspect.ratio=0.9)
    }else{
      figure<-figure+scale_x_datetime(date_labels = "%H:%M:%S")+
      theme_bw()+
      theme(aspect.ratio=0.9)
    }
  if (output!=FALSE){
    ggsave(filename=output,path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-rotating-result\\output-rotating-figures",width=10,height=8)
  }#
}

get_size<-function(df){
  temp<-unique(df$price)
  temp<-temp[!is.na(temp)]
  temp<-sort(temp)
  temp<-temp[-length(temp)]
  temp<-temp[-1]
  dif<-Mode(diff(temp))
  return (dif/temp[as.integer(length(temp)/2)]*16000)
}

n_depth_plot<-function(df,trade=data.frame(),output=FALSE,re,bl){
  range<- max(abs(df$depth_size))
  range<- range+(5-range%%5)
  figure<-ggplot(df,aes(x=Time,y=price))+
    geom_segment(aes(x=Time,y=price,xend=Shift,yend=price,col=depth_size),size=((max(df$price)-min(df$price))*35),alpha=0.9)+
    scale_colour_gradientn(colours=c(re,"white",bl),limits=c(-range,range))

  if (nrow(trade)!=0){
    figure<-figure+geom_point(data=trade,aes(x=Time,y=Price,shape=Trade),fill="black",size=3)+
    geom_text(data=trade,aes(x=Time,y=Price,label=Size),colour = "white", fontface = "plain",size=2)+
    scale_shape_manual(values=c(24,25))+
    scale_x_datetime(date_labels = "%H:%M:%S")+
    theme_bw()+
    theme(aspect.ratio=0.9)
  }else{
    figure<-figure+scale_x_datetime(date_labels = "%H:%M:%S")+
    theme_bw()+
    theme(aspect.ratio=0.9)
  }    
    # geom_point(data=trade,aes(x=Time,y=Price,shape=Trade),fill="black",size=3)+
    # geom_text(data=trade,aes(x=Time,y=Price,label=Size),colour = "white", fontface = "plain",size=2)+
    # scale_shape_manual(values=c(24,25))+
    # scale_x_datetime(date_labels = "%H:%M:%S")+
    # theme_bw()+
    # theme(aspect.ratio=0.9)
  if (output!=FALSE){
    ggsave(filename=output,path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-figures",width=10,height=8)
  }
}



# new re, bl
# bl <- colorRampPalette(c("lightskyblue1","lightskyblue","royalblue1","royalblue","navy"))(6)                      
# re <- colorRampPalette(c("#550000","darkred","firebrick3",'palevioletred3',"pink1","mistyrose"))(6)
plot_depth_spoof<-function(df,four_size,bl,re,output=FALSE){
  hour<-unique(format(df$Time,"%H"))
  f_sell<-four_size[four_size$depth<0,]
  f_buy<-four_size[four_size$depth>=0,]
  ggplot(df,aes(x=Time,y=price))+geom_segment(aes(x=Time,y=price,xend=Shift,yend=price,col=depth_size),size=8,alpha=0.9)+
    scale_colour_gradientn(colours=c(re,"white",bl),limits=c(-90,90))+
    scale_x_datetime(date_labels = paste(hour,":%M:%S",sep=""),breaks = date_breaks("1 sec"))+
    geom_vline(data = f_sell,alpha=0.3,size=1,linetype=8,colour="purple",show.legend = TRUE,aes(xintercept=as.numeric(Time)))+
    geom_vline(data = f_buy,alpha=0.3,size=1,linetype=8,colour="forestgreen",show.legend = TRUE,aes(xintercept=as.numeric(Time)))
  if (output!=FALSE){
    ggsave(filename=output,path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-figures\\",width=8.15,height=5.62)
    # 
  }
}

size_label_log<-function(trade){
  mean<-mean(trade$log_size)
  std<-sd(trade$log_size)*sqrt((dim(trade)[1]-1)/dim(trade)[1])
  if (is.na(std)){std<-0}
  if (mean-std<=0){
    size_range<- c(0.,exp(mean+1.5*std),exp(mean+2.5*std))
  }else{
    size_range<- c(exp(mean-std),exp(mean+1.5*std),exp(mean+2.5*std))
  }
  size_range<-round(size_range, 0)
  size_range<-as.character(size_range)
  range<-vector(mode="character")
  range[1]<-paste("[0,",size_range[1],"]",sep="")
  range[2]<-paste("(",size_range[1],",",size_range[2],"]",sep="")
  range[3]<-paste("(",size_range[2],",",size_range[3],"]",sep="")
  range[4]<-paste("(",size_range[3],",inf)",sep="")
  range
  }


size_label<-function(trade){
  mean<-mean(trade$Size)
  std<-sd(trade$Size)*sqrt((dim(trade)[1]-1)/dim(trade)[1])
  if (is.na(std)){std<-0}
  if (mean-std<0){
    size_range<- c(0,mean+1.5*std,mean+2.5*std)
  }else{
    size_range<- c(mean-std,mean+1.5*std,mean+2.5*std)
  }
  
  size_range<-round(size_range, 0)
  size_range<-as.character(size_range)
  range<-vector(mode="character")
  range[1]<-paste("[0,",size_range[1],"]",sep="")
  range[2]<-paste("(",size_range[1],",",size_range[2],"]",sep="")
  range[3]<-paste("(",size_range[2],",",size_range[3],"]",sep="")
  range[4]<-paste("(",size_range[3],",inf)",sep="")
  range
  }


shift_time<- function(df){
  df$Shift<-shift(df$Time,n=1,type="lead")
  df[nrow(df),]$Shift<-df[nrow(df),]$Time
  if (any(is.na(df$Shift))){
    print('still nan in shift')
  }
  df
}

scale_time<-function(df,start_str,end_str,f_size=data.frame(),price_filter=FALSE){
  op <- options(digits.secs=3)
  start<- strptime(start_str, "%H:%M:%OS")
  end<- strptime(end_str, "%H:%M:%OS")
  
  df<-df[(df$Time>=start & df$Time <= end),]
  
  if (nrow(f_size)){
    if (price_filter!=FALSE){
      f_size<-f_size[(f_size$Time>=start & f_size$Time <= end)&(f_size$price==price_filter),]
    }else{
      f_size<-f_size[(f_size$Time>=start & f_size$Time <= end),]
    }
    return (list(df,f_size))
  }
  return (list(df))
}


## for test
# hour<-unique(format(df_a$Time,"%H"))
# f_sell<-four_size_a[four_size_a$depth<0,]
# f_buy<-four_size_a[four_size_a$depth>=0,]
# ggplot(df_a,aes(x=Time,y=price))+geom_segment(aes(x=Time,y=price,xend=Shift,yend=price,col=depth_size),size=8,alpha=0.9)+
#   scale_colour_gradientn(colours=c(re,"white",bl),limits=c(-90,90))+
#   scale_x_datetime(date_labels = paste(hour,":%M:%S",sep=""),breaks = date_breaks("1 sec"))+
#   geom_vline(data = f_sell,alpha=0.3,size=1,linetype=8,colour="purple",show.legend = TRUE,aes(xintercept=as.numeric(Time)))+
#   geom_vline(data = f_buy,alpha=0.3,size=1,linetype=8,colour="forestgreen",show.legend = TRUE,aes(xintercept=as.numeric(Time)))


n_depth_plot_archive<-function(df,output=FALSE,re,bl){
  hour<-unique(format(df$Time,"%H"))
  ggplot(df,aes(x=Time,y=price))+geom_segment(aes(x=Time,y=price,xend=Shift,yend=price,col=depth_size),size=5,alpha=0.9)+
    scale_colour_gradientn(colours=c(re,"white",bl),limits=c(-75,75))+
    scale_x_datetime(date_labels = paste(hour,":%M:%S",sep=""))+coord_fixed(ratio = 7)
  if (output!=FALSE){
    ggsave(filename=output,path="C:\\Users\\Interns4\\Documents\\spoofing\\suger\\figures",width=8.15,height=5.62)
  }
}


# general functions 
#get the mode
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# extract date string and convert it into date type from the csv name
extr_date<-function(item){
  date_str=paste(strsplit(item, split="-",fixed=TRUE)[[1]][2:4],collapse="-")
  ymd(date_str)
}