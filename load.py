import os
import pandas as pd
import numpy as np
from six.moves import urllib
from pathlib import Path

ROOT_PATH = '../../Dataset_UNASUS_UFMA'
COURSE_PATH = None
MODULE_PATH = None
CLASS_PATH = None

GRADES_PATH = 'Grades.xlsx'
LOGS_PATH = 'logs.xlsx'
INPUT_PATH = 'input.csv'

def load_logs_data(path):
    xls_path = os.path.join(path, LOGS_PATH)
    if os.path.exists(xls_path):
        return pd.read_excel(xls_path,skiprows=2)
    print(xls_path)
    print("Wrong logs path!")


def load_grades_data(path):
    xls_path = os.path.join(path,GRADES_PATH)
    if os.path.exists(xls_path):
        return pd.read_excel(xls_path)
    print(xls_path)
    print("Wrong grades path!")


def load_input_data(path):
    csv_path = os.path.join(path, INPUT_PATH)
    if os.path.exists(csv_path):
        return pd.read_csv(csv_path)
    print(csv_path)
    print("Wrong input path!")


def arrange_data_by_class(root_path=ROOT_PATH, course_path=COURSE_PATH, module_path=MODULE_PATH, class_path=CLASS_PATH, path=None):
    dataset_path = path
    if path is None:
        dataset_path = os.path.join(root_path,course_path,module_path,class_path)

    logs_path = os.path.join(dataset_path,LOGS_PATH)
    if not os.path.exists(logs_path):
        print ("Without logs in ",dataset_path)
        return

    grades_path = os.path.join(dataset_path,GRADES_PATH)
    if not os.path.exists(grades_path):
        print ("Without grades in ",dataset_path)
        return

    logs = load_logs_data(dataset_path)
    grades = load_grades_data(dataset_path)

    #Take name and actions without links
    df_logs = pd.DataFrame(columns=["Name","Action"])
    df_logs["Name"] = logs["User full name"]
    df_logs["Action"] = logs["Action"].str.split("(").str[0].str.strip()

    ftab_col = ["Name","Grades"]
    actions = []

    #Take actions from log and append to ftab_col and actions
    for act in df_logs["Action"].unique():
        actions.append(act)
        ftab_col.append(act)

    #Make ftab with columns Name, Grades and Actions
    ftab = pd.DataFrame(columns=ftab_col)
    ftab["Name"] = grades["First name"] + " " + grades["Surname"]
    if "Média Final" in grades.columns: #Verify if there is "Média Final" column
        ftab["Grades"] = grades ["Média Final"]
    elif "Course total" in grades.columns: #Verify if there is "Course Total" column
        ftab["Grades"] = grades ["Course total"]
    else:
        print ("Without grades in ", logs_path)

    #Assign columns actions with frequency of each user
    for name in ftab["Name"].unique(): #Take names
        df_aux_name = df_logs.loc[df_logs["Name"] == name] #select actions logs grouped by user name
        for act in actions: #Assign to ftab the frequency of actions for each user
            df_aux_act = df_aux_name.loc[df_aux_name["Action"]==act]
            ftab.loc[ftab["Name"]==name,act] = df_aux_act["Action"].count()

    path = os.path.join(dataset_path, INPUT_PATH)
    ftab.to_csv(path,index=False)

    return ftab


def arrange_data_by_module(root_path=ROOT_PATH, course_path=COURSE_PATH, module_path=MODULE_PATH, path=None):
    dataset_path = path
    if path is None:
        dataset_path = os.path.join(root_path,course_path,module_path)

    classes_folders = []
    files_path = []
    input_path = []
    lInput = []

    for (dirpath, dirnames, filenames) in os.walk(dataset_path): #Get all the classes in the module
        classes_folders.extend(dirnames)
        break

    if(len(classes_folders)==0): #Verify if the current module has some class
        files_path.append(dataset_path)
        input_path.append(os.path.join(dataset_path,INPUT_PATH))
    else:
        classes_folders.sort()
        for i in range(0,len(classes_folders)):
            files_path.append(os.path.join(dataset_path,classes_folders[i]))
            input_path.append(os.path.join(dataset_path,classes_folders[i],INPUT_PATH))

    for i in range(0,len(input_path)): #Get all input files
        if not os.path.exists(input_path[i]): #Verify if there is a input file
            arrange_data_by_class(path=files_path[i]) #Otherwise, generate a input file

        lInput.append(load_input_data(files_path[i])) #Add into list each input
        class_path = "Turma_Unica"
        if len(classes_folders)>0:
            class_path = classes_folders[i]
        print(class_path)
        lInput[i].insert(loc=0,column="Class",value=class_path) #Add into the list a column to assign a class

    if len(input_path)==1:
        ftab = lInput[0].fillna(0)
    else:
        ftab = lInput[0]
        for i in range(1,len(input_path)):
            ftab = pd.concat([ftab,lInput[i]], ignore_index=True, sort=False)
            # ftab = pd.concat([ftab,lInput[i]], ignore_index=True)

        df_aux = pd.DataFrame(columns=["Class","Name","Grades"])
        df_aux["Class"] = ftab["Class"]
        df_aux["Name"] = ftab["Name"]
        df_aux["Grades"] = ftab["Grades"]
        ftab = pd.concat([df_aux,ftab.iloc[:,3:]],axis=1)

        ftab = ftab.fillna(0)

    path = os.path.join(dataset_path,INPUT_PATH)
    ftab.to_csv(path,index=False)

    return ftab


