import processing.opengl.*;

float kfParams[] = { 
  0.0625, 0.035, 0.06, 0.035, 0.0475, 0.0118, 0.057,0.016  };

float r_u = 0.082;
float r_v = 0.041;

float frameSkip = 10;

float globalK = kfParams[0];
float globalF = kfParams[1];

int nBlocks = 150;
boolean anim = false;
boolean reaction = true;
boolean euler = true;
boolean spatial = false;

float u[] = new float[(nBlocks+2)*(nBlocks+2)];
float v[] = new float[(nBlocks+2)*(nBlocks+2)];
float spatialK[] = new float[(nBlocks+2)*(nBlocks+2)];
float spatialF[] = new float[(nBlocks+2)*(nBlocks+2)];
float curU[] = u;
float curV[] = v;

float con_min, con_max;
boolean drawU = true;

float u2[] = new float[(nBlocks+2)*(nBlocks+2)];
float v2[] = new float[(nBlocks+2)*(nBlocks+2)];
float resU[] = u2;
float resV[] = v2;

float[] g_diag = new float[nBlocks];
float[] g_upper = new float[nBlocks];
float[] g_lower = new float[nBlocks];
float[] g_tmprow = new float[nBlocks];
float[] g_newdiag = new float[nBlocks];

float[] g_diag2 = new float[nBlocks];
float[] g_upper2 = new float[nBlocks];
float[] g_lower2 = new float[nBlocks];
float[] g_tmprow2 = new float[nBlocks];
float[] g_newdiag2 = new float[nBlocks];

float[] g_tmpres = new float[nBlocks];

final float adiStep = 5;
final float eulerStep = 2;

int g_start = nBlocks+3;
final int row = nBlocks+2;

void swap ()
{
  float tmp[] = curU;
  curU = resU;
  resU = tmp;

  tmp = curV;
  curV = resV;
  resV = tmp;

}

void setup ()
{
  size(600,600,OPENGL); 
  iniCon ();
  initADI (adiStep * r_u * 0.5, adiStep * r_v * 0.5);
  iniSpatial ();
}

void findMinMax ()
{
  con_min = 1e9;
  con_max = -1e9;

  if ( drawU ) {
    for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
      for ( int j = 0; j < nBlocks; ++j, ++index ) {
        con_min = min (con_min, curU[index]);
        con_max = max (con_max, curU[index]);
      }
  } 
  else {
    for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
      for ( int j = 0; j < nBlocks; ++j, ++index ) {
        con_min = min (con_min, curV[index]);
        con_max = max (con_max, curV[index]);
      }  
  }

}

void copyBorder ()
{

  //left row
  int i = nBlocks+2, j = nBlocks+3;
  int sz = (nBlocks+2)*(nBlocks+1);

  while ( i < sz) {
    curU[i] = curU[j];
    curV[i] = curV[j];
    i += nBlocks+2;
    j += nBlocks+2;
  }

  //right row
  i = 2*(nBlocks+2)-1; 
  j = 2*(nBlocks+2)-2;
  sz = (nBlocks+2)*(nBlocks+1);

  while ( i < sz) {
    curU[i] = curU[j];
    curV[i] = curV[j];
    i += nBlocks+2;
    j += nBlocks+2;
  }

  //upper row
  i =0; 
  j =nBlocks+2;
  sz = nBlocks+2;
  while ( i < sz) {
    curU[i] = curU[j];
    curV[i++] = curV[j++];
  }

  //lower row
  i = (nBlocks+2)*(nBlocks+1); 
  j = (nBlocks+2)*nBlocks;
  sz = (nBlocks+2)*(nBlocks+2);

  while ( i < sz) {
    curU[i] = curU[j];
    curV[i++] = curV[j++];
  }

}

