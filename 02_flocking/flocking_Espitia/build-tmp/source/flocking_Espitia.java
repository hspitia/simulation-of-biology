import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class flocking_Espitia extends PApplet {

// ==========================================================
// Decription:  This program recreates Flocking
//              Project 2
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================
// import java.util.Map;
// ==========================================================
// Global variables
// colors
// color backgroundColor   = #444444;
int backgroundColor   = color(68,68,68,20);
// color strokeColor    = #888888;
int pathColor         = 0xff888888;
int strokeColor       = 0xff333333;
int creatureCellColor = 0xffFFB115;
// color strokeColor    = #FFB115;

PFont myFont;
PFont myFontBold;

int nCreatures   = 5;
int maxCreatures = 100;
int canvasSize   = 600;
float r          = 40.0f;

Flock flock;

boolean leavePath  = true;
boolean simRunning = true;

// Forces flags
boolean flockCenteringOn = true;
boolean velMatchingOn    = true;
boolean collisionAvoidOn = true;
boolean wanderingForceOn = true;

int lastTime             = 0;
int interval             = 0;
float minVel             = 0.02f;
float maxVel             = 1.0f;
float minWanderingFactor = 0.5f;
float maxWanderingFactor = 1.5f;
float minDistance        = 20.0f;
float weight             = 0.01f;
// =============================================================================
public void setup() {
    
    background(backgroundColor);
        
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
    flock = new Flock(nCreatures, maxCreatures);
}
// =============================================================================
public void draw() {
    displayBackground();
    flock.display();
    
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
    }
    // displayHelp();
}
// =============================================================================
public void runSimulationStep(){
    flock.update();
    lastTime = millis();
}
// =========================================================
public String getOnOffStr(boolean state){
    if(state) 
        return "On";
    return "Off";
}
// =============================================================================
class Creature {
    // Attributes
    PVector pos;
    PVector vel;
    PVector accel;
    float   r;
    String  id;
    
    // Methods
    // Constructor
    Creature(PVector pos, PVector vel, float r) {
        this.pos = pos;
        this.vel = vel;
        this.r   = r;
        this.accel = new PVector(0, 0);
    }
    
    public void display() {
        // stroke(creatureCellColor);
        stroke(strokeColor);
        fill(creatureCellColor);
        ellipse(pos.x, pos.y, 8, 8);
    }
    
    public void displayLastPosition() {
        stroke(pathColor);
        fill(pathColor);
        ellipse(pos.x, pos.y, 2, 2);
    }
    
    public void applyForce(PVector f) {
        accel.add(f);
    }
    
    public void update(){
        // check borders
        // PVector newPos = new PVector(pos.x, pos.y);
        
        float[] limits = {0.0f, canvasSize};
        if (pos.y > canvasSize || pos.y < 0.0f)
            pos.y = limits[PApplet.parseInt(pos.y < 0.0f)];
            // newPos.y = limits[int(pos.y < 0.0)];
        
        if (pos.x > canvasSize || pos.x < 0.0f)
            pos.x = limits[PApplet.parseInt(pos.x < 0.0f)];
        
        // add acceleration
        vel.add(accel);
        // add wandering
        // pos.add(new PVector(getWandering(), getWandering()));
        // add velocity
        pos.add(vel);
        accel.mult(0);
    }
    
    private float getWandering() {
        return random(minWanderingFactor, maxWanderingFactor) * getRandomSign();
    }
    
