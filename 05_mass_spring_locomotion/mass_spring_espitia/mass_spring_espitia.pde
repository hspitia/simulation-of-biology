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
color backgroundColor    = #444444;
color infoPanelColor     = #001A31; 
color pathColor          = #888888;
// color strokeColor        = #333333;
color strokeColor        = #222222;
color springColor        = #0068D8;
// color massColor       = #FFB115;
// color massOverColor      = #FF8C00;
color massColor          = color(255, 177, 21, 255);
color massOverColor      = color(255, 140, 0, 255);
color titleColor         = #FF9D00;
color textColor          = #E2E2E2;

// fonts
PFont myFont;
PFont myFontBold;
PFont myTitleFont;

// canvas related variables
int canvasSize    = 600;
int infoPanelSize = 300;

// Environment variables
Environment env;
int nMasses      = 3;
int nSprings     = 2;
// PVector g     = new PVector(0.0, 2);
// PVector g     = new PVector(0.0, 0);
float g          = 3;
float damp       = 0.12;
float mass       = 10.0;
float maxVel     = 20.0;
float restLength = 80.0;


// Time
int lastTime = 0;
int interval = 0;

// Flags
boolean simRunning = true;
boolean gravityOn  = true;
boolean dampingOn  = true;

// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    env = new Environment(nMasses, nSprings, g, damp, mass, maxVel, restLength);
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
    env = new Environment(nMasses, nSprings, g, damp, mass, maxVel, restLength);
    updateGravity();
    updateDamping();
}
// =============================================================================
class Environment {
    int nPointMasses;
    int nSprings;
    // PVector g;
    float g;
    float damp;
    float mass;
    float maxVel;
    float restLength;
    PointMass[] pointMasses;
    Spring[] springs;
    ArrayList<PVector> springPointMasses = new ArrayList<PVector>();
    int[] associatedSprings              = new int[nPointMasses];
    float k                              = 0.2;
    float massDiameterFactor             = 6;
    
    // -------------------------------------------------------------------------
    Environment(int nPointMasses, int nSprings, 
                float g, float damp, 
                float mass, float maxVel, float restLength) {
        this.nPointMasses = nPointMasses;
        this.nSprings     = nSprings;
        this.g            = g;
        this.damp         = damp;
        this.mass         = mass;
        this.maxVel       = maxVel;
        this.restLength   = restLength;
        
        // Point masses creation
        pointMasses = new PointMass[this.nPointMasses];
        for (int i = 0; i < this.nPointMasses; ++i) {
            PVector newPos = new PVector(random(canvasSize),
                                         random(canvasSize)); 
            // pointMasses[i] = new PointMass(int(random(1, mass)), newPos, 
            pointMasses[i] = new PointMass(int(random(4, mass)), newPos, 
                                           getRandomVelocity(),
                                           maxVel, massDiameterFactor, i);
        }
        
        // make spring and pointMasses triads
        setupSpringPointMasses();
        
        // Springs creation
        springs = new Spring[nSprings];
        for (int i = 0; i < nSprings; ++i) {
            int pm1Idx = int(springPointMasses.get(i).x);
            int pm2Idx = int(springPointMasses.get(i).y);
            springs[i] = new Spring(pointMasses[pm1Idx], 
                                    pointMasses[pm2Idx],
                                    k, restLength, i);
            // add the current spring to the corresponding 
            // pointMass
            pointMasses[pm1Idx].addSpring(springs[i]);
            pointMasses[pm2Idx].addSpring(springs[i]);
        }
        
    }
    // -------------------------------------------------------------------------
    void setupSpringPointMasses() {
        springPointMasses.add(new PVector(0, 1));
        springPointMasses.add(new PVector(1, 2));
        springPointMasses.add(new PVector(2, 3));
    }
    // -------------------------------------------------------------------------
    void update() {
        // Apply forces to point masses:
        // forces different from springs
        for (PointMass pm : pointMasses) {
            // create forces
            PVector damping = PVector.mult(pm.vel, -damp);
            PVector gravity = new PVector(0, g);
            gravity.mult(pm.mass);   // scale by mass
            
            // apply forces
            pm.applyForce(damping);
            pm.applyForce(gravity);
        }
        
        // forces from springs
        for (Spring s : springs) {
            PVector sForce = s.getForce(s.pm1.id);
            s.pm1.applyForce(sForce);
            sForce = s.getForce(s.pm2.id);
            s.pm2.applyForce(sForce);
        }
        
        // Execute motion in point masses
        for (PointMass pm : pointMasses) {
            // execute motion
            pm.update();
            
            // mouse interaction
            pm.over(mouseX, mouseY);
            pm.drag(mouseX, mouseY);
            
            // check for edges
            pm.checkEdges();
        }
        
        for (Spring s : springs) {
            s.update();
        }
    }
    // -------------------------------------------------------------------------
    void display(){
        // background(backgroundColor);
        for (Spring s : springs) {
            s.display();
        }
        
        // for (int i = 0; i < nSprings; ++i) {
        //     int pm1Idx = int(springPointMasses.get(i).x);
        //     int pm2Idx = int(springPointMasses.get(i).y);
        //     springs[i].display(pointMasses[pm1Idx],
        //                        pointMasses[pm2Idx]);
        // }
        
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
void mousePressed() {
  for (PointMass pm : env.pointMasses) { 
    // pm.pressed();
    pm.clicked(mouseX,mouseY);
  }
  
}
// =============================================================================
void updateGravity(){
    env.g     = int(gravityOn) * g;
}
// =============================================================================
void updateDamping(){
    env.damp  = int(dampingOn) * damp;
}
// =============================================================================
void mouseReleased() {
  for (PointMass pm : env.pointMasses) { 
    // pm.released();
    pm.stopDragging();
  }
}
// =============================================================================
void displaySimPanel() {
    noStroke();
    fill(backgroundColor);
    rect(0, 0, canvasSize, canvasSize);
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
        case 'g':
        case 'G': {
            gravityOn = !gravityOn;
            updateGravity();
            break;
        }
        case 'd':
        case 'D': {
            dampingOn = !dampingOn;
            updateDamping();
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