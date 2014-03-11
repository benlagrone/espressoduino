//define analog inputs
int fillSensor = A0;
int tempSensor = A1;
int pressureSensor = A2;
int onSwitch = A3;
int groupSwitch = A4;

//define digital outputs 
int pumpRelay = 9;
int valveRelay = 8;
int heaterRelay = 7;
//on indicator
int heatOnLight = 10;
//ready indicator
int readyLight = 11;



//varables to store fill, temp, active status
int fill_val;
int fill_min = 1010;
int pressureStat_val;
int pressureStat_min = 50;
int temp_val;
int temp_min = 20;
int activeStatus_val;
int activeStatus_min = 50;
int groupStatus_val;
int groupStatus_min = 50;
int maxHeat = 100;
int pressureMax = 1;
int maxWait = 360;

//Machine modes
int machineOnState;
int boilerFillState;

int machineAction;

void setup(){
  Serial.begin(9600);
  //set the out relays: pump, valve, heater, and other outputs as output and LOW
  pinMode(fillSensor, INPUT);
  pinMode(onSwitch, INPUT);
  pinMode(pressureSensor, INPUT);
  pinMode(tempSensor, INPUT);
  pinMode(groupSwitch, INPUT);
  
  pinMode(pumpRelay, OUTPUT);
  pinMode(valveRelay, OUTPUT);
  pinMode(heaterRelay, OUTPUT);
  pinMode(heatOnLight, OUTPUT);
  pinMode(readyLight, OUTPUT);
  
  digitalWrite(pumpRelay, LOW);
  digitalWrite(valveRelay, LOW);
  digitalWrite(heaterRelay, LOW);
  digitalWrite(heatOnLight, LOW);
  digitalWrite(readyLight, LOW);
}

void loop(){
  machineOnState = machineOn_function();
  if (machineOnState > 0){
  boilerFillState = boilerFillCheck_function(machineOnState);
  heaterElementCommand_function(boilerFillState);
  toggleGroup_function();
  } else {
  all_off();
  };
  seriesTest();
  delay(30);
};

/*** Function Area ***/

int all_off(){
  digitalWrite(pumpRelay, LOW);
  digitalWrite(valveRelay, LOW);
  digitalWrite(heaterRelay, LOW);
}

int seriesTest(){
  activeStatus_val = analogRead(onSwitch);
  fill_val = analogRead(fillSensor);
  pressureStat_val = analogRead(pressureSensor);
  temp_val = analogRead(tempSensor);
  groupStatus_val = analogRead(groupSwitch);
  
  Serial.print("on switch value: ");
  Serial.println(activeStatus_val);
  Serial.print("moisture level: ");
  Serial.println(fill_val);
  Serial.print("pressure value: ");
  Serial.println(pressureStat_val);
  Serial.print("temp value: ");
  Serial.println(temp_val);
  Serial.print("groupSwitch: ");
  Serial.println(groupStatus_val);
  Serial.println(" ");
  Serial.println(" ");
  Serial.println(" ");
  Serial.println(" ");
  Serial.println(" ");
};

int machineOn_function(){
  activeStatus_val = analogRead(onSwitch);
  //int theValue;
  if (activeStatus_val > activeStatus_min){
    return 1;
  } else {
    return 0;
  };
};

int boilerFillCheck_function(int machineOnState){
  Serial.println("machineOnState: ");
  Serial.println(machineOnState);
  if (machineOnState > 0){
    fill_val = analogRead(fillSensor);
    if (fill_val > fill_min){// min = 1010 if above min, it is dry
      return 0;
    } else {
      return 1;
    }
  }
};

int heaterElementCommand_function(int boilerFillState){//expects low or high
  Serial.println("boilerFillState: ");
  Serial.println(boilerFillState);
  if (boilerFillState < 1){
    Serial.println("***** DRY!!   *****");
    toggleHeatingElement_function(0);//0 for off
    waterValve_function(12);//0 is for boiler
    togglePump_function(1);//1 is on
  } else {
    Serial.println("@@@@@  wet   @@@@");
    if (pressureStat_val > pressureStat_min && temp_val > temp_min){
    toggleHeatingElement_function(1);//turn it on
    } else {
    toggleHeatingElement_function(0);//turn off
    }
    waterValve_function(0);//1 is for group
    if (groupStatus_val < groupStatus_min){
    togglePump_function(0);//0 is off
    }
  }
};

int togglePump_function(int state){
  if (state > 0){
  digitalWrite(pumpRelay, HIGH);
    Serial.println("pump on");
  } else {
  digitalWrite(pumpRelay, LOW);
    Serial.println("pump off");
  }
};

int waterValve_function(int direction){
  if (direction < 1){
    digitalWrite(valveRelay, LOW);
    Serial.println("valve direction: boiler");
  } else {
    digitalWrite(valveRelay, HIGH);
    Serial.println("valve direction: group");
  }
};

int toggleHeatingElement_function(int state){
    Serial.println("heater element:");
    Serial.println(state);
  if (state > 0){//0 is off
    fill_val = analogRead(fillSensor);
    if (fill_val < fill_min){//if there is water
      pressureStat_val = analogRead(pressureSensor);
      temp_val = analogRead(tempSensor);
      if (pressureStat_val > pressureStat_min && temp_val > temp_min){
      digitalWrite(heaterRelay, HIGH);
      Serial.println("heater element on");
      }
    } else {//if there is no water
      digitalWrite(heaterRelay, LOW);
      Serial.println("heater element off");
    }
  } else if (state < 1){
    Serial.println("heater element off");
    digitalWrite(heaterRelay, LOW);
  }
};

int toggleGroup_function(){
  groupStatus_val = analogRead(groupSwitch);
  if (groupStatus_val > groupStatus_min){
    togglePump_function(1);//1 is on
    //waterValve_function(1);
  } else {
    
    //togglePump_function(0);//0 is off
    //waterValve_function(0);
  };
  
};


