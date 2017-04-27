// ==========================================================
// Decription:  This program recreates locomotion based on a
//              spring-mass system
//              Project 5
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              MassSpringSystem of Biology - Spring 2017
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
// MassSpringSystem variables
MassSpringSystem smSystem;
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
boolean simRunning   = true;
boolean gravityOn    = false;
boolean dampingOn    = true;
boolean singleStep   = false;
boolean showFriction = true;

// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    // smSystem = new MassSpringSystem(nMasses, nSprings, g, damp, mass, maxVel);
    smSystem = new MassSpringSystem(g, damp, mass, maxVel);
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
    // smSystem = new MassSpringSystem(nMasses, nSprings, g, damp, mass, maxVel);
    smSystem = new MassSpringSystem(g, damp, mass, maxVel);
    updateGravity();
    updateDamping();
}
// =============================================================================
class MassSpringSystem {
    // int nPointMasses;
    // int nSprings;
    float g;
    float damp;
    float mass;
    float maxVel;
    PointMass[] pointMasses;
    ArrayList<PointMass> pointMassList;
    Spring[] springs;
    ArrayList<Spring> springList;
    ArrayList<PVector> springPointMasses;
    float massDiameterFactor;
    int time;
    ArrayList<PointMass> ptmsToApplyFriction;
    ArrayList<Spring> springsToUpdate;
    
    // -------------------------------------------------------------------------
    MassSpringSystem( 
                float g, float damp, 
                float mass, float maxVel) {
        this.g                  = g;
        this.damp               = damp;
        this.mass               = mass;
        this.maxVel             = maxVel;
        this.massDiameterFactor = 1;
        
        setupShape01();
    }
    // -------------------------------------------------------------------------
    void createMassesAndSprings(float restLength, int[] masses, 
                                float[] ks, ArrayList<PVector> pmPositions) {
        
        pointMassList = new ArrayList<PointMass>();
        springList    = new ArrayList<Spring>();
        
        // Create point masses
        for (int i = 0; i < pmPositions.size(); ++i) {
            pointMassList.add(new PointMass(masses[i], pmPositions.get(i), 
            // pointMasses[i] = new PointMass(masses[i], pmPositions.get(i), 
                                           new PVector(0,0),
                                           maxVel, 0.5, i,
                                           0.9, 0.01));
        }
                
        // Create srings
        for (int i = 0; i < springPointMasses.size(); ++i) {
            int pm1Idx = int(springPointMasses.get(i).x);
            int pm2Idx = int(springPointMasses.get(i).y);
            springList.add(new Spring(pointMassList.get(pm1Idx), 
                                      pointMassList.get(pm2Idx),
                                      ks[i], restLength, i, 
                                      0, 0));
            // Add the current spring to its corresponding point masses
            pointMassList.get(pm1Idx).addSpring(springList.get(i));
            pointMassList.get(pm2Idx).addSpring(springList.get(i));
        }
    }
    // -------------------------------------------------------------------------
    void setupShape01() {
        float restLength = 60;
        int[] masses     = {50,60,50,50,50,50,50,50};
        float[] ks       = {6,6,6,6,6,6,6,6,6,6,6,6,6};
        
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
        // springPointMasses.add(new PVector(3, 7));
        // springPointMasses.add(new PVector(4, 7));
        
        // Define point masses
        int idx = 0;
        
        // Create positions for point masses
        //            7 
        //           /  \
        //          3 —  4
        //        /  \ /  \
        //       0 —  1 — 2
        //        \ /  \ /
        //         5    6
        ArrayList<PVector> pmPositions = new ArrayList<PVector>();
        float y = sqrt((pow(restLength,2)-pow(restLength/2,2)));
        float x = restLength;
        pmPositions.add(new PVector(0, 0));
        pmPositions.add(new PVector(x, 0));
        pmPositions.add(new PVector(2*x, 0));
        pmPositions.add(new PVector(x/2, -y));
        pmPositions.add(new PVector(pmPositions.get(3).x+x, pmPositions.get(3).y));
        pmPositions.add(new PVector(restLength/2, y));
        pmPositions.add(new PVector(pmPositions.get(5).x+x, pmPositions.get(5).y));
        // pmPositions.add(new PVector(pmPositions.get(1).x+restLength, -2*y));
        
        // Move points relative to the start point
        for (PVector p : pmPositions) {
            p.add(startPoint);
        }
        
        // Create point masses and springs
        createMassesAndSprings(restLength, masses, ks, pmPositions);
        
        // Define motion params:
        float period = 60;
        // Set friction params for pointMasses
        int[] ptmList1 = {0,1,2,3,4};
        //                          amp period  pha kf1  kf2
        setFrictionParams(ptmList1, 20, period, 0,  0.9, 0.0);
        int[] ptmList2 = {5,6};
        setFrictionParams(ptmList2, 20, period, 0,  0.0, 1.5);
        
        // Set oscillation params for springs
        //                                  amp period  phase 
        springList.get(4).setMovementParams(40, period, 0);
        springList.get(5).setMovementParams(40, period, 0);
        // springList.get(4).restLength = 90;
        // springList.get(5).restLength = 90;
        
        // Register springs to update
        springsToUpdate.add(springList.get(4));
        springsToUpdate.add(springList.get(5));
        
    }
    // -------------------------------------------------------------------------
    void setFrictionParams(int[] ptmIdxList, float amp, float per, float phase, 
                           float kf1, float kf2) 
    {
        for (Integer i : ptmIdxList) {
            PointMass pm = pointMassList.get(i);
            pm.setFrictionParams(amp, per, phase, kf1, kf2);
            ptmsToApplyFriction.add(pm);
        }
    }
    // -------------------------------------------------------------------------
    void update() {
        // Apply forces to point masses:
        // Environment forces: damping & gravity
        for (PointMass pm : pointMassList) {
            // create forces
            PVector damping = PVector.mult(pm.vel, -damp);
            PVector gravity = new PVector(0, g);
            gravity.mult(pm.mass);   // scale by mass
            
            // apply forces
            pm.applyForce(damping);
            pm.applyForce(gravity);
        }
        // Friction force
        for (PointMass p : ptmsToApplyFriction) {
            PVector friction = PVector.mult(p.vel, -p.kFriction);
            friction.mult(p.mass);
            p.applyForce(friction);
        }
        // Spring forces
        for (Spring s : springList) {
            PVector sForce = s.getForce(s.pm1.id);
            s.pm1.applyForce(sForce);
            sForce = s.getForce(s.pm2.id);
            s.pm2.applyForce(sForce);
        }
        
        // Execute motion in point masses
        for (PointMass pm : pointMassList) {
            // execute motion
            pm.update();
            // mouse interaction
            pm.over(mouseX, mouseY);
            pm.drag(mouseX, mouseY);
            // check for edges
            pm.checkEdges();
            pm.updateKf(time);
        }
        
        // Update spring length
        for (Spring s : springsToUpdate) {
            s.updateLength(time);
        }
        
        ++time;
    }
    // -------------------------------------------------------------------------
    void display(){
        // background(backgroundColor);
        // if (springs != null) { 
        //     for (Spring s : springs) {
        //         s.display();
        //     }
        // }
        
        // for (PointMass pm : pointMasses) {
        //     pm.display();
        // }
        
        
        for (Spring s : springList) {
            s.display();
        }
        
        for (PointMass pm : pointMassList) {
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