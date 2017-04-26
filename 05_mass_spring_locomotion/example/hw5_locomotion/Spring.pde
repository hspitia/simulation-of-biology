public class Spring{
  public Ptm pt1;
  public Ptm pt2;
  public float l0;
  public float k;
  public float freq;
  public float ph;
  public float amp;
  public float t;
  public boolean existS;
  
  
  public Spring(Ptm point1, Ptm point2, float rest_length, float stiffness){
    pt1=point1;
    pt2=point2;
    l0=rest_length;
    k=stiffness;
    existS=true;
    freq=0;
    ph=0;
    amp=l0/2;
    t=-1;
  }
  
  public void setDetails(float frequency, float phase, float amplitude){
    freq=frequency;
    ph=phase;
    amp=amplitude;
    t=0;
  }
  
  public void updateLength(){
    if(t!=-1){
    t=t+1;
    l0=amp+amp*sin(2*PI*freq*t+ph);
    }
  }  
}
