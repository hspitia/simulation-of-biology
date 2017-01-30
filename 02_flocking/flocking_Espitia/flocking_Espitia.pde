
// ==========================================================
// Decription:  This program recreates Flocking
//              Project 2
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================

// ==========================================================
// Global variables
// colors
color backgroundColor   = #444444;
color strokeColor       = #888888;
color pathColor         = #888888;
// color strokeColor       = #000000;
color creatureCellColor = #FFB115;

PFont myFont;
PFont myFontBold;

int nCreatures = 10;
int canvasSize = 700;

Flock flock;

int lastTime = 0;
int interval = 100;
// =========================================================
void setup() {
    size(700, 700);
        
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
    flock = new Flock(nCreatures);
}
// =========================================================
void draw() {
    background(backgroundColor);
    flock.display();
    
    
    if (millis() - lastTime > interval){
        // flock.update();
        update();
        lastTime = millis();
    }
}

void update() {
    for (Creature c : flock.herd) {
        stroke(strokeColor);
        fill(creatureCellColor);
        ellipse(c.pos.x, c.pos.y, 8, 8);
        c.update();
    }
}

// =========================================================
class Creature {
    // Attributes
    PVector pos;
    PVector vel;
    float r;
    // Methods
    // Constructor
    Creature(PVector pos, PVector vel, float r) {
        this.pos = pos;
        this.vel = vel;
        this.r   = r;
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
    
    void update(){
        // displayLastPosition();
        pos.add(vel);
    }
}

class Flock {
    // Attributes
    Creature[] herd;
    int nCreatures = 0;
    // Methods
    Flock(int nCreatures){
        this.nCreatures = nCreatures;
        this.herd = new Creature[this.nCreatures];
        for (int i = 0; i < this.nCreatures; ++i) {
            PVector p = getRandomPoint();
            // PVector v = getRandomPoint();
            PVector v = new PVector(int(random(1,10)), 
                                    int(random(1,10)));
            herd[i] = new Creature(p, v, 40.0);
        }
    }
    
    void display(){
        for (Creature creature : herd) {
            creature.display();
        }
    }
    
    void update(){
        for (Creature creature : herd) {
            creature.update();
        }
    }
}

PVector getRandomPoint() {
    float x = map(random(1), 0, 1, 0, canvasSize);
    float y = map(random(1), 0, 1, 0, canvasSize);
    PVector v = new PVector(x, y);
    return v;
}

// =========================================================
void keyPressed() {
    switch (key) {
        case 'a':
        case 'A': {
            break;
        }
        
        case 'r':
        case 'R': {
            break;
        }
        
        case 's':
        case 'S': {
            break;
        }
        case 'p':
        case 'P': {
            break;
        }
        case 'c':
        case 'C': {
            break;
        }
        case '1': {
            break;
        }
        case '2': {
            break;
        }
        case '3': {
            break;
        }
        case '4': {
            break;
        }
        case '=': 
        case '+': {
            break;
        }
        
        case '-': {
            break;
        }
        case ' ': {
            break;
        }
        
        
    }
}