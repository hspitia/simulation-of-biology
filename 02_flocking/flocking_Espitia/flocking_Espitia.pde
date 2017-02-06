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
color backgroundColor   = color(68,68,68,20);
// color strokeColor    = #888888;
color pathColor         = #888888;
color strokeColor       = #333333;
color creatureCellColor = #FFB115;
// color strokeColor    = #FFB115;

PFont myFont;
PFont myFontBold;

int nCreatures   = 5;
int maxCreatures = 100;
int canvasSize   = 600;
float r          = 40.0;

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
float minVel             = 0.02;
float maxVel             = 1.0;
float minWanderingFactor = 0.5;
float maxWanderingFactor = 1.5;
float minDistance        = 20.0;
float weight             = 0.01;
// =============================================================================
void setup() {
    size(600, 600);
    background(backgroundColor);
        
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
    flock = new Flock(nCreatures, maxCreatures);
}
// =============================================================================
void draw() {
    displayBackground();
    flock.display();
    
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
    }
    // displayHelp();
}
// =============================================================================
void runSimulationStep(){
    flock.update();
    lastTime = millis();
}
// =========================================================
String getOnOffStr(boolean state){
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
    
    void display() {
        // stroke(creatureCellColor);
        stroke(strokeColor);
        fill(creatureCellColor);
        ellipse(pos.x, pos.y, 8, 8);
    }
    
    void displayLastPosition() {
        stroke(pathColor);
        fill(pathColor);
        ellipse(pos.x, pos.y, 2, 2);
    }
    
    void applyForce(PVector f) {
        accel.add(f);
    }
    
    void update(){
        // check borders
        // PVector newPos = new PVector(pos.x, pos.y);
        
        float[] limits = {0.0, canvasSize};
        if (pos.y > canvasSize || pos.y < 0.0)
            pos.y = limits[int(pos.y < 0.0)];
            // newPos.y = limits[int(pos.y < 0.0)];
        
        if (pos.x > canvasSize || pos.x < 0.0)
            pos.x = limits[int(pos.x < 0.0)];
        
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
    
    String toString(){
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
    void display(){
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].display();
        }
    }
    // -------------------------------------------------------------------------
    void update(){
        if(collisionAvoidOn) collisionAvoidance();
        if(flockCenteringOn) flockCentering();
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].update();
        }
    }
    // -------------------------------------------------------------------------
    void randomize() {
        for (int i = 0; i < this.nCreatures; ++i) {
            creatures[i].pos = getRandomPoint();
        }
    }
    // -------------------------------------------------------------------------
    void addCreature() {
        if (nCreatures <= maxCreatures) {
            creatures[nCreatures++] = new Creature(getRandomPoint(), 
                                                   getRandomVelocity(),
                                                   r);
        }
    }
    // -------------------------------------------------------------------------
    void removeCreature() {
        if (nCreatures > 1) {
            creatures[nCreatures--] = null;
        }
    }
    // -------------------------------------------------------------------------
    void collisionAvoidance() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector force = new PVector(0,0);
            int nNeighbors = 0;
            // println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < minDistance && cDistance > 0) {
                    // println(" cDistance: " + cDistance);
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
    void  flockCentering(){
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
PVector getRandomPoint() {
    float x = map(random(1), 0, 1, 0, canvasSize);
    float y = map(random(1), 0, 1, 0, canvasSize);
    PVector v = new PVector(x, y);
    return v;
}
// =============================================================================
PVector getRandomVelocity() {
    PVector v = new PVector(getRandomSign() * (random(minVel, maxVel)), 
                            getRandomSign() * (random(minVel, maxVel)));
    
    return v;
}
// =============================================================================
int getRandomSign(){
    int[] signs = {1,-1};
    return signs[int(random(signs.length))];
}
// =============================================================================
void displayBackground() {
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
void clear() {
    background(backgroundColor);
}
// =========================================================
void displayHelp() {
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
void keyPressed() {
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