// ==========================================================
// Decription:  This program recreates locomotion based on a
//              spring-mass system
//              Project 5
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================
// Global variables
// colors
color backgroundColor = color(68,68,68,30);
color infoPanelColor  = #B0B0B0;
color pathColor       = #888888;
color strokeColor     = #333333;
color massColor       = #FFB115;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

int nMasses    = 5;
int canvasSize = 600;


// =============================================================================
class Mass {
    // Attributes
    PVector pos;
    PVector vel;
    PVector accel;
    float   shapeRadius;
    String  id;
    
    // Methods
    // Constructor
    Mass(PVector pos, PVector vel) {
        this.pos         = pos;
        this.vel         = vel;
        this.shapeRadius = 8;
        this.accel       = new PVector(0, 0);
    }
    
    void display() {
        // stroke(massColor);
        stroke(strokeColor);
        fill(massColor);
        ellipse(pos.x, pos.y, shapeRadius, shapeRadius);
    }
    
    void applyForce(PVector f) {
        accel.add(f);
    }
    
    void update(){
        // check borders
        float offset = shapeRadius/2;
        float[] limits = {offset, (canvasSize-offset)};
        if (pos.y > (canvasSize-offset) || pos.y < offset)
            pos.y = limits[int(pos.y < offset)];
        
        if (pos.x > (canvasSize-offset) || pos.x < offset)
            pos.x = limits[int(pos.x < offset)];
        
        vel.add(accel);
        vel.limit(maxVel);
        pos.add(vel);
        
        accel.mult(0);
    }
    
    String toString(){
        return pos.toString();
    }
}