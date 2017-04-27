// ==========================================================
// Decription:  This program recreates locomotion based on a
//              spring-mass system
//              Project 5
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              SpringMassSystem of Biology - Spring 2017
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
PFont pointMassFont;
PFont myFontBold;
PFont myTitleFont;
// canvas related variables
int canvasSize    = 600;
int infoPanelSize = 300;
// SpringMassSystem variables
SpringMassSystem smSystem;
int nMasses      = 2;
int nSprings     = 1;
float g          = 0.2;
float damp       = 3.8;
float mass       = 10.0;
float maxVel     = 20.0;
// float restLength = 100.0;
// Time
int lastTime = 0;
int interval = 0;
// Flags
boolean simRunning = true;
boolean gravityOn  = false;
boolean dampingOn  = true;
boolean singleStep = false;

// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    smSystem = new SpringMassSystem(nMasses, nSprings, g, damp, mass, maxVel);
    updateGravity();
    updateDamping();
    // sim.display();
    // // printArray(PFont.list());
    myFont        = createFont("Ubuntu Mono", 14);
    pointMassFont = createFont("Ubuntu Mono", 12);
    myFontBold    = createFont("Ubuntu Bold", 14);
    myTitleFont   = createFont("Ubuntu Bold", 18);
}
// =============================================================================
void draw() {
    displaySimPanel();
    smSystem.display();
    displayInfoPanel();
    
    if (millis() - lastTime > interval){
        if (singleStep || simRunning){
            runSimulationStep();
        };
    }
}
// =============================================================================
void runSimulationStep(){
    smSystem.update();
    lastTime   = millis();
    singleStep = false;
}
// =============================================================================
void restart() {
    smSystem = new SpringMassSystem(nMasses, nSprings, g, damp, mass, maxVel);
    updateGravity();
    updateDamping();
}
// =============================================================================
class SpringMassSystem {
    int nPointMasses;
    int nSprings;
    float g;
    float damp;
    float mass;
    float maxVel;
    PointMass[] pointMasses;
    Spring[] springs;
    ArrayList<PVector> springPointMasses;
    float massDiameterFactor;
    int time;
    ArrayList<PointMass> ptmsToApplyFriction;
    ArrayList<Spring> springsToUpdate;
    
