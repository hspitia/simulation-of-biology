color backgroundColor = #999999;

PVector p1, p2;
float frequency = 240;
float period    = 120;
float amplitude = 1;

// Time
int lastTime = 0;
int interval = 0;



void setup() {
    size(1000, 600);
    p1 = new PVector(400, 300);
    p2 = new PVector(500, 300);
}

void draw() {
    
    
    if (millis() - lastTime > interval){
        // background(backgroundColor);
        // strokeWeight(4);
        // // p1 = new PVector(200, 300);
        // // p2 = new PVector(400, 300);
        
        // float x1 = 0;
        // // float disp = amplitude * cos(TWO_PI * frameCount / period);
        // float disp = 1 * cos(TWO_PI * frameCount / 120);
        // // float disp = cos(TWO_PI * frameCount / period);
        // println("frameCount: "+frameCount);
        // println("disp: "+disp);
        
        // PVector dir = PVector.sub(p1, p2);
        // float angle = dir.heading();
        // // println("angle: "+angle);
        
        
        // PVector newP1 = new PVector(round(disp*cos(angle)), 
        //                             round(disp*sin(angle)));
        // PVector newP2 = new PVector(round(-disp*cos(angle)), 
        //                             round(-disp*sin(angle)));
        // println("p1: "+p1+"  p2:"+p2);
        // // println("newP1: "+newP1);
        // p1.add(newP1);
        // p2.add(newP2);
        // // println("p1: "+p1);
        // strokeWeight(3);
        // // line(p1.x, p1.y, p2.x, p2.y);
        // strokeWeight(1);
        // fill(255, 140, 0, 255);
        // ellipse(p1.x, p1.y, 30, 30);
        // // fill(255);
        // // ellipse(p2.x, p2.y, 30, 30);
        
        background(255);
         
        float period = 120;
        float amplitude = 100;

        // Calculating horizontal location according to the formula for simple harmonic motion

        float x = 100 * cos(TWO_PI * frameCount / 120);
        println("x: "+x);
        
        
        PVector dir = PVector.sub(p1, p2);
        float angle = dir.heading();
        
        
        stroke(0);
        fill(175);
        translate(width/2,height/2);
        line(0,0,x,0);
        ellipse(x,0,20,20);
        
        /
        
        
        lastTime = millis();
    }
    
}