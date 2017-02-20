// Grid variables
int nCols    = 600;
int nRows    = 600;
int cellSize = 1;

// Reaction-Diffusion variables
float rU = 1.0;
float rV = 0.5;
float f  = 0.055;
float k  = 0.062;

// Grid arrays
Cell[][] gridPrime;
Cell[][] grid;

// Interval variables
int lastTime = 0;
int interval = 10;

// Flags
boolean simRunning = true;
boolean reactDiff  = true;

// =============================================================================
void setup() {
    size(600, 600);
    gridPrime = new Cell[nCols][nRows];
    grid      = new Cell[nCols][nRows];
    initGrids();
    // display();
}
// -----------------------------------------------------------------------------
void draw() {
    // println(frameRate);
    if (millis() - lastTime > interval && simRunning){
        update();
        swapGrids();
        display();
        lastTime  = millis();
    }
}
// =============================================================================
// Functions
// Initialization of grids
void initGrids() {
    // initial values
    for (int i = 0; i < nRows; i++) {
        for (int j = 0; j < nCols; j++) {
            float u = 1;
            float v = 0;
            // float u = random(1);
            // float v = random(1);
            gridPrime[i][j] = new Cell(j*cellSize,
                                       i*cellSize,
                                       cellSize,
                                       cellSize,
                                       u, v);
            grid[i][j]      = new Cell(j*cellSize,
                                       i*cellSize,
                                       cellSize,
                                       cellSize,
                                       u, v);
        }
    }
    
    // random regions
    int nRegions   = 10;
    int regionSize = 10;
    
    for (int r = 0; r < nRegions; r++) {
        int startX = int(random(20, nCols-20));
        int startY = int(random(20, nRows-20));
        
        for (int i = startX; i < startX+regionSize; i++) {
            for (int j = startY; j < startY+regionSize; j++) {
                float u = 1;
                float v = 1;
                gridPrime[i][j] = new Cell(j*cellSize,
                                           i*cellSize,
                                           cellSize,
                                           cellSize,
                                           u, v);
                
                grid[i][j]      = new Cell(j*cellSize,
                                           i*cellSize,
                                           cellSize,
                                           cellSize,
                                           u, v);
            }
        }
    }
}
// -----------------------------------------------------------------------------
void display() {
    for (int i = 0; i < nRows; ++i) {
        for (int j = 0; j < nCols; ++j) {
            gridPrime[i][j].display();
        }
    }
}
// -----------------------------------------------------------------------------
void update(){
    for (int i = 1; i < nRows-1; i++) {
        for (int j = 1; j < nCols-1; j++) {
            Cell cell      = grid[i][j];
            Cell cellPrime = gridPrime[i][j];
            
            float u = cell.compU;
            float v = cell.compV;
            
            cellPrime.compU = u + (rU * laplaceU(i,j) - u*v*v + f*(1-u)) * 1;
            cellPrime.compV = v + (rV * laplaceV(i,j) + u*v*v + (k+f)*v) * 1;
            
            cellPrime.compU = constrain(cellPrime.compU, 0, 1);
            cellPrime.compV = constrain(cellPrime.compV, 0, 1);
        }
    }
}
// -----------------------------------------------------------------------------
void swapGrids() {
    Cell[][] tmp = grid;
    grid      = gridPrime;
    gridPrime = tmp;
}
// -----------------------------------------------------------------------------
float laplaceU(int i, int j) {
    float sum = 0;
    
    sum += grid[i][j].compU * -1;
    sum += grid[i-1][j].compU * 0.2;
    sum += grid[i+1][j].compU * 0.2;
    sum += grid[i][j+1].compU * 0.2;
    sum += grid[i][j-1].compU * 0.2;
    sum += grid[i-1][j-1].compU * 0.05;
    sum += grid[i+1][j-1].compU * 0.05;
    sum += grid[i+1][j+1].compU * 0.05;
    sum += grid[i-1][j+1].compU * 0.05;
    
    return sum;
}
// -----------------------------------------------------------------------------
float laplaceV(int i, int j) {
    float sum = 0;
    
    sum += grid[i][j].compV * -1;
    sum += grid[i-1][j].compV * 0.2;
    sum += grid[i+1][j].compV * 0.2;
    sum += grid[i][j+1].compV * 0.2;
    sum += grid[i][j-1].compV * 0.2;
    sum += grid[i-1][j-1].compV * 0.05;
    sum += grid[i+1][j-1].compV * 0.05;
    sum += grid[i+1][j+1].compV * 0.05;
    sum += grid[i-1][j+1].compV * 0.05;
    
    return sum;
}
// -----------------------------------------------------------------------------
// =============================================================================
class Cell {
    float x, y;
    float w, h;
    float compU, compV;
    
    Cell(float x, float y, float w, float h, float u, float v) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        compU  = u;
        compV  = v;
    }
    
    Cell(float u, float v) {
        compU = u;
        compV = v;
    }
    
    void display() {
        noStroke();
        color currentColor = color((compU-compV)*255);
        fill(currentColor);
        rect(x, y, w, h);
    }
}
// =============================================================================