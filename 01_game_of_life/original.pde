// =========================================================
// 
// =========================================================

// =========================================================
// Global variables
Grid grid;
Grid tmpGrid;
int nCols             = 100;
int nRows             = 100;
int cellSize          = 6;
// boolean live          = true;
color backgroundColor = #666666;
color strokeColor     = #888888;
color deadCellColor   = #666666;
color aliveCellColor  = #FFB115;

PFont myFont;
CellCoordinate currentCell;
Status currentCellStatus;

float aliveStartProb = 50;
int lastTime         = 0;
int interval         = 100;
boolean pause        = false;

// =========================================================
void setup() {
    // size(601, 601);
    size(601, 631);
    grid = new Grid(nRows, nCols, cellSize);
    
    // font 
    // printArray(PFont.list());
    PFont myFont = createFont("Ubuntu", 20);
    textFont(myFont);
    
    // drawSomeFigures();
}

void draw() {
    background(backgroundColor);
    grid.display();
    
    // Display information of the cell under mouse
    fill(255);
    currentCell       = grid.getCellUnderMouse(mouseX, mouseY);
    currentCellStatus = grid.getCellStatus(currentCell.row, currentCell.col);
    text("Cell: " + str(currentCell.row) + "," + str(currentCell.col) + " " + 
         getStatusStr(currentCellStatus) + "  "+ 
         "Alive neighbors: " + grid.getLiveNeighbors(currentCell.row, currentCell.col) + "  " + 
         mouseX + "," + mouseY + " - " + (((currentCell.row + 1) * cellSize) + 1) + 
         "   Pause: " + pause, 10, 622);
    
    // Iterate if timer ticks
    if (millis() - lastTime > interval) {
        if (!pause) {
          runStep();
          // lastTime = millis();
        }
    } 
    
    if (pause && !mousePressed) {
        tmpGrid = new Grid(grid);
    }
}

// =========================================================
void runStep() {
    tmpGrid = new Grid(grid);
    tmpGrid.updateAllAliveNeighbors();
    grid.update(tmpGrid);
    lastTime = millis();
}

// =========================================================
Status getRandomStatus(){
    float rndNumber = random(100);
    Status status = Status.DEAD;
    if (rndNumber <= aliveStartProb) status = Status.ALIVE;
    return status;
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
            pause = !pause;
            break;
        }
        
        case ' ': {
            runStep();
            break;
        }
    }
}
// =========================================================
void mousePressed() {
    CellCoordinate current = grid.getCellUnderMouse(mouseX, mouseY);
    
    if(mouseY <= (((current.row + 1) * cellSize) + 1) && mouseX <= (((current.col + 1) * cellSize) + 1))
        grid.changeStatus(current.row, current.col);
}
// =========================================================
void drawSomeFigures() {
    // glider
    grid.reviveCell(10, 10);
    grid.reviveCell(11, 11);
    grid.reviveCell(9, 12);
    grid.reviveCell(10, 12);
    grid.reviveCell(11, 12);
    
    grid.reviveCell(30,30);
    grid.killCell(30,30);
    grid.reviveCell(40,40);
}
    
// =========================================================
public enum Status {
    ALIVE,
    DEAD
};

// =========================================================
String getStatusStr(Status status) {
    String strStatus = "DEAD";
    if (status == Status.ALIVE) strStatus = "ALIVE";
    return strStatus;
}

// =========================================================
class Cell {
  // Attributes
  float x, y;
  float w, h;
  Status status = Status.DEAD;
  
  // Methods
  // constructor
  Cell(float x, float y, 
       float w, float h, 
       Status status) {
    
      this.x      = x;
      this.y      = y;
      this.w      = w;
      this.h      = h;
      this.status = status;
  }
  
  void fillCell() {
    color currentColor = deadCellColor;
    if (status == Status.ALIVE) currentColor = aliveCellColor;
    fill(currentColor);
  }
  
  void display() {
    stroke(strokeColor);
    fillCell();
    rect(x, y, w, h); 
  }
}
// =========================================================
class CellCoordinate {
    int row = -1;
    int col = -1;
    
    CellCoordinate(int row, int col) {
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
                // aliveNeighbors[i][j] = 0;
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
                                      obj.getCellStatus(i, j));
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
        return (grid[row][col].status == Status.ALIVE);
    }
    // --------------------------------------------------------
    void reviveCell (int row, int col) {
        grid[row][col].status = Status.ALIVE;
        // updateAliveNeighbors(row, col);
        // delay(1000);
        // update();
    }
    // --------------------------------------------------------
    void killCell (int row, int col) {
        grid[row][col].status = Status.DEAD;
        // updateAliveNeighbors(row, col);
        // delay(1000);
        // update();
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
        if (isAlive(row, col)) {
            killCell(row, col);
        }
        else {
            reviveCell(row, col);
        }
    }
    // --------------------------------------------------------
    CellCoordinate getCellUnderMouse(int x, int y) {
        int col = x/cellSize;
        int row = y/cellSize;
        
        // Prevent grid index overflow error (along rows)
        if (col > (nCols - 1)) col = nCols - 1;
        if (row > (nRows - 1)) row = nRows - 1;
        
        return (new CellCoordinate(row, col));
    }
    // --------------------------------------------------------
    Status getCellStatus(int row, int col) {
        return grid[row][col].status;
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
                grid[row][col].status = getRandomStatus();
            }
        }
    }
}

void testNeighbors(int row, int col) {
    int rowLowerAdjust = 0;
    int colLowerAdjust = 0;
    int rowUpperAdjust = 0;
    int colUpperAdjust = 0;
    
    if (row == 0) rowLowerAdjust = nRows;
    if (col == 0) colLowerAdjust = nCols;
    if (row == nRows-1) rowUpperAdjust = -nRows;
    if (col == nCols-1) colUpperAdjust = -nCols;
    
    int[] neighborRows = {(row - 1 + rowLowerAdjust), row, (row + 1 + rowUpperAdjust)};
    int[] neighborCols = {(col - 1 + colLowerAdjust), col, (col + 1 + colUpperAdjust)};
    
    print(row + "," + col + ":\n");
    for (int i : neighborRows) {
        for (int j : neighborCols) {
            print("  " + i + "," + j + " ");
        }
        print("\n");
    }
    print("\n");
}