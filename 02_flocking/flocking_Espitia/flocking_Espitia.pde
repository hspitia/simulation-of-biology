// ==========================================================
// Decription:  This program recreates Flocking
//              Project 2
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================
// Global variables
// colors
color backgroundColor   = color(68,68,68,30);
color infoPanelColor    = #B0B0B0;
color pathColor         = #888888;
color strokeColor       = #333333;
color creatureCellColor = #FFB115;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

int nCreatures    = 98;
int maxCreatures  = 100;
int canvasSize    = 600;
int infoPanelSize = 250;

Flock flock;

// Flags
boolean simRunning       = true;
boolean leavePath        = false;
boolean attractionModeOn = true;
boolean repulsionModeOn  = !attractionModeOn;
boolean flockCenteringOn = true;
boolean velMatchingOn    = true;
boolean colAvoidanceOn   = true;
boolean wanderingOn      = true;

// Time
int lastTime          = 0;
int interval          = 0;

// Distances and limits
float attractionR     = 80.0;
float repulsionR      = 90.0;
float minVel          = 0.0;
float maxVel          = 2.0;   // *
float r               = 50.0;  // *
float minNeighborDist = 25.0;  // *
float forceLim        = 0.1;   // *

// Weights
float attractionWeight   = 1.5;
float repulsionWeight    = 1.8;
float flockingWeight     = 1.1;
float colAvoidanceWeight = 1.5;
float velMatchingWeight  = 1.0;
float wanderWeight       = 0.4;

