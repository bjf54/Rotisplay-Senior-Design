import numpy as np
import math

def pol2cart(r, theta):
    theta = np.deg2rad(theta)
    return (r * np.cos(theta), r * np.sin(theta))

def cart2pol(x, y):
    return (np.sqrt(x**2 + y**2), np.arctan2(y, x))

size = 20
x,y = pol2cart(size, 0)
print(round(size+x), round(size+y))
x2, y2 = pol2cart(size, 1)
print(round(size+x2), round(size+y2))