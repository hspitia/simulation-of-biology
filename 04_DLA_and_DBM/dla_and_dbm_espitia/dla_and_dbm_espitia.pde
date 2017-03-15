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


// int canvasSize        = nCols*cellSize;
int canvasSize        = 600;
int infoPanelWidth    = 300;
int infoPanelHeight   = canvasSize;

// Grid variables
int cellSize = 3;
int nCols    = floor(canvasSize/cellSize);
int nRows    = floor(canvasSize/cellSize);




color infoPanelColor  = #001A31;
color titleColor      = #FF9D00;
color textColor       = #E2E2E2;
color backgroundColor = #444444;
color strokeColor     = #333333;
color emptyCellColor  = #222222;
// color filledCellColor = #FF9D00;
color filledCellColor = #00686F;
color pathCellColor   = #21331D;

PFont myFont;
PFont myFontBold;
PFont myTitleFont;

int lastTime       = 0;
int interval       = 1;
// flags
boolean singleStep = true;
boolean simRunning = false;
boolean runningDla = true;
// Simulation values
float sf  = 1;
float eta = 0;

int externalMargin = (int)(nRows/3);
PVector lastOrigin;

// =========================================================
void setup() {
    size(900, 600);
    grid = new Grid(nRows, nCols, cellSize);
    
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
    grid.initDlaSingleSeed();
    testArrayListRefs();
}
// =========================================================
void draw() {
    background(backgroundColor);
    grid.display();
    displayInfo();
    
    if (millis() - lastTime > interval && simRunning){
        grid.randomWalk();
    }
    
}

// =========================================================
void testArrayListRefs() {
    int nCells = 5;
    Cell[] cells = new Cell[nCells];
    
    for (int i = 0; i < nCells; ++i) {
        cells[i] = new Cell(i*cellSize, 0, cellSize, cellSize, 0, 0);
    }
    println("cells: ");
    for (Cell c : cells) {
        println("c: "+c);
    }
    
    ArrayList<Cell> cellList = new ArrayList<Cell>();
    
    for (Cell c : cells) {
        cellList.add(c);
    }
    
    println("\ncellList: ");
    for (Cell c : cellList) {
        println("c: "+c);
    }
    
    println("\nModifying cells:");
    cells[1].status = 1;
    cells[2].status = 1;
    for (Cell c : cells) {
        println("c: "+c);
    }
    
    println("\ncellList: ");
    for (Cell c : cellList) {
        println("c: "+c);
    }
    
    println("\nModifying cellList:");
    cellList.remove(0);
    println("cells: ");
    for (Cell c : cells) {
        println("c: "+c);
    }
    println("\ncellList: ");
    for (Cell c : cellList) {
        println("c: "+c);
    }
    
    println("\nModifying cells:");
    cells[0].status = 1;
    cells[4].status = 1;
    for (Cell c : cells) {
        println("c: "+c);
    }
    
    println("\ncellList: ");
    for (Cell c : cellList) {
        println("c: "+c);
    }
    
    // distances
    for (Cell c : cells) {
        println("dist: " + cells[0].getDist(c.getRow(), c.getCol()));
    }
    
}