void iniCon ()
{
  for ( int i=0, sz = (nBlocks+2)*(nBlocks+2); i < sz; ++i ) {
    curU[i] = 1; 
    curV[i] =0;
  }

  for ( int i = nBlocks/6; i < min ( nBlocks/6+10, height); ++i )
    for ( int j = nBlocks/8; j < min ( nBlocks/8+10, width); ++j ) {
      curU[g_start+i*(nBlocks+2)+j] = 0.5;//+random(0, 0.1) ; 
      curV[g_start+i*(nBlocks+2)+j] = 0.25;//+random(0, 0.1);
    }

  for ( int i = nBlocks*3/4; i < min ( nBlocks*3/4+10, height); ++i )
    for ( int j = nBlocks*4/5; j < min ( nBlocks*4/5+10, width); ++j ) {
      curU[g_start+i*(nBlocks+2)+j] = 0.5;//+random(0, 0.1) ; 
      curV[g_start+i*(nBlocks+2)+j] = 0.25;//+random(0, 0.1);
    }

  for ( int i = nBlocks/2; i < min ( nBlocks/2+10, height); ++i )
    for ( int j = nBlocks/2; j < min ( nBlocks/2+10, width); ++j ) {
      curU[g_start+i*(nBlocks+2)+j] = 0.5;//+random(0, 0.1) ; 
      curV[g_start+i*(nBlocks+2)+j] = 0.25;//+random(0, 0.1);
    }

  for ( int i = nBlocks*3/4; i < min ( nBlocks*3/4+10, height);  ++i )
    for ( int j = nBlocks/5; j < min ( nBlocks/5+10, width); ++j ) {
      curU[g_start+i*(nBlocks+2)+j] = 0.5;//+random(0, 0.1) ; 
      curV[g_start+i*(nBlocks+2)+j] = 0.25;//+random(0, 0.1);
    }
   
}

void draw()
{
  colorMode (RGB, 1.0);
  background(0);

  //animation
  if ( anim) {
    for ( int i =0; i < frameSkip; ++i )
    {
      doDiffusion ();
    }
  }

  // draw routine
  float sx = float(width) / nBlocks;
  float sy = float(height) / nBlocks;

  noStroke ();
  findMinMax ();
  float diff = con_max - con_min;

  if ( diff < 1e-6 )
    diff = 1e-6;

  float data[] = drawU ? curU : curV;

  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      fill ( (data[index] - con_min) / diff);
      rect ( j * sx, i * sy, sx, sy);
    }
}

void keyPressed ()
{
  switch (key) {
  case '1':
    globalK = kfParams[0];
    globalF = kfParams[1];
    break;
  case '2':
    globalK = kfParams[2];
    globalF = kfParams[3];
    break;
  case '3':
    globalK = kfParams[4];
    globalF = kfParams[5];
    break;
  case '4':
    globalK = kfParams[6];
    globalF = kfParams[7];
    break;
  case 'i':
  case 'I':
    iniCon ();
    break;
  case 'u':
  case 'U':
    drawU = true;
    break;
  case 'v':
  case 'V':
    drawU = false;
    break;
  case ' ':
    anim = !anim;
    break;
  case 'a':
  case 'A':
    euler = false;
    break;
  case 'e':
  case 'E':
    euler = true;
    break;
  case 'd':
  case 'D':
    reaction = !reaction;
    break;
    case 'p':
    case 'P':
    spatial = !spatial;
  } 
}

void mousePressed ()
{
 int i = mouseX / (width / nBlocks);
 int j = mouseY / (height / nBlocks);
 int index = g_start + j * row + i;
 println ( "cell (" + i + "," + j + ") u=" + curU[index] + " v=" + curV[index] + 
   (spatial ? ( " k=" + spatialK[index] + " f=" + spatialF[index] ) : "" ) );
}

void testDerivative ()
{
  copyBorder ();
  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      resU[index] = (curU[index+row] - curU[index-row]) * 0.5;
    }

  swap();
}


