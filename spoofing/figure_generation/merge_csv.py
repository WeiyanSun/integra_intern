# this code is for python 3, please install pandas package before use 
## change two place before use:
##1. read csv path, 2.output excel path

import pandas as pd
from pandas import ExcelWriter
import os
import time
import pdb

def write_excel_one_day(path,output_path,dir_list):
	writer = ExcelWriter(output_path)
	# open each csv and put them into one xlsx file with sheet name equal to csv name
	for csv in dir_list:
	    current_path=path+'\\'+csv
	    sheet=".".join(csv.split(".")[1:-1])
	    sheet=sheet[4::]
	    if len(sheet)>31:
	    	sheet=sheet[len(sheet)-31:]
	    a=pd.read_csv(current_path)
	    a.to_excel(writer,sheet_name=sheet,index=False)
	writer.save()

t=time.time()
print("start ",t)
day_list=[]
# change here
path=r"\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-raw-sc"
#get the list of all csv file in a directory 
for filename in os.listdir(path):
	day_list.append(filename)

for day in day_list:
	if (day!="2016-07-24") and (day!="2016-07-25") and (day!="2016-07-26") and (day!="2016-07-27") and (day!="2016-07-28") and (day!="2016-07-29") :
		continue
	new_path=path+"\\"+day
	future_list=[]
	for filename in os.listdir(new_path):
		future_list.append(filename)
	for future in future_list:
		#pdb.set_trace()
		t=time.time()
		hour_list=[]
		last_path=new_path+"\\"+future
		for filename in os.listdir(last_path):
			hour_list.append(filename)
		hour_list=[x for x in hour_list if "markov" not in x]
		hour_list=[x for x in hour_list if "summary" not in x]
		excel_name=future+"-"+day
		check_path="\\\\SERVER1\\\\Dropbox\\\\spoofing\\\\test-output\\\\spoof-candidates\\\\output-sc-excel\\\\"+day+"\\"+future
		output_path=check_path+"\\"+excel_name+".xlsx"
		if not os.path.exists(check_path):
			os.makedirs(check_path)
		write_excel_one_day(last_path,output_path,hour_list)
		elapsed=time.time()-t
		print("finish ",future," use",elapsed," sec")
	print("finish ",day)
# if current directory only contains one day
# write_excel_one_day("\\INTEGRA-SERVER\\REC Projects\\Spoofing\\combine excel\\combine_gold_7_11.xlsx",dir_list)

# # get rid of csv of markov and summary
# dir_list=[x for x in dir_list if "markov" not in x]
# dir_list=[x for x in dir_list if "summary" not in x]
# # get the unique time list
# time_list=set([x[8:18] for x in dir_list])
# print(time_list)
# for time in time_list:
# 	cur_dir=[x for x in dir_list if time in x]
# 	output_path="C:\\Users\\Interns4\\Documents\\spoofing\\combined_excel\\suger\\"+time+".xlsx"
# 	write_excel_one_day(path,output_path,cur_dir)
