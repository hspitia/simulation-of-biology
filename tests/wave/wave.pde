float startAngle = 0;
float angleVel = 0.1;

void setup() {
  size(400,200);
}

void draw() {
  background(255);

  //[full] In order to move the wave, we start at a different theta value each frame.  startAngle += 0.02;
float angle = startAngle;
  //[end]

  for (int x = 0; x <= width; x += 24) {
    float y = map(sin(angle),-1,1,0,height);
    stroke(0);
    fill(0,50);
    ellipse(x,y,48,48);
    angle += angleVel;
  }
}