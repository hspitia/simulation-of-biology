public Ptm[] ptms;
int size;
float delta_time;
float fspringx;
float fspringy;
float ux;
float uy;
float d;
float fsp;
Spring[][] springs;
boolean continuous;
int[][]array;
float initl;
boolean onestep;


void setup() {
  onestep=true;
  continuous=false;
  initl=0;
  fsp=0;
  d=0;
  ux=0;
  uy=0;
  fspringx=0;
  fspringy=0;
  size(1200, 600);
  delta_time=0.05;
  size=7;
  array = new int [size][size];
  ptms = new Ptm[size];
  springs=new Spring[size][size];

  //body triangle
  //FROG CODE
   ptms[0]= new Ptm (50, 50, 89, 0, 0);
   ptms[1]= new Ptm (50, 70, 89, 0, 0);
   ptms[2]= new Ptm (50, 60, 89-sqrt(300), 0, 0);
  for (int i=0; i<3; i++) { //initialization of position and speed // GO TO SIZE
    if(i<3){
    for(int j=0;j<3;j++){
      if(i!=j){
      springs[i][j]=new Spring(ptms[i],ptms[j],20,20);
      }
      }
    }
  }
  
  ptms[3]=new Ptm(50,50,99,0,0);
  ptms[4]=new Ptm(50,70,99,0,0);//2 vx?
  ptms[5]=new Ptm(50,60,89,0,0);
  ptms[6]=new Ptm(50,60,99,0,0);
  springs[3][0]=new Spring(ptms[3],ptms[0],10,30);
  array[3][0]=2;
  springs[4][1]=new Spring(ptms[4],ptms[1],10,30);
  array[4][1]=2;
  springs[5][1]=new Spring(ptms[5],ptms[1],0.1,30);
  array[5][1]=2;
  springs[5][0]=new Spring(ptms[5],ptms[0],1.8,30);
  array[5][0]=2;
  springs[5][3]=new Spring(ptms[5],ptms[3],sqrt(200),30);
  array[5][3]=2;
  springs[5][4]=new Spring(ptms[5],ptms[0],sqrt(200),30);
  array[5][4]=2;
  
  springs[6][0]=new Spring(ptms[6],ptms[0],10,30);
  array[6][0]=2;
  springs[6][1]=new Spring(ptms[6],ptms[1],10,30);
  array[6][1]=2;
  springs[6][5]=new Spring(ptms[6],ptms[5],10,30);
  array[6][5]=2;
  
  springs[6][3]=new Spring(ptms[6],ptms[3],sqrt(200),30);
  array[6][3]=2;
  springs[6][4]=new Spring(ptms[6],ptms[0],sqrt(200),30);
  array[6][4]=2;
  
//  springs[5][2]=new Spring(ptms[5],ptms[2],20,50);
//  array[5][2]=2;

  
    //  //frequency, phase, amplitude
    springs[5][0].setDetails(1,0,2);
    springs[5][1].setDetails(1,PI,2);
    
    
    ptms[0]= new Ptm (50, 50, 89, 0, 0);
   ptms[1]= new Ptm (50, 70, 89, 0, 0);
   ptms[2]= new Ptm (50, 60, 89-sqrt(300), 0, 0);
  for (int i=0; i<3; i++) { //initialization of position and speed // GO TO SIZE
    if(i<3){
    for(int j=0;j<3;j++){
      if(i!=j){
      springs[i][j]=new Spring(ptms[i],ptms[j],20,20);
      }
      }
    }
  }
  //FISH CODE
  
//  ptms[3]=new Ptm(100,50,99,0,0);
//  ptms[4]=new Ptm(100,70,99,0,0);
//  ptms[5]=new Ptm(100,60,89,0,0);
//  springs[3][0]=new Spring(ptms[3],ptms[0],10,30);
//  array[3][0]=2;
//  springs[4][1]=new Spring(ptms[4],ptms[1],10,30);
//  array[4][1]=2;
//  springs[5][1]=new Spring(ptms[5],ptms[1],2,30);
//  array[5][1]=2;
//  springs[5][0]=new Spring(ptms[5],ptms[0],2,30);
//  array[5][0]=2;
//  springs[5][3]=new Spring(ptms[5],ptms[3],sqrt(200),30);
//  array[5][3]=2;
//  springs[5][4]=new Spring(ptms[5],ptms[0],sqrt(200),30);
//  array[5][4]=2;
//  springs[3][4]=new Spring(ptms[3],ptms[4],20,30);
//  array[3][4]=2;
//  
//    //  //frequency, phase, amplitude
//    springs[5][0].setDetails(1,0,2);
//    springs[5][1].setDetails(1,PI,2);
//    
  
  
  
  
//  for(int i=3;i<6;i++){
//    ptms[i]=new Ptm(100,20+5*i,99,0,0);
//    if(i>3){
//      springs[i][i-1]=new Spring(ptms[i],ptms[i-1],5,100);
//      array[i][i-1]=2;
//    }
//  }
//  springs[3][1]=new Spring(ptms[3],ptms[1],5,50);
//  array[3][1]=2;
//  
//  for(int i=6;i<size;i++){
//    ptms[i]=new Ptm(100,25+5*(i-5),99-sqrt(5*5-2.5*2.5),0,0);
//      if(i>6){
//      springs[i][i-1]=new Spring(ptms[i],ptms[i-1],5,50);
//      array[i][i-1]=2;
//    }    
//  }
//  springs[6][2]=new Spring(ptms[6],ptms[2],5,50);
//  array[6][2]=2;
//  
//  for(int i=0;i<3;i++){
//    springs[3+i][6+i]=new Spring(ptms[3+i],ptms[6+i],5,500);
//    array[3+i][6+i]=2;
//  }
//  
//  springs[6][1]=new Spring(ptms[6],ptms[1],5,500);
//  array[6][1]=2;
//  springs[6][4]=new Spring(ptms[6],ptms[4],5,500);
//  array[6][4]=2;
//  springs[7][3]=new Spring(ptms[7],ptms[3],5,500);
//  array[7][3]=2;
//  springs[7][5]=new Spring(ptms[7],ptms[5],5,500);
//  array[7][5]=2;
//  springs[2][3]=new Spring(ptms[2],ptms[3],5,500);
//  array[2][3]=2;
//  
  
  
    //  //frequency, phase, amplitude

    
    
    
    
}