    // -------------------------------------------------------------------------
    SpringMassSystem(int nPointMasses, int nSprings, 
                float g, float damp, 
                float mass, float maxVel) {
        this.nPointMasses       = nPointMasses;
        this.nSprings           = nSprings;
        this.g                  = g;
        this.damp               = damp;
        this.mass               = mass;
        this.maxVel             = maxVel;
        this.massDiameterFactor = 1;
        
        // setupRandomSystem();
        // setupTestSystem01(2, 1);
        // setupTriangle();
        setupShape01();
    }
    // -------------------------------------------------------------------------
    void createMassesAndSprings(int nPointMasses, int nSprings, float restLength,
                                int[] masses, float[] ks, ArrayList<PVector> pmPositions,
                                PVector startPoint) {
        
        // move points relative to the start point
        for (PVector p : pmPositions) {
            p.add(startPoint);
        }
        
        // Create point masses
        for (int i = 0; i < nPointMasses; ++i) {
            pointMasses[i] = new PointMass(masses[i], pmPositions.get(i), 
                                           new PVector(0,0),
                                           maxVel, 0.5, i,
                                           0.9, 0.01);
        }
                
        // Create srings
        springs = new Spring[nSprings];
        for (int i = 0; i < nSprings; ++i) {
            int pm1Idx = int(springPointMasses.get(i).x);
            int pm2Idx = int(springPointMasses.get(i).y);
            springs[i] = new Spring(pointMasses[pm1Idx], 
                                    pointMasses[pm2Idx],
                                    ks[i], restLength, i, 
                                    0, 0);
            // add the current spring to the corresponding pointMass
            pointMasses[pm1Idx].addSpring(springs[i]);
            pointMasses[pm2Idx].addSpring(springs[i]);
        }
    }
    // -------------------------------------------------------------------------
    void setupShape01() {
        int nPointMasses = 7;
        int nSprings     = 11;
        float restLength = 60;
        int[] masses     = {50,60,50,50,50,50,50};
        float[] ks       = {6,6,6,6,6,6,6,6,6,6,6};
        ptmsToApplyFriction = new ArrayList<PointMass>();
        springsToUpdate     = new ArrayList<Spring>();
        PVector startPoint  = new PVector(canvasSize/4, canvasSize-80);
        
        // Create spring-mass triads
        springPointMasses = new ArrayList<PVector>();
        springPointMasses.add(new PVector(0, 1));
        springPointMasses.add(new PVector(1, 3));
        springPointMasses.add(new PVector(1, 4));
        springPointMasses.add(new PVector(1, 2));
        springPointMasses.add(new PVector(1, 6));
        springPointMasses.add(new PVector(1, 5));
        springPointMasses.add(new PVector(0, 3));
        springPointMasses.add(new PVector(3, 4));
        springPointMasses.add(new PVector(2, 4));
        springPointMasses.add(new PVector(2, 6));
        springPointMasses.add(new PVector(0, 5));
        
        // Create point masses
        pointMasses = new PointMass[nPointMasses];
        int idx = 0;
        
        // Create positions for point masses
        ArrayList<PVector> pmPositions = new ArrayList<PVector>();
        pmPositions.add(new PVector(0, 0));
        pmPositions.add(new PVector(restLength, 0));
        pmPositions.add(new PVector(2*restLength, 0));
        pmPositions.add(new PVector(restLength/2, 0-sqrt((pow(restLength,2)-pow(restLength/2,2)))));
        pmPositions.add(new PVector(pmPositions.get(3).x+restLength, pmPositions.get(3).y));
        pmPositions.add(new PVector(restLength/2, sqrt((pow(restLength,2)-pow(restLength/2,2)))));
        pmPositions.add(new PVector(pmPositions.get(5).x+restLength, pmPositions.get(5).y));
        
        createMassesAndSprings(nPointMasses, nSprings, restLength,
                               masses, ks, pmPositions,
                               startPoint);
        
        // Set friction params for pointMasses
        int[] ptmList1 = {0,1,2,3,4};
                                // amp per pha kf1  kf2
        setFrictionParams(ptmList1, 20, 60, 0,  0.9, 0.0);
        int[] ptmList2 = {5,6};
        setFrictionParams(ptmList2, 20, 60, 0,  0.0, 1.5);
        
        // Set oscillation params for springs
        springs[4].setMovementParams(20, 60, PI/4);
        springs[5].setMovementParams(20, 60, 0);
        springsToUpdate.add(springs[4]);
        springsToUpdate.add(springs[5]);
    }
    // -------------------------------------------------------------------------
    void setFrictionParams(int[] pointMassesList, float amp, float per, float phase, 
                           float kf1, float kf2) 
    {
        for (Integer i : pointMassesList) {
            PointMass pm = pointMasses[i];
            pm.setFrictionParams(amp, per, phase,  kf1, kf2);
            ptmsToApplyFriction.add(pm);
        }
    }
    // -------------------------------------------------------------------------
    void moveTriangle() {
        // amp freq pha per
        // springs[0].setMovementParams(3, 60, 0);
        // springs[0].updateLength();
        springs[1].setMovementParams(1, 240, 1);
        springs[1].updateLength(time);
        springs[2].setMovementParams(3, 60, 2);
        springs[2].updateLength(time);
    }
    // -------------------------------------------------------------------------
    void setupTriangle() {
        int nPointMasses = 3;
        int nSprings     = 3;
        float restLength = 80;
        int[] masses     = {30,30,30};
        float[] ks       = {8,8,8};
        
        // Create spring-mass triads
        springPointMasses.add(new PVector(0, 1));
        springPointMasses.add(new PVector(1, 2));
        springPointMasses.add(new PVector(0, 2));
        
        // Create point masses
        pointMasses = new PointMass[nPointMasses];
        int idx = 0;
        
        // Create positions for point masses
        ArrayList<PVector> pmPositions = new ArrayList<PVector>();
        PVector startPoint = new PVector(canvasSize/2, canvasSize/2 - 60);
        pmPositions.add(new PVector(0, 0));
        pmPositions.add(new PVector(restLength, 0));
        pmPositions.add(new PVector(restLength/2, 0-sqrt((pow(restLength,2)-pow(restLength/2,2)))));
        
        createMassesAndSprings(nPointMasses, nSprings, restLength,
                               masses, ks, pmPositions,
                               startPoint);
    }
    // -------------------------------------------------------------------------
    void setupRandomSystem() {
        int nMasses      = 4;
        int nSprings     = 4;
        float amplitude  = 1;    // pixels. Extension of springs
        float fequency   = 60;   // frames
        float period     = 214;   // frames
        float phase      = 0;   // frames
        float restLength = 100;   // pixels
        float k          = 0.2; 
        
        // Create point masses
        pointMasses = new PointMass[this.nPointMasses];
        for (int i = 0; i < this.nPointMasses; ++i) {
            PVector newPos = new PVector(random(canvasSize),
                                         random(canvasSize)); 
            // pointMasses[i] = new PointMass(int(random(1, mass)), newPos, 
            pointMasses[i] = new PointMass(int(random(4, mass)), newPos, 
                                           // getRandomVelocity(),
                                           new PVector(0,0),
                                           maxVel, massDiameterFactor, i,
                                           0.9, 0.01);
        }
        
        // Create spring-mass triads
        springPointMasses.add(new PVector(0, 1));
        springPointMasses.add(new PVector(1, 2));
        springPointMasses.add(new PVector(1, 3));
        springPointMasses.add(new PVector(0, 2));
        
        // Create srings
        springs = new Spring[nSprings];
        for (int i = 0; i < nSprings; ++i) {
            int pm1Idx = int(springPointMasses.get(i).x);
            int pm2Idx = int(springPointMasses.get(i).y);
            springs[i] = new Spring(pointMasses[pm1Idx], 
                                    pointMasses[pm2Idx],
                                    k, restLength, i, 
                                    amplitude, period);
                                    // , phase);
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
        springPointMasses.add(new PVector(1, 3));
        springPointMasses.add(new PVector(0, 2));
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
        // friction force
        for (PointMass p : ptmsToApplyFriction) {
            PVector friction = PVector.mult(p.vel, -p.kFriction);
            friction.mult(p.mass);
            p.applyForce(friction);
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
            pm.updateKf(time);
        }
        
        // updateMovement();
        for (Spring s : springsToUpdate) {
            s.updateLength(time);
        }
        
        ++time;
    }
    // -------------------------------------------------------------------------
    void display(){
        // background(backgroundColor);
        if (springs != null) { 
            for (Spring s : springs) {
                s.display();
            }
        }
        
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
  for (PointMass pm : smSystem.pointMasses) { 
    // pm.pressed();
    pm.clicked(mouseX,mouseY);
  }
  
}
// =============================================================================
void updateGravity(){
    smSystem.g     = int(gravityOn) * g;
}
// =============================================================================
void updateDamping(){
    smSystem.damp  = int(dampingOn) * damp;
}
// =============================================================================
void mouseReleased() {
  for (PointMass pm : smSystem.pointMasses) { 
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
        case 's':
        case 'S': {
            singleStep = true;
            simRunning = false;
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
    textAlign(LEFT);
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