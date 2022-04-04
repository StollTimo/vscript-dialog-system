#Translates json to squirrel table syntax since json isn't supported in v2.2.3 (CS:G0)

import re
import tkinter as tk
from tkinter import filedialog

def openFile():
    root = tk.Tk()
    root.withdraw()
    filePath = filedialog.askopenfilename()
    global jsonFile
    jsonFile = open(filePath, "r")

def saveFile():
    root = tk.Tk()
    root.withdraw()
    filePath = filedialog.asksaveasfile(mode='w', defaultextension=".nut")
    print(tableString)
    filePath.write(tableString)
    filePath.close()

def processJSON():
    jsonString = jsonFile.read()
    jsonFile.close()

    occurenceList = re.findall('["].*["]:' ,jsonString)

    listIndex = 0
    changeList = []

    global tableString

    for element in occurenceList:
        element = element.replace(":", "=")
        element = element.replace('"', '')
        changeList.append(element)
        jsonString = jsonString.replace(occurenceList[listIndex], changeList[listIndex])
        listIndex+=1

    tableString = "dialogTable <-" + jsonString + "}"

openFile()
processJSON()
saveFile()