    public String toString(){
        return pos.toString();
    }
}
// =============================================================================
class Flock {
    // Attributes
    Creature[] creatures;
    int nCreatures    = 0;
    int maxCreatures  = 0;
    // -------------------------------------------------------------------------
    // Methods
    Flock(int nCreatures, int maxCreatures){
        this.nCreatures   = nCreatures;
        this.maxCreatures = maxCreatures;
        this.creatures    = new Creature[this.maxCreatures];
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i] = new Creature(getRandomPoint(), 
                                        getRandomVelocity(),
                                        r);
        }
    }
    // -------------------------------------------------------------------------
    public void display(){
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].display();
        }
    }
    // -------------------------------------------------------------------------
    public void update(){
        if(collisionAvoidOn) collisionAvoidance();
        if(flockCenteringOn) flockCentering();
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].update();
        }
    }
    // -------------------------------------------------------------------------
    public void randomize() {
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].pos = getRandomPoint();
        }
    }
    // -------------------------------------------------------------------------
    public void addCreature() {
        if (nCreatures <= maxCreatures) {
            creatures[nCreatures++] = new Creature(getRandomPoint(), 
                                                   getRandomVelocity(),
                                                   r);
        }
    }
    // -------------------------------------------------------------------------
    public void removeCreature() {
        if (nCreatures > 1) {
            creatures[nCreatures--] = null;
        }
    }
    // -------------------------------------------------------------------------
    public void collisionAvoidance() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector force = new PVector(0,0);
            int nNeighbors = 0;
            println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < minDistance && cDistance > 0) {
                    println(" cDistance: " + cDistance);
                    PVector difference = PVector.sub(creatures[i].pos, creatures[j].pos);
                    force.add(difference);
                    ++nNeighbors;
                }
            }
            
            if (force.mag() > 0) {
                force.mult(weight);
                force.div(weight * nNeighbors);
                force.normalize();
                creatures[i].applyForce(force);
            } else {
                creatures[i].applyForce(new PVector(0,0));
            }
            
        }
    }
    // -------------------------------------------------------------------------
    public void  flockCentering(){
        PVector center = new PVector(0,0);
        for (int i = 0; i < this.nCreatures; ++i) {
            int nNeighbors = 0;
            // println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < minDistance && cDistance > 0) {
                    center.add(creatures[j].pos);
                    ++nNeighbors;
                }
            }
            
            PVector force = new PVector(0,0);
            if (nNeighbors > 0) {
                center.div(nNeighbors);
                force = center.sub(creatures[i].pos);
            }
            creatures[i].applyForce(force);
        }
    }
    // -------------------------------------------------------------------------
    // ArrayList<int> getNeighbors(int creatureIdx) {
    //     ArrayList<int> neighbors = new ArrayList<int>();
    //     for (int i = 0; i < this.nCreatures; ++i) {
    //         PVector cDistance = PVector.dist(creatures[creatureIdx], creatures[i]);
    //         if (cDistance < minDistance && cDistance > 0) {
                
    //         }
    //     }
    // }
    // -------------------------------------------------------------------------
}

// =============================================================================
public PVector getRandomPoint() {
    float x = map(random(1), 0, 1, 0, canvasSize);
    float y = map(random(1), 0, 1, 0, canvasSize);
    PVector v = new PVector(x, y);
    return v;
}
// =============================================================================
public PVector getRandomVelocity() {
    PVector v = new PVector(getRandomSign() * (random(minVel, maxVel)), 
                            getRandomSign() * (random(minVel, maxVel)));
    
    return v;
}
// =============================================================================
public int getRandomSign(){
    int[] signs = {1,-1};
    return signs[PApplet.parseInt(random(signs.length))];
}
// =============================================================================
public void displayBackground() {
    // Background for creatures path
    if (leavePath) {
        noStroke();
        fill(backgroundColor);
        rect(0, 0, canvasSize, canvasSize);
    }
    // No path
    else {
        background(backgroundColor);
    }
}
// =============================================================================
public void clear() {
    background(backgroundColor);
}
// =========================================================
public void displayHelp() {
    textFont(myFont);
    String[] labels = new String[4];
    String[] values = new String[4];
    
    labels[0] = "Centering: ";
    labels[1] = "Collisions: ";
    labels[2] = "Vel. matching: ";
    labels[3] = "Wandering: ";
    
    values[0] = getOnOffStr(flockCenteringOn);
    values[1] = getOnOffStr(velMatchingOn);
    values[2] = getOnOffStr(collisionAvoidOn);
    values[3] = getOnOffStr(wanderingForceOn);
    
    fill(255);
    text("Forces:", 10, 618);
    // text("Keyboard Controls:", 10, 618);
}
// =============================================================================
public void keyPressed() {
    switch (key) {
        case 'a':
        case 'A': {
            // Toggle attraction mode
            break;
        }
        
        case 'r':
        case 'R': {
            // Toggle repulsion mode
            break;
        }
        
        case 's':
        case 'S': {
            // Creatures at random positions
            clear();
            flock.randomize();
            break;
        }
        case 'p':
        case 'P': {
            // Toggle display path mode
            leavePath = !leavePath;
            break;
        }
        case 'c':
        case 'C': {
            // Clear background
            clear();
            break;
        }
        case '1': {
            break;
        }
        case '2': {
            break;
        }
        case '3': {
            collisionAvoidOn = !collisionAvoidOn;
            break;
        }
        case '4': {
            break;
        }
        case '=': 
        case '+': {
            // Add a new creature
            flock.addCreature();
            break;
        }
        
        case '-': {
            // Remove a creature
            flock.removeCreature();
            break;
        }
        case ' ': {
            simRunning = !simRunning;
            break;
        }
        
        
    }
}
  public void settings() {  size(600, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "flocking_Espitia" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
