// ==========================================================
// Decription:  This program recreates locomotion based on a
//              spring-mass system
//              Project 5
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Environment of Biology - Spring 2017
// ==========================================================
// Global variables
// colors
// color backgroundColor = #333333;
color backgroundColor = #444444;
color infoPanelColor  = #001A31; 
color pathColor       = #888888;
color strokeColor     = #333333;
// color strokeColor     = #FFB115;
color massColor       = #FFB115;
color titleColor      = #FF9D00;
color textColor       = #E2E2E2;

// fonts
PFont myFont;
PFont myFontBold;
PFont myTitleFont;

// canvas related variables
int canvasSize    = 600;
int infoPanelSize = 300;

// Environment variables
Environment env;
int nMasses  = 5;
int nSprings = 5;
float g      = 9.8;
float damp   = 0.3;
float maxVel = 2.0;

// Time
int lastTime = 0;
int interval = 0;

// Flags
boolean simRunning = true;


// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    env = new Environment(nMasses, nSprings, g, damp, maxVel);
    // sim.display();
    // // printArray(PFont.list());
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
}
// =============================================================================
void draw() {
    displaySimPanel();
    displayInfoPanel();
    env.display();
    
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
    }
}
// =============================================================================
void runSimulationStep(){
    env.update();
    lastTime = millis();
}
// =============================================================================
void restart() {
    env = new Environment(nMasses, nSprings, g, damp, maxVel);
}
// =============================================================================
class Environment {
    int nPointMasses;
    int nSprings;
    float g;
    float damp;
    float maxVel;
    PointMass[] pointMasses;
    int pointMassRadius = 14;
    
    Environment(int nPointMasses, int nSprings, 
                float g, float damp, float maxVel) {
        this.nPointMasses = nPointMasses;
        this.nSprings     = nSprings;
        this.g            = g;
        this.damp         = damp;
        this.maxVel       = maxVel;
        
        pointMasses = new PointMass[this.nPointMasses];
        
        for (int i = 0; i < this.nPointMasses; ++i) {
            PVector newPos = new PVector(random(canvasSize - pointMassRadius),
                                         random(canvasSize - pointMassRadius)); 
            pointMasses[i] = new PointMass(newPos, 
                                           getRandomVelocity(),
                                           pointMassRadius);
        }
        
        // for (int i = 0; i < this.nCreatures; ++i) {
        //     // creatures[i] = new Creature(getRandomPoint(),
        //     PVector newPos = new PVector(canvasSize/int(random(2,4)),
        //                                  canvasSize/int(random(2,4))); 
        //     creatures[i] = new Creature(newPos, 
        //                                 getRandomVelocity());
        // }
        
    }
    // -------------------------------------------------------------------------
    void update() {
        for (PointMass pm : pointMasses) {
            pm.update();
        }
    }
    // -------------------------------------------------------------------------
    void display(){
        // background(backgroundColor);
        for (PointMass pm : pointMasses) {
            pm.display();
        }
    }
    // -------------------------------------------------------------------------
    private PVector getRandomVelocity() {
        PVector v = new PVector(getRandomSign() * (random(0, this.maxVel)), 
                                getRandomSign() * (random(0, this.maxVel)));
        
        return v;
    }
    // -------------------------------------------------------------------------
    private int getRandomSign(){
        int[] signs = {1,-1};
        return signs[int(random(signs.length))];
    }
}
// =============================================================================
// =============================================================================
class PointMass {
    // Attributes
    PVector pos;
    PVector vel;
    PVector accel;
    float   shapeRadius;
    String  id;
    
    // Methods
    // Constructor
    PointMass(PVector pos, PVector vel, int pointMassRadius) {
        this.pos         = pos;
        this.vel         = vel;
        this.shapeRadius = pointMassRadius;
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
// =============================================================================
void displaySimPanel() {
    // // Background for creatures path
    // if (leavePath) {
    //     // noStroke();
        fill(backgroundColor);
        rect(0, 0, canvasSize, canvasSize);
    // }
    // // No path
    // else {
    //     background(backgroundColor);
    // }
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
void keyPressed() {
    switch (key) {
        case 'r':
        case 'R': {
            restart();
            break;
        }
        case ' ': {
            simRunning = !simRunning;
            break;
        }
        
        
    }
}
// =========================================================
void setupTitle(){
    fill(titleColor);
    textFont(myTitleFont);
}
// =========================================================
void setupSubtitle(){
    fill(titleColor);
    textFont(myFontBold);
}
// =========================================================
void setupText(){
    fill(textColor);
    textFont(myFont);
}
void displayHelp() {
    
    // String[] labels = new String[7];
    // String[] values = new String[7];
    String[] controlText = new String[2];
    
    // labels[0] = "Centering:     " + getOnOffStr(flockCenteringOn);
    
    controlText[0]  = "R:     Restart simulation";
    controlText[1]  = "Space: Stop/Resume simulation";
    
    // display title
    fill(0);
    int marginX = canvasSize + 15;
    int marginY = 30;
    setupTitle();
    text("Spring-Mass Locomotion\nSimulation", marginX, marginY);

    // setup text
    int textX   = marginX;
    int textY   = marginY + 60;
    int offsetY = 16;

    // display controls subtitle
    setupSubtitle();
    text("Controls:", textX, textY);
    textY += 3;
    // display controls text
    setupText();
    for (int i = 0; i < controlText.length; ++i) {
        textY += offsetY;
        text(controlText[i], textX, textY);
    }
    
    // textY += 40;

    // textFont(myFontBold);
    // text("Info:", textX, textY);
    
    // // textY += marginY + 10;
    // int offsetY = 16;
    // textFont(myFont);
    // for (int i = 0; i < labels.length; ++i) {
    //     textY += offsetY;
    //     if (i == labels.length - 1) textY += 5;
    //     text(labels[i], textX, textY);
    // }
    
    
}