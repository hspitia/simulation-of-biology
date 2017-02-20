// Grid variables
int nCols    = 150;
int nRows    = 150;
int cellSize = 4;

// Reaction-Diffusion variables
float rU = 1.0;
float rV = 0.5;
float f  = 0.055;
float k  = 0.062;
// values from the assignment
// float rU = 0.082;
// float rV = 0.041;
// float f  = 0.035;
// float k  = 0.0625;

// Grid arrays
// Cell[][] gridPrime;
// Cell[][] grid;
Grid grid;
Grid gridPrime;

// Interval variables
int lastTime = 0;
int interval = 10;

// Flags
boolean simRunning = true;
boolean reactDiff  = true;

// Init region variables
int nRegions   = 10;
int regionSize = 10;

// =============================================================================
void setup() {
    size(600, 600);
    colorMode(RGB, 1);
    grid      = new Grid(nRows, nCols, cellSize);
    gridPrime = new Grid(nRows, nCols, cellSize);
    grid.initRegion(nRegions, regionSize);
}
// -----------------------------------------------------------------------------
void draw() {
    // println(frameRate);
    if (millis() - lastTime > interval && simRunning){
        gridPrime.update(grid);
        gridPrime.display();
        swapGrids();
        // grid.display();
        lastTime  = millis();
    }
}
// =============================================================================
void swapGrids() {
    Grid tmp = new Grid(grid);
    grid = new Grid(gridPrime);
    gridPrime = new Grid(tmp);
}
// =============================================================================
class Grid {
    Cell[][] grid;
    // Cell[][] gridPrime;
    
    int nRows;
    int nCols;
    int cellSize;
    
