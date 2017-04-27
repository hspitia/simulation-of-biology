color backgroundColor = #999999;

PVector p1, p2;
float frequency = 240;
float period    = 120;
float amplitude = 20;
float phase = 20;

// Time
int lastTime = 0;
int interval = 0;
float restLength = 20;
float length = restLength;
// ArrayList<Integer> list;


void setup() {
    size(1000, 600);
    p1 = new PVector(400, 300);
    p2 = new PVector(600, 300);
    
    // list = new ArrayList<Integer>();
    // list.add(0);
    // list.add(1);
}

void draw() {
    
    
    if (millis() - lastTime > interval){
        background(backgroundColor);
        
        period    = 120;
        
        amplitude = 4;
        
        frequency = 1/period;
        phase     = PI/2;
        
        float x1 = amplitude * sin(TWO_PI * frequency * frameCount + 0);
        // float x1 = amplitude * cos(TWO_PI * frameCount / period + 0);
        float x2 = amplitude * cos(TWO_PI * frameCount / period + phase);
        
        float maxX1 = 0;
        float minX1 = 0;
        float maxX2 = 0;
        float minX2 = 0;
        if (x1 > maxX1) maxX1 = x1;
        if (x1 < minX1) minX1 = x1;
        if (x2 > maxX2) maxX2 = x2;
        if (x2 < minX2) minX2 = x2;
        
        // println("minX1: "+minX1+"   maxX1:"+maxX1);
        // println("minX2: "+minX2+"   maxX1:"+maxX2);
        
        strokeWeight(4);
        p1.x -= x1;
        p2.x += x2;
        line(p1.x, p1.y, p2.x, p2.y);
        
        float disp = x1;
        length = restLength + disp;
        println("length: "+length);
        // println("length: "+length);
        
        strokeWeight(1);
        ellipse(p1.x, p1.y, 10, 10);
        ellipse(p2.x, p2.y, 10, 10);

        lastTime = millis();
    }
    
    
    
    // for (Integer i : list) {
    //     println("i: "+i);
    // }
    
    
}