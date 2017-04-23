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
// color massColor       = #FFB115;
color massColor       = color(255, 177, 21, 200);
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
int nMasses  = 10;
int nSprings = 10;
PVector g    = new PVector(0.0, 2);
// PVector g    = new PVector(0.0, 0);
float damp   = 0.12;
float mass   = 10.0;
float maxVel = 20.0;

// Time
int lastTime = 0;
int interval = 0;

// Flags
boolean simRunning = true;


// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    env = new Environment(nMasses, nSprings, g, damp, mass, maxVel);
    // sim.display();
    // // printArray(PFont.list());
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
}
// =============================================================================
void draw() {
    displaySimPanel();
    env.display();
    displayInfoPanel();
    
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
    env = new Environment(nMasses, nSprings, g, damp, mass, maxVel);
}
// =============================================================================
class Environment {
    int nPointMasses;
    int nSprings;
    PVector g;
    float damp;
    float mass;
    float maxVel;
    PointMass[] pointMasses;
    float massDiameterFactor = 6;
    // -------------------------------------------------------------------------
    Environment(int nPointMasses, int nSprings, 
                PVector g, float damp, 
                float mass, float maxVel) {
        this.nPointMasses = nPointMasses;
        this.nSprings     = nSprings;
        this.g            = g;
        this.damp         = damp;
        this.mass         = mass;
        this.maxVel       = maxVel;
        
        pointMasses = new PointMass[this.nPointMasses];
        
        for (int i = 0; i < this.nPointMasses; ++i) {
            PVector newPos = new PVector(random(canvasSize),
                                         random(canvasSize)); 
            // pointMasses[i] = new PointMass(int(random(1, mass)), newPos, 
            pointMasses[i] = new PointMass(int(random(4, mass)), newPos, 
                                           getRandomVelocity(),
                                           maxVel, massDiameterFactor);
        }
    }
    // -------------------------------------------------------------------------
    void update() {
        for (PointMass pm : pointMasses) {
            // background(backgroundColor);
            
            // PVector damping = PVector.mult(pm.vel, -1);     // get vel's opposite direction
            // damping.normalize();                            // normalize to the unit vector
            // damping.mult(damp);                             // give magnitude
            
            
            PVector damping = PVector.mult(pm.vel, -damp);
            PVector gravity = PVector.mult(g, pm.mass);     // scale by mass

            // apply forces
            pm.applyForce(damping);
            pm.applyForce(gravity);
            // update velocity
            pm.update();
            // check for edges
            pm.checkEdges();
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
// Spring Class
// =============================================================================
// PointMass Class
// =============================================================================
// Auxiliary Functions
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
// =========================================================
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