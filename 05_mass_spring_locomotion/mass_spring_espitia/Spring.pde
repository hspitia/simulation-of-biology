import java.util.Map;
import java.util.Set;
// import java.util.*;  

class Spring {
    PointMass pm1;
    PointMass pm2;
    float restLength;
    float length;
    float k;
    
    float amplitude;
    float frequency;
    float period;
    float phase;
    
    color springColor;
    
    // float time;
    
    int id;
    
    Spring(PointMass pm1, PointMass pm2, 
           float k, float restLength, int id,
           float amplitude,
           float period, color springColor) {
        this.pm1           = pm1;
        this.pm2           = pm2;
        this.k             = k;
        this.restLength    = restLength;
        this.length        = this.restLength;
        this.id            = id;
        this.amplitude     = amplitude;
        this.period        = period;
        this.springColor   = springColor;
        // this.time          = -1;
    }
    // -------------------------------------------------------------------------
    PVector getForce(int pointMassId) {
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
        float distance = force.mag();                    // distance between point masses
        force.normalize();                               // direction - unit vector
        float strectch = distance - length;            // difference of lenghts
        // float strectch = restLength - length;            // difference of lenghts
        force.mult(-1 * k * strectch);                   // spring force
        
        return force;
    }
    // -------------------------------------------------------------------------
    void setMovementParams(float amplitude, float period, float phase){
        this.amplitude = amplitude;
        // this.frequency = frequency;
        this.period    = period;
        this.phase     = phase;
    }
    // -------------------------------------------------------------------------
    void updateLength(int time) {
        float freq = 1/period;
        float x = sin(TWO_PI * freq * ++time + phase);
        
        float start = 0;
        float end   = amplitude;
        if (amplitude < 0) {
            start = amplitude;
            end   = 0;
        }
        // println("x: "+x);
        
        float xMapped = map(x, -1, 1, start, end);
        
        length     = restLength + xMapped;
        
        // length     = restLength + disp;
        
        
        
        // println("disp: "+disp+"  time: "+time);
        
        // println("x: "+x);
        // println("xMapped: "+xMapped);
        // println("length: "+length);
        // println("restLength: "+restLength);
        
        // pm2.pos.add(new PVector(cos(angle1)*-disp, sin(angle1)*-disp));
    }
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
        
        line(pm1.pos.x, pm1.pos.y, pm2.pos.x, pm2.pos.y);
    }
    // -------------------------------------------------------------------------
}