void testDiffusion()
{
  copyBorder();

  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      resU[index] = curU[index] + ( curU[index-1] + curU[index+1] + curU[index-row] + curU[index+row] - curU[index] * 4 ) * 0.1;
    }

  swap ();

}

void doDiffusion ()
{
  if ( euler && reaction )
    scottStepReaction (eulerStep);
  else if ( euler &&  !reaction )
    scottStepDiffusion (eulerStep);
  else 
  {
    //adi
    
    // first euler --> keep old data and copies answer to res
    eulerVertical ( adiStep * 0.5);
    backEulerHoriz();

    eulerHorizontal(adiStep*0.5);
    backEulerVert();    
      
     if ( reaction )
      doReaction (adiStep);
  }
}

void eulerHorizontal ( float dt)
{
  copyBorder ();

  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      resU[index] = curU[index] + dt * r_u * (curU[index-1] + curU[index+1] - 2.0 * curU[index]);
      resV[index] = curV[index] + dt * r_v * ( curV[index-1] + curV[index+1] - curV[index] * 2.0);
    }
    
  swap ();
}


void eulerVertical ( float dt)
{
  copyBorder ();
  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      resU[index] = curU[index] + dt * r_u * ( curU[index-row] + curU[index+row] - 2.0 * curU[index]);
      resV[index] = curV[index] + dt * r_v * ( curV[index-row] + curV[index+row] - curV[index] * 2.0);
    }
    
   swap ();
}

void doReaction (float dt)
{
  float uvv;

  if ( !spatial ) 
  {
  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      uvv = curU[index]*curV[index]*curV[index];
      resU[index] = curU[index] + dt * ( globalF * ( 1.0 - curU[index] ) - uvv );
      resV[index] = curV[index] + dt * ( -(globalF+globalK) * curV[index] + uvv );
    }
  }
  else {
     for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      uvv = curU[index]*curV[index]*curV[index];
      resU[index] = curU[index] + dt * ( spatialF[index] * ( 1.0 - curU[index] ) - uvv );
      resV[index] = curV[index] + dt * ( -(spatialF[index]+spatialK[index]) * curV[index] + uvv );
    
  }
  }

  swap ();
}

void scottStepReaction (float dt)
{
  float Lu, Lv, uvv;
  copyBorder ();
  
  if ( !spatial ) {

  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      Lu = curU[index-1] + curU[index+1] + curU[index-row] + curU[index+row] - curU[index] * 4.0;
      Lv = curV[index-1] + curV[index+1] + curV[index-row] + curV[index+row] - curV[index] * 4.0;
      uvv = curU[index]*curV[index]*curV[index];
      resU[index] = curU[index] + dt * ( globalF * ( 1.0 - curU[index] ) - uvv + r_u * Lu );
      resV[index] = curV[index] + dt * ( -(globalF+globalK) * curV[index] + uvv + r_v * Lv );
    }
  }
  else
  {
     for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      Lu = curU[index-1] + curU[index+1] + curU[index-row] + curU[index+row] - curU[index] * 4.0;
      Lv = curV[index-1] + curV[index+1] + curV[index-row] + curV[index+row] - curV[index] * 4.0;
      uvv = curU[index]*curV[index]*curV[index];
      resU[index] = curU[index] + dt * ( spatialF[index] * ( 1.0 - curU[index] ) - uvv + r_u * Lu );
      resV[index] = curV[index] + dt * ( -(spatialF[index]+spatialK[index]) * curV[index] + uvv + r_v * Lv );
    }
 
  }

  swap ();
}

void scottStepDiffusion (float dt)
{
  float Lu, Lv, uvv;
  copyBorder ();

  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      Lu = curU[index-1] + curU[index+1] + curU[index-row] + curU[index+row] - curU[index] * 4.0;
      Lv = curV[index-1] + curV[index+1] + curV[index-row] + curV[index+row] - curV[index] * 4.0;
      resU[index] = curU[index] + dt * r_u * Lu;
      resV[index] = curV[index] + dt * r_v * Lv;
    }

  swap ();
}

