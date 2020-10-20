# -*- coding: utf-8 -*-
"""
Created on Sun Oct 18 12:37:06 2020

data = [1,2,2,3,3,3]

pd_series = pd.Series(data)
counts = pd_series.value_counts()
entropy = stat.entropy(counts)

https://www.kite.com/python/answers/how-to-calculate-shannon-entropy-in-python

@author: JS
"""

def library_import():
    
    import pandas as pd
    import scipy.stats as stat
    import scipy.io as sio
    
    return;

def shannons_entropy(data):
    
    # this needs to made into a function that can be called into matlab
    #import pandas as pd
    #import scipy.stats as stat
    #import scipy.io as sio

    # shannons entropy
    #mat       = sio.loadmat('testing_entropy.mat', squeeze_me=True)
    #data      = mat["binned_data"]
    pd_series = pd.Series(data)
    counts    = pd_series.value_counts()
    entropy   = stat.entropy(counts)

    return [entropy]


