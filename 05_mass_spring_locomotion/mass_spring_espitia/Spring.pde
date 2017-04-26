import java.util.Map;
import java.util.Set;
// import java.util.*;  

class Spring {
    // HashMap<Integer,PointMass> pointMasses;
    // HashMap<Integer,PVector>   restPoints;
    PointMass pm1;
    PointMass pm2;
    // PVector anchor1;
    // PVector anchor2;
    float restLength;
    float currentLength;
    float k;
    
    float amplitude;
    float frequency;
    float period;
    float phase;
    
    int id;
    
    Spring(PointMass pm1, PointMass pm2, 
           float k, float restLength, int id,
           float amplitude, float frequency, float period) {
        this.pm1           = pm1;
        this.pm2           = pm2;
        this.k             = k;
        this.restLength    = restLength;
        this.currentLength = restLength;
        this.id            = id;
        this.amplitude     = amplitude;
        this.frequency     = frequency;
        this.period        = period;
        // this.anchor1 = anchor1;
        // this.anchor2 = anchor2;
        // pointMasses = new HashMap<Integer,PointMass>();
        // pointMasses.put(pm1.id, pm1);
        // pointMasses.put(pm2.id, pm2);
        
        // restPoints = new HashMap<Integer,PVector>();
        // restPoints.put(pm1.id, pm2.pos);
        // restPoints.put(pm2.id, pm1.pos);
    }
    // -------------------------------------------------------------------------
    // PVector connect(int nPointMass) {
    //     PointMass pm;
    //     PVector anchor;
    //     if (nPointMass >= 1 && nPointMass <= 2) {
    //         pm     = pm1;
    //         anchor = anchor2;
    //         if (nPointMass == 2) {
    //             pm     = pm2;
    //             anchor = anchor1;
    //         }
    //     } else {
    //         println("Error: Invalid index for Spring. Valid values are 1 or 2");
    //         exit();
    //     }
        
    //     // PVector force = PVector.sub();
        
    //     // PVector force = PVector.sub(b.location,anchor);
        
    //     // float d = force.mag();
    //     // float stretch = d - len;
         
    //     // force.normalize();
    //     // force.mult(-1 * k * stretch);
         
    //     // b.applyForce(force);
    //     return new PVector(0,0);
    // }
    // -------------------------------------------------------------------------
    PVector getForce(int pointMassId) {
        // int secondaryId;
        // for (Map.Entry pms : pointMasses.entrySet()) {
        //     currentId = ((PointMass)pms.getValue()).id;
        //     if (pointMassId != currentId){
        //         secondaryId = currentId;
        //     }
        // }
        // 
        // PointMass mainPm  = pointMasses.get(pointMassId);
        // PointMass secondaryPm = pointMasses.get(secondaryId);
        
        PointMass mainPm;
        PointMass secondaryPm;
        if (pointMassId == pm1.id) {
            mainPm      = pm1;
            secondaryPm = pm2;
        } else {
            mainPm      = pm2;
            secondaryPm = pm1;
        }
        
        // PVector restPoint = restPoints.get(pointMassId);
        PVector force  = PVector.sub(mainPm.pos, secondaryPm.pos);  // difference between point masses
        float length   = force.mag();                    // distance between point masses
        force.normalize();                               // direction - unit vector
        float strectch = length - restLength;            // difference of lenghts
        // float strectch = currentLength - restLength;            // difference of lenghts
        force.mult(-1 * k * strectch);                   // spring force
        
        return force;
    }
    // -------------------------------------------------------------------------
    void setMovementParams(float amplitude, float frequency, float period, float phase){
        this.amplitude = amplitude;
        this.frequency = frequency;
        this.period    = period;
        this.phase     = phase;
    }
    // -------------------------------------------------------------------------
    void updateLength() {
        // float amplitude = 2;
        // float period    = 60;
        this.restLength = this.restLength + amplitude/2 * sin(TWO_PI * frameCount/period + phase);
        
        // // ------------------------------------------------------------
        // PVector dirPm1 = PVector.sub(pm1.pos, pm2.pos);
        // PVector dirPm2 = PVector.sub(pm2.pos, pm1.pos);
        // float angle1 = dirPm1.heading();
        // float angle2 = dirPm2.heading();
        // dirPm1.normalize();
        // dirPm2.normalize();
        // pm1.pos.add(new PVector(cos(angle1)*disp, sin(angle1) * disp));
        // pm2.pos.add(new PVector(cos(angle1)*-disp, sin(angle1)*-disp));
        
        
    }
    // // -------------------------------------------------------------------------
    // void update() {
        
    // }
    // // -------------------------------------------------------------------------
    // // Constrain the distance between bob and anchor between min and max
    // void constrainLength(Bob b, float minlen, float maxlen) {
    //     PVector dir = PVector.sub(b.position, anchor);
    //     float d = dir.mag();
    //     // Is it too short?
    //     if (d < minlen) {
    //         dir.normalize();
    //         dir.mult(minlen);
    //         // Reset position and stop from moving (not realistic physics)
    //         b.position = PVector.add(anchor, dir);
    //         b.velocity.mult(0);
    //         // Is it too long?
    //     } 
    //     else if (d > maxlen) {
    //         dir.normalize();
    //         dir.mult(maxlen);
    //         // Reset position and stop from moving (not realistic physics)
    //         b.position = PVector.add(anchor, dir);
    //         b.velocity.mult(0);
    //     }
    // }
    // // -------------------------------------------------------------------------
    // void update(PointMass pm1, PointMass pm2) {
    //     anchor1 = pm1.pos.get();
    //     anchor2 = pm2.pos.get();
    // }
    // -------------------------------------------------------------------------
    void display() {
        int st = 4;
        strokeWeight(st);
        stroke(springColor);
        
        // int nPositions = 2;
        // PVector[] positions = new PVector[pointMasses.size()];
        
        // int idx = 0;
        // for (Map.Entry pms : pointMasses.entrySet()) {
        //     positions[idx++] = ((PointMass)pms.getValue()).pos.get();
        // }
        
        // line(positions[0].x, positions[0].y, 
        //      positions[1].x, positions[1].y);
        
        line(pm1.pos.x, pm1.pos.y, pm2.pos.x, pm2.pos.y);
    }
    // -------------------------------------------------------------------------
}