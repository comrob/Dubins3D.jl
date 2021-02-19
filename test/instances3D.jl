"""
Test intances collected mainly from various papers about 3D Dubins paths.
"""

rhomin = 40.
pitchlims = pi * [-15., 20.] / 180.
deg2rad(x) = pi * x / 180.

LONG = [
  [
    [200, 500, 200, deg2rad(180), deg2rad(-5)],
    [500, 350, 100, deg2rad(0), deg2rad(-5)],
    [467.70, 449.56],
    "Long 1"
  ],[
    [100, -400, 100, deg2rad(30), deg2rad(0)],
    [500, -700, 0, deg2rad(150), deg2rad(0)],
    [649.52, 636.12],
    "Long 2"
  ],[
    [-200, 200, 250, deg2rad(240), deg2rad(15)],
    [ 500, 800,   0, deg2rad(45), deg2rad(15)],
    [1088.10, 1063.41],
    "Long 3"
  ],[
    [-300, 1200, 350, deg2rad(160), deg2rad(0)],
    [1000,  200,   0, deg2rad(30), deg2rad(0)],
    [1802.60, 1789.21],
    "Long 4"
  ],[
    [-500, -300, 600, deg2rad(150), deg2rad(10)],
    [1200,  900, 100, deg2rad(300), deg2rad(10)],
    [2245.14, 2216.40],
    "Long 5"
  ]
]

SHORT = [
  [
    [120, -30, 250, deg2rad(100), deg2rad(-10)],
    [220, 150, 100, deg2rad(300), deg2rad(-10)],
    [588.60, 583.47],
    "Short 1"
  ],[
    [380, 230, 200, deg2rad(30), deg2rad(0)],
    [280, 150,  30, deg2rad(200), deg2rad(0)],
    [667.71, 658.53],
    "Short 2"
  ],[
    [-80, 10, 250, deg2rad(20), deg2rad(0)],
    [ 50, 70,   0, deg2rad(240), deg2rad(0)],
    [979.34, 968.25],
    "Short 3"
  ],[
    [400, -250, 600, deg2rad(350), deg2rad(0)],
    [600, -150, 300, deg2rad(150), deg2rad(0)],
    [1169.73, 1161.55],
    "Short 4"
  ],[
    [-200, -200, 450, deg2rad(340), deg2rad(0)],
    [-300,  -80, 100, deg2rad(100), deg2rad(0)],
    [1367.56, 1354.12],
    "Short 5"
  ]
]

BEARD = [
  [
    [   0,   0, 350, deg2rad(180)+pi/2,  0],
    [-100, 100, 100, deg2rad(180)+pi/2,  0],
    [NaN],
    "Beard 1"
  ], [
    [  0,   0,  100, deg2rad(70)+pi/2,  0],
    [100, 100,  125, deg2rad(70)+pi/2,  0],
    [NaN],
    "Beard 2"
  ], [
    [  0, 0, 100, deg2rad(0)+pi/2,   0,  0],
    [200, 0, 200, deg2rad(270)-pi/2, 0,  0],
    [NaN],
    "Beard 3"
  ]
]

OTHERS = [
  [
    [500, 100, 300, deg2rad(240), deg2rad(15)],
    [-100, 400, 0, deg2rad(45), deg2rad(15)],
    [NaN],
    "Others 1"
  ], [
    [0., 0, 0, 0, 0],
    [0., 0, 5, 0, 0],
    [NaN],
    "Others 2"
  ], [
    [0., 0, 0, 0, 0],
    [0., 0, 10, 0, 0],
    [NaN],
    "Others 3"
  ], [
    [0., 0, 0, 0, 0],
    [0., 0, 20, 0, 0],
    [NaN],
    "Others 4"
  ], [
    [0., 0, 0, 0, 0],
    [0., 0, 30, 0, 0],
    [NaN],
    "Others 5"
  ], [
    [0., 0, 0, 0, 0],
    [0., 0, 50, 0, 0],
    [NaN],
    "Others 6"
  ], [
    [0., 0, 0, 0, deg2rad(10)],
    [292.4, 0, 100, 0, deg2rad(10)],
    [NaN],
    "Others 7"
  ], [
    [0., 0, 200, 0, 0],
    [0., 0, 20, 0, 0],
    [NaN],
    "Others 8"
  ]
]

HOTA = [
  [
    [100, 10, 200, deg2rad(180), deg2rad(20)],
    [500, 40, 100, deg2rad(0), deg2rad(20)],
    [NaN],
    "Hota 1"
  ], [
    [100, 10, 200, deg2rad(180), deg2rad(20)],
    [120, 20, 210, deg2rad(90), deg2rad(20)],
    [NaN],
    "Hota 2"
  ]
]
