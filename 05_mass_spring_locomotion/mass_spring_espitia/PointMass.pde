class PointMass {
    // Attributes
    float mass;
    PVector pos;
    PVector vel;
    PVector accel;
    float   shapeDiameter;
    String  id;
    float maxVel;
    
    // Methods
    // -------------------------------------------------------------------------
    PointMass(float mass,   PVector pos, PVector vel, 
              float maxVel, float massDiameterFactor) {
        this.mass          = mass;
        this.pos           = pos;
        this.vel           = vel;
        this.maxVel        = maxVel;
        // this.shapeDiameter = pointMassDiameter;
        this.shapeDiameter = (mass * massDiameterFactor);
        this.accel         = new PVector(0, 0);
    }
    // -------------------------------------------------------------------------
    void display() {
        strokeWeight(2);
        // stroke(massColor);
        stroke(strokeColor);
        fill(massColor);
        ellipse(pos.x, pos.y, shapeDiameter, shapeDiameter);
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
    String toString(){
        return pos.toString();
    }
}