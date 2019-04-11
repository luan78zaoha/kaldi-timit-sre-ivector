#coding: utf-8

import os
path = os.getcwd()

mm = 1
####### modify dir name ####
for d in os.listdir(os.path.join(path, "timit_sre", "wav", "train")):
    if len(str(mm)) == 1:
        n_d = "SP000" + str(mm)
        os.rename(os.path.join(path,"timit_sre",  "wav", "train", d), os.path.join(path,"timit_sre", "wav", "train", n_d))
        mm += 1
    elif len(str(mm)) == 2:
        n_d = "SP00" + str(mm)
        os.rename(os.path.join(path,"timit_sre", "wav",  "train", d), os.path.join(path,"timit_sre", "wav", "train", n_d))
        mm += 1
    else:
        n_d = "SP0" + str(mm)
        os.rename(os.path.join(path,"timit_sre",  "wav", "train", d), os.path.join(path,"timit_sre", "wav", "train", n_d))
        mm += 1
print("Train over!")
for d in os.listdir(os.path.join(path, "timit_sre",  "wav", "test")):
    n_d = "SP0" + str(mm)
    os.rename(os.path.join(path,"timit_sre",  "wav", "test", d), os.path.join(path,"timit_sre", "wav", "test", n_d))
    mm += 1
print("Test over!")

####### modify wav name ######
for root, dirs, files in os.walk(os.path.join(path, "timit_sre")):
    print("*"*10)
    print("root: {0}, dir:{1}".format(root,dirs))
    print("SpeakerID " + root[-6:])
    n=0
    for name in files:
        if(name.endswith(".PHN")):
            os.remove(os.path.join(root, name))
        elif(name.endswith(".TXT")):
            os.remove(os.path.join(root, name))
        elif(name.endswith(".WRD")):
            os.remove(os.path.join(root, name))
        else:
            new_name = root[-6:] + "W0" + str(n) + ".wav"
            os.rename(os.path.join(root, name), os.path.join(root, new_name))
            n += 1
    print(os.listdir(root))