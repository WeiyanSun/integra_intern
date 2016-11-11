import pandas as pd
import numpy as np
from datetime import datetime
import pdb
import os



def float_to_int(str_value):
	if str_value.split(".")[-1]=="0":
		return str_value.split(".")[0]
	else:
		return str_value

def find_n_depth_new(a,output_path,n=10):
    # to avoid further error, it is safe to change the column elements into string.
    a.columns=[str(x) for x in a.columns]
    a.iloc[:,4:]=a.iloc[:,4:].apply(lambda x: pd.to_numeric(x, errors='coerce'))
    column=a.columns
    n_level_df=pd.DataFrame(columns=column)
    price_list=a.columns[4::].tolist()
    for i, row in a.iterrows():
        if sum(pd.notnull(row[price_list]))==0:
            continue
        if any((row[price_list]>=0).diff(1)==True)==False:
            continue
        first_sell=row[price_list][(row[price_list]>=0).diff(1)==True].index[0]
        first_sell_v=price_list.index(first_sell)
        temp=pd.DataFrame(columns=column)
        temp.loc[0,'Time']=row['Time']
        for i in range(1,n+1,1):
            try:
                plus=price_list[first_sell_v+(i-1)]
                temp.loc[0,plus]=row[row.index==plus].values[0]
            except IndexError:
                print("plus")
            try:
                minus=price_list[first_sell_v-i]
                temp.loc[0,minus]=row[row.index==minus].values[0]
            except IndexError:
                print("minus")
        n_level_df=pd.concat([n_level_df,temp])
    n_level_df['number']=list(range(1,len(n_level_df)+1,1))
    n_level_df.to_csv(output_path,index=False)

def find_n_depth(a,output_path,n=10):
    # to avoid further error, it is safe to change the column elements into string.
    a.columns=[str(x) for x in a.columns]
    a.iloc[:,4:]=a.iloc[:,4:].apply(lambda x: pd.to_numeric(x, errors='coerce'))
    column=a.columns
    n_level_df=pd.DataFrame(columns=column)
    price_list=a.columns[4::]
    for i, row in a.iterrows():
        if sum(pd.notnull(row[price_list]))==0:
            continue
        first_sell=row[price_list][(row[price_list]>=0).diff(1)==True].index[0]
        first_sell_v=float(first_sell)
        temp=pd.DataFrame(columns=column)
        temp.loc[0,'Time']=row['Time']
        for i in range(1,n+1,1):
            plus=float_to_int(str(round(first_sell_v+(i-1)/10,1)))
            minus=float_to_int(str(round(first_sell_v-i/10,1)))
            temp.loc[0,plus]=row[row.index==plus].values[0]
            temp.loc[0,minus]=row[row.index==minus].values[0]
        n_level_df=pd.concat([n_level_df,temp])
    n_level_df['number']=list(range(1,len(n_level_df)+1,1))
    n_level_df.to_csv(output_path,index=False)


#when we have several excels file to do at once.
dir_list=[]
path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-raw-rotating"
#get the list of all excel file in a directory 

# filename is e.g 2016-07-11
for filename in os.listdir(path):
    dir_list.append(filename)
#print(dir_list)
for filename in dir_list: 
    day=filename
    if (day=="2016-07-06") or (day=="2016-07-08") or (day=="2016-07-26") or (day=="2016-07-12") or (day=="2016-07-14") or (day=="2016-07-21") or (day=="2016-07-26"):
        continue
    next_path=path+"\\"+filename
    future_list=[]
    # future is fGC.Z17 like in a time folder
    for future in os.listdir(next_path):
        future_list.append(future)
    for file in future_list:
        cur_path=next_path+"\\"+file
        for gz in os.listdir(cur_path):
            if ("markov" not in gz) and ("summary" not in gz):
                final_path=cur_path+"//"+gz
                a= pd.read_csv(final_path,compression='gzip')
                out_csv=".".join(gz.split(".")[0:-1])
                out_path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-rotating-result\\output-rotating-intermid-csv\\n_depth\\"+out_csv
                find_n_depth_new(a,out_path)
                print("finish",gz)


# test
# cur_path=path+"\\"+"2016-07-29.xlsx"
# x=pd.ExcelFile(cur_path)
# for name in x.sheet_names:
#     a= x.parse(name)
#     out_path="C:\\Users\\Interns4\\Documents\\spoofing\\whole_july\\n_depth\\"+name+".csv"
#     find_n_depth_new(a,out_path)

# # when we only focus on one excel file.
# dir_list=[]
# x=pd.ExcelFile("C:\\Users\\Interns4\\Documents\\spoofing\\gold 07-26\\gold-20160726-spoof-wide.xlsx")
# n=10    
# i=1
# for name in x.sheet_names:
#     a= x.parse(name)
#     out_path="C:\\Users\\Interns4\\Documents\\spoofing\\gold 07-26\\"+name+".csv"
#     find_n_depth_new(a,out_path)