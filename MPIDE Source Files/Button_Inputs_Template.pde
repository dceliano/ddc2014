//Depending on what button is pressed (0, 1, or 3), this program
//will jump to a certain setting (0,1, or 3).
//There is no setting 2 because button 2 does not work.
//setting 0: A null setting (in which nothing will happen)
//setting 1:
//setting 3: 

//setting up pin numbers as constants
const int button0Pin = A2;  
const int button1Pin = 40;
const int button3Pin = A5;
// variables for reading the pushbutton status
int button0State;        
int button1State; 
int button3State; 
//The program will start at setting 0 (a null setting)
int setting = 0;
//These variables will be used later - these values are just
//fillers (start at setting 0 and put all the buttons at
//a state of 0 - AKA not pressed)
int previousSetting = 0;
int previousButton0State = 0;
int previousButton1State = 0;
int previousButton3State = 0;

void setup() {     
  // initialize the pushbutton pins as inputs:
  pinMode(button0Pin, INPUT);    
  pinMode(button1Pin, INPUT);  
  pinMode(button3Pin, INPUT);  
}

void loop(){
  // read the states of the pushbutton values:
  button0State = digitalRead(button0Pin);
  button1State = digitalRead(button1Pin);
  button3State = digitalRead(button3Pin);
  
  //see if a button has been pressed or not and then change
  //the setting based on which button was pressed
  if (button0State != previousButton0State){
    setting = 0;
  }
  else if (button1State != previousButton1State){
    setting = 1;
  }
  else if (button3State != previousButton3State){
    setting = 3;
  }
  //if no button was pressed, stay on the previous setting
  else setting = previousSetting;
  
  // go to a certain program based on what setting we are on
  if (setting == 0) {     
    //nullify the program to make sure nothing is happening
  } 
  else if (setting == 1) {     
    //do something
  } 
  else if (setting == 3) {    
   //do something
  }
  
 //Save the values of these variables as the 'previous' values
 //so that they can be compared with the new values next time we
 //go through the loop.
   previousButton0State = button0State;
   previousButton1State = button1State;
   previousButton3State = button3State;
   previousSetting = setting;
}
