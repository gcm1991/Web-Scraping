# -*- coding: utf-8 -*-
"""
Created on Thu Jul 22 19:36:06 2021

@author: cayde
"""
import os
import requests
import pandas as pd

#requests is the package that does the magic

#Change this directory to wherever you are getting the excel file from
os.chdir("E:\Graduate Studies\Misc\RM\Stein")

#Reading in the excel file (You can also just use the full path directory here like I did)
voters_2018_school = pd.read_csv("E:/Graduate Studies/Misc/RM/Stein/2018_voters_who_voted_w_addr_split.csv")

#Defining the URL
url = "https://tech.springbranchisd.com/Public/GetAddressesJSon"
#NOTE, this is NOT the url you gave me. Whenever you type info in on the site it uses a GetAddressesJSON
#You need to use this url. You can access this URL by going to the site and entering information
#After that, inspect element -> network, and the info should be under there

#Simply looping through all the data
for i in range(len(voters_2018_school)):
    #Getting the address number from the excel file
    street_numb = voters_2018_school.loc[i,'address_number']
    #Getting the address street name from the excel file
    street_name = voters_2018_school.loc[i,'address_name']

    #Here I am creating a dictionary using the number and name I just got from the excel file
    #The 'streetNumber' and 'streetName' are variables defined by the website.
    #You can access these variables the same way you found the URL
    #I am telling it to put name and number I extracted from the excel file into the website fields
    data = {
    'streetNumber': int(street_numb),
    'streetName': street_name
    }
    
    #After I have entered the name and number, the response is printing out all of the schools that show up on the website
    response = requests.post(url, data=data).text
    
    #Not all of the addresses returned schools, this 'if' skips over them if they don't have a school
    if response != "[]":
        #If they do have a school, the response is a giant string containing all the schools
        #I am just splitting the string to obatin the middle school.
        response = response.split(',')
        response = response[4]
        response = response.split(':')
        response = response[1]
        
    #After I have the middle school I am putting it into a new column that corresponds to the row
    voters_2018_school.loc[i,'middle_school'] = response
    print(i)
    
#Writing the dataframe to an excel sheet
voters_2018_school.to_excel("E:/Graduate Studies/Misc/RM/Stein/voters_2018_school.xlsx")




