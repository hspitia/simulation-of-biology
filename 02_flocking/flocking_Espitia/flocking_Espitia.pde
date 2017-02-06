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
color infoPanelColor    = #B0B0B0;
// color strokeColor    = #888888;
color pathColor         = #888888;
color strokeColor       = #333333;
color creatureCellColor = #FFB115;
// color strokeColor    = #FFB115;

PFont myFont;
PFont myFontBold;

int nCreatures    = 5;
int maxCreatures  = 100;
int canvasSize    = 600;
int infoPanelSize = 250;
float r           = 40.0;

Flock flock;

boolean leavePath  = true;
boolean simRunning = true;

// Forces flags
boolean flockCenteringOn = true;
boolean velMatchingOn    = true;
boolean colAvoidanceOn   = false;
boolean wanderingOn      = true;

int lastTime             = 0;
int interval             = 0;
float minVel             = 0.02;
float maxVel             = 1.0;
float minWanderingFactor = 0.5;
float maxWanderingFactor = 1.5;
float minDistance        = 20.0;
float flockingWeight     = 0.001;
float colAvoidanceWeight = 0.01;
float velMatchingWeight  = 0.01;
// =============================================================================
void setup() {
    size(850, 600);
    background(backgroundColor);
        
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu Mono", 14);
    myFontBold = createFont("Ubuntu Bold", 14);
    
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
        float[] limits = {0.0, canvasSize};
        if (pos.y > canvasSize || pos.y < 0.0)
            pos.y = limits[int(pos.y < 0.0)];
        
        if (pos.x > canvasSize || pos.x < 0.0)
            pos.x = limits[int(pos.x < 0.0)];
        
        vel.add(accel);
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
            // creatures[i] = new Creature(getRandomPoint(), 
            creatures[i] = new Creature(new PVector(canvasSize/2, canvasSize/2), 
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
                force.mult(colAvoidanceWeight);
                force.div(colAvoidanceWeight * nNeighbors);
                // force.normalize();
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
    void velocityMatching() {
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector force = new PVector(0,0);
            int nNeighbors = 0;
            // println("i: " + i);
            for (int j = 0; j < this.nCreatures; ++j) {
                float cDistance = PVector.dist(creatures[i].pos, creatures[j].pos);
                if (cDistance < minDistance && cDistance > 0) {
                    // println(" cDistance: " + cDistance);
                    PVector difference = PVector.sub(creatures[i].vel, creatures[j].vel);
                    force.add(difference);
                    ++nNeighbors;
                }
            }
            
            if (force.mag() > 0) {
                force.mult(velMatchingWeight);
                force.div(velMatchingWeight * nNeighbors);
                // force.normalize();
                creatures[i].applyForce(force);
            } else {
                creatures[i].applyForce(new PVector(0,0));
            }
            
        }
    }
    // -------------------------------------------------------------------------
    void wandering(){
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector force = new PVector(random(-1.0, 1),random(-1.0, 1));
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
    
    String[] labels = new String[4];
    String[] values = new String[4];
    String[] controlText = new String[11];
    
    labels[0] = "Centering: " + getOnOffStr(flockCenteringOn);
    labels[1] = "Vel. matching: " + getOnOffStr(velMatchingOn);
    labels[2] = "Collisions: " + getOnOffStr(colAvoidanceOn);
    labels[3] = "Wandering: " + getOnOffStr(wanderingOn);
    
    controlText[0]  = "A:   Toggle Attraction Mode";
    controlText[1]  = "R:   Toggle Repulsion Mode";
    controlText[2]  = "S:   Randomize creatures";
    controlText[3]  = "C:   Clear window";
    controlText[4]  = "1:   Toggle Flock Centering";
    controlText[5]  = "2:   Toggle Velocity Matching";
    controlText[6]  = "3:   Toggle Collision Avoidance";
    controlText[7]  = "4:   Toggle Wandering";
    controlText[8]  = "=,+: Add a new creature";
    controlText[9]  = "-:   Remove a creature";
    controlText[10] = "Space:   Run a single step";
    
    // values[0] = getOnOffStr(flockCenteringOn);
    // values[1] = getOnOffStr(velMatchingOn);
    // values[2] = getOnOffStr(colAvoidanceOn);
    // values[3] = getOnOffStr(wanderingOn);
    
    fill(0);
    int marginX = canvasSize + 15;
    int marginY = 30;
    textFont(myFontBold);
    textFont(myFontBold);
    text("Forces:", marginX, marginY);
    
    int textX   = marginX;
    int textY   = marginY + 3;
    int offsetY = 16;
    textFont(myFont);
    for (int i = 0; i < labels.length; ++i) {
        textY += offsetY;
        text(labels[i], textX, textY);
    }
    
    // textX = marginX;
    textY += 30;
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