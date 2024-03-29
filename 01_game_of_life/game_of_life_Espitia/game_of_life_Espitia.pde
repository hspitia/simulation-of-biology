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
Grid tmpGrid;

int nCols             = 100;
int nRows             = 100;
int cellSize          = 6;

color backgroundColor = #444444;
color strokeColor     = #888888;
color deadCellColor   = #666666;
color aliveCellColor  = #FFB115;

PFont myFont;
PFont myFontBold;
CellPosition currentCell;

int lastTime       = 0;
int interval       = 100;
boolean singleStep = true;

// =========================================================
void setup() {
    size(601, 674);
    grid       = new Grid(nRows, nCols, cellSize);
    
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
}
// =========================================================
void draw() {
    background(backgroundColor);
    grid.display();
    displayHelp();
    
    if (millis() - lastTime > interval){
        if (!singleStep){
            runStep();
        }
    }
    
    if (singleStep && !mousePressed)
        tmpGrid = new Grid(grid);
}
// =========================================================
void displayHelp() {
    textFont(myFont);
    String[] controlText = new String[6];
    
    controlText[0] = "C:   Clear";
    controlText[1] = "R:   Randomize";
    controlText[2] = "G:   Toggle mode";
    controlText[3] = "Space:   Run a single step";
    controlText[4] = "+ :   Increase speed";
    controlText[5] = "-  :   Decrease speed";
    
    fill(255);
    String modeText  = "Single-step";
    if(!singleStep) modeText = "Continuous";
    textSize(12);
    text("Keyboard Controls:", 10, 618);
    
    int textX   = 15;
    int textY   = 636;
    int offsetY = 14;
    for (int i = 0; i < 6; ++i) {
        text(controlText[i], textX, textY);
        textY += offsetY;
        if(i == 2) {
            textX = 120;
            textY = 636;
        }
    }
    
    text("Current Mode:", 400, 618);
    textFont(myFontBold);
    textSize(18);
    fill(aliveCellColor);
    text(modeText, 400, 644);
}
// =========================================================
void runStep() {
    tmpGrid = new Grid(grid);
    tmpGrid.updateAllAliveNeighbors();
    grid.update(tmpGrid);
    lastTime = millis();
}

// =========================================================
boolean getRandomStatus(){
    return boolean(int(random(2)));
}
// =========================================================
void keyPressed() {
    switch (key) {
        case 'c':
        case 'C': {
            grid.clear();
            break;
        }
        
        case 'r':
        case 'R': {
            grid.randomize();
            break;
        }
        
        case 'g':
        case 'G': {
            singleStep = !singleStep;
            break;
        }
        
        case ' ': {
            if(!singleStep) singleStep = !singleStep;
            runStep();
            break;
        }
        
        case '+': {
            interval -= 10;
            break;
        }
        
        case '-': {
            interval += 10;
            break;
        }
    }
}
// =========================================================
void mousePressed() {
    CellPosition current = grid.getCellUnderMouse(mouseX, mouseY);
    
    if(mouseY <= (((current.row + 1) * cellSize) + 1) && mouseX <= (((current.col + 1) * cellSize) + 1))
        grid.changeStatus(current.row, current.col);
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
    boolean alive;
    // --------------------------------------------------------
    // Methods
    // constructor
    Cell(float x, float y, float w, float h, boolean alive) {
        this.x      = x;
        this.y      = y;
        this.w      = w;
        this.h      = h;
        this.alive  = alive;
    }
    // --------------------------------------------------------
    void fillCell() {
        color currentColor = deadCellColor;
        if(alive) currentColor = aliveCellColor;
        fill(currentColor);
    }
    // --------------------------------------------------------
    void display() {
        stroke(strokeColor);
        fillCell();
        rect(x, y, w, h); 
    }
}
// =========================================================
class CellPosition {
    int row = -1;
    int col = -1;
    
