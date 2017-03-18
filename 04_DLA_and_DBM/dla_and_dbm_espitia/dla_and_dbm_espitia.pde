// ==========================================================
// Decription:  This program recreates the Diffusion Limited 
//              Aggregation (DLA) and the Dielectric 
//              Breakdown Model algorithms.
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
int cellSize = 10;
int nCols    = floor(canvasSize/cellSize);
int nRows    = floor(canvasSize/cellSize);




color infoPanelColor  = #001A31;
color titleColor      = #FF9D00;
color textColor       = #E2E2E2;
color backgroundColor = #444444;
color strokeColor     = #333333;
color emptyCellColor  = #222222;
color filledCellColor = #FF9D00;
// color filledCellColor = #00686F;
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

// Debug variables
int nIterations = 8;
int counter     = 0;


String xPos = "";
String yPos = "";
// =========================================================
void setup() {
    size(900, 600);
    // frameRate(6000);
    grid = new Grid(nRows, nCols, cellSize, eta, sf);
    
    myFont      = createFont("Ubuntu Mono", 14);
    myFontBold  = createFont("Ubuntu Bold", 14);
    myTitleFont = createFont("Ubuntu Bold", 18);
    
    grid.initDlaSingleSeed();
    // testArrayListRefs();
    // testNeighbors();
    counter = 0;
}
// =========================================================
void draw() {
    background(backgroundColor);
    grid.display();
    displayInfo();
    
    // if (millis() - lastTime > interval && simRunning){
    if (simRunning){
        if (runningDla) 
            grid.runDLA();
        else {
            // if (counter++ < nIterations){
                // println("counter: "+counter);
                grid.runDBM();
            // }
                // printArrayList(grid.candidateCells);
                // grid.computeMaxAndMinPotential();
                // println("maxP: "+grid.maxP+" minP: "+grid.minP);
        }
    }
    
}
// =========================================================
PVector getCellUnderMouse(int x, int y) {
    int col = nCols-1;
    int row = nRows-1;
    
    if (mouseX < canvasSize && mouseY < canvasSize) {
        col = (int)x/cellSize;
        row = (int)y/cellSize;
    }
    
    return (new PVector(row, col));
}
// =========================================================
void updateCellCoordInfo() {
    if (mouseX < canvasSize && mouseY < canvasSize) {
        PVector pos = getCellUnderMouse(mouseX, mouseY);
        int row = (int)pos.x;
        int col = (int)pos.y;
        xPos = "" + col;
        yPos = "" + row;
        // xPos = "" + mouseX;
        // yPos = "" + mouseY;
    }
}
// =========================================================
void mousePressed() {
    // PVector current = grid.getCellUnderMouse(mouseX, mouseY);
    PVector current = getCellUnderMouse(mouseX, mouseY);
    int row = int(current.x);
    int col = int(current.y);
    if(runningDla) {
        if (grid.grid[row][col].status == 0) 
            grid.grid[row][col].status = 1;
        else if (grid.grid[row][col].status == 1) 
            grid.grid[row][col].status = 0;
    }
}
// =========================================================
class Grid {
    // Attributes
    int cols;
    int rows;
    int cellSize;
    Cell[][] grid;
    // int lastRow;
    // int lastCol;
    ArrayList<Cell> patternCells;
    ArrayList<Cell> candidateCells;
    float eta;
    float sf;
    float maxP       = 0.0;
    float minP       = 0.0;
    float phiIEtaSum = 0.0;
    