    Grid(int nRows, int nCols, int cellSize) {
        this.nRows    = nRows;
        this.nCols    = nCols;
        this.cellSize = cellSize;
        
        // build grids
        // gridPrime = new Cell[nCols][nRows];
        grid      = new Cell[nCols][nRows];
        this.initGrids();
    }
    // -----------------------------------------------------------------------------
    Grid(Grid obj) {
        this.nRows    = obj.nRows;
        this.nCols    = obj.nCols;
        this.cellSize = obj.cellSize;
        
        grid = new Cell[this.nRows][this.nCols];
        
        // copy grid
        for (int i = 0; i < nRows; i++) {
            for (int j = 0; j < nCols; j++) {
                grid[i][j] = new Cell(j*this.cellSize, i*this.cellSize,
                                        cellSize, cellSize,
                                        obj.grid[i][j].compU, 
                                        obj.grid[i][j].compV);
            }
        }
    }
    // -----------------------------------------------------------------------------
    String toString() {
        String outStr = "";
        for (int i = 0; i < nRows; i++) {
            for (int j = 0; j < nCols; j++) {
                outStr += "(" + grid[i][j].compU + "," + grid[i][j].compV + ")";
                outStr += "\t";
            }
            outStr += "\n";
        }
        return outStr;
    }
    // -----------------------------------------------------------------------------
    void initGrids() {
        for (int i = 0; i < nRows; i++) {
            for (int j = 0; j < nCols; j++) {
                float u = 1;
                float v = 0;
                // float u = random(1);
                // float v = random(1);
                grid[i][j]      = new Cell(j*cellSize,
                                           i*cellSize,
                                           cellSize,
                                           cellSize,
                                           u, v);
            }
        }
        
    }
    // -----------------------------------------------------------------------------
    void initRegion(int nRegions, int regionSize){
        int margin = 20;
        for (int r = 0; r < nRegions; r++) {
            int rowStart = int(random(margin, nRows - margin));
            int colStart = int(random(margin, nCols - margin));
            
            for (int i = rowStart; i < rowStart+regionSize; i++) {
                for (int j = colStart; j < colStart+regionSize; j++) {
                    // float u = 1;
                    // float v = 1;
                    float u = 0.5;
                    float v = 0.25;
                    grid[i][j] = new Cell(j*cellSize, i*cellSize,
                                          cellSize, cellSize,
                                          u, v);
                }
            }
        }
    }
    // -----------------------------------------------------------------------------
    void display() {
        for (int i = 0; i < nRows; ++i) {
            for (int j = 0; j < nCols; ++j) {
                grid[i][j].display();
            }
        }
    }
    // -----------------------------------------------------------------------------
    void clear() {
        for (int i = 0; i < nRows; ++i) {
            for (int j = 0; j < nCols; ++j) {
                grid[i][j].compU = 1;
                grid[i][j].compV = 0;
            }
        }
    }
    // -----------------------------------------------------------------------------
    void update(Grid obj){
        for (int i = 1; i < nRows-1; i++) {
            for (int j = 1; j < nCols-1; j++) {
                Cell cell      = obj.grid[i][j];
                Cell cellPrime = grid[i][j];
                
                float u = cell.compU;
                float v = cell.compV;
                
                cellPrime.compU = u + (rU * laplaceU(i,j) - u*v*v + f*(1-u)) * 1;
                cellPrime.compV = v + (rV * laplaceV(i,j) + u*v*v + (k+f)*v) * 1;
                // cellPrime.compU = (rU * laplaceU(i,j) - u*v*v + f*(1-u)) * 1;
                // cellPrime.compV = (rV * laplaceV(i,j) + u*v*v + (f+k)*v) * 1;
                
                cellPrime.compU = constrain(cellPrime.compU, 0, 1);
                cellPrime.compV = constrain(cellPrime.compV, 0, 1);
            }
        }
    }
    // -----------------------------------------------------------------------------
    float laplaceU(int i, int j) {
        float sum = 0;
        
        sum += this.grid[i][j].compU * -1;
        sum += this.grid[i-1][j].compU * 0.2;
        sum += this.grid[i+1][j].compU * 0.2;
        sum += this.grid[i][j+1].compU * 0.2;
        sum += this.grid[i][j-1].compU * 0.2;
        sum += this.grid[i-1][j-1].compU * 0.05;
        sum += this.grid[i+1][j-1].compU * 0.05;
        sum += this.grid[i+1][j+1].compU * 0.05;
        sum += this.grid[i-1][j+1].compU * 0.05;
        
        // sum += this.grid[i][j].compU * -4;
        // sum += this.grid[i-1][j].compU * 1;
        // sum += this.grid[i+1][j].compU * 1;
        // sum += this.grid[i][j+1].compU * 1;
        // sum += this.grid[i][j-1].compU * 1;
        
        return sum;
    }
    // -----------------------------------------------------------------------------
    float laplaceV(int i, int j) {
        float sum = 0;
        
        sum += this.grid[i][j].compV * -1;
        sum += this.grid[i-1][j].compV * 0.2;
        sum += this.grid[i+1][j].compV * 0.2;
        sum += this.grid[i][j+1].compV * 0.2;
        sum += this.grid[i][j-1].compV * 0.2;
        sum += this.grid[i-1][j-1].compV * 0.05;
        sum += this.grid[i+1][j-1].compV * 0.05;
        sum += this.grid[i+1][j+1].compV * 0.05;
        sum += this.grid[i-1][j+1].compV * 0.05;
        
        // sum += this.grid[i][j].compU * -4;
        // sum += this.grid[i-1][j].compU * 1;
        // sum += this.grid[i+1][j].compU * 1;
        // sum += this.grid[i][j+1].compU * 1;
        // sum += this.grid[i][j-1].compU * 1;
        
        return sum;
    }
    // -----------------------------------------------------------------------------

}
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
        color currentColor = color(compU - compV);
        fill(currentColor);
        rect(x, y, w, h);
    }
}
// =============================================================================
void keyPressed() {
    switch (key) {
        case 'i':
        case 'I': {
            grid.clear();
            gridPrime.clear();
            grid.initRegion(nRegions, regionSize);
            break;
        }
        case ' ': {
            simRunning = !simRunning;
            break;
        }
        case 'u':
        case 'U': {
            break;
        }
        
        case 'v':
        case 'V': {
            break;
        }
        
        case 'd': 
        case 'D': {
            reactDiff = !reactDiff;
            break;
        }
        case 'p': 
        case 'P': {
            break;
        }
        case '1': {
            f = 0.035;
            k = 0.0625;
            break;
        }
        case '2': {
            f = 0.035;
            k = 0.06;
            break;
        }
        case '3': {
            k = 0.06;
            f = 0.035;
            break;
        }
        case '4': {
            break;
        }
    }
}