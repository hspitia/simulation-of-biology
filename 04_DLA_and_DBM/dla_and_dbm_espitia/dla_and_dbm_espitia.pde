// ==========================================================
// Decription:  This program recreates Conways's Game of Life
// 
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================

// ==========================================================
// Global variables
Grid grid;
// Grid tmpGrid;

int nCols             = 100;
int nRows             = 100;
int cellSize          = 4;

int canvasSize        = nCols*cellSize;
int infoPanelWidth    = 300;
int infoPanelHeight   = canvasSize;


color infoPanelColor  = #001A31;
color titleColor      = #FF9D00;
color textColor       = #E2E2E2;
color backgroundColor = #444444;
color strokeColor     = #333333;
color deadCellColor   = #222222;
// color aliveCellColor  = #FF9D00;
color aliveCellColor  = #00686F;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

int lastTime       = 0;
int interval       = 100;
// flags
boolean singleStep = true;
boolean simRunning = false;
boolean runningDla = true;
// Simulation values
float sf = 1;

// =========================================================
void setup() {
    size(700, 400);
    grid = new Grid(nRows, nCols, cellSize);
    
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
}
// =========================================================
void draw() {
    background(backgroundColor);
    grid.display();
    displayInfo();
    
    // if (millis() - lastTime > interval){
    //     if (!singleStep){
    //         runStep();
    //     }
    // }
    
    // if (singleStep && !mousePressed)
    //     tmpGrid = new Grid(grid);
}

