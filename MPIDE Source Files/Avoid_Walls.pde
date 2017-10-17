/*This is a program which has two modes for driving a truck.
The first mode (setting 1) will go straight until it encounters
a wall, at which point it will stop, make a 180* turn, and 
continue going straight in the direction it came from.
The second mode (setting 2) will turn right/left into a wall
on purpose, and then use the side LED sensors to find when it
is about to hit its wall, and then correct itself.
3 buttons control these settings:
button 0: no setting (a null program)
button 1: go to setting 1
button 3: go to setting 2
*/
//BUTTON VARIABLES/CONSTANTS
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

//MOTOR/INFARED CONSTANTS AND VARIABLES
//Setting up pins with easy to read variables//
//Motor 1 (LEFT MOTOR - bottom  - if looking forward)
const int DIR1pin = A4;
const int SPEED1pin = 9;
//Motor 2 (RIGHT MOTOR - top)
//Right motor is oriented in the opposite way
const int DIR2pin = A0;
const int SPEED2pin = 6;
//Front Infared
const int IR1pin = A6;
//Right Infared
const int IR2pin = A7;
//Left Infared
const int IR3pin = A1;
//speed variables
int speed1;
int speed2;
//counter
int i;


void setup(){
  Serial.begin(9600);
  //motors are outputs
  pinMode(DIR1pin, OUTPUT);
  pinMode(SPEED1pin, OUTPUT);
  pinMode(DIR2pin, OUTPUT);
  pinMode(SPEED2pin, OUTPUT);
  // initialize the pushbutton pins as inputs:
  pinMode(IR1pin, INPUT);
  pinMode(IR2pin, INPUT);
  pinMode(IR3pin, INPUT);
  pinMode(button0Pin, INPUT);    
  pinMode(button1Pin, INPUT);  
  pinMode(button3Pin, INPUT);  
  
}

void loop(){
  //After remapping, 0 will be closer to the wall, 1023 farther
  int Sensor1Reading = map(analogRead(IR1pin), 0, 1023, 1023, 0);
  int Sensor2Reading = map(analogRead(IR2pin), 0, 1023, 1023, 0);
  int Sensor3Reading = map(analogRead(IR3pin), 0, 1023, 1023, 0);
  // read the states of the pushbutton values:
  button0State = digitalRead(button0Pin);
  button1State = digitalRead(button1Pin);
  button3State = digitalRead(button3Pin);
  Serial.println(Sensor1Reading, DEC);
  
  //see if a button has been pressed or not and then change
  //the setting based on which button was pressed
  if (button0State != previousButton0State){
    setting = 0;
  }
  else if (button1State != previousButton1State){
    setting = 1;
  }
  else if (button3State != previousButton3State){
    setting = 2;
  }
  //if no button was pressed, stay on the previous setting
  else setting = previousSetting;
  
  // go to a certain program based on what setting we are on
  if (setting == 0) {     
    //turn the motors off to make sure nothing is happening
    speed1 = 0;
    speed2 = 0;
    analogWrite(SPEED1pin, speed1); //stop left motor
    analogWrite(SPEED2pin, speed2); //stop right motor
     
    //reset the counter used in setting 2 (because we are not
    //in setting 2)
    i = 1;
  } 
  else if (setting == 1) {     
    //start the motors going forwards
    speed1 = 60;
    speed2 = 60;
    digitalWrite(DIR1pin, HIGH);
    analogWrite(SPEED1pin, speed1);
    digitalWrite(DIR2pin, LOW); //motor has opposite orientation
    analogWrite(SPEED2pin, speed2);
    
    //We have gotten close to the wall, and are now stopping
    //and turning around
    if(Sensor1Reading < 700 || Sensor2Reading < 750 || Sensor3Reading < 750){
      speed1 = 0;
      speed2 = 0;
      //stop both of the motors
      analogWrite(SPEED1pin, speed1);
      analogWrite(SPEED2pin, speed2);
      turn180(); //call the turn 180* function to turn around 
     //after turning around, it will start over at setting 1
     //going forward like normal    
     
      //reset the counter used in setting 2 (because we are not
      //in setting 2)
      i = 1;
    }
  } 
  else if (setting == 2) {    
    //go in a straight line unless we are on the first setting(i=1)
    //and if we are far away from both of the walls
    if (i != 1 && Sensor2Reading >= 725 && Sensor3Reading >= 725){
      speed1 = 60;
      speed2 = 60;
      digitalWrite(DIR1pin, HIGH);
      analogWrite(SPEED1pin, speed1);
      digitalWrite(DIR2pin, LOW); //motor has opposite orientation
      analogWrite(SPEED2pin, speed2);
    }
    
    //Start the motors going forwards with the left motor going
    //faster so that it turns to the right. Only set it to this
    //setting once by using a counter.
    if(i==1){
    speed1 = 110;
    speed2 = 0;
    digitalWrite(DIR1pin, HIGH);
    analogWrite(SPEED1pin, speed1);
    digitalWrite(DIR2pin, LOW); //motor has opposite orientation
    analogWrite(SPEED2pin, speed2);
    }
    
    //getting too close to the right wall
    if(Sensor2Reading < 700){
      if(Sensor2Reading >=500){
      //Turn a certain amount
      TurnLeft100();
      }
      if(Sensor2Reading <500){
        //turn even more because we are closer to the wall
        TurnLeft200();
      }
      //Go straight to get clear of the wall
      GoStraight2000();
      
      i++; //increment counter
    }
    //getting too close to the left wall
    if(Sensor3Reading < 700){
      if(Sensor3Reading >=500){
      //Turn a certain amount
      TurnRight100();
      }
      if(Sensor3Reading <500){
        //turn even more because we are closer to the wall
        TurnRight200();
      }
      //Go straight to get clear of the wall
      GoStraight2000();
      
      i++; //increment counter
    }
    
    //failsafe to stop if we get too close to a wall in front of us
    //only do this if we are not close to any walls to the sides of us
    if(Sensor1Reading < 700 && Sensor2Reading > 850 && Sensor3Reading > 850){
    speed1 = 0;
    speed2 = 0;
    analogWrite(SPEED1pin, speed1);
    analogWrite(SPEED2pin, speed2);
    //delay 2 seconds and then restart
    delay(2000);
    }
    
 }
  
 //Save the values of these variables as the 'previous' values
 //so that they can be compared with the new values next time we
 //go through the loop.
   previousButton0State = button0State;
   previousButton1State = button1State;
   previousButton3State = button3State;
   previousSetting = setting;
}


