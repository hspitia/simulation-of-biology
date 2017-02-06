# Project 2: Flocking Creatures

#### CS 7492, Spring 2017

#### Due: February 6, 2017

##Objective

The goal of this assignment is to learn about simulation based on particle systems. In particular, you will implement flocking, herding and schooling behaviour. Your virtual creatures will group together similar to the way in which fish swim together in schools. A major part of this assignment is learning how to tune simulation parameters to get reasonable behaviors. This assignment is based on the simulated flocking work of Craig Reynolds.
Flocking Simulation

You will write a flocking simulator using Processing. When your program starts, you will have 16 creatures on the screen that have a tendency to group together according to Craig Reynolds' three rules of interaction.
Characteristics of your simulator:

Draw a representation of each creature, including some way of telling which direction the creature is facing (e.g a tail).
Make your window at least 600 by 600 pixels in size. (Larger is okay -- I look at your assignments on a screen that can handle 850 by 850.)
You can choose whether your simulator will have toroidal wrapping, or whether the sides will act like hard walls.
Your simulator should obey simple mouse and keyboard commands. Your interface will allow the mouse to be in one of two modes: attracting or repelling. When in attracting mode, holding down the mouse button will cause the creatures to follow the cursor. When in repelling mode, holding down the button will cause the creatures to move away from the cursor, as if it is a predator that they are trying to escape.
Your simulator should act on this group of keyboard commands:

**a,A** - Switch to attraction mode (for when mouse is held down).
r,R - Switch to repulsion mode (for when mouse is held down).
s,S - Cause all creatures to be instantly scattered to random positions in the window.
p,P - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not.
c,C - Clear the window (useful when creatures are leaving paths).
1 - Toggle the flock centering forces on/off.
2 - Toggle the velocity matching forces on/off.
3 - Toggle the collision avoidance forces on/off.
4 - Toggle the wandering force on/off.
=,+ - Add one new creature to the simulation. You should allow up to 100 creatures to be created.
- (minus sign) - Remove one new creature from the simulation (unless there are none already).
space bar - Start or stop the simulation (toggle between these).
When the user types 1, 2, 3, or 4, print out a line or show a message on the screen that describes which forces are on/off at the time, such as:
Centering: off Collisions: off Velocity matching: on Wandering: on

In addition to the three forces from Reynolds, each of your creatures should have a small randomness factor (wandering) added to their motion. There are two reasons for this. First, this will cause your creatures to look more natural in their motion. Second, when all of the other three forces have been turned off, this slight randomness will prevent them from moving in exactly a straight line. Also, you should have a minimum and maximum value that you use to clamp the velocity of each creature. This will keep your creatures from sitting still or zooming too fast across the window.

As usual, we will use "Processing" to carry out this assignment:

http://www.processing.org/

For any large project such as this, I recommend backing up your work often. You don't want to put in a ton of work and then accidentally delete all of it. I suggest making a new copy of your entire work folder every hour or so, and giving each new copy a higher number. Don't worry about file sizes -- source files are tiny. I also recommend copying all of your backups to a different computer once each day for extra safety.

Suggested Approach

As always, you can follow my suggestions or not, depending on your level of confidence about programming.
You should begin by deciding what attributes each creature should have. This will include at least position and velocity. Then create a data structure that is capable of storing up to 100 creatures. Best would be to have a class such as "creature" and/or "creature_list". Then create a routine that draws all of your creatures from this data structure. Initially this can be as simple as drawing a single dot at the correct position. Initialize your set of creatures to contain just one creature, for the purpose of initially debugging creature motion. Test your drawing routine on this one, un-moving creature. I suggest having your creature positions have x and y values that are in the range of zero to one. Then you will multiply these coordinates by the screen width and height when you draw the creature.

Now initialize this test creature to have some non-zero velocity. Create a simulation update routine that moves each creature a small distance according to their velocity and your delta_time value. Have the draw() routine call this simulation update routine and draw the creatures. You will have to adjust the velocity and the delta_time values in order to get this first creature to move at a speed that is reasonable. Don't bother with avoiding walls yet. Once you've got one creature working, modify your initialization routine to create 10 creatures with random positions and velocities. Run your simulator on this collection of creatures. Now add a wandering force to their motions, and watch their behavior. You may find it useful to NOT clear the screen at each time-step, so you can watch their paths of motion.

Once you've got several creatures moving, return to working with one creature. Decide whether the edges of the window will wrap toroidally (left/right and top/bottom) or if they will act as hard walls. Then figure out how to make your creature behave correctly when it reaches the edge of the window. If you want hard walls, easiest way to do this is have them "bounce" by negating their x velocity when they are within a short range of the left or right edge, and similarly negate the y velocity near the top or bottom of the window. Drawing the creatures in a manner that shows their direction of motion will help at this point.

If you decide to have your window edges wrap toroidally, you will want to transport your creature from one side to the other the moment it tries to step outside the window. This is easy. What is harder is calculating distances between two creatures (which will come later). One creature that is way over on the left of the window should be considered to be close to a creature at the same height but that is at the far right of the window.

Now you should begin to implement each of the three flocking forces, one at a time. The main issue here is to decide, for each creature, what that creatures nearest neighbors are. That is, which creatures are within a particular distance of the creature in question. Then you can create the flock centering force from this. Just using flock centering will give a behavior that is not exactly like flocking, but they will group in a swarming fashion. You will have to "tune" the strength of the flock centering force in order to get reasonable behavior. You will definitely want to clamp the velocity to the minimum and maximum values while debugging this.

After getting the creatures to use flock centering, add in one of the other two forces. Debug each new force on its own first, without either of the other two flocking forces acting with it. Then start to mix the forces together to see what happens. Part of this mixing process will be tuning the relative strengths of the different forces. Eventually you should have a flocking simulator that has reasonable behavior no matter which of the forces are on or off. Naturally, the most realistic flocking behavior should happen when all of the forces are "on".

Finish up the assignment by adding mouse click behavior and the various keyboard commands. You may have to experiment a fair amount before you can get the creatures to follow or run away from the cursor when the mouse button is held down. These can be implemented in a way that is similar to the flock centering and collision avoidance behaviors, but with just a single "neighbor" (the cursor position).

Authorship Rules

The code that you turn in must be entirely your own. You are allowed to talk to other members of the class and to the teacher about general implementation issues. It is also fine to seek the help of others for general programming questions about Processing. You may not, however, use code that anyone other than yourself has written. Code that is explicitly not allowed includes code taken from the Web, from books, from previous assignments or from any source other than yourself. You should not show your code to other students. Feel free to seek the help of the teacher for suggestions about debugging your code. 
 
Turning In Your Assignment

Turn in your project on T-square. Please zip up the Processing folder that contains your code and submit this.