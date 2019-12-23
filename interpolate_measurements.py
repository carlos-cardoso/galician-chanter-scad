import numpy as np
from scipy.optimize import minimize
import matplotlib.pyplot as plt

holes_center_from_top = [58.05, 66.25, 90.05, 115.60, 141.65, 165.00, 189.65, 216.45, 238.85, 257.90, 317.00];
holes_diam_vertical   = [ 1.50,  2.70,  3.50,  4.40 ,   4.30,   8.00,   7.50,   5.50,   5.50,   8.00,  20,00];
holes_diam_horizontal = [ 1.50,  2.70,  3.70,  4.50 ,   4.60,   8.35,   7.50,   5.50,   5.50,   8.00,  20.00];
#//holes_cone_outer_diam = [ 12.0, 12.30, 13.40, 14.60 ,  16.80,  17.20,  18.20,  19.30,  19.90,  22.00,  48.40];
holes_cone_outer_diam = [12.0, 12.30, 13.40, 14.60 ,  16.80,  17.20,  18.20,  19.30,  19.90,  22.00,  28];
hole_angle =            [180.0,   0.0,   0.0,   0.0 ,    0.0,    0.0,    0.0,  340.0,  180.0,   -90.0,   0.0];

lenght_from_espigo    = [0.00, 17.15, 23.45, 32.8, 46.4, 61.45, 73.65, 85.1, 98, 110.9, 123.4, 134.25, 144.1, 153.0, 157, 175.1, 184, 198.7 , 227, 241.25, 261.5, 266.3, 290.0, 317];
inner_diam            = [6.50,  4.00,  4.25,  4.5,  5.0,  5.5 ,  6.0 ,  6.5,  7,   7.5,   8.0,   8.5 ,   9.0,   9.5,  10,  10.5,  11,  11.75,  13,  14.00,  15.0,  15.5,  17.5,  20];

espigo_diam_exterior            = 15.30;
espigo_altura                   = 23.20;

lens_outer = [0,espigo_altura] + holes_center_from_top
outer_diam = [espigo_diam_exterior, espigo_diam_exterior] + holes_cone_outer_diam


from scipy import interpolate

def f(x,x_points=[ 0, 1, 2, 3, 4, 5],y_points= [12,14,22,39,58,77]):
    tck = interpolate.splrep(x_points, y_points)
    return interpolate.splev(x, tck)

"""
x=np.array(holes_center_from_top)
y=np.array(holes_cone_outer_diam)

points_per_mm=10

total_length=holes_center_from_top[-1]
n_points = int(total_length*points_per_mm)
xs=np.zeros(n_points)
for i in range(n_points):
    xs[i]=i*(1/points_per_mm)

interp = f(xs, x, y)
plt.plot(x,y, '.')
plt.plot(xs,interp)
plt.gca().set_aspect('equal', adjustable='box')
plt.show()
"""

def run_interpolate(x,y,points_per_mm=1):
    total_length=holes_center_from_top[-1]
    n_points = int(total_length*points_per_mm)
    xs=np.zeros(n_points)
    for i in range(n_points):
        xs[i]=i*(1/points_per_mm)

    #https://stackoverflow.com/questions/12427146/combine-two-arrays-and-sort/12427633#12427633
    c = np.concatenate((xs, x))
    c.sort(kind='mergesort')
    flag = np.ones(len(c), dtype=bool)
    np.not_equal(c[1:], c[:-1], out=flag[1:])
    xs=c[flag]
    return xs,f(xs, x, y)

x=np.array(lenght_from_espigo)
y=np.array(inner_diam)
xs_inner, interp_inner = run_interpolate(x,y)

plt.plot(x,y, '.')
plt.plot(xs_inner,interp_inner)
plt.gca().set_aspect('equal', adjustable='box')
plt.show()

x=np.array(lens_outer)
y=np.array(outer_diam)
xs_outer, interp_outer = run_interpolate(x,y)


with open('interpolated.scad', 'w') as f:
    print('lens_inner=[', end = " ", file=f)  # Python 3.x
    print (*xs_inner, end = " ", sep=" ,", file=f)
    print('];', file=f)  # Python 3.x

    print('inner_diam=[', end = " ", file=f)  # Python 3.x
    print (*interp_inner, end = " ", sep=" ,", file=f)
    print('];', file=f)  # Python 3.x

    print('lens_outer=[', end = " ", file=f)  # Python 3.x
    print (*xs_outer, end = " ", sep=" ,", file=f)
    print('];', file=f)  # Python 3.x

    print('outer_diam=[', end = " ", file=f)  # Python 3.x
    print (*interp_outer, end = " ", sep=" ,", file=f)
    print('];', file=f)  # Python 3.x

