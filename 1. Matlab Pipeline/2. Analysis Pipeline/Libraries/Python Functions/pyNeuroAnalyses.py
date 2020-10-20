# -*- coding: utf-8 -*-
"""
Created on Sun Oct 18 12:37:06 2020

These functions can be used in python of course, but were designed for matlab
utility.

@author: JS
"""

# these functions are a bit redundant, but are useful for matlab
def shannons_entropy(data):
    """
    https://www.kite.com/python/answers/how-to-calculate-shannon-entropy-in-python   
    """
    # import libraries
    import pandas as pd
    import scipy.stats as stat
    
    # convert to pandas
    pd_series = pd.Series(data)
    counts    = pd_series.value_counts()
    
    # probability
    prob = counts/sum(counts)
    
    # get entropy
    entropy = stat.entropy(prob, base=2)

    return [entropy]