// =============================================================================
void setup() {
    size(850, 600);
    background(backgroundColor);
        
    // printArray(PFont.list());
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
    flock = new Flock(nCreatures, maxCreatures);
}
// =============================================================================
void draw() {
    displaySimPanel();
    displayInfoPanel();
    flock.display();
    
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
    }
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
    float   shapeRadius;
    String  id;
    
    // Methods
    // Constructor
    Creature(PVector pos, PVector vel) {
        this.pos         = pos;
        this.vel         = vel;
        this.shapeRadius = 7;
        this.accel       = new PVector(0, 0);
    }
    
    void display() {
        // stroke(creatureCellColor);
        stroke(strokeColor);
        fill(creatureCellColor);
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
    
    // private float getWandering() {
    //     return random(minWanderFactor, maxWanderFactor) * getRandomSign();
    // }
    
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
            // creatures[i] = new Creature(getRandomPoint(),
            PVector newPos = new PVector(canvasSize/int(random(2,4)),
                                         canvasSize/int(random(2,4))); 
            creatures[i] = new Creature(newPos, 
                                        getRandomVelocity());
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
        if(attractionModeOn) attractionMode();
        if(repulsionModeOn) repulsionMode();
        if(colAvoidanceOn) collisionAvoidance();
        if(flockCenteringOn) flockCentering();
        if(velMatchingOn) velocityMatching();
        if(wanderingOn) wandering();
        
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
        if (nCreatures < maxCreatures) {
            creatures[nCreatures++] = new Creature(getRandomPoint(), 
                                                 getRandomVelocity());
            // nCreatures++;
        }
    }
    // -------------------------------------------------------------------------
    void removeCreature() {
        if (nCreatures > 1) {
            creatures[--nCreatures] = null;
        }
    }
    // -------------------------------------------------------------------------
    // key A
    void attractionMode(){
        if (mousePressed) {
            PVector pointerPos = new PVector(mouseX, mouseY);
            
            for (int i = 0; i < this.nCreatures; ++i) {
                PVector sumPos = new PVector(0,0);
                int nNeighbors = 0;
                // for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, pointerPos);
                if (cDistance < attractionR) {
                    ++nNeighbors;
                    sumPos.add(pointerPos);
                }
                // }
                
                PVector force = new PVector(0,0);
                if (nNeighbors > 0) {
                    sumPos.div(nNeighbors);
                    sumPos.sub(creatures[i].pos);
                    sumPos.normalize();
                    sumPos.mult(maxVel);
                    force = PVector.sub(sumPos, creatures[i].vel);
                    force.limit(forceLim);
                    force.mult(attractionWeight);
                }
                creatures[i].applyForce(force);
            }
        }
    }
    // -------------------------------------------------------------------------
    // key R
    void repulsionMode(){
        if (mousePressed) {
            PVector pointerPos = new PVector(mouseX, mouseY);
            
            for (int i = 0; i < this.nCreatures; ++i) {
                PVector tmpForce = new PVector(0,0);
                int nNeighbors = 0;
                // println("i: " + i);
                // for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, pointerPos);
                // Neighbor in radius and not the same creature (cDistance = 0)
                if (cDistance < repulsionR && cDistance > 0) {
                    ++nNeighbors;
                    PVector difference = PVector.sub(creatures[i].pos, pointerPos);
                    difference.normalize();
                    difference.div(cDistance);
                    tmpForce.add(difference);
                }
                // }
                
                if(nNeighbors > 0)
                    tmpForce.div(float(nNeighbors));
                
                PVector force = new PVector(0,0);
                if (tmpForce.mag() > 0) {
                    tmpForce.normalize();
                    tmpForce.mult(maxVel);
                    tmpForce.sub(creatures[i].vel);
                    tmpForce.limit(forceLim);
                    force = tmpForce;
                    force.mult(repulsionWeight);
                } 
                creatures[i].applyForce(force);
            }
        }
    }
    // -------------------------------------------------------------------------
    // key 1
    void flockCentering() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector sumPos = new PVector(0,0);
            int nNeighbors = 0;
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < r && cDistance > 0) {
                    ++nNeighbors;
                    sumPos.add(creatures[j].pos);
                }
            }
            
            PVector force = new PVector(0,0);
            if (nNeighbors > 0) {
                sumPos.div(nNeighbors);
                sumPos.sub(creatures[i].pos);
                sumPos.normalize();
                sumPos.mult(maxVel);
                force = PVector.sub(sumPos, creatures[i].vel);
                force.limit(forceLim);
                force.mult(flockingWeight);
            }
            creatures[i].applyForce(force);
        }
    }
    
    // -------------------------------------------------------------------------
    // key 2
    void velocityMatching() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector sumVel = new PVector(0,0);
            int nNeighbors = 0;
            // println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < r && cDistance > 0) {
                    // println(" cDistance: " + cDistance);
                    ++nNeighbors;
                    sumVel.add(creatures[j].vel);
                }
            }
            
            PVector force = new PVector(0, 0);
            if (nNeighbors > 0) {
                sumVel.div(nNeighbors);
                sumVel.normalize();
                sumVel.mult(maxVel);
                force = PVector.sub(sumVel, creatures[i].vel);
                force.limit(forceLim);
                force.mult(velMatchingWeight);
            }
            creatures[i].applyForce(force);
        }
    }
    // -------------------------------------------------------------------------
    // key 3
    void collisionAvoidance() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector tmpForce = new PVector(0,0);
            int nNeighbors = 0;
            // println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                // Neighbor in radius and not the same creature (cDistance = 0)
                if (cDistance < minNeighborDist && cDistance > 0) {
                    ++nNeighbors;
                    // println(" cDistance: " + cDistance);
                    PVector difference = PVector.sub(creatures[i].pos, creatures[j].pos);
                    difference.normalize();
                    difference.div(cDistance);
                    tmpForce.add(difference);
                }
            }
            
            if(nNeighbors > 0)
                tmpForce.div(float(nNeighbors));
            
            PVector force = new PVector(0,0);
            if (tmpForce.mag() > 0) {
                tmpForce.normalize();
                tmpForce.mult(maxVel);
                tmpForce.sub(creatures[i].vel);
                tmpForce.limit(forceLim);
                force = tmpForce;
                force.mult(colAvoidanceWeight);
            } 
            creatures[i].applyForce(force);
        }
    }
    // -------------------------------------------------------------------------
    void wandering(){
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector force = new PVector(random(-1.0, 1),random(-1.0, 1));
            force.normalize();
            force.mult(maxVel);
            force.normalize();
            force.mult(forceLim);
            force.mult(wanderWeight);
            creatures[i].applyForce(force);
        }
    }
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
    PVector v = new PVector(getRandomSign() * (random(0, maxVel)), 
                            getRandomSign() * (random(0, maxVel)));
    
    return v;
}
// =============================================================================
int getRandomSign(){
    int[] signs = {1,-1};
    return signs[int(random(signs.length))];
}
// =============================================================================
void displaySimPanel() {
    // Background for creatures path
    if (leavePath) {
        // noStroke();
        fill(backgroundColor);
        rect(0, 0, canvasSize, canvasSize);
    }
    // No path
    else {
        background(backgroundColor);
    }
    // displayInfoPanel();
}
// =============================================================================
void displayInfoPanel(){
    noStroke();
    fill(infoPanelColor);
    rect(canvasSize, 0, infoPanelSize, canvasSize);
    displayHelp();
}
// =============================================================================
void clear() {
    background(backgroundColor);
    displayInfoPanel();
}
// =========================================================
void displayHelp() {
    
    String[] labels = new String[7];
    String[] values = new String[7];
    String[] controlText = new String[11];
    
    labels[0] = "Centering:     " + getOnOffStr(flockCenteringOn);
    labels[1] = "Vel. matching: " + getOnOffStr(velMatchingOn);
    labels[2] = "Collisions:    " + getOnOffStr(colAvoidanceOn);
    labels[3] = "Wandering:     " + getOnOffStr(wanderingOn);
    labels[4] = "Attraction:    " + getOnOffStr(attractionModeOn);
    labels[5] = "Repulsion:     " + getOnOffStr(repulsionModeOn);
    labels[6] = "# Creatures:   " + flock.nCreatures;
    
    controlText[0]  = "A:     Toggle Attraction Mode";
    controlText[1]  = "R:     Toggle Repulsion Mode";
    controlText[2]  = "S:     Randomize creatures";
    controlText[3]  = "C:     Clear window";
    controlText[4]  = "1:     Toggle Flock Centering";
    controlText[5]  = "2:     Toggle Velocity Matching";
    controlText[6]  = "3:     Toggle Collision Avoidance";
    controlText[7]  = "4:     Toggle Wandering";
    controlText[8]  = "=,+:   Add a new creature";
    controlText[9]  = "-:     Remove a creature";
    controlText[10] = "Space: Stop/Resume simulation";
    
    
    // values[0] = getOnOffStr(flockCenteringOn);
    // values[1] = getOnOffStr(velMatchingOn);
    // values[2] = getOnOffStr(colAvoidanceOn);
    // values[3] = getOnOffStr(wanderingOn);
    
    fill(0);
    int marginX = canvasSize + 15;
    int marginY = 30;
    textFont(myTitleFont);
    text("Flocking Simulation", marginX, marginY);
    
    int textX   = marginX;
    int textY   = marginY + 40;
    textFont(myFontBold);
    text("Info:", textX, textY);
    
    // textY += marginY + 10;
    int offsetY = 16;
    textFont(myFont);
    for (int i = 0; i < labels.length; ++i) {
        textY += offsetY;
        if (i == labels.length - 1) textY += 5;
        text(labels[i], textX, textY);
    }
    
    // textX = marginX;
    textY += 40;
    textFont(myFontBold);
    text("Controls:", textX, textY);
    textY += 3;
    textFont(myFont);
    for (int i = 0; i < controlText.length; ++i) {
        textY += offsetY;
        text(controlText[i], textX, textY);
    }
}
// =============================================================================
void keyPressed() {
    switch (key) {
        case 'a':
        case 'A': {
            // Toggle attraction mode
            attractionModeOn = repulsionModeOn;
            repulsionModeOn = !attractionModeOn;
            break;
        }
        case 'r':
        case 'R': {
            // Toggle repulsion mode
            repulsionModeOn  = attractionModeOn;
            attractionModeOn = !repulsionModeOn;
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
            flockCenteringOn = !flockCenteringOn;
            break;
        }
        case '2': {
            velMatchingOn = !velMatchingOn;
            break;
        }
        case '3': {
            colAvoidanceOn = !colAvoidanceOn;
            break;
        }
        case '4': {
            wanderingOn = !wanderingOn;
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