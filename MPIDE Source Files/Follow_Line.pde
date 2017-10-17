/*Use proximity sensor readings to follow a black line on a
white surface. The vehicle will follow the line and turn when
necessary
Proximity Sensors: Black Line = LOW (0)
                   White Line = HIGH  (1) */

//Setting up pins with easy to read constant names//
//Motor 1 (LEFT MOTOR if looking forward)
const int DIR1pin = A4;
const int SPEED1pin = 9;
//Motor 2 (RIGHT MOTOR)
//Right motor oriented in opposite way (i.e. a value of HIGH
//will make it go backwards and LOW will make it go forwards)
const int DIR2pin = A0;
const int SPEED2pin = 6; 
//IR Proximity sensors in front of vehicle.
//ORIENTATION (If looking forward in relation to vehicle):
//  |SNSR 1|      |SNSR 2|      |SNSR 3|       |SNSR 4|
const int Prox1pin = 42;
const int Prox2pin = 41;
const int Prox3pin = 3;
const int Prox4pin = 5;
//variables for holding the reading of the proximity pins
int Sensor1Reading;
int Sensor2Reading;
int Sensor3Reading;
int Sensor4Reading;
//speed variables
int speed1;
int speed2;
//boolean variables for seeing if we are too far right or too far left
//they are both initially false
boolean TooFarRight = false;
boolean TooFarLeft = false;
//are we turning to adjust getting back on the line? Initially, no.
boolean Turning = false;

void setup(){
 //setting up appropriate inputs and outputs
  pinMode(DIR1pin, OUTPUT);
  pinMode(SPEED1pin, OUTPUT);
  pinMode(DIR2pin, OUTPUT);
  pinMode(SPEED2pin, OUTPUT);
  pinMode(Prox1pin, INPUT);
  pinMode(Prox2pin, INPUT);
  pinMode(Prox3pin, INPUT);
  pinMode(Prox4pin, INPUT);
  
}
void loop(){
  //collect the current reading of each of the 4 proximity sensors
  Sensor1Reading = digitalRead(Prox1pin);
  Sensor2Reading = digitalRead(Prox2pin);
  Sensor3Reading = digitalRead(Prox3pin);
  Sensor4Reading = digitalRead(Prox4pin);
  //**We are assuming that the line can only be sensed by 1 sensor at a time.**
  //**Start the vehicle so that it is in the middle of the line.**
  
  //NO PROBLEMS
  //Go in a straight line if we are not too far left or too far right.
  //Also make sure we are not turning
  if(TooFarRight == false && TooFarLeft == false && Turning == false){
    ContinueStraight();
  }
  
  //TOO FAR RIGHT 
  //If we were initially on the line and then get too far right of the line
  if(Sensor2Reading == 0 && TooFarRight == false && TooFarLeft == false){
    TurnLeftLess(); //turn left a mediocre amount to correct and go back to the line
    TooFarRight = true; //say that we are too far right of the line
    Turning = true; //yes, we are turning
  }
  //If we get way far right of the line, turn even more
  if(Sensor1Reading == 0 && TooFarLeft == false){
    TurnLeftMost();
    Turning = true; //we are still turning
  }
  //We should now be turning back towards the line (going left).
  //Once we get back onto the line, sensor 3 (or 4 if it misses) will be activated, and we will adjust to turn right 
  //in order to be perfectly on the line
  if((Sensor3Reading == 0 || Sensor4Reading == 0) && TooFarRight == true){
    //***FOR TURNING RIGHT THE LEAST, WE MUST STAY ON OR NEAR THE LINE OR EVERYTHING WILL GET MESSED UP***//
    TurnRightLeast(); //make a slight adjustment to get back to straddling the line
    Turning = false; //say that we are not turning anymore - we are now just making a quick adjustment
  }
  //if all the sensor readings are 1, we can say we are back on the line and then set
  //the variable TooFarRight to false. This will cause the car to continue straight.
  if(TooFarRight == true && Turning == false && Sensor1Reading == 1 && Sensor2Reading == 1 && Sensor3Reading == 1 && Sensor4Reading == 1){
    TooFarRight = false; //we will now go back to going straight like normal
    ContinueStraight();
  }
  
  //TOO FAR LEFT
  //If we were initially on the line and then get too far left of the line
  if(Sensor3Reading == 0 && TooFarLeft == false && TooFarRight == false){
    TurnRightLess(); //turn left a mediocre amount to correct and go back to the line
    TooFarLeft = true; //say that we are too far right of the line
    Turning = true; //yes, we are turning
  }
  //If we get way far left of the line, turn even more
  if(Sensor4Reading == 0 && TooFarRight == false){
    TurnRightMost();
    Turning = true; //we are still turning
  }
  //We should now be turning back towards the line (going right).
  //Once we get back onto the line, sensor 2 (or 1 if it misses) will be activated, and we will adjust to turn left
  //in order to be perfectly on the line
  if((Sensor2Reading == 0 || Sensor1Reading == 0) && TooFarLeft == true){
    //***FOR TURNING RIGHT THE LEAST, WE MUST STAY ON OR NEAR THE LINE OR EVERYTHING WILL GET MESSED UP***//
    TurnLeftLeast(); //make a slight adjustment to get back to straddling the line
    Turning = false; //say that we are not turning anymore - we are now just making a quick adjustment
  }
  //if all the sensor readings are 1, we can say we are back on the line and then set
  //the variable TooFarRight to false. This will cause the car to continue straight.
  if(TooFarLeft == true && Turning == false && Sensor1Reading == 1 && Sensor2Reading == 1 && Sensor3Reading == 1 && Sensor4Reading == 1){
    TooFarLeft = false;
    ContinueStraight();
  }

   
}