void draw() {
  if(continuous==true || onestep==true){
  background(0,0,0);
  noStroke();


  //display
  for (int i=0; i<size; i++) { 
    if (ptms[i].exist==true) {
      if(i<3){ //triangle
        fill(12,102,0);
        rect(6*ptms[i].px, 6*ptms[i].py, 6, 6);
        for(int j=0;j<3;j++){
         stroke(12,102,0);
         line(6*ptms[i].px+3, 6*ptms[i].py+3, 6*ptms[j].px+3, 6*ptms[j].py+3);
        }
        
        
      }
      else{ //muscles
      fill(204, 102, 0);//204,102
      rect(6*ptms[i].px, 6*ptms[i].py, 6, 6);
      }
    }
  }
  
  //display muscles
  stroke(204, 102, 0);
  for(int i=0;i<size;i++){
    for(int j=0;j<size;j++){
      if(array[i][j]==2){
        line(6*ptms[i].px+3, 6*ptms[i].py+3, 6*ptms[j].px+3, 6*ptms[j].py+3);
      }
    }
  }
  
  
  //triangle
  for(int i=0;i<3;i++){
    fspringx=0;
    fspringy=0;
    fsp=0;
    //elements of triangle
     for(int j=0;j<3;j++){
       if(i!=j){
         d=sqrt((ptms[i].px-ptms[j].px)*(ptms[i].px-ptms[j].px) + (ptms[i].py-ptms[j].py)*(ptms[i].py-ptms[j].py));
           if(d!=0){
             fsp=-springs[i][j].k*(d-springs[i][j].l0);
             ux=ptms[j].px-ptms[i].px;
             uy=ptms[j].py-ptms[i].py;
             fspringx=fspringx-fsp*ux;
             fspringy=fspringy-fsp*uy;  
       }
       
     }
    }
     ptms[i].vx=ptms[i].vx+delta_time*fspringx/(ptms[i].m);
     ptms[i].vy=ptms[i].vy+delta_time*fspringy/(ptms[i].m);
     ptms[i].update();
  }
  
  //muscles
  for(int i=0;i<size;i++){
    for(int j=0;j<size;j++){
      if(array[i][j] == 2){// where there is a spring
        Spring sp = springs[i][j];
        sp.updateLength();
        fspringx = 0;
        fspringy = 0;
        fsp      = 0;
        d        = sqrt((ptms[i].px-ptms[j].px)*(ptms[i].px-ptms[j].px) + (ptms[i].py-ptms[j].py)*(ptms[i].py-ptms[j].py));
        if(d !=0 ){
          fsp      = -sp.k*(d-sp.l0);
          ux       = ptms[j].px-ptms[i].px;
          uy       = ptms[j].py-ptms[i].py;
          fspringx = fspringx-fsp*ux;
          fspringy = fspringy-fsp*uy;  
        }
        
        ptms[i].vx = ptms[i].vx+delta_time*fspringx/(ptms[i].m);
        ptms[i].vy = ptms[i].vy+delta_time*fspringy/(ptms[i].m);
        ptms[i].update();
        
        ptms[j].vx = ptms[j].vx-delta_time*fspringx/(ptms[j].m);
        ptms[j].vy = ptms[j].vy-delta_time*fspringy/(ptms[j].m);
        ptms[j].update();
      }
      }
    }  
  }
  onestep=false;
}


void keyPressed(){
  if(key==' '){
    continuous=!continuous;
  }
  if(key=='s'){
    onestep=true;
    continuous=false;
  }
  
}