def arrange_data_by_course(root_path=ROOT_PATH, course_path=COURSE_PATH):
    print(course_path)
    print ("checking files...")
    if not check_course(root_path,course_path): #Verify if there are logs and grades in all the modules
        return

    dataset_path = os.path.join(root_path, course_path)

    module_folders = []
    module_path = []
    input_path = []
    lInput= []
    for (dirpath, dirnames, filenames) in os.walk(dataset_path): #Get all the modules in the course
        module_folders.extend(dirnames)
        break

    module_folders.sort()
    for i in range(0,len(module_folders)): #Get all module paths
        module_path.append(os.path.join(dataset_path,module_folders[i]))
        input_path.append(os.path.join(dataset_path,module_folders[i],INPUT_PATH))

    for i in range(0,len(input_path)): #Get all input files
        print(module_folders[i])
        if not os.path.exists(input_path[i]): #Verify if there is a input file
            arrange_data_by_module(path=module_path[i]) #Otherwise, generate a input file

        lInput.append(load_input_data(module_path[i])) #Add into list each input
        lInput[i].insert(loc=0,column="Module",value=module_folders[i]) #Add into the list a column to assign a class

    ftab = lInput[0]
    for i in range(1,len(module_folders)):
        ftab = pd.concat([ftab,lInput[i]], ignore_index=True, sort=False)
        # ftab = pd.concat([ftab,lClass[i]], ignore_index=True)

    df_aux = pd.DataFrame(columns=["Module","Class","Name","Grades"])
    df_aux["Module"] = ftab["Module"]
    df_aux["Class"] = ftab["Class"]
    df_aux["Name"] = ftab["Name"]
    df_aux["Grades"] = ftab["Grades"]
    ftab = pd.concat([df_aux,ftab.iloc[:,4:]],axis=1)

    ftab = ftab.fillna(0)

    path = os.path.join(dataset_path,INPUT_PATH)
    ftab.to_csv(path,index=False)

    return ftab


def check_course(root_path=ROOT_PATH, course_path=COURSE_PATH):
    dataset_path = os.path.join(root_path, course_path)

    module_folders = []
    classes_folders = []
    for (dirpath, dirnames, filenames) in os.walk(dataset_path): #Get all the modules in the course
        module_folders.extend(dirnames)
        break

    module_folders.sort()
    for i in range(0,len(module_folders)):
        # print(module_folders[i])

        module_path = os.path.join(root_path, course_path, module_folders[i])
        for (dirpath, dirnames, filenames) in os.walk(module_path): #Get all the classes in the module
            classes_folders.extend(dirnames)
            break

        if (len(classes_folders) > 0): #Verify if the current module has some class
            classes_folders.sort()
            for i in range(0,len(classes_folders)):
                # print(classes_folders[i])
                class_path = os.path.join(root_path,course_path,module_path,classes_folders[i])

                logs_path = os.path.join(class_path,LOGS_PATH)
                if not os.path.exists(logs_path):
                    print ("Without logs ",class_path)
                    return False

                grades_path = os.path.join(class_path,GRADES_PATH)
                if not os.path.exists(grades_path):
                    print ("Without grades in ",class_path)
                    return False
        else:
            logs_path = os.path.join(module_path,LOGS_PATH)
            if not os.path.exists(logs_path):
                print ("Without logs ",module_path)
                return False

            grades_path = os.path.join(module_path,GRADES_PATH)
            if not os.path.exists(grades_path):
                print ("Without grades in ",module_path)
                return False

        classes_folders.clear()

    return True

def fix_data(root_path=ROOT_PATH, course_path=COURSE_PATH, module_path=MODULE_PATH, path=None):    
    dataset_path = path
    if path is None:
        dataset_path = os.path.join(root_path,course_path,module_path)

    logs_path = os.path.join(dataset_path,LOGS_PATH)
    if not os.path.exists(logs_path):
        print ("Without logs in ",dataset_path)
        return

    logs = load_logs_data(dataset_path)
    print (dataset_path)

    return logs

    