//FUNCTIONS
void turn180(){
    speed1 = 140;
    speed2 = 40;
    digitalWrite(DIR1pin, LOW);
    digitalWrite(DIR2pin, LOW); //go opposite way
    analogWrite(SPEED1pin, speed1);
    analogWrite(SPEED2pin, speed2);
    delay(1400); //pause until half turn finished
    speed1 = 40;
    speed2 = 140;
    digitalWrite(DIR1pin, LOW); //backwards with left wheel
    digitalWrite(DIR2pin, LOW); //go forwards with right wheel
    analogWrite(SPEED1pin, speed1);
    analogWrite(SPEED2pin, speed2);
    delay(1400); //pause until full turn finished
}
//turn left for 100 milliseconds
void TurnLeft100(){
   //go to the left to correct being too close to the right wall
   speed1 = 40; 
   speed2 = 170;
   //motors going in opposite directions
   digitalWrite(DIR1pin, LOW);
   analogWrite(SPEED1pin, speed1);
   digitalWrite(DIR2pin, LOW); //motor has opposite orientation
   analogWrite(SPEED2pin, speed2);
   //do the turn for this amount of time
   delay(200); 
}
void TurnLeft200(){
   //go to the left to correct being too close to the right wall
   speed1 = 40; 
   speed2 = 170;
   //motors going in opposite directions
   digitalWrite(DIR1pin, LOW);
   analogWrite(SPEED1pin, speed1);
   digitalWrite(DIR2pin, LOW); //motor has opposite orientation
   analogWrite(SPEED2pin, speed2);
   //do the turn for this amount of time
   delay(400); 
}
//turn right for 100 milliseconds
void TurnRight100(){
    //go to the right to correct being too close to the left wall
    speed1 = 170; 
    speed2 = 40;
    //motors going in opposite directions
    digitalWrite(DIR1pin, HIGH);
    analogWrite(SPEED1pin, speed1);
    digitalWrite(DIR2pin, HIGH); //motor has opposite orientation
    analogWrite(SPEED2pin, speed2);
    //do the turn for this amount of time
   delay(200);
}
void TurnRight200(){
    //go to the right to correct being too close to the left wall
    speed1 = 170; 
    speed2 = 40;
    //motors going in opposite directions
    digitalWrite(DIR1pin, HIGH);
    analogWrite(SPEED1pin, speed1);
    digitalWrite(DIR2pin, HIGH); //motor has opposite orientation
    analogWrite(SPEED2pin, speed2);
    //do the turn for this amount of time
   delay(400);
}
//go straight for 2 seconds
void GoStraight2000(){
      speed1 = 60;
      speed2 = 60;
      digitalWrite(DIR1pin, HIGH);
      analogWrite(SPEED1pin, speed1);
      digitalWrite(DIR2pin, LOW); //motor has opposite orientation
      analogWrite(SPEED2pin, speed2);
      delay(300);
}
