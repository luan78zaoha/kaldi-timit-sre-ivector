# coding: utf-8
#
# sph2pip .nist to .wav
#

import os
import sys

def nist2wav(src_dir):
    count = 0
    for subdir, _, files in os.walk(src_dir):
        print("*"*20)
        for f in files:
            fullFilename = os.path.join(subdir, f)
            if f.endswith('.wav'):
                count += 1
                os.rename(fullFilename,fullFilename+".WAV")
                os.system("sph2pipe "+fullFilename+".WAV"+" -f rif " +fullFilename)
                os.remove(fullFilename+".WAV")
                print(fullFilename)

if __name__ == '__main__':
    os.system(". ./path.sh")
    if len(sys.argv) != 2:
        print('usage: no <data-wav-dir>')
        sys.exit()
    path = sys.argv[1]
    if os.path.exists(path):
        nist2wav(path)
        print("Transform finished!")
    else:
        print(path+" is not exist!")