    // --------------------------------------------------------
    // Methods
    // constructor
    Grid(int rows, int cols, int cellSize, float eta, float sf) {
        this.cols     = cols;
        this.rows     = rows;
        this.cellSize = cellSize;
        this.sf       = sf;
        this.eta      = eta;
        
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
        
        patternCells   = new ArrayList<Cell>();
        candidateCells = new ArrayList<Cell>();
    }
    // --------------------------------------------------------
    // copy constructor
    Grid(Grid obj) {
        sf             = obj.sf;
        eta            = obj.eta;
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
        
        // lastRow = row;
        // lastCol = col;
        
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
    private ArrayList<Integer> getRowNeighbor(int pos) {
        ArrayList<Integer> neighbors = new ArrayList<Integer>();
        if (pos-1 >= 0) neighbors.add(pos-1);
        neighbors.add(pos);
        if (pos+1 <= rows-1) neighbors.add(pos+1);
        
        return neighbors;
    }
    // --------------------------------------------------------
    private ArrayList<Integer> getColNeighbor(int pos) {
        ArrayList<Integer> neighbors = new ArrayList<Integer>();
        if (pos-1 >= 0) neighbors.add(pos-1);
        neighbors.add(pos);
        if (pos+1 <= cols-1) neighbors.add(pos+1);
        
        return neighbors;
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
    void runDLA() {
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
                    if (grid[i][j].isFilled())
                        return false;
                } 
            }
        }
        return true;
    }
    // --------------------------------------------------------
    private boolean isFilled(int row, int col) {
        return (grid[row][col].status == 1) ;
    }
    // --------------------------------------------------------
    void initDlaSingleSeed() {
        clear();
        
        int row = floor(nRows/2);
        int col = floor(nCols/2);
        
        // lastRow = row;
        // lastCol = col;
        
        grid[row][col].status = 1; // FILLED
    }
    // --------------------------------------------------------
    void initDbmSingleSeed() {
        clear();
        
        patternCells   = new ArrayList<Cell>();
        candidateCells = new ArrayList<Cell>();
        
        int row = floor(nRows/2);
        int col = floor(nCols/2);
        
        // lastRow = row;
        // lastCol = col;
        
        // fillCell(row, col);
        fillCell(grid[row][col]);
        // updateNeighborsStatus(row, col);
        updateNeighborsStatus(grid[row][col]);
        updateCandidatesPotential(grid[row][col]);
        
        // println("candidateCells: ");
        // printArrayList(candidateCells);
        // println("patternCells: ");
        // printArrayList(patternCells);
        
    }
    // --------------------------------------------------------
    void runDBM() {
        // println("patternCells: "+patternCells.size());
        // println("candidateCells: "+candidateCells.size());
        
        // Select a new cell to add to the pattern
        // int idx = int(random(candidateCells.size()));
        int idx      = selectCandidateCell();
        
        Cell newCell = candidateCells.get(idx);
        int row      = newCell.getRow(); 
        int col      = newCell.getCol();
        
        // fillCell(row, col);
        fillCell(newCell);
        candidateCells.remove(idx); // point for improvement
        int nCandidates = candidateCells.size();
        updateCandidatesPotential(newCell);
        // updateNeighborsStatus(row, col);
        updateNeighborsStatus(newCell);
        
        // Compute the electric potencial for the new candidates
        for (int i = nCandidates; i < candidateCells.size(); ++i) {
            Cell cCell = candidateCells.get(i);
            cCell.ep = computeElectricPotential(cCell);
        }
        
        // println("candidateCells: ");
        // printArrayList(candidateCells);
        // println("patternCells: ");
        // printArrayList(patternCells);
        // println("idx. " + idx);
        
    }
    // // --------------------------------------------------------
    // private void fillCell(int row, int col) {
    //     grid[row][col].status = 1; // FILLED
    //     patternCells.add(grid[row][col]);
    // }
    // --------------------------------------------------------
    private void fillCell(Cell cell) {
        cell.status = 1; // FILLED
        patternCells.add(cell);
    }
    // --------------------------------------------------------
    // private void updateNeighborsStatus(int row, int col) {
    private void updateNeighborsStatus(Cell cell) {
        int row = cell.getRow();
        int col = cell.getCol();
        // Update neighbors' status
        ArrayList<Integer> rowNeighbors = getRowNeighbor(row);
        ArrayList<Integer> colNeighbors = getColNeighbor(col);
        
        for (int r : rowNeighbors) {
            for (int c : colNeighbors) {
                // print(r+","+c+"  ");
                if ((r != row || c != col) && grid[r][c].status == 0) {
                        grid[r][c].status = 2; // CANDIDATE
                        candidateCells.add(grid[r][c]);
                    // print("*  ");
                }
            }
            // println("");
        }
    }
    // --------------------------------------------------------
    private float computeElectricPotential(Cell cell) {
        float potential = 0;
        float r0        = 1.0;
        
        for (Cell pCell : patternCells) {
            potential += (1 - (r0 / cell.distTo(pCell)));
        }
        
        return potential;
    }
    // --------------------------------------------------------
    private void updateCandidatesPotential(Cell newPatternCell) {
        float r0 = (float)cellSize/2;
        
        for (Cell cCell : candidateCells) {
            cCell.ep = cCell.ep + (1 - (r0/cCell.distTo(newPatternCell)));
        }
    }
    // --------------------------------------------------------
    private void computeMaxAndMinPotential() {
        maxP = candidateCells.get(0).ep;
        minP = candidateCells.get(0).ep;
        
        for (int i = 1; i < candidateCells.size(); ++i) {
            Cell cCell = candidateCells.get(i);
            if (maxP < cCell.ep) 
                maxP = cCell.ep;
            
            if (minP > cCell.ep)
                minP = cCell.ep;
        }
    }
    // --------------------------------------------------------
    private void computeCandidatesPhiIEta() {
        computeMaxAndMinPotential();
        phiIEtaSum = 0.0;
        for (Cell cCell : candidateCells) {
            float phiI    = (cCell.ep - minP) / (maxP - minP);
            cCell.phiIEta = pow(phiI, eta);
            phiIEtaSum    += cCell.phiIEta;
        }
    }
    // --------------------------------------------------------
    private void computeCandidatesProb() {
        for (Cell cCell : candidateCells) {
            cCell.pI = cCell.phiIEta/phiIEtaSum;
        }
    }
    // --------------------------------------------------------
    private void computeCadidatePartialSumI() {
        float sum = 0.0;
        for (Cell cCell : candidateCells) {
            sum += cCell.pI;
            cCell.partialSumI = sum;
        }
    }
    // --------------------------------------------------------
    private int selectCandidateCell() {
        
        computeCandidatesPhiIEta();
        computeCandidatesProb();
        computeCadidatePartialSumI();
        
        float lastPartialSumI = candidateCells.get(candidateCells.size()-1).partialSumI;
        float r = random(lastPartialSumI);
        int idx = -1;
        for (int i = 0; i < candidateCells.size(); ++i) {
            if (r < candidateCells.get(i).partialSumI) {
                idx = i;
                break;
            }
        }
        
        return idx;
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
                grid[row][col].status      = 0; // EMPTY
                grid[row][col].ep          = 0;
                grid[row][col].phiIEta     = 0;
                grid[row][col].pI          = 0;
                grid[row][col].partialSumI = 0;
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
    float phiIEta;
    float pI;
    float partialSumI;
    
    // --------------------------------------------------------
    // Methods
    // constructor
    Cell(float x, float y, float w, float h, int status, float ep) {
        this.x           = x;
        this.y           = y;
        this.w           = w;
        this.h           = h;
        this.status      = status;
        this.ep          = ep;
        this.phiIEta     = 0;
        this.pI          = 0;
        this.partialSumI = 0;
    }
    // --------------------------------------------------------
    Cell(Cell obj) {
        this.x           = obj.x;
        this.y           = obj.y;
        this.w           = obj.w;
        this.h           = obj.h;
        this.status      = obj.status;
        this.ep          = obj.ep;
        this.phiIEta     = obj.phiIEta;
        this.pI          = obj.pI;
        this.partialSumI = obj.partialSumI;
    }
    // --------------------------------------------------------
    void display() {
        stroke(strokeColor);
        // noStroke();
        color currentColor = emptyCellColor;
        // if (status == 2) currentColor = pathCellColor; //
        if (status == 1) currentColor = filledCellColor;
        fill(currentColor);
        rect(x, y, w, h); 
    }
    // --------------------------------------------------------
    boolean isFilled() {
        return (status == 1);
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
        String outStr = "(" + getRow() + "," + getCol() + ")" + 
                         " st: " + status + 
                         " phiIEta: " + phiIEta + 
                         " ep: " + ep + 
                         " pI: " + pI + 
                         " partialSumI: " + partialSumI;
        return outStr;
    }
    // --------------------------------------------------------
    float distTo(Cell obj) {
        // return dist((float)getRow(), (float)getCol(), 
                    // (float)obj.getRow(), (float)obj.getCol());
        return dist(x, y, obj.x, obj.y);
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
            grid.sf    = 1.0;
            runningDla = true;
            break;
        }
        case '2': {
            grid.initDlaSingleSeed();
            grid.sf    = 0.1;
            runningDla = true;
            break;
        }
        case '3': {
            grid.initDlaSingleSeed();
            grid.sf    = 0.01;
            runningDla = true;
            break;
        }
        case '4': {
            grid.initDbmSingleSeed();
            grid.eta   = 0;
            counter    = 0;
            runningDla = false;
            break;
        }
        case '5': {
            grid.initDbmSingleSeed();
            grid.eta   = 3;
            counter    = 0;
            runningDla = false;
            break;
        }
        case '6': {
            grid.initDbmSingleSeed();
            grid.eta   = 6;
            counter    = 0;
            runningDla = false;
            break;
        }
        case '0': {
            grid.initDlaSingleSeed();
            grid.sf    = 0.7;
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
    updateCellCoordInfo();
    
    int nControlText = 8;
    int nInfoText    = 4;
    
    String[] controlText = new String[nControlText];
    String[] infoText    = new String[nInfoText];
    // String[] values      = new String[5];
    
    controlText[0]  = "Space: Start/Stop growth";
    controlText[1]  = "1:     DLA, sticking factor = 1";
    controlText[2]  = "2:     DLA, sticking factor = 0.1";
    controlText[3]  = "3:     DLA, sticking factor = 0.01";
    controlText[4]  = "4:     DBM, eta = 0";
    controlText[5]  = "5:     DBM, eta = 3";
    controlText[6]  = "6:     DBM, eta = 6";
    controlText[7]  = "0:     DLA (custom pattern, sf = 0.8)";
    
    infoText[0] = "Grid size:       " + nRows + " x " + nCols + " cells";
    infoText[1] = "Cell size:       " + cellSize + " pixels";
    infoText[2] = "Mode:            " + ((runningDla) ? "DLA" : "DBM");
    infoText[3] = ((runningDla) ? "Sticking Factor: " + grid.sf : "eta:             " + grid.eta);
    
    // String algorithmParam = ((runningDla) ? "Sticking Factor: " + sf : "eta:             " + eta);
    
    // infoText[3] = "Sticking Factor: " + sf;
    
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
    
    String coordinates = "(row,col): (" + yPos + "," + xPos + ")";
    textY += 20;
    text(coordinates, textX, textY);
}
// =========================================================
// void testNeighbors () {
//     int row = 0;
//     int col = 0;
//     ArrayList<Integer> rN = grid.getRowNeighbor(row);
//     ArrayList<Integer> cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = 0;
//     col = 4;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = 0;
//     col = nCols-1;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = 4;
//     col = nCols-1;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = nRows-1;
//     col = nCols-1;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
    
//     row = nRows-1;
//     col = 4;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
    
//     row = nRows-1;
//     col = 0;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = 4;
//     col = 0;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
    
//     row = 4;
//     col = 4;
//     rN = grid.getRowNeighbor(row);
//     cN = grid.getColNeighbor(col);
//     printNeighbors(rN, cN);
//     println("");
//     // for (int r : rN) {
//     //     for (int c : cN) {
//     //         print(r + ","+ c + "  ");
//     //     }
//     //     println("");
//     // }
    
// }
// =========================================================
void printArrayList(ArrayList<Cell> list) {
    // for (Cell c : list) {
    //     // print(c.ep + " ");
    //     println(c);
    // }
    
    for (int i = 0; i < list.size(); ++i) {
        println(i+1 + " - " + list.get(i));
    }
    
    println("---");
}
// // =========================================================
// void printNeighbors(ArrayList<Integer> rowN, ArrayList<Integer> colN) {
//     for (int r : rowN) {
//         for (int c : colN) {
//             print(r + ","+ c + "  ");
//         }
//         println("");
//     }
// }
// // =========================================================
// void testArrayListRefs() {
//     int nCells = 5;
//     Cell[] cells = new Cell[nCells];
    
//     for (int i = 0; i < nCells; ++i) {
//         cells[i] = new Cell(i*cellSize, 0, cellSize, cellSize, 0, 0);
//     }
//     println("cells: ");
//     for (Cell c : cells) {
//         println("c: "+c);
//     }
    
//     ArrayList<Cell> cellList = new ArrayList<Cell>();
    
//     for (Cell c : cells) {
//         cellList.add(c);
//     }
    
//     println("\ncellList: ");
//     for (Cell c : cellList) {
//         println("c: "+c);
//     }
    
//     println("\nModifying cells:");
//     cells[1].status = 1;
//     cells[2].status = 1;
//     for (Cell c : cells) {
//         println("c: "+c);
//     }
    
//     println("\ncellList: ");
//     for (Cell c : cellList) {
//         println("c: "+c);
//     }
    
//     println("\nModifying cellList:");
//     cellList.remove(0);
//     println("cells: ");
//     for (Cell c : cells) {
//         println("c: "+c);
//     }
//     println("\ncellList: ");
//     for (Cell c : cellList) {
//         println("c: "+c);
//     }
    
//     println("\nModifying cells:");
//     cells[0].status = 1;
//     cells[4].status = 1;
//     for (Cell c : cells) {
//         println("c: "+c);
//     }
    
//     println("\ncellList: ");
//     for (Cell c : cellList) {
//         println("c: "+c);
//     }
    
//     // distances
//     for (Cell c : cells) {
//         println("dist: " + cells[0].distTo(c));
//     }
    
// }