//FUNCTIONS
void ContinueStraight(){
  //go straight at a fairly slow speed
  speed1 = 50;
  speed2 = 50;
  digitalWrite(DIR1pin, HIGH);
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, LOW); //motor has opposite orientation
  analogWrite(SPEED2pin, speed2);
}
void TurnLeftMost(){
  //turn approx. 45*
  speed1 = 50;
  speed2 = 175;
  digitalWrite(DIR1pin, LOW); //left wheel goes backwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, LOW); //right wheel goes forward
  analogWrite(SPEED2pin, speed2);
}
void TurnLeftLess(){
  //turn approx. 25*
  speed1 = 35;
  speed2 = 175;
  digitalWrite(DIR1pin, LOW); //left wheel goes backwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, LOW); //right wheel goes forward
  analogWrite(SPEED2pin, speed2);
}
void TurnLeftLeast(){
  //turn approx. 15*
  speed1 = 20;
  speed2 = 175;
  digitalWrite(DIR1pin, LOW); //left wheel goes backwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, LOW); //right wheel goes forward
  analogWrite(SPEED2pin, speed2);
}
void TurnRightMost(){
  //turn approx. 45*
  speed1 = 160;
  speed2 = 50;
  digitalWrite(DIR1pin, HIGH); //left wheel goes forwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, HIGH); //right wheel going backwards
  analogWrite(SPEED2pin, speed2);
}
void TurnRightLess(){
  //turn approx. 25*
  speed1 = 160;
  speed2 = 40;
  digitalWrite(DIR1pin, HIGH); //left wheel goes forwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, HIGH); //right wheel going backwards
  analogWrite(SPEED2pin, speed2);
}
void TurnRightLeast(){
  //turn approx. 15*
  speed1 = 160;
  speed2 = 25;
  digitalWrite(DIR1pin, HIGH); //left wheel goes forwards
  analogWrite(SPEED1pin, speed1);
  digitalWrite(DIR2pin, HIGH); //right wheel going backwards
  analogWrite(SPEED2pin, speed2);
}
