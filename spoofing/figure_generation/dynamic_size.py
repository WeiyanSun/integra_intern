import os
import pandas as pd
import scipy
import pdb 

def dynamic_size(size,std,mean):
	if size<=mean-std:
		return 0.8
	elif (size>=mean-std) and (size<=mean+1.5*std):
		return 1.5
	elif (size>mean+1.5*std) and (size<=mean+2.5*std):
		return 3 
	elif (size>mean+2.5*std):
		return 6


path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-intermid-csv\\trade"
path2="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-intermid-csv\\trade_log"

dir_list=[]

for filename in os.listdir(path):
	dir_list.append(filename)

for file in dir_list:
	cur_path=path+"\\"+file
	out_path=path2+"\\"+file
	temp=pd.read_csv(cur_path)
	temp['log_size']=scipy.log(temp['Size'])
	# orginal edition
	#std=scipy.std(temp['Size'])
	#mean=scipy.mean(temp['Size'])
	#pdb.set_trace()
	#log edition
	std=scipy.std(temp['log_size'])
	mean=scipy.mean(temp['log_size'])
	temp['shape']=temp['log_size'].apply(lambda x: dynamic_size(x,std,mean))
	temp.to_csv(out_path,index=False)