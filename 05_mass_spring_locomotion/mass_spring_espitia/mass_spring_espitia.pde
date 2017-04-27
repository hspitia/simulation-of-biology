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
int creature     = 1;
float g          = 0.2;
float damp       = 3.8;
float mass       = 10.0;
float maxVel     = 20.0;
// Time
int lastTime = 0;
int interval = 0;
// Flags
boolean simRunning   = false;
boolean gravityOn    = false;
boolean dampingOn    = true;
boolean singleStep   = false;
boolean showFriction = true;

// =============================================================================
void setup() {
    size(900, 600);
    background(backgroundColor);
    
    // smSystem = new MassSpringSystem(nMasses, nSprings, g, damp, mass, maxVel);
    smSystem = new MassSpringSystem(g, damp, mass, maxVel, creature);
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
    smSystem = new MassSpringSystem(g, damp, mass, maxVel, creature);
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
    MassSpringSystem(float g, float damp, float mass, float maxVel, int creature) {
        this.g                  = g;
        this.damp               = damp;
        this.mass               = mass;
        this.maxVel             = maxVel;
        this.massDiameterFactor = 1;
        
        switch (creature) {
            case 1 : {
                setupShape01();
                break;
            }
            case 2: {
                setupShape03();
                break;
            }
        }
    }
    // -------------------------------------------------------------------------
    void printCurrentLegths() {
        for (Spring s : springList) {
            PointMass p1 = s.pm1;
            PointMass p2 = s.pm2;
            
            PVector dist = PVector.sub(p1.pos, p2.pos);
            float l = dist.mag();
            println("spring : "+s.id+" :"+l);
        }
        println("");
    }
    
    // -------------------------------------------------------------------------
    void createMassesAndSprings(float[] restLengths, int[] masses, 
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
                                      ks[i], restLengths[i], i, 
                                      0, 0));
            // Add the current spring to its corresponding point masses
            pointMassList.get(pm1Idx).addSpring(springList.get(i));
            pointMassList.get(pm2Idx).addSpring(springList.get(i));
        }
    }
    // -------------------------------------------------------------------------
    void setupShape03() {
        float bl = 40;
        float adL = sqrt(2*bl*bl);
        //                     0  1  2  3  4  5   6   7  8  9  10 11
        float[] restLengths = {bl,bl,bl,bl,bl,adL,adL,bl,bl,bl};
        float[] ks          = {12,12,12,12,12,12, 12, 12,12,12,12,12};
        int[] masses        = {30,30,30,30,35,35, 30, 30};
        
        ptmsToApplyFriction = new ArrayList<PointMass>();
        springsToUpdate     = new ArrayList<Spring>();
        
        PVector startPoint  = new PVector(canvasSize/2, canvasSize - 150);
        
        // Create spring-mass triads
        springPointMasses = new ArrayList<PVector>();
        springPointMasses.add(new PVector(0, 4)); // 0
        springPointMasses.add(new PVector(1, 4)); // 1
        springPointMasses.add(new PVector(0, 2)); // 2
        springPointMasses.add(new PVector(0, 1)); // 3
        springPointMasses.add(new PVector(1, 3)); // 4
        springPointMasses.add(new PVector(1, 2)); // 5
        springPointMasses.add(new PVector(0, 3)); // 6
        springPointMasses.add(new PVector(2, 3)); // 7
        springPointMasses.add(new PVector(2, 5)); // 8
        springPointMasses.add(new PVector(3, 5)); // 9
        // springPointMasses.add(new PVector(0, 3)); // 10
        // springPointMasses.add(new PVector(2, 6)); // 11
        
        // Define point masses
        // Create positions for point masses
        ArrayList<PVector> pmPositions = new ArrayList<PVector>();
        float y = sqrt((pow(bl,2)-pow(bl/2,2)));
        float x = bl;
        pmPositions.add(new PVector(0, 0));       // 0
        pmPositions.add(new PVector(x, 0));        // 1
        pmPositions.add(new PVector(0, x));       // 2
        pmPositions.add(new PVector(x, x));       // 3
        pmPositions.add(new PVector(x/2, -y));     // 4
        pmPositions.add(new PVector(x/2, y+x)); // 5   
        
        // Move points relative to the start point
        for (PVector p : pmPositions) {
            p.add(startPoint);
        }
        
        // Create point masses and springs
        createMassesAndSprings(restLengths, masses, ks, pmPositions);
        
        // Define motion params:
        float period = 60;
        float pha    = 2;
        // Set friction params for pointMasses
        // int[] ptmList1 = {0,1,2,3,4,5};
        int[] ptmList1 = {4};
        //                          amp period  pha   kFriction kf1  kf2
        setFrictionParams(ptmList1, 20, period, 0,    0.0,      1.5, 0.0);
        // int[] ptmList2 = {0,1};
        // setFrictionParams(ptmList2, 20, period, 0,    0.0,      0.0, 1.5);
        int[] ptmList3 = {5};
        setFrictionParams(ptmList3, 20, period, 0,    0.0,      0.0, 1.5);
        // Set oscillation params for springs
        // Set params
        //                                  amp period  phase 
        springList.get(0).setMovementParams(20, period, 0);
        springList.get(1).setMovementParams(20, period, 0);
        springList.get(2).setMovementParams(20, period, 61);
        springList.get(4).setMovementParams(20, period, 61);
        springList.get(8).setMovementParams(-20, period, 0);
        springList.get(9).setMovementParams(-20, period, 0);
        
        // Register springs to update
        springsToUpdate.add(springList.get(0));
        springsToUpdate.add(springList.get(1));
        // springsToUpdate.add(springList.get(2));
        // springsToUpdate.add(springList.get(4));
        springsToUpdate.add(springList.get(8));
        springsToUpdate.add(springList.get(9));
    }
    // -------------------------------------------------------------------------
    void setupShape02() {
        float bl = 40;
        //                     0  1  2  3  4  5  6  7  8  9  10 11
        float[] restLengths = {40,40,40,40,40,40,40,40,40,40,40,40};
        float[] ks          = {12,12,12,12,12,12,12,12,12,12,12,12};
        int[] masses        = {40,40,40,40,40,40,40,40};
        
        ptmsToApplyFriction = new ArrayList<PointMass>();
        springsToUpdate     = new ArrayList<Spring>();
        
        PVector startPoint  = new PVector(canvasSize/4, canvasSize/2);
        
        // Create spring-mass triads
        springPointMasses = new ArrayList<PVector>();
        springPointMasses.add(new PVector(0, 1)); // 0
        springPointMasses.add(new PVector(1, 2)); // 1
        springPointMasses.add(new PVector(0, 4)); // 2
        springPointMasses.add(new PVector(1, 4)); // 3
        springPointMasses.add(new PVector(1, 5)); // 4
        springPointMasses.add(new PVector(2, 5)); // 5
        springPointMasses.add(new PVector(4, 7)); // 6
        springPointMasses.add(new PVector(5, 7)); // 7
        // springPointMasses.add(new PVector(1, 3)); // 8
        // springPointMasses.add(new PVector(1, 6)); // 9
        springPointMasses.add(new PVector(0, 3)); // 10
        springPointMasses.add(new PVector(2, 6)); // 11
        
        // Define point masses
        // Create positions for point masses
        ArrayList<PVector> pmPositions = new ArrayList<PVector>();
        float y = sqrt((pow(bl,2)-pow(bl/2,2)));
        float x = bl;
        pmPositions.add(new PVector(0, 0));                          // 0
        pmPositions.add(new PVector(x, 0));                          // 1
        pmPositions.add(new PVector(x*2, 0));                        // 2
        pmPositions.add(new PVector(-(x/2), y));                     // 3
        pmPositions.add(new PVector(pmPositions.get(3).x+x, y));    // 4
        pmPositions.add(new PVector(pmPositions.get(4).x+x, y));    // 5   
        pmPositions.add(new PVector(pmPositions.get(5).x+x, y));    // 6
        pmPositions.add(new PVector(pmPositions.get(1).x, 2*y));    // 7
        
        // Move points relative to the start point
        for (PVector p : pmPositions) {
            p.add(startPoint);
        }
        
        // Create point masses and springs
        createMassesAndSprings(restLengths, masses, ks, pmPositions);
        
        // // Define motion params:
        // float period = 60;
        // // Set friction params for pointMasses
        // int[] ptmList1 = {0,1,2,3,4};
        // //                          amp period  pha kFriction kf1  kf2
        // setFrictionParams(ptmList1, 20, period, 0,  0.0,      0.9, 0.0);
        // int[] ptmList2 = {5,6};
        // setFrictionParams(ptmList2, 20, period, 0,  1.5,      0.0, 1.5);
        
        // // Set oscillation params for springs
        // // Set params
        // //                                  amp period  phase 
        // // springList.get(4).setMovementParams(-50, period, 0);
        // springList.get(4).setMovementParams(40, period, 0);
        // // springList.get(5).setMovementParams(-50, period, 0);
        // springList.get(5).setMovementParams(40, period, 0);
        // // springList.get(4).restLength = 90;
        // // springList.get(5).restLength = 90;
        
        // // Register springs to update
        // springsToUpdate.add(springList.get(4));
        // springsToUpdate.add(springList.get(5));
        // // springsToUpdate.add(springList.get(9));
        // // springsToUpdate.add(springList.get(10));
    }
    // -------------------------------------------------------------------------
    void setupShape01() {
        float bl = 60;
        // float restLength = 60;
        // int[] masses     = {50,60,50,50,50,50,50,50};
        // int[] masses     = {20,30,20,20,20,40,40,40};
        float[] restLengths = {60,60,60,60,60,60,60,60,60,60,60,60};
        int[] masses        = {40,50,40,40,40,45,45,40};
        float[] ks          = {12,12,12,12,6,6,12,6,12,12,12,12,12};
        
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
        float y = sqrt((pow(bl,2)-pow(bl/2,2)));
        float x = bl;
        pmPositions.add(new PVector(0, 0));
        pmPositions.add(new PVector(x, 0));
        pmPositions.add(new PVector(2*x, 0));
        pmPositions.add(new PVector(x/2, -y));
        pmPositions.add(new PVector(pmPositions.get(3).x+x, pmPositions.get(3).y));
        pmPositions.add(new PVector(bl/2, y));
        pmPositions.add(new PVector(pmPositions.get(5).x+x, pmPositions.get(5).y));
        // pmPositions.add(new PVector(pmPositions.get(1).x+bl, -2*y));
        
        // Move points relative to the start point
        for (PVector p : pmPositions) {
            p.add(startPoint);
        }
        
        // Create point masses and springs
        createMassesAndSprings(restLengths, masses, ks, pmPositions);
        
        // Define motion params:
        float period = 60;
        // Set friction params for pointMasses
        int[] ptmList1 = {0,1,2,3,4};
        //                          amp period  pha kFriction kf1  kf2
        setFrictionParams(ptmList1, 20, period, 0,  0.0,      0.9, 0.0);
        int[] ptmList2 = {5,6};
        setFrictionParams(ptmList2, 20, period, 0,  1.5,      0.0, 1.5);
        
        // Set oscillation params for springs
        // Set params
        //                                  amp period  phase 
        // springList.get(4).setMovementParams(-50, period, 0);
        springList.get(4).setMovementParams(40, period, 0);
        // springList.get(5).setMovementParams(-50, period, 0);
        springList.get(5).setMovementParams(40, period, 0);
        // springList.get(4).bl = 90;
        // springList.get(5).bl = 90;
        
        // Register springs to update
        springsToUpdate.add(springList.get(4));
        springsToUpdate.add(springList.get(5));
        // springsToUpdate.add(springList.get(9));
        // springsToUpdate.add(springList.get(10));
        //         
    }
    // -------------------------------------------------------------------------
    void setFrictionParams(int[] ptmIdxList, float amp, float per, float phase, 
                           float kFriction, float kf1, float kf2) 
    {
        for (Integer i : ptmIdxList) {
            PointMass pm = pointMassList.get(i);
            pm.setFrictionParams(amp, per, phase, kFriction, kf1, kf2);
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
        // printCurrentLegths();        
        ++time;
    }
    // -------------------------------------------------------------------------
    void display(){
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
  for (PointMass pm : smSystem.pointMassList) { 
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
  for (PointMass pm : smSystem.pointMassList) { 
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
        case '1': {
            creature = 1;;
            break;
        }
        case '2': {
            creature = 2;;
            break;
        }
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