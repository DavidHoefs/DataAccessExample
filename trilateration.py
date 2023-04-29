import matplotlib.pyplot as plt
import sympy as sp
from sympy.solvers import solve
from sympy import *
import numpy as np
#reference : https://math.stackexchange.com/questions/884807/find-x-location-using-3-known-x-y-location-using-trilateration
fig, ax = plt.subplots()
#Use adjustable='box-forced' to make the plot area square-shaped as well.
ax.set_aspect('equal', adjustable='datalim')
ax.plot()   #Causes an autoscale update.
# beacon 1 location and distance from tag
x1 =650
y1=375
r1=2
# beacon 2 location and distance from tag
x2 = 500
y2= 300
r2= 4
# beacon 3 location and distance from tag
x3 = 800
y3 = 300
r3 = 5
beacon1 = plt.Circle((x1, y1), r1, color='r', alpha=0.5,)
beacon2 = plt.Circle((x2, y2), r2, color='blue', alpha=0.5)
beacon3 = plt.Circle((x3, y3), r3, color='yellow', alpha=0.5)
# plot the three beacons with signal distance as radius
ax.add_patch(beacon1)
ax.add_patch(beacon2)
ax.add_patch(beacon3)


# Setup variables and solve equation
A = (-2*x1 + 2*x2)
B = (-2*y1 + 2*y2)
C = r1**2 - r2**2 - x1**2 + x2**2 - y1**2 + y2**2
F = r2**2 - r3**2 - x2**2 + x3**2 - y2**2 + y3**2
D = (-2*x2 + 2*x3)
E = (-2*y2 + 2 * y3)

CE = simplify(C * E)
FB = simplify(F * B)
AE = simplify(A * E)
BD = simplify(B * D)
AF = simplify(A * F)
CD = simplify(C * D)

print(CE)
print(FB)
print(AE)
print(BD)
print(AF)
print(CD)

# Solve 
xSolved = (CE - FB) / (AE - BD)
ySolved = (AF - CD) / (AE - BD)
colors = np.array(["red","blue","yellow","black"])
plt.scatter([x1,x2,x3,xSolved], [y1,y2,y3,ySolved], label= "stars", c=colors, s=30)
# plot the location of the tag using the solved x and y
lotLocation = plt.Circle((xSolved, ySolved), 1, color='black', alpha=0.5)
ax.add_patch(lotLocation)
ax.legend([beacon1,beacon2,beacon3,lotLocation],['beacon1','beacon2','beacon3','lot/cart'])
plt.show()


