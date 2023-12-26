#lang racket
#| "physics_Zpq.rkt" resolves Z forces (lift) p moments (roll) q moments (pitch) in body axes
   Part of "YNot", the land yacht simulation.
   Written by Patrick King, all rights reserved.

   Axis system - body - origin at interface between ground plane and nose wheel.
   Positive x to the rear. Positive y to the left. Positive z up.

   Aerodynamic forces have been resolved.
   Ax - + is drag, - is thrust
   Ay - + is left
   Az - should be 0, since we assume roll is 0. When we linearize, I think negligible, maybe not

   Aerodynamic center, seperate for lift and drag - 1/4 chord vs 1/2 chord, boom angle, stuff
   Maybe it doesn't go here.
   Xl
   Yl
   Zl == Zd 
   Yd
   Xd

   Geometry, mass, moment of inertia
   m - mass, kg
   x_cg, y_cg, z_cg - meters - position of center of gravity... likely assumption y_cg == 0
   wt - wheel track - width in m between main wheels (y direction)
   wb = wheel base - length in m between mains and nose wheel (x direction)
   
   Default case, roll is 0 and stable, therefore moments 0. Pitch
   is 0 and stable, therefore moments 0. Normal forces balance weight.
   
   Z (weight, tires): vertical forces sum to 0
     mg = Nl + Nr + Nn
       Nl - Normal (vertical) force, left wheel
       Nr - right wheel
       Nn - nose wheel
   
   P (roll):   summed about x axis (z=y=0)
     (Nr - Nl)*wt == Ay * Zd (Zl?)
   
   Q (pitch):  summed about y axis (z=x=0)
     (Nr + Nl)*wb == m*g*x_cg


|#
