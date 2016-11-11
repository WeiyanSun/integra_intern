import pandas as pd
import os
import pdb
import numpy as np

def trade_summary(a,out_path):
    temp=a[['Time','Size','Price']]
    result=temp[~pd.isnull(temp['Price'])]
    if result.empty:
        return 0
    result['buy']=np.nan
    for i, row in temp[~pd.isnull(temp['Price'])].iterrows():
        ind_list=temp[~pd.isnull(temp['Price'])].index
        index=i-1
        price=row['Price']
        if str(price).split(".")[-1]=="0":
            price=int(price)
        while index in ind_list:
            index=index-1
        if index==-1:
            index=temp[pd.isnull(temp['Price'])].index[0]
        # sometimes the trade price not in the csv, we just skip it
        try:
            depth=a.loc[index,str(price)]
            if int(depth)>=0:
                buy=0
            else:
                buy=1
            result.loc[i,"buy"]=buy
        except KeyError:
            result.drop([i],inplace=True)

    result['Size'] = result.groupby(['Time',"Price","buy"])['Size'].transform('sum')
    result.drop_duplicates(subset=['Time','Size','Price'],inplace=True)
    result.to_csv(out_path,index=False)


#path="Z:\\Spoofing\\spoofing\\combined_excel\\suger"

#dir_list=[]
#path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-excel"
#get the list of all excel file in a directory 

# filename is e.g 2016-07-11
# for filename in os.listdir(path):
#     dir_list.append(filename)
# # only try the first two days.
# dir_list=dir_list[0:2]
# print(dir_list)
# for filename in dir_list:
#     next_path=path+"\\"+filename
#     for file in os.listdir(next_path):
#         cur_path=next_path+"\\"+file
#         x=pd.ExcelFile(cur_path)
#         for name in x.sheet_names:
#             # this name means this excel is empty
#             if name=="Sheet1":
#                 continue
#             a= x.parse(name)
#             # change to str convience for indexing
#             a.columns=[str(x) for x in a.columns]
#             out_path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-sc-intermid-csv\\trade\\"+name+".csv"
#             trade_summary(a,out_path)
#         print("finish",file)
dir_list=[]
path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-raw-rotating"
#get the list of all excel file in a directory 

# filename is e.g 2016-07-11
for filename in os.listdir(path):
    dir_list.append(filename)
#print(dir_list)
for filename in dir_list: 
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
                a.columns=[str(x) for x in a.columns]
                out_path="\\\\SERVER1\\Dropbox\\spoofing\\test-output\\spoof-candidates\\output-rotating-result\\output-rotating-intermid-csv\\trade\\"+out_csv
                trade_summary(a,out_path)