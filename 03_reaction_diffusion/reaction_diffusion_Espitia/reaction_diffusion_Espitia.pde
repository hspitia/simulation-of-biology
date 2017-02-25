color backgroundColor = #ffffff;
int canvasSize        = 600;
int infoPanelWidth    = 350;
int infoPanelHeight   = 600;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

// Grid variables
int cellSize = 3;
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
boolean simRunning     = true;
boolean reactDiff      = true;
boolean constantParams = true;
boolean drawU          = true;

// Init region variables
int nRegions   = 10;
int regionSize = 10;
int margin     = 20;

// Info variables
String currentPattern = "Spots";
String xPos           = "";
String yPos           = "";
String currentU       = "";
String currentV       = "";
String currentF       = "";
String currentK       = "";

// =============================================================================
void setup() {
    background(backgroundColor);
    size(950, 600);
    colorMode(RGB, 1);
    
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
    setUpGrids();
    initVariableValues();
}
// -----------------------------------------------------------------------------
void draw() {
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
        lastTime  = millis();
    }
    displayInfo();
}
// =============================================================================
void runSimulationStep() {
    // grid.display();
    if (reactDiff) {
        if (constantParams)
            gridPrime.reactionDiffusion(grid, k, f);
        else
            gridPrime.reactionDiffusion(grid, variableK, variableF);
    }
    else{
        if (constantParams)
            gridPrime.diffusion(grid, k, f);
        else
            gridPrime.diffusion(grid, variableK, variableF);
    }
    
    gridPrime.display(drawU);
    swapGrids();
}
// =============================================================================
void setUpGrids() {
    grid = new Grid(nRows, nCols, cellSize);
    grid.initRegion(nRegions, regionSize, margin);
    gridPrime = new Grid(grid);
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
    variableF = new float[cols];
    variableK = new float[rows];
    
    for (int i = 0; i < cols; ++i) {
        // kValue += kInterval;
        float kValue = map(i, 0, cols, minK, maxK);
        variableK[i] = kValue;
    }
    
    int end = rows-1;
    for (int i = 0; i <= end ; ++i) {
        // fValue += fInterval;
        float fValue = map(end-i, 0, cols, minF, maxF);
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
                grid[i][j]      = new Cell(x, y,
                                           cellSize,
                                           cellSize,
                                           u, v);
            }
        }
        
        // Init borders to 0
        for (int i = 0; i < nRows; i++) {
            grid[0][i].compU = 0; // cols 
            grid[i][0].compU = 0; // rows
            grid[nRows-1][i].compU = 0; // cols 
            grid[i][nRows-1].compU = 0; // rows
        }
    }
    // -----------------------------------------------------------------------------
    void initRegion(int nRegions, int regionSize, int margin) {
        int adjustedMargin = margin+1;
        for (int r = 0; r < nRegions; r++) {
            int rowStart = (int)random(adjustedMargin, nRows-2 - adjustedMargin);
            int colStart = (int)random(adjustedMargin, nCols-2 - adjustedMargin);
            // int rowStart = 2;
            // int colStart = 2;
            // println("rowStart: "+rowStart);
            // println("colStart: "+colStart);
            
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
    void display(boolean drawU) {
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                grid[i][j].display(drawU);
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
    void reactionDiffusion(Grid obj, float k, float f){
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
                cellPrime.compU = u + (rU * laplace(obj, i, j, true) - u*v*v + (f*(1-u))) * 2.0;
                cellPrime.compV = v + (rV * laplace(obj, i, j, false) + u*v*v - ((k+f)*v)) * 2.0;
                
                cellPrime.compU = constrain(cellPrime.compU, 0, 1);
                cellPrime.compV = constrain(cellPrime.compV, 0, 1);
            }
        }
    }
    // -----------------------------------------------------------------------------
    void reactionDiffusion(Grid obj, float[] kValues, float[] fValues){
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                Cell cell      = obj.grid[i][j];
                Cell cellPrime = grid[i][j];
                
                float u = cell.compU;
                float v = cell.compV;
                float k = kValues[j-1];
                float f = fValues[i-1];
                
                //                                              Reaction
                // cellPrime.compU = u + (rU * laplaceU(obj, i, j) - u*v*v + (f*(1-u))) * 2.7;
                // cellPrime.compV = v + (rV * laplaceV(obj, i, j) + u*v*v - ((k+f)*v)) * 2.7;
                cellPrime.compU = u + (rU * laplace(obj, i, j, true) - u*v*v + (f*(1-u))) * 1.0;
                cellPrime.compV = v + (rV * laplace(obj, i, j, false) + u*v*v - ((k+f)*v)) * 1.0;
                
                cellPrime.compU = constrain(cellPrime.compU, 0, 1);
                cellPrime.compV = constrain(cellPrime.compV, 0, 1);
            }
        }
    }
    // -----------------------------------------------------------------------------
    void diffusion(Grid obj, float k, float f){
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                Cell cell      = obj.grid[i][j];
                Cell cellPrime = grid[i][j];
                
                float u = cell.compU;
                float v = cell.compV;
                
                cellPrime.compU = u + (rU * laplace(obj, i, j, true)) * 1.0;
                cellPrime.compV = v + (rV * laplace(obj, i, j, false)) * 1.0;
                
                cellPrime.compU = constrain(cellPrime.compU, 0, 1);
                cellPrime.compV = constrain(cellPrime.compV, 0, 1);
            }
        }
    }
    // -----------------------------------------------------------------------------
    void diffusion(Grid obj, float[] kValues, float[] fValues){
        int start = 1;
        int end   = nRows-2;
        for (int i = start; i <= end; ++i) {
            for (int j = start; j <= end; ++j) {
                Cell cell      = obj.grid[i][j];
                Cell cellPrime = grid[i][j];
                
                float u = cell.compU;
                float v = cell.compV;
                float k = kValues[j-1];
                float f = fValues[i-1];
                
                cellPrime.compU = u + (rU * laplace(obj, i, j, true)) * 1.0;
                cellPrime.compV = v + (rV * laplace(obj, i, j, false)) * 1.0;
                
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
}
// =============================================================================
class Cell {
    float x, y;
    float w, h;
    float k, f;
    float compU, compV;
    
    Cell(float x, float y, float w, float h, float u, float v) {//, float k, float f) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        // this.k = k;
        // this.f = f;
        compU  = u;
        compV  = v;
    }
    
    void display(boolean drawU) {
        color strokeColor = #888888;
        stroke(strokeColor );
        noStroke();
        color currentColor = color(compU - compV);
        // color currentColor = color(compU);
        if(!drawU) currentColor = color(compV);
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
            setUpGrids();
            gridPrime.display(drawU);
            break;
        }
        case ' ': {
            simRunning = !simRunning;
            break;
        }
        case 'u':
        case 'U': {
            drawU = true;
            break;
        }
        
        case 'v':
        case 'V': {
            drawU = false;
            break;
        }
        
        case 'd': 
        case 'D': {
            reactDiff = !reactDiff;
            break;
        }
        case 'p': 
        case 'P': {
            constantParams = !constantParams;
            break;
        }
        case '1': {
            f = 0.035;
            k = 0.0625;
            currentPattern = "Spots";
            break;
        }
        case '2': {
            f = 0.035;
            k = 0.06;
            currentPattern = "Stripes";
            break;
        }
        case '3': {
            f = 0.035;
            k = 0.06;
            currentPattern = "Spiral waves";
            break;
        }
        case '4': {
            f = 0.05;
            k = 0.062;
            currentPattern = "Custom";
            break;
        }
        case '+': {
            increaseInitialRegions();
            break;
        }
        case '-': {
            decreaseInitialRegions();
            break;
        }
    }
}
// =========================================================
PVector getCellUnderMouse(int x, int y) {
    int col = nCols-3;
    int row = nRows-3;
    
    if (mouseX < canvasSize && mouseY < canvasSize) {
        col = (int)x/cellSize;
        row = (int)y/cellSize;
    }
    
    return (new PVector(row+1, col+1));
    // return (new PVector(row, col));
}
// =========================================================
void increaseInitialRegions(){
    if (nRegions < 20) ++nRegions;
}
// =========================================================
void decreaseInitialRegions(){
    if (nRegions > 1) --nRegions;
}
// =========================================================
void updateCellCoordInfo() {
    if (mouseX < canvasSize && mouseY < canvasSize) {
        PVector pos = getCellUnderMouse(mouseX, mouseY);
        int row = (int)pos.x;
        int col = (int)pos.y;
        // xPos = "" + grid.grid[row][col].x;
        // yPos = "" + grid.grid[row][col].y;
        xPos = "" + row;
        yPos = "" + col;
        // xPos = "" + mouseX;
        // yPos = "" + mouseY;
    }
}
// =========================================================
void updateCurrentCellInfo(Grid obj) {
    if (mouseX < canvasSize && mouseY < canvasSize) {
        PVector pos = getCellUnderMouse(mouseX, mouseY);
        int row = (int)pos.x;
        int col = (int)pos.y;
        Cell cCell = obj.grid[row][col];
        xPos     = "" + col;
        yPos     = "" + row;
        currentU = "" + cCell.compU;
        currentV = "" + cCell.compV;
        
        if(constantParams) {
            currentF = "" + f;
            currentK = "" + k;
        }
        else {
            currentK = "" + variableK[col-1];
            currentF = "" + variableF[row-1];
        }
    }
}
// =========================================================
void displayInfo() {
    // int canvasSize = 600; //temporal
    
    color infoPanelColor = #B0B0B0;
    noStroke();
    fill(infoPanelColor);
    rect(canvasSize, 0, infoPanelWidth, infoPanelHeight);
    
    updateCellCoordInfo();
    updateCurrentCellInfo(gridPrime);
    
    String[] labels = new String[10];
    String[] values = new String[5];
    String[] controlText = new String[12];
    
    controlText[0]  = "I:     Initialize with fixed regions";
    controlText[1]  = "Space: Stop/Resume simulation";;
    controlText[2]  = "U:     Draw values for u (default)";
    controlText[3]  = "V:     Draw values for v";
    controlText[4]  = "D:     Toggle Difussion/Reaction-Diffusion";
    controlText[5]  = "P:     Toggle Constant/Spatially Var. params.";
    controlText[6]  = "1:     Spots        k = 0.0625, f = 0.035";
    controlText[7]  = "2:     Stripes      k = 0.06,   f = 0.035";
    controlText[8]  = "3:     Spiral waves k = 0.0475, f = 0.0118";
    controlText[9]  = "4:     Custom       k = 0.062,  f = 0.05";
    controlText[10] = "Click: Display values u, v, k, and f";
    controlText[11] = "+/-:   Increse/decrease # initial regions";
    
    
    labels[0] = "Mode:             " + ((reactDiff) ? "Reaction-Diffusion" : "Difussion");
    labels[1] = "Pattern:          " + currentPattern;
    labels[2] = "Params mode:      " + ((constantParams) ? "Constant" : "Spatially-Varying");
    labels[3] = "Initial regions:  " + nRegions;
    labels[4] = "Drawing:          " + ((drawU) ? "U" : "V");
    
    if (mousePressed) {
        labels[5] = "Parameter values of cell (" + yPos + "," + xPos + "): ";
        labels[6] = "     u: " + currentU;
        labels[7] = "     v: " + currentV;
        labels[8] = "     k: " + currentK;
        labels[9] = "     f: " + currentF;
    }
    else {
        for (int i = 5; i < 10; ++i) {
            labels[i] = "";
        }
    }
    
    // values[0] = getOnOffStr(flockCenteringOn);
    // values[1] = getOnOffStr(velMatchingOn);
    // values[2] = getOnOffStr(colAvoidanceOn);
    // values[3] = getOnOffStr(wanderingOn);
    
    fill(0);
    int marginX = canvasSize + 15;
    int marginY = 30;
    int offsetY = 16;
    
    textFont(myTitleFont);
    text("Reaction-Diffusion Simulation", marginX, marginY);
    
    int textX = marginX;
    int textY = marginY + 40;
    textFont(myFontBold);
    text("Controls:", textX, textY);
    
    textY += 10;
    textFont(myFont);
    for (int i = 0; i < controlText.length; ++i) {
        textY += offsetY;
        text(controlText[i], textX, textY);
    }
    
    textY += 40;
    textFont(myFontBold);
    text("Info:", textX, textY);
    
    textY += 10;
    textFont(myFont);
    for (int i = 0; i < labels.length; ++i) {
        textY += offsetY;
        text(labels[i], textX, textY);
    }
    
    String coordinates = "(x,y): (" + xPos + "," + yPos + ")";
    textY += 100;
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
