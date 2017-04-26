public Ptm[] list;
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
  list = new Ptm[size];
  springs=new Spring[size][size];

  //body triangle
  //FROG CODE
   list[0]= new Ptm (50, 50, 89, 0, 0);
   list[1]= new Ptm (50, 70, 89, 0, 0);
   list[2]= new Ptm (50, 60, 89-sqrt(300), 0, 0);
  for (int i=0; i<3; i++) { //initialization of position and speed // GO TO SIZE
    if(i<3){
    for(int j=0;j<3;j++){
      if(i!=j){
      springs[i][j]=new Spring(list[i],list[j],20,20);
      }
      }
    }
  }
  
  list[3]=new Ptm(50,50,99,0,0);
  list[4]=new Ptm(50,70,99,0,0);//2 vx?
  list[5]=new Ptm(50,60,89,0,0);
  list[6]=new Ptm(50,60,99,0,0);
  springs[3][0]=new Spring(list[3],list[0],10,30);
  array[3][0]=2;
  springs[4][1]=new Spring(list[4],list[1],10,30);
  array[4][1]=2;
  springs[5][1]=new Spring(list[5],list[1],0.1,30);
  array[5][1]=2;
  springs[5][0]=new Spring(list[5],list[0],1.8,30);
  array[5][0]=2;
  springs[5][3]=new Spring(list[5],list[3],sqrt(200),30);
  array[5][3]=2;
  springs[5][4]=new Spring(list[5],list[0],sqrt(200),30);
  array[5][4]=2;
  
  springs[6][0]=new Spring(list[6],list[0],10,30);
  array[6][0]=2;
  springs[6][1]=new Spring(list[6],list[1],10,30);
  array[6][1]=2;
  springs[6][5]=new Spring(list[6],list[5],10,30);
  array[6][5]=2;
  
  springs[6][3]=new Spring(list[6],list[3],sqrt(200),30);
  array[6][3]=2;
  springs[6][4]=new Spring(list[6],list[0],sqrt(200),30);
  array[6][4]=2;
  
//  springs[5][2]=new Spring(list[5],list[2],20,50);
//  array[5][2]=2;

  
    //  //frequency, phase, amplitude
    springs[5][0].setDetails(1,0,2);
    springs[5][1].setDetails(1,PI,2);
    
    
    list[0]= new Ptm (50, 50, 89, 0, 0);
   list[1]= new Ptm (50, 70, 89, 0, 0);
   list[2]= new Ptm (50, 60, 89-sqrt(300), 0, 0);
  for (int i=0; i<3; i++) { //initialization of position and speed // GO TO SIZE
    if(i<3){
    for(int j=0;j<3;j++){
      if(i!=j){
      springs[i][j]=new Spring(list[i],list[j],20,20);
      }
      }
    }
  }
  //FISH CODE
  
