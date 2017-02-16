// ==========================================================
// Decription:  This program recreates 
// 
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================

// ==========================================================
// Global variables
Grid grid;
Grid gridPrime;

int nCols             = 100;
int nRows             = 100;
int cellSize          = 6;

color backgroundColor = #444444;
color strokeColor     = #888888;
color deadCellColor   = #666666;
color aliveCellColor  = #FFB115;

PFont myFont;
PFont myFontBold;

int lastTime       = 0;
int interval       = 200;

// Flags
boolean simRunning = true;
boolean reactDiff  = true;

// Simulation values
float rU = 0.082;
float rV = 0.041;

// =========================================================
void setup() {
    size(600, 600);
    grid = new Grid(nRows, nCols, cellSize);
    grid.init();
    
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
}
// =========================================================
void draw() {
    // displayHelp();
    
    if (millis() - lastTime > interval && simRunning){
        runSimulationStep();
    }
}

// =========================================================
void runSimulationStep() {
    gridPrime = new Grid(grid);
    grid.update(gridPrime);
    grid.display();
    lastTime  = millis();
}
// =========================================================
void keyPressed() {
    switch (key) {
        case 'i':
        case 'I': {
            grid.init();
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
            break;
        }
        case '2': {
            break;
        }
        case '3': {
            break;
        }
        case '4': {
            break;
        }
    }
}
// =========================================================
class Cell {
    // Attributes
    float x, y;
    float w, h;
    float compU, compV;
    // --------------------------------------------------------
    // Methods
    // constructor
    Cell(float x, float y, float w, float h, float compU, float compV) {
        this.x     = x;
        this.y     = y;
        this.w     = w;
        this.h     = h;
        this.compU = compU;
        this.compU = compV;
    }
    // --------------------------------------------------------
    void fillCell() {
        color currentColor = color(255, compU * 255, compV * 255);
        fill(currentColor);
    }
    // --------------------------------------------------------
    void display() {
        noStroke();
        fillCell();
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
                grid[i][j] = new Cell(j * this.cellSize, i * this.cellSize,
                                      this.cellSize, this.cellSize,
                                      1, 0);
                                      // random(1), random(1));
            }
        }
    }
    // --------------------------------------------------------
    // copy constructor
    Grid(Grid obj) {
        cols     = obj.cols;
        rows     = obj.rows;
        cellSize = obj.cellSize;
        grid     = new Cell[rows][cols];
        
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j] = new Cell(j * this.cellSize, i * this.cellSize,
                                      this.cellSize, this.cellSize,
                                      obj.grid[i][j].compU, obj.grid[i][j].compV);
            }
        }
    }
    // --------------------------------------------------------
    void display() {
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j].display();
            }
        }
    }
    // --------------------------------------------------------
    void update(Grid previousGrid) {
        for (int i = 0; i < previousGrid.rows; ++i) {
            for (int j = 0; j < previousGrid.cols; ++j) {
                grid[i][j].compU = previousGrid.grid[i][j].compU * 0.2;
                grid[i][j].compV = previousGrid.grid[i][j].compV * 0.1;
            }
        }
    }
    // --------------------------------------------------------
    void init() {
        clear();
        initSeedRegion();
    }
    // --------------------------------------------------------
    void clear() {
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j].compU = 1;
                grid[i][j].compV = 0;
            }
        }
    }
    // --------------------------------------------------------
    void initSeedRegion() {
        int r     = 5;
        int start = (cols/2) - r;
        int end   = (cols/2) + r;
        
        println("start: "+start);
        println("end: "+end);
        
        for (int i = start; i < end; ++i) {
            for (int j = start; j < end; ++j) {
                grid[i][j].compU = 0.5;
                grid[i][j].compV = 0.25;
            }
        }
    }
    // --------------------------------------------------------
    // --------------------------------------------------------
    
}

// // =========================================================
// void displayHelp() {
//     textFont(myFont);
//     String[] controlText = new String[6];
    
//     controlText[0] = "C:   Clear";
//     controlText[1] = "R:   Randomize";
//     controlText[2] = "G:   Toggle mode";
//     controlText[3] = "Space:   Run a single step";
//     controlText[4] = "+ :   Increase speed";
//     controlText[5] = "-  :   Decrease speed";
    
//     fill(255);
//     String modeText  = "Single-step";
//     if(!singleStep) modeText = "Continuous";
//     textSize(12);
//     text("Keyboard Controls:", 10, 618);
    
//     int textX   = 15;
//     int textY   = 636;
//     int offsetY = 14;
//     for (int i = 0; i < 6; ++i) {
//         text(controlText[i], textX, textY);
//         textY += offsetY;
//         if(i == 2) {
//             textX = 120;
//             textY = 636;
//         }
//     }
    
//     text("Current Mode:", 400, 618);
//     textFont(myFontBold);
//     textSize(18);
//     fill(aliveCellColor);
//     text(modeText, 400, 644);
// }