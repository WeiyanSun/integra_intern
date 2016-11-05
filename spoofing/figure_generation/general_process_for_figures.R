library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(readxl)
library(grid)
library(scales)
library(gtable)
library(grid)

source("\\\\SERVER1\\REC Projects\\Spoofing\\spoofing\\update_code\\function_for_spoofing.R")

# defin color pattern 
bl <- colorRampPalette(c("lightskyblue1","lightskyblue","royalblue1","royalblue","navy"))(6)                      
re <- colorRampPalette(c("#550000","darkred","firebrick3",'palevioletred3',"pink1","mistyrose"))(6)



# path="C:\\Users\\Interns4\\Documents\\spoofing\\gold-2016-7-11\\n_depth"
#path="C:\\Users\\Interns4\\Documents\\spoofing\\whole_july\\n_depth_new"

path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-intermid-csv\\n_depth_new"
trade_path<-"\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-intermid-csv\\trade_log_new"
file.names <- dir(path, pattern =".csv")

# focus on certain part
new_name<-character()
for (item in file.names){
  if (grepl("2016-07-01", item) & (grepl("fGC",item)) ) {
    new_name<-append(new_name,item)
  }
}


temp<-dir(trade_path, pattern =".csv")

#file.names<-c('2016-07-11-bigCancel-lvl=1-n11.csv')

for (item in new_name){
  new_list<-read_prepro(paste(path,"\\",item,sep=""))
  df<-new_list$df
  upper<-new_list$upper
  lower<-new_list$lower
  if (item %in% temp){
    trade<- prepro_trade(paste(trade_path,"\\",item,sep=""))
    trade<-subset(trade,Price>=lower & Price<=upper)
    n_depth_plot_dynamic_size(df,trade,paste(item,".png"),re,bl)
  }else{
    n_depth_plot_dynamic_size(df,data.frame(),paste(item,".png"),re,bl)
  }
  #break
  #  if (i==2){
  #    break
  #  }
  #  i=i+1
}
