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
              float maxVel, int pointMassDiameter) {
        this.mass          = mass;
        this.pos           = pos;
        this.vel           = vel;
        this.maxVel        = maxVel;
        this.shapeDiameter = pointMassDiameter;
        // this.shapeDiameter = (mass*16);
        this.accel         = new PVector(0, 0);
    }
    // -------------------------------------------------------------------------
    void display() {
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
         // check borders
        float offset = shapeDiameter/2;
        // float[] limits = {offset, (canvasSize-offset)};
        
        // // toroidal
        // if (pos.y > (canvasSize-offset) || pos.y < offset)
        //     pos.y = limits[int(pos.y < offset)];
        
        // if (pos.x > (canvasSize-offset) || pos.x < offset)
        //     pos.x = limits[int(pos.x < offset)];
        
        
        // bouncing
        if (pos.x > (canvasSize-offset) || pos.x < offset)
            vel.x *= -0.8;
        
        if (pos.y > (canvasSize-offset) || pos.y < offset)
            vel.y *= -0.8;
        
        if (pos.x > (canvasSize-offset))
            pos.x = canvasSize-offset;
        
        if (pos.x < offset)
            pos.x = offset;
        
        if (pos.y > (canvasSize-offset))
            pos.y = canvasSize-offset;
        
        if (pos.y < offset)
            pos.y = offset;
    }
    // -------------------------------------------------------------------------
    void update(){
        checkEdges();
        
        vel.add(accel);
        vel.limit(maxVel);
        pos.add(vel);
        // reset acceleration
        accel.mult(0);
    }
    // -------------------------------------------------------------------------
    String toString(){
        return pos.toString();
    }
}