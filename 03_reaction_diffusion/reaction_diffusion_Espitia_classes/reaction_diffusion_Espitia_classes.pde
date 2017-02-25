int canvasSize = 600;
int infoPanelWidth  = 350;
int infoPanelHeight = 600;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

String xPos = "";
String yPos = "";

// Grid variables
int cellSize = 4;
int nCols    = floor(canvasSize/cellSize) + 2;
int nRows    = floor(canvasSize/cellSize) + 2;

// Reaction-Diffusion variables
// float rU = 1.0;
// float rV = 0.5;
// float f  = 0.055;
// float k  = 0.062;

// Initial values
float rU = 0.082;
float rV = 0.041;
// value set 1
float f  = 0.035;
float k  = 0.0625;

float[] variableK;
float[] variableF;

float minK = 0.03;
float maxK = 0.07;
float minF = 0.00;
float maxF = 0.08;

// Grid arrays
// Cell[][] gridPrime;
// Cell[][] grid;
Grid grid;
Grid gridPrime;

// Interval variables
int lastTime = 0;
int interval = 1;

// Flags
boolean simRunning = true;
boolean reactDiff  = true;

// Init region variables
int nRegions   = 10;
int regionSize = 10;
int margin     = 20;

// =============================================================================
void setup() {
    size(950, 600);
    colorMode(RGB, 1);
    
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
    grid      = new Grid(nRows, nCols, cellSize);
    gridPrime = new Grid(nRows, nCols, cellSize);
    
    grid.initRegion(nRegions, regionSize, margin);
    
    initVariableValues();
    
    displayHelp();
}
// -----------------------------------------------------------------------------
void draw() {
    // grid.display();
    // displayHelp();
    if (millis() - lastTime > interval && simRunning){
        gridPrime.update(grid);
        gridPrime.display();
        swapGrids();
        
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
void initVariableValues(){
    int rows = nRows-2;
    int cols = nCols-2;
    float fInterval = (maxF - minF + 0.01)/(float)rows;
    float kInterval = (maxK - minK + 0.01)/(float)cols;
    
    variableF = new float[cols];
    variableK = new float[rows];
    
    for (int i = 0; i < cols; ++i) {
        // kValue += kInterval;
        float kValue = map(i, 0, cols, minK, maxK);
        variableK[i] = kValue;
    }
    
    for (int i = 0; i < rows; ++i) {
        // fValue += fInterval;
        float fValue = map(i, 0, cols, minF, maxF);
        variableF[i] = fValue;
    }
    
    // for (float value : variableK) {
    //     println(value);
    // }
    // println("------");
    // println("------");
    // for (float value : variableF) {
    //     println(value);
    // }
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
        
        // build grid
        this.grid = new Cell[nCols][nRows];
        this.initGrid();
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
                
                grid[i][j] = new Cell(obj.grid[i][j].x, 
                                      obj.grid[i][j].y,
                                      obj.cellSize, obj.cellSize,
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
                // outStr += "(" + grid[i][j].compU + "," + grid[i][j].compV + ")";
                // outStr += "\t";
                outStr += grid[i][j].toString();
            }
            outStr += "\n";
        }
        return outStr;
    }
    // -----------------------------------------------------------------------------
    void initGrid() {
        for (int i = 0; i < nRows; i++) {
            for (int j = 0; j < nCols; j++) {
                float u = 1;
                float v = 0;
                // float u = random(1);
                // float v = random(1);
                float x = (j-1)*this.cellSize;
                float y = (i-1)*this.cellSize;
                // println("x,y: "+x+","+y);
                grid[i][j]      = new Cell(x, y,
                                           cellSize,
                                           cellSize,
                                           u, v);
            }
            // println("");
        }
        
        // borders:
        for (int i = 0; i < nRows; i++) {
            grid[0][i].compU = 0; // cols 
            // grid[0][i].compV = 0; // cols 
            grid[i][0].compU = 0; // rows
            // grid[i][0].compV = 0; // rows
            grid[nRows-1][i].compU = 0; // cols 
            // grid[nRows-1][i].compV = 0; // cols 
            grid[i][nRows-1].compU = 0; // rows
            // grid[i][nRows-1].compV = 0; // rows
        }
    }
    // -----------------------------------------------------------------------------
    void initRegion(int nRegions, int regionSize, int margin){
        // int margin = 20;
        for (int r = 0; r < nRegions; r++) {
            int rowStart = int(random(margin, nRows-2 - margin));
            int colStart = int(random(margin, nCols-2 - margin));
            
            for (int i = rowStart; i < rowStart+regionSize; i++) {
                for (int j = colStart; j < colStart+regionSize; j++) {
                    // float u = 1;
                    // float v = 1;
                    float u = 0.5;
                    float v = 0.25;
                    float x = (j-1)*this.cellSize;
                    float y = (i-1)*this.cellSize;
                    grid[i][j] = new Cell(x, y,
                                          cellSize, cellSize,
                                          u, v);
                }
            }
        }
    }
    // -----------------------------------------------------------------------------
    void display() {
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                grid[i][j].display();
            }
        }
    }
    // -----------------------------------------------------------------------------
    void clear() {
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                grid[i][j].compU = 1;
                grid[i][j].compV = 0;
            }
        }
    }
    // -----------------------------------------------------------------------------
    void update(Grid obj){
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                Cell cell      = obj.grid[i][j];
                Cell cellPrime = grid[i][j];
                
                float u = cell.compU;
                float v = cell.compV;
                //                                              Reaction
                // cellPrime.compU = u + (rU * laplaceU(obj, i, j) - u*v*v + (f*(1-u))) * 2.7;
                // cellPrime.compV = v + (rV * laplaceV(obj, i, j) + u*v*v - ((k+f)*v)) * 2.7;
                cellPrime.compU = u + (rU * laplace(obj, i, j, true) - u*v*v + (f*(1-u))) * 1.0;
                cellPrime.compV = v + (rV * laplace(obj, i, j, false) + u*v*v - ((k+f)*v)) * 1.0;
                // cellPrime.compU = (rU * laplaceU(obj, i, j) - u*v*v + (f*(1-u)));b
                // cellPrime.compV = (rV * laplaceV(obj, i, j) + u*v*v - ((k+f)*v));
                
                cellPrime.compU = constrain(cellPrime.compU, 0, 1);
                cellPrime.compV = constrain(cellPrime.compV, 0, 1);
            }
        }
    }
    // -----------------------------------------------------------------------------
    float laplace(Grid obj, int i, int j, boolean isU) {
        float sum            = 0;
        float centerFactor   = -4.0;
        float neighborFactor = 1.0;
        int borders          = 0;
        
        if (i == 1 || i == nRows-2) ++borders;
        if (j == 1 || j == nRows-2) ++borders;
        
        centerFactor += borders;
        
        if (isU) {
            sum += obj.grid[i][j].compU * centerFactor;
            sum += obj.grid[i-1][j].compU * neighborFactor;
            sum += obj.grid[i+1][j].compU * neighborFactor;
            sum += obj.grid[i][j+1].compU * neighborFactor;
            sum += obj.grid[i][j-1].compU * neighborFactor;
        } 
        else {
            sum += obj.grid[i][j].compV * centerFactor;
            sum += obj.grid[i-1][j].compV * neighborFactor;
            sum += obj.grid[i+1][j].compV * neighborFactor;
            sum += obj.grid[i][j+1].compV * neighborFactor;
            sum += obj.grid[i][j-1].compV * neighborFactor;
        }
        
        return sum;
    }
    // -----------------------------------------------------------------------------
    float laplaceU(Grid obj, int i, int j) {
        float sum            = 0;
        float centerFactor   = -4.0;
        float neighborFactor = 1.0;
        int borders          = 0;
        
        if (i == 1 || i == nRows-2) ++borders;
        if (j == 1 || j == nRows-2) ++borders;
        
        centerFactor += borders;
        
        sum += obj.grid[i][j].compU * centerFactor;
        sum += obj.grid[i-1][j].compU * neighborFactor;
        sum += obj.grid[i+1][j].compU * neighborFactor;
        sum += obj.grid[i][j+1].compU * neighborFactor;
        sum += obj.grid[i][j-1].compU * neighborFactor;
        
        // sum = 0;
        // sum += obj.grid[i][j].compU * -1;
        // sum += obj.grid[i-1][j].compU * 0.2;
        // sum += obj.grid[i+1][j].compU * 0.2;
        // sum += obj.grid[i][j+1].compU * 0.2;
        // sum += obj.grid[i][j-1].compU * 0.2;
        // sum += obj.grid[i-1][j-1].compU * 0.05;
        // sum += obj.grid[i+1][j-1].compU * 0.05;
        // sum += obj.grid[i+1][j+1].compU * 0.05;
        // sum += obj.grid[i-1][j+1].compU * 0.05;
        
        return sum;
    }
    // -----------------------------------------------------------------------------
    float laplaceV(Grid obj, int i, int j) {
        float sum            = 0;
        float centerFactor   = -4.0;
        float neighborFactor = 1.0;
        int borders          = 0;
        
        if (i == 1 || i == nRows-2) ++borders; // top & bottom border
        if (j == 1 || j == nRows-2) ++borders; // left & rigth border
        
        centerFactor += borders;
        
        sum += obj.grid[i][j].compV * centerFactor;
        sum += obj.grid[i-1][j].compV * neighborFactor;
        sum += obj.grid[i+1][j].compV * neighborFactor;
        sum += obj.grid[i][j+1].compV * neighborFactor;
        sum += obj.grid[i][j-1].compV * neighborFactor;   
        
        // sum = 0;
        // sum += obj.grid[i][j].compV * -1;
        // sum += obj.grid[i-1][j].compV * 0.2;
        // sum += obj.grid[i+1][j].compV * 0.2;
        // sum += obj.grid[i][j+1].compV * 0.2;
        // sum += obj.grid[i][j-1].compV * 0.2;
        // sum += obj.grid[i-1][j-1].compV * 0.05;
        // sum += obj.grid[i+1][j-1].compV * 0.05;
        // sum += obj.grid[i+1][j+1].compV * 0.05;
        // sum += obj.grid[i-1][j+1].compV * 0.05;
        
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
        // color strokeColor = #888888;
        // stroke(strokeColor );
        noStroke();
        color currentColor = color(compU - compV);
        fill(currentColor);
        rect(x, y, w, h);
    }
    
    String toString() {
        return "[" + x + "," + y + " - " + compU + "," + compV + "]";
    }
}
// =============================================================================
void keyPressed() {
    switch (key) {
        case 'i':
        case 'I': {
            grid.clear();
            // gridPrime.clear();
            grid.initRegion(nRegions, regionSize, margin);
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
            f = 0.035;
            k = 0.06;
            break;
        }
        case '4': {
            f = 0.05;
            k = 0.062;
            break;
        }
    }
}
// =========================================================
PVector getCellUnderMouse(int x, int y) {
    int col = x/cellSize;
    int row = y/cellSize;
    
    return (new PVector(row+1, col+1));
}
// =========================================================
void updateCellCoordInfo() {
    
    if (mouseX < canvasSize && mouseY < canvasSize) {
        PVector pos = getCellUnderMouse(mouseX, mouseY);
        xPos = "" + grid.grid[(int)pos.y][(int)pos.x].x;
        yPos = "" + grid.grid[(int)pos.y][(int)pos.x].y;
        // xPos = "" + pos.x;
        // yPos = "" + pos.y;
        // xPos = "" + mouseX;
        // yPos = "" + mouseY;
    }
}
// =========================================================
void displayHelp() {
    // int canvasSize = 600; //temporal
    
    color infoPanelColor = #B0B0B0;
    noStroke();
    fill(infoPanelColor);
    rect(canvasSize, 0, infoPanelWidth, infoPanelHeight);
    
    updateCellCoordInfo();
    
    String[] labels = new String[7];
    String[] values = new String[7];
    String[] controlText = new String[11];
    
    // labels[0] = "Centering:     " + getOnOffStr(flockCenteringOn);
    // labels[1] = "Vel. matching: " + getOnOffStr(velMatchingOn);
    // labels[2] = "Collisions:    " + getOnOffStr(colAvoidanceOn);
    // labels[3] = "Wandering:     " + getOnOffStr(wanderingOn);
    // labels[4] = "Attraction:    " + getOnOffStr(attractionModeOn);
    // labels[5] = "Repulsion:     " + getOnOffStr(repulsionModeOn);
    // labels[6] = "# Creatures:   " + flock.nCreatures;
    
    controlText[0]  = "I:     Initialize with fixed regions";
    controlText[1]  = "Space: Stop/Resume simulation";;
    controlText[2]  = "U:     Draw values for u (default)";
    controlText[3]  = "V:     Draw values for v";
    controlText[8]  = "D:     Toggle Difussion/Reaction-Diffusion";
    controlText[9]  = "P:     Toggle Constant/Spatially Var. params.";
    controlText[4]  = "1:     Sspots   k = 0.0625, f = 0.035";
    controlText[5]  = "2:     Stripes  k = 0.06,   f = 0.035";
    controlText[6]  = "3:     Spiral waves k = 0.0475, f = 0.0118";
    controlText[7]  = "4:     Set k = ----,   f = ----";
    controlText[10] = "Click: Print values u, v, k, and f";
    
    
    // values[0] = getOnOffStr(flockCenteringOn);
    // values[1] = getOnOffStr(velMatchingOn);
    // values[2] = getOnOffStr(colAvoidanceOn);
    // values[3] = getOnOffStr(wanderingOn);
    
    fill(0);
    int marginX = canvasSize + 15;
    int marginY = 30;
    textFont(myTitleFont);
    text("Reaction-Diffusion Simulation", marginX, marginY);
    
    int textX   = marginX;
    int textY   = marginY + 40;
    textFont(myFontBold);
    text("Controls:", textX, textY);
    
    textY += 10;
    int offsetY = 16;
    textFont(myFont);
    for (int i = 0; i < controlText.length; ++i) {
        textY += offsetY;
        text(controlText[i], textX, textY);
    }
    
    String coordinates = "(x,y): (" + xPos + "," + yPos + ")";
    textY += 60;
    text(coordinates, textX, textY);
    
    // // textX = marginX;
    // textY += 40;
    // textFont(myFontBold);
    // text("Controls:", textX, textY);
    // textY += 3;
    // textFont(myFont);
    // for (int i = 0; i < controlText.length; ++i) {
    //     textY += offsetY;
    //     text(controlText[i], textX, textY);
    // }
}