// =========================================================
void runStep() {
}
// =========================================================
class Grid {
    // Attributes
    int cols;
    int rows;
    int cellSize;
    Cell[][] grid;
    int lastRow;
    int lastCol;
    ArrayList<Cell> patternCells;
    ArrayList<Cell> candidateCells;
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
                                      status, 0);
            }
        }
        
        patternCells  = new ArrayList<Cell>();
        candidateCells = new ArrayList<Cell>();
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
    private PVector getRandomPosition() {
        int row;
        int col;
        do {
            row = floor(random(nRows));
            col = floor(random(nCols));
        } while(isFilled(row, col));
        // } while(isFilled(row, col) || isNear(row, col));
        
        lastRow = row;
        lastCol = col;
        
        return new PVector(col,row);
    }
    // --------------------------------------------------------
    private boolean isNear(int row, int col) {
        if ((row >= externalMargin && row < (nRows-externalMargin)) ||
            (col >= externalMargin && col < (nCols-externalMargin)))
            return true;
        
        return false;
    }
    // --------------------------------------------------------
    private int[] getRowNeighbors(int row) {
        int rowLowerAdjust = 0;
        int rowUpperAdjust = 0;
        
        if (row == 0) rowLowerAdjust = nRows;
        if (row == nRows-1) rowUpperAdjust = -nRows;
        
        int[] neighborRows = {(row - 1 + rowLowerAdjust), row, (row + 1 + rowUpperAdjust)};
        return neighborRows;
    }
    // --------------------------------------------------------
    private int[] getColNeighbors(int col) {
        int colLowerAdjust = 0;
        int colUpperAdjust = 0;
        
        if (col == 0) colLowerAdjust = nCols;
        if (col == nCols-1) colUpperAdjust = -nCols;
        
        int[] neighborCols = {(col - 1 + colLowerAdjust), col, (col + 1 + colUpperAdjust)};
        return neighborCols;
    }
    // --------------------------------------------------------
    void randomWalk() {
        PVector initPos     = getRandomPosition();
        int row             = (int)initPos.y;
        int col             = (int)initPos.x;
        boolean keepWalking = true;
        
        while (keepWalking) {
            row += round(random(-1, 1));
            col += round(random(-1, 1));
            // println(row+","+col);
            
            // Check for grid boundaries
            if (row < 0 || row > nRows-1 || 
                col < 0 || col > nCols-1) {
                initPos = getRandomPosition();
                row     = (int)initPos.y;
                col     = (int)initPos.x;
            } 
            else {
                if (!isAlone(row, col)) {
                    if (random(1) <= sf) {
                        grid[row][col].status = 1; // filled
                        keepWalking = false;
                    }
                }
            }
        }
        
    }
    // --------------------------------------------------------
    boolean isAlone(int row, int col) {
        int[] rowNeighbors = getRowNeighbors(row);
        int[] colNeighbors = getColNeighbors(col);
        
        for (int i : rowNeighbors) {
            for (int j : colNeighbors) {
                if (i != row || j != col) {
                    if (isFilled(i,j))
                        return false;
                } 
            }
        }
        return true;
    }
    // --------------------------------------------------------
    private boolean isFilled(int row, int col) {
        if (grid[row][col].status == 1) 
            return true;
        
        return false;
    }
    // --------------------------------------------------------
    void initDlaSingleSeed() {
        clear();
        
        int row = floor(nRows/2);
        int col = floor(nCols/2);
        
        lastRow = row;
        lastCol = col;
        
        grid[row][col].status = 1; // FILLED
    }
    // --------------------------------------------------------
    void initDbmSingleSeed() {
        clear();
        
        int row = floor(nRows/2);
        int col = floor(nCols/2);
        
        lastRow = row;
        lastCol = col;
        
        grid[row][col].status = 1; // FILLED
        patternCells.add(grid[row][col]);
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
class Cell {
    // Attributes
    float x, y;
    float w, h;
    int status;
    float ep;
    
    // --------------------------------------------------------
    // Methods
    // constructor
    Cell(float x, float y, float w, float h, int status, float ep) {
        this.x      = x;
        this.y      = y;
        this.w      = w;
        this.h      = h;
        this.status = status;
        this.ep     = ep;
    }
    // --------------------------------------------------------
    Cell(Cell obj) {
        this.x      = obj.x;
        this.y      = obj.y;
        this.w      = obj.w;
        this.h      = obj.h;
        this.status = obj.status;
        this.ep     = obj.ep;
    }
    // --------------------------------------------------------
    void display() {
        // stroke(strokeColor);
        noStroke();
        color currentColor = emptyCellColor;
        if (status == 2) currentColor = pathCellColor; //
        if (status == 1) currentColor = filledCellColor;
        fill(currentColor);
        rect(x, y, w, h); 
    }
    // --------------------------------------------------------
    PVector getPosition(){
        return new PVector(y/h, x/w);
    }
    // --------------------------------------------------------
    int getRow(){
        return (int)(y/h);
    }
    // --------------------------------------------------------
    int getCol(){
        return (int)(x/w);
    }
    // --------------------------------------------------------
    String toString() {
        String outStr = "(" + getRow() + "," + getCol() + ") - st: " + status;
        return outStr;
    }
    // --------------------------------------------------------
    float getDist(int row, int col) {
        return dist((float)getRow(), (float)getCol(), (float)row, (float)col);
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
            grid.initDlaSingleSeed();
            sf  = 1.0;
            runningDla = true;
            break;
        }
        case '2': {
            grid.initDlaSingleSeed();
            sf  = 0.1;
            runningDla = true;
            break;
        }
        case '3': {
            grid.initDlaSingleSeed();
            sf  = 0.01;
            runningDla = true;
            break;
        }
        case '4': {
            grid.initDlaSingleSeed();
            eta = 0;
            runningDla = false;
            break;
        }
        case '5': {
            grid.initDlaSingleSeed();
            eta = 3;
            runningDla = false;
            break;
        }
        case '6': {
            grid.initDlaSingleSeed();
            eta = 6;
            runningDla = false;
            break;
        }
        case '0': {
            grid.initDlaSingleSeed();
            sf  = 0.3;
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
    controlText[8]  = "0:     DLA (custom pattern, sf = XX)";
    
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