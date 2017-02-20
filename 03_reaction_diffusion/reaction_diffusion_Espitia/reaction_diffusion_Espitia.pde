// Grid variables
int nCols    = 100;
int nRows    = 100;
int cellSize = 3;

// Reaction-Diffusion variables
float rU = 1.0;
float rV = 0.5;
float f  = 0.055;
float k  = 0.062;

// Grid arrays
Cell[][] gridPrime;
Cell[][] grid;

// =============================================================================
void setup() {
    size(300, 300);
    gridPrime = new Cell[width][height];
    grid      = new Cell[width][height];
    initGrids();
}
// -----------------------------------------------------------------------------
void draw() {
    println(frameRate);
    for (int i = 0; i < 1; i++) {
        update();
        swapGrids();
    }
    loadPixels();
    for (int i = 1; i < width-1; i++) {
        for (int j = 1; j < height-1; j++) {
            Cell cell = gridPrime[i][j];
            float u = cell.compU;
            float v = cell.compV;
            int pos = i + j * width;
            pixels[pos] = color((u-v)*255);
        }
    }
    updatePixels(); 
}
// =============================================================================
// Functions
// create Grids
void initGrids() {
    // initial values
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            float u = 1;
            float v = 0;
            // gridPrime[i][j] = new Cell(u, v);
            // grid[i][j]      = new Cell(u, v);
            gridPrime[i][j] = new Cell(u, v);
            grid[i][j]      = new Cell(u, v);
        }
    }
    
    // random regions
    int nRegions   = 10;
    int regionSize = 10;
    
    for (int r = 0; r < nRegions; r++) {
        int startX = int(random(20, width-20));
        int startY = int(random(20, height-20));
        
        for (int i = startX; i < startX+regionSize; i++) {
            for (int j = startY; j < startY+regionSize; j++) {
                float u = 1;
                float v = 1;
                gridPrime[i][j] = new Cell(u, v);
                grid[i][j]      = new Cell(u, v);
            }
        }
    }
}
// -----------------------------------------------------------------------------
void update(){
    for (int i = 1; i < width-1; i++) {
        for (int j = 1; j < height-1; j++) {
            Cell cell      = grid[i][j];
            Cell cellPrime = gridPrime[i][j];
            
            float u = cell.compU;
            float v = cell.compV;
            
            float laplaceU = 0;
            
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
}
// =============================================================================