void backEulerHoriz ()
{
  for ( int i=0, index = g_start; i < nBlocks; ++i, index+=nBlocks+2 ) {
    thomas_solveHoriz ( g_newdiag, g_upper, g_tmprow, curU, index, g_tmpres); 
    thomas_solveHoriz ( g_newdiag2, g_upper2, g_tmprow2, curV, index, g_tmpres);
  }
}

void backEulerVert ()
{
  for ( int i=0, index = g_start; i < nBlocks; ++i, ++index ) {
    thomas_solveVert ( g_newdiag, g_upper, g_tmprow, curU, index, g_tmpres); 
    thomas_solveVert ( g_newdiag2, g_upper2, g_tmprow2, curV, index, g_tmpres);
  }
}

void initADI(float a, float b)
{
  // setup diag,upper,lower
  for ( int i =0; i < nBlocks; ++i )
  {
   g_diag[i] = 1.0 + 2.0 * a; 
   g_upper[i] = g_lower[i] = -a;
   g_diag2[i] = 1.0 + 2.0 * b; 
   g_upper2[i] = g_lower2[i] = -b;

  }
  
  g_diag[0] = g_diag[nBlocks-1] = 1.0 +a;
  g_lower[0] = g_upper[nBlocks-1] = 0;  
  thomas_preprocess ( g_diag, g_upper, g_lower, g_newdiag, g_tmprow );
  
  g_diag2[0] = g_diag2[nBlocks-1] = 1.0 +b;
  g_lower2[0] = g_upper2[nBlocks-1] = 0;  
  thomas_preprocess ( g_diag2, g_upper2, g_lower2, g_newdiag2, g_tmprow2 );

}

void thomas_solveHoriz ( float[] newdiag, float upper[], float[] tmpinfo, float[] rhs, int start, float[] newrhs )
{
  int n= newdiag.length;
  newrhs[0] = rhs[start];
  for ( int i =1; i < n; ++i)
  {
    newrhs[i] = rhs[start+i] - tmpinfo[i] * newrhs[i-1];
  }
  
  rhs[start+n-1] = newrhs[n-1] / newdiag[n-1];
  for ( int i = n-2, index = start+n-2; i >= 0; --i, --index )
  {
   rhs[index] = (newrhs[i] - upper[i] * rhs[index+1]) / newdiag[i];
  }
}

void thomas_solveVert ( float[] newdiag, float upper[], float[] tmpinfo, float[] rhs, int start, float[] newrhs )
{
  int n= newdiag.length;
  newrhs[0] = rhs[start];
  for ( int i =1, index=start+row; i < n; ++i, index+=row)
  {
    newrhs[i] = rhs[index] - tmpinfo[i] * newrhs[i-1];
  }
  
  rhs[start+(n-1)*row] = newrhs[n-1] / newdiag[n-1];
  for ( int i = n-2, index = start+(n-2)*row; i >= 0; --i, index-=row )
  {
   rhs[index] = (newrhs[i] - upper[i] * rhs[index+row]) / newdiag[i];
  }
}

void thomas_preprocess ( float[] diag, float[] upper, float lower[], float[] newdiag, float[] tmpinfo )
{
  newdiag[0] = diag[0];
  for ( int i =1; i < diag.length; ++i)
  {
        tmpinfo[i] = lower[i] / newdiag[i-1];
        newdiag[i] = diag[i] - tmpinfo[i] * upper[i-1];
  }
}

void iniSpatial ()
{
   for ( int i=0, index = g_start; i < nBlocks; ++i, index+=2 )
    for ( int j = 0; j < nBlocks; ++j, ++index ) {
      spatialK[index] = 0.03 + float(j)/float(nBlocks) * (0.07-0.03);
      spatialF[index] = (1.0 - float(i)/float(nBlocks))*0.08;
    } 
}