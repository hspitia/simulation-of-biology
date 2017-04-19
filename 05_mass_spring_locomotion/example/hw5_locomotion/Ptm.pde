public class Ptm {
  public float px;
  public float py;
  public float m;
  public float vx;
  public float vy;
  public float ax;
  public float ay;
  public float fx;
  public float fy;
  public float oldpx;
  public float oldpy;
  public float olderpx;
  public float olderpy;
  public float damp;
  public float fdampx;
  public float fdampy;
  public boolean exist;
  public float delta_time;
  public float g;
  
  public Ptm(float mass, float posx,float posy, float speedx, float speedy){
      px=posx;
      py=posy;
      vx=speedx;
      vy=speedy;
      m=mass;
      exist=true;
    }
  
  public void update(){
    g=10;
    damp=0.3;
    delta_time=0.05;
      if(px+delta_time*vx>199 || px+delta_time*vx<0 ){
        vx=-vx;
      }
      olderpx=oldpx;
      oldpx=px;
      px=px+delta_time*vx;
      
      if(py+delta_time*vy>99 || py+delta_time*vy<0 ){
        vy=-vy;
      }
      olderpy=oldpy;
      oldpy=py;
      py=py+delta_time*vy;
    
    //damping force
    fdampx=-damp*vx;
    fdampy=-damp*vy;
    
    //gravity
    
    vx=vx+delta_time*(fdampx)/m;
    vy=vy+delta_time*(fdampy)/m;

  }
  

}