// =========================================================
void runStep() {
}
// =========================================================
String getStatusStr(boolean alive) {
    String strStatus = "DEAD";
    if (alive) strStatus = "ALIVE";
    return strStatus;
}
// =========================================================
class Cell {
    // Attributes
    float x, y;
    float w, h;
    int status;
    // --------------------------------------------------------
    // Methods
    // constructor
    Cell(float x, float y, float w, float h, int status) {
        this.x      = x;
        this.y      = y;
        this.w      = w;
        this.h      = h;
        this.status = status;
    }
    // --------------------------------------------------------
    Cell(Cell obj) {
        this.x      = obj.x;
        this.y      = obj.y;
        this.w      = obj.w;
        this.h      = obj.h;
        this.status = obj.status;
    }
    // --------------------------------------------------------
    void display() {
        // stroke(strokeColor);
        noStroke();
        color currentColor = deadCellColor;
        if (status == 1) currentColor = aliveCellColor;
        fill(currentColor);
        rect(x, y, w, h); 
    }
}
// =========================================================
class Grid {
    // Attributes
    int cols;
    int rows;
    int cellSize;
    Cell[][] grid;
    // --------------------------------------------------------
    // Methods
    // constructor
    Grid(int rows, int cols, int cellSize) {
        this.cols     = cols;
        this.rows     = rows;
        this.cellSize = cellSize;
        
        grid = new Cell[this.rows][this.cols];
        
        for (int i = 0; i < this.rows; ++i) {
            for (int j = 0; j < this.cols; ++j) {
                int status = 0; // EMPTY
                // int status = (int)random(2); // random
                grid[i][j] = new Cell(j * this.cellSize, 
                                      i * this.cellSize,
                                      this.cellSize, this.cellSize,
                                      status);
            }
        }
    }
    // --------------------------------------------------------
    // copy constructor
    Grid(Grid obj) {
        cols           = obj.cols;
        rows           = obj.rows;
        cellSize       = obj.cellSize;
        grid           = new Cell[rows][cols];
        
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j] = new Cell(obj.grid[i][j]);
            }
        }
    }
    // --------------------------------------------------------
    void initSingleSeed() {
        clear();
        
        int row = floor(nRows/2);
        int col = floor(nCols/2);
        
        grid[row][col].status = 1; // FILLED
    }
    // --------------------------------------------------------
    void display () {
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j].display();
            }
        }
    }
    // --------------------------------------------------------
    void clear() {
        for (int row = 0; row < rows; ++row) {
            for (int col = 0; col < cols; ++col) {
                grid[row][col].status = 0; // EMPTY
            }
        }
    }
    // --------------------------------------------------------
}
// =========================================================
void keyPressed() {
    switch (key) {
        case ' ': {
            simRunning = !simRunning;
            break;
        }
        case 's':
        case 'S': {
            break;
        }
        case '1': {
            grid.initSingleSeed();
            sf  = 1.0;
            runningDla = true;
            break;
        }
        case '2': {
            grid.initSingleSeed();
            sf  = 0.1;
            runningDla = true;
            break;
        }
        case '3': {
            grid.initSingleSeed();
            sf  = 0.01;
            runningDla = true;
            break;
        }
        case '4': {
            grid.initSingleSeed();
            runningDla = false;
            break;
        }
        case '5': {
            grid.initSingleSeed();
            runningDla = false;
            break;
        }
        case '6': {
            grid.initSingleSeed();
            runningDla = false;
            break;
        }
        case '0': {
            grid.initSingleSeed();
            runningDla = true;
            break;
        }
    }
}
// =========================================================
void setupTitle(){
    fill(titleColor);
    textFont(myTitleFont);
}
// =========================================================
void setupSubtitle(){
    fill(titleColor);
    textFont(myFontBold);
}
// =========================================================
void setupText(){
    fill(textColor);
    textFont(myFont);
}
// =========================================================
void displayInfo() {
    noStroke();
    fill(infoPanelColor);
    rect(canvasSize, 0, infoPanelWidth, infoPanelHeight);
    
    int nControlText = 9;
    int nInfoText    = 4;
    
    String[] controlText = new String[nControlText];
    String[] infoText    = new String[nInfoText];
    // String[] values      = new String[5];
    
    controlText[0]  = "Space: Start/Stop growth";
    controlText[1]  = "S:     Take one simulation step";
    controlText[2]  = "1:     DLA, sticking factor = 1";
    controlText[3]  = "2:     DLA, sticking factor = 0.1";
    controlText[4]  = "3:     DLA, sticking factor = 0.01";
    controlText[5]  = "4:     DBM, eta = 0";
    controlText[6]  = "5:     DBM, eta = 3";
    controlText[7]  = "6:     DBM, eta = 6";
    controlText[8]  = "0:     Custom (seed pattern, sf = XX)";
    
    infoText[0] = "Grid size:       " + nRows + " x " + nCols + " cells";
    infoText[1] = "Cell size:       " + cellSize + " pixels";
    infoText[2] = "Mode:            " + ((runningDla) ? "DLA" : "DBM");
    infoText[3] = "Sticking Factor: " + sf;
    // infoText[4] = "Pattern:          " + currentPattern;
    // infoText[5] = "Params mode:      " + ((constantParams) ? "Constant" : "Spatially-Varying");
    // infoText[6] = "Drawing:          " + ((drawU) ? "U" : "V");
    // infoText[7] = "dt:               " + dt;
    
    int marginX = canvasSize + 15;
    int marginY = 30;
    int offsetY = 16;
    
    setupTitle();
    text("DLA and DBM Simulation", marginX, marginY);
    
    int textX = marginX;
    int textY = marginY + 30;
    setupSubtitle();
    text("Controls:", textX, textY);
    
    textY += 10;
    setupText();
    for (int i = 0; i < nControlText; ++i) {
        textY += offsetY;
        text(controlText[i], textX, textY);
    }
    
    textY += 40;
    setupSubtitle();
    text("Current State Info:", textX, textY);
    
    textY += 10;
    setupText();
    for (int i = 0; i < nInfoText; ++i) {
        textY += offsetY;
        text(infoText[i], textX, textY);
    }
    
    // String coordinates = "(row,col): (" + yPos + "," + xPos + ")";
    // textY += 20;
    // text(coordinates, textX, textY);
}