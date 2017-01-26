
// ==========================================================
// Decription:  This program recreates Flocking
//              Project 2
//              
// Author:      Hector Fabio Espitia Navarro
// Version:     1.0
// Institution: Georgia Intitute of Technology
//              Simulation of Biology - Spring 2017
// ==========================================================

// ==========================================================
// Global variables
// colors
color backgroundColor   = #444444;
color strokeColor       = #888888;
color creatureCellColor = #FFB115;

PFont myFont;
PFont myFontBold;
// =========================================================
void setup() {
    size(700, 700);
        
    // printArray(PFont.list());
    myFont     = createFont("Ubuntu", 20);
    myFontBold = createFont("Ubuntu Bold", 20);
    
}
// =========================================================
void draw() {
    background(backgroundColor);
    
}
// =========================================================
void keyPressed() {
    switch (key) {
        case 'a':
        case 'A': {
            break;
        }
        
        case 'r':
        case 'R': {
            break;
        }
        
        case 's':
        case 'S': {
            break;
        }
        case 'p':
        case 'P': {
            break;
        }
        case 'c':
        case 'C': {
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
        case '=': 
        case '+': {
            break;
        }
        
        case '-': {
            break;
        }
        case ' ': {
            break;
        }
        
        
    }
}
// =========================================================
class Creature {
    // Attributes
    PVector velocity;
    PVector position;
    float r;
    // Methods
    // Constructor
    Creature() {
        
    }
    
    void display(){
        
    }
}