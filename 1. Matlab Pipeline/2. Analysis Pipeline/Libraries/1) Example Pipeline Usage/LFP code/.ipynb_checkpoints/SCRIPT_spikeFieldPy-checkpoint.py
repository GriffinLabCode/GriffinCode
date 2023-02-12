import scipy.io as sio
from pylab import *
rcParams['figure.figsize']=(12,3)                   # Change the default figure size
import matplotlib.pyplot as plt

data = sio.loadmat('spikefieldData.mat')