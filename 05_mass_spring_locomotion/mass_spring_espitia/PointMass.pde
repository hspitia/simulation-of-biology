class PointMass {
    // Attributes
    float             mass;
    PVector           pos;
    PVector           vel;
    PVector           accel;
    float             shapeDiameter;
    ArrayList<Spring> springs;
    int               id;
    float             maxVel;
    
    // For mouse interaction
    PVector dragOffset;
    boolean dragging = false;
    boolean over     = false; 
    
    // Friction 
    float amplitude;
    float period;
    float phase;
    float kFriction;
    float kf1;
    float kf2;
    
    // Methods
    // -------------------------------------------------------------------------
    PointMass(float mass,   PVector pos, PVector vel, 
              float maxVel, float massDiameterFactor, 
              int id, float kf1, float kf2) {
              // float amplitude, float period, float phase,
              
        this.mass          = mass;
        this.pos           = pos;
        this.vel           = vel;
        this.maxVel        = maxVel;
        this.accel         = new PVector(0, 0);
        this.shapeDiameter = (mass * massDiameterFactor);
        this.dragOffset    = new PVector();
        
        this.id            = id;
        
        this.amplitude     = 0.0;
        this.period        = 0.0;
        this.phase         = 0.0;
        // this.kFriction     = 0.0;
        // this.kf1 = 0.0;
        // this.kf2  = 0.0;
        
        // this.amplitude     = amplitude;
        // this.period        = period;
        // this.phase         = phase;
        this.kf1 = kf1;
        this.kf2  = kf1;
        this.kFriction     = kf2;
        
        springs = new ArrayList<Spring>();
    }
    // -------------------------------------------------------------------------
    void addSpring(Spring s) {
        springs.add(s);
    }
    // -------------------------------------------------------------------------
    void display() {
        strokeWeight(2);
        // stroke(massColor);
        stroke(strokeColor);
        fill(massColor);
        if (dragging || over) fill(massOverColor);
        ellipse(pos.x, pos.y, shapeDiameter, shapeDiameter);
        fill(strokeColor);
        textAlign(CENTER);
        textFont(pointMassFont);
        text(new String(""+kFriction), pos.x, pos.y+3);
    }
    // -------------------------------------------------------------------------
    void setFrictionParams(float amplitude, float period, float phase,
                           float kf1, float kf2) {
        this.amplitude    = amplitude;
        this.period       = period;
        this.phase        = phase;
        // this.kFriction = kFriction;
        this.kf1          = kf1;
        this.kf2          = kf2;
    }
    // -------------------------------------------------------------------------
    void updateKf(int time) {
        float fraction = period/4;
        float counter  = time/fraction;
        
        if (counter % 4 == 1) {
            kFriction = kf1;
        } else if (counter % 4 == 3) {
            kFriction = kf2;
        }
            
        // println("time: "+time+"  kFriction: "+kFriction);
    }
    // -------------------------------------------------------------------------
    void applyForce(PVector force) {
        // accel = F/m
        PVector f = PVector.div(force, mass);
        accel.add(f);
    }
    // -------------------------------------------------------------------------
    void checkEdges() {
         // Change direction when edges are reached

        float offset = (shapeDiameter/2)+1;
        // float offset = 0;
                
        float dampingFactor = 1;
        
        if (pos.x > (canvasSize-offset)) {
            pos.x = (canvasSize-offset);
            vel.x *= -dampingFactor;
        } else if (pos.x < offset) {
            vel.x *= -dampingFactor;
            pos.x = offset;
        }

        if (pos.y > (canvasSize-offset)) {
            vel.y *= -dampingFactor;
            pos.y = (canvasSize-offset);
        } else if (pos.y < offset) {
            vel.y *= -dampingFactor;
            pos.y = offset;
        }
    }
    // -------------------------------------------------------------------------
    void update(){
        vel.add(accel);
        vel.limit(maxVel);
        pos.add(vel);
        accel.mult(0);
    }
    // -------------------------------------------------------------------------
    void over(int mx, int my) {
        float d = dist(mx, my, pos.x, pos.y);
        if (d < (shapeDiameter/2)) 
            over = true;
        else
            over = false;
    }   
    // -------------------------------------------------------------------------
    void clicked(int mx, int my) {
        if (over) {
            dragging = true;
            dragOffset.x = pos.x-mx;
            dragOffset.y = pos.y-my;
        }
    }
    // -------------------------------------------------------------------------
    void stopDragging() {
        dragging = false;
    }
    // -------------------------------------------------------------------------
    void drag(int mx, int my) {
        if (dragging) {
            pos.x = mx + dragOffset.x;
            pos.y = my + dragOffset.y;
        }
    }
    // -------------------------------------------------------------------------
    String toString(){
        return pos.toString();
    }
}