    CellPosition(int row, int col) {
        this.row = row;
        this.col = col;
    }
}
// =========================================================
class Grid {
    // Attributes
    int cols;
    int rows;
    int cellSize;
    Cell[][] grid;
    int[][] aliveNeighbors;
    // --------------------------------------------------------
    // Methods
    // constructor
    Grid(int rows, int cols, int cellSize) {
        this.cols     = cols;
        this.rows     = rows;
        this.cellSize = cellSize;
        
        aliveNeighbors = new int[this.rows][this.cols];
        grid           = new Cell[this.rows][this.cols];
        
        for (int i = 0; i < this.rows; ++i) {
            for (int j = 0; j < this.cols; ++j) {
                grid[i][j] = new Cell(j * this.cellSize, i * this.cellSize,
                                      this.cellSize, this.cellSize,
                                      getRandomStatus());
            }
        }
        updateAllAliveNeighbors();
    }
    // --------------------------------------------------------
    // copy constructor
    Grid(Grid obj) {
        cols           = obj.cols;
        rows           = obj.rows;
        cellSize       = obj.cellSize;
        aliveNeighbors = new int[rows][cols];
        grid           = new Cell[rows][cols];
        
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                grid[i][j] = new Cell(j * cellSize, i * cellSize,
                                      cellSize, cellSize,
                                      obj.isAlive(i, j));
            }
        }
        updateAllAliveNeighbors();
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
    boolean isAlive(int row, int col) {
        return grid[row][col].alive;
    }
    // --------------------------------------------------------
    void reviveCell (int row, int col) {
        grid[row][col].alive = true;
    }
    // --------------------------------------------------------
    void killCell (int row, int col) {
        grid[row][col].alive = false;
    }
    // --------------------------------------------------------
    private int[] getRowNeighbors(int row, int col) {
        int rowLowerAdjust = 0;
        int rowUpperAdjust = 0;
        
        if (row == 0) rowLowerAdjust = nRows;
        if (row == nRows-1) rowUpperAdjust = -nRows;
        
        int[] neighborRows = {(row - 1 + rowLowerAdjust), row, (row + 1 + rowUpperAdjust)};
        return neighborRows;
    }
    // --------------------------------------------------------
    private int[] getColNeighbors(int row, int col) {
        int colLowerAdjust = 0;
        int colUpperAdjust = 0;
        
        if (col == 0) colLowerAdjust = nCols;
        if (col == nCols-1) colUpperAdjust = -nCols;
        
        int[] neighborCols = {(col - 1 + colLowerAdjust), col, (col + 1 + colUpperAdjust)};
        return neighborCols;
    }
    // --------------------------------------------------------
    void updateAliveNeighbors(int row, int col) {
        
        int[] rowNeighbors = getRowNeighbors(row, col);
        int[] colNeighbors = getColNeighbors(row, col);
        
        int nAlive = 0;
        for (int i : rowNeighbors) {
            for (int j : colNeighbors) {
                if (i != row || j != col) {
                    if (isAlive(i, j))
                        nAlive++;
                } 
            }
        }
        aliveNeighbors[row][col] = nAlive;
    }
    // --------------------------------------------------------
    void updateAllAliveNeighbors() {
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                updateAliveNeighbors(i, j);
            }
        }
    }
    // --------------------------------------------------------
    void changeStatus (int row, int col) {
        grid[row][col].alive = !grid[row][col].alive;
    }
    // --------------------------------------------------------
    CellPosition getCellUnderMouse(int x, int y) {
        int col = x/cellSize;
        int row = y/cellSize;
        
        // Prevent grid index overflow error
        if (col > (nCols - 1)) col = nCols - 1;
        if (row > (nRows - 1)) row = nRows - 1;
        
        return (new CellPosition(row, col));
    }
    // --------------------------------------------------------
    int getLiveNeighbors(int row, int col) {
        return aliveNeighbors[row][col];
    }
    // --------------------------------------------------------
    void clear() {
        for (int row = 0; row < rows; ++row) {
            for (int col = 0; col < cols; ++col) {
                killCell(row, col);
            }
        }
    }
    // --------------------------------------------------------
    void update() {
        for (int row = 0; row < rows; ++row) {
            for (int col = 0; col < cols; ++col) {
                if (isAlive(row, col)) {
                    if (getLiveNeighbors(row, col) < 2 || getLiveNeighbors(row, col) > 3) {
                        killCell(row, col);
                    }
                }
                else {
                    if(getLiveNeighbors(row, col) == 3)
                        reviveCell(row, col);
                }
            }
        }
    }
    // --------------------------------------------------------
    void update(Grid tmpGrid) {
        for (int row = 0; row < tmpGrid.rows; ++row) {
            for (int col = 0; col < tmpGrid.cols; ++col) {
                if (tmpGrid.isAlive(row, col)) {
                    if (tmpGrid.getLiveNeighbors(row, col) < 2 || tmpGrid.getLiveNeighbors(row, col) > 3) {
                        killCell(row, col);
                    }
                }
                else {
                    if(tmpGrid.getLiveNeighbors(row, col) == 3)
                        reviveCell(row, col);
                }
            }
        }
    }
    // --------------------------------------------------------
    void randomize(){
        for (int row = 0; row < rows; ++row) {
            for (int col = 0; col < cols; ++col) {
                // grid[row][col].alive = boolean(int(random(2)));
                grid[row][col].alive = getRandomStatus();
            }
        }
    }
}