//  list[3]=new Ptm(100,50,99,0,0);
//  list[4]=new Ptm(100,70,99,0,0);
//  list[5]=new Ptm(100,60,89,0,0);
//  springs[3][0]=new Spring(list[3],list[0],10,30);
//  array[3][0]=2;
//  springs[4][1]=new Spring(list[4],list[1],10,30);
//  array[4][1]=2;
//  springs[5][1]=new Spring(list[5],list[1],2,30);
//  array[5][1]=2;
//  springs[5][0]=new Spring(list[5],list[0],2,30);
//  array[5][0]=2;
//  springs[5][3]=new Spring(list[5],list[3],sqrt(200),30);
//  array[5][3]=2;
//  springs[5][4]=new Spring(list[5],list[0],sqrt(200),30);
//  array[5][4]=2;
//  springs[3][4]=new Spring(list[3],list[4],20,30);
//  array[3][4]=2;
//  
//    //  //frequency, phase, amplitude
//    springs[5][0].setDetails(1,0,2);
//    springs[5][1].setDetails(1,PI,2);
//    
  
  
  
  
//  for(int i=3;i<6;i++){
//    list[i]=new Ptm(100,20+5*i,99,0,0);
//    if(i>3){
//      springs[i][i-1]=new Spring(list[i],list[i-1],5,100);
//      array[i][i-1]=2;
//    }
//  }
//  springs[3][1]=new Spring(list[3],list[1],5,50);
//  array[3][1]=2;
//  
//  for(int i=6;i<size;i++){
//    list[i]=new Ptm(100,25+5*(i-5),99-sqrt(5*5-2.5*2.5),0,0);
//      if(i>6){
//      springs[i][i-1]=new Spring(list[i],list[i-1],5,50);
//      array[i][i-1]=2;
//    }    
//  }
//  springs[6][2]=new Spring(list[6],list[2],5,50);
//  array[6][2]=2;
//  
//  for(int i=0;i<3;i++){
//    springs[3+i][6+i]=new Spring(list[3+i],list[6+i],5,500);
//    array[3+i][6+i]=2;
//  }
//  
//  springs[6][1]=new Spring(list[6],list[1],5,500);
//  array[6][1]=2;
//  springs[6][4]=new Spring(list[6],list[4],5,500);
//  array[6][4]=2;
//  springs[7][3]=new Spring(list[7],list[3],5,500);
//  array[7][3]=2;
//  springs[7][5]=new Spring(list[7],list[5],5,500);
//  array[7][5]=2;
//  springs[2][3]=new Spring(list[2],list[3],5,500);
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
    if (list[i].exist==true) {
      if(i<3){ //triangle
        fill(12,102,0);
        rect(6*list[i].px, 6*list[i].py, 6, 6);
        for(int j=0;j<3;j++){
         stroke(12,102,0);
         line(6*list[i].px+3, 6*list[i].py+3, 6*list[j].px+3, 6*list[j].py+3);
        }
        
        
      }
      else{ //muscles
      fill(204, 102, 0);//204,102
      rect(6*list[i].px, 6*list[i].py, 6, 6);
      }
    }
  }
  
  //display muscles
  stroke(204, 102, 0);
  for(int i=0;i<size;i++){
    for(int j=0;j<size;j++){
      if(array[i][j]==2){
        line(6*list[i].px+3, 6*list[i].py+3, 6*list[j].px+3, 6*list[j].py+3);
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
         d=sqrt((list[i].px-list[j].px)*(list[i].px-list[j].px) + (list[i].py-list[j].py)*(list[i].py-list[j].py));
           if(d!=0){
         fsp=-springs[i][j].k*(d-springs[i][j].l0);
         ux=list[j].px-list[i].px;
         uy=list[j].py-list[i].py;
         fspringx=fspringx-fsp*ux;
         fspringy=fspringy-fsp*uy;  
       }
       
     }
    }
     list[i].vx=list[i].vx+delta_time*fspringx/(list[i].m);
     list[i].vy=list[i].vy+delta_time*fspringy/(list[i].m);
     list[i].update();
  }
  
  //muscles
  for(int i=0;i<size;i++){
    for(int j=0;j<size;j++){
      if(array[i][j]==2){// where there is a spring
    springs[i][j].updateLength();
    fspringx=0;
    fspringy=0;
    fsp=0;
    d=sqrt((list[i].px-list[j].px)*(list[i].px-list[j].px) + (list[i].py-list[j].py)*(list[i].py-list[j].py));
    if(d!=0){
         fsp=-springs[i][j].k*(d-springs[i][j].l0);
         ux=list[j].px-list[i].px;
         uy=list[j].py-list[i].py;
         fspringx=fspringx-fsp*ux;
         fspringy=fspringy-fsp*uy;  
       }
     list[i].vx=list[i].vx+delta_time*fspringx/(list[i].m);
     list[i].vy=list[i].vy+delta_time*fspringy/(list[i].m);
     list[i].update();
     list[j].vx=list[j].vx-delta_time*fspringx/(list[j].m);
     list[j].vy=list[j].vy-delta_time*fspringy/(list[j].m);
     list[j].update();
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


