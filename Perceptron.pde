int sizeX; //Remember to change size command too!
int sizeY;
int n;
float lr;
double[] rules;
int[][] unlabeledData;
int[][] trainingData;
double[] ourModel;
double[] untrainedModel;
boolean notDone2;
boolean doneForReal;
int index;
int numTimesThrough;

void setup(){
  background(255, 255, 255);
  size(600,600);
  sizeX = 600;
  sizeY = 600;
  n = 200;
  lr = 0.05;
  rules = makeModel();
  unlabeledData = makeData(n);
  trainingData = classify(unlabeledData, rules);
  ourModel = makeModel();
  untrainedModel = new double[ourModel.length];
  for (int i=0; i<ourModel.length; i++){
    untrainedModel[i] = ourModel[i];
  }
  notDone2 = true;
  doneForReal = false;
  index = 0;
  numTimesThrough = 0;
  drawLine(rules, 0);
  drawData(trainingData, true);
  drawLine(untrainedModel, 2);
}

void draw(){
  
  //trains one step and draws it
  int[] point = trainingData[index];
  if (trainOneStep(point, ourModel, lr)){
    notDone2 = true;
  }
  
  //Draws for every few steps
  /*if (index%1 == 0){
    background(255, 255, 255);
    drawLine(rules, 0);
    drawData(trainingData, true);
    drawLine(untrainedModel, 2);
    drawLine(ourModel, 3);
  }*/
  
  //Loops appropriately
  index++;
  if (index >= n){
    if (!notDone2){
      doneForReal = true;
    }
    index = 0;
    notDone2 = false;
    numTimesThrough++;
    print("Hi");
  }
  if (numTimesThrough >= 50){
    doneForReal = true;
  }
  if (doneForReal){
    noLoop();
    print(numTimesThrough);
    background(255, 255, 255);
    drawLine(rules, 0);
    drawData(trainingData, true);
    drawLine(untrainedModel, 2);
    drawLine(ourModel, 3);
  }
}

//Trains the model
void train(double[] model, int[][] trData, float lr){
  //print("At start, model[0] is " + model[0] + ", model[1] is " + model[1] + ", model[2] is " + model[2] + "\n");
  boolean notDone = true;
  int n = 0;
  while(notDone&&(n<500)){
    notDone = false;
    for (int i=0; i<trData.length; i++){
      int[] point = trData[i];
      if (trainOneStep(point, model, lr)){
        notDone = true;
      }
    }
    n++;
    //print("model[0] is " + model[0] + ", model[1] is " + model[1] + ", model[2] is " + model[2] + "\n");
    drawLine(model, 1);
  }
  print(n);
}

//Performs the basic step of training
boolean trainOneStep(int[] point, double[] model, float lr){
  boolean result = testPoint(point, model);
  int iResult = result ? 1 : 0;
  int diff = point[2] - iResult;
  model[0] = model[0] + lr*diff*point[0];
  model[1] = model[1] + lr*diff*point[1];
  model[2] = model[2] + lr*diff;
  return (diff != 0);
}

//Classifies data, returning new array that is the same as the old with one more dimension for each point for the class
int[][] classify(int[][] data, double[]rules){
  int[][] labeledData = new int[data.length][3];
  for (int i=0; i<data.length; i++){
    labeledData[i][0] = data[i][0];
    labeledData[i][1] = data[i][1];
    if (testPoint(data[i], rules)){
      labeledData[i][2] = 1; //blue
    }else{
      labeledData[i][2] = 0; //red
    }
  }
  return labeledData;
}

boolean testPoint(int[] point, double[] rules){
  return (point[0]*rules[0] + point[1]*rules[1] + rules[2] > 0);
}

//Makes the model such that the clasifier line is on the screen and not too steep: 150<=y-intercept<=450, -4<=m<=4
double[] makeModel(){
  double ruleY = 0;
  while (ruleY==0){
    ruleY = Math.random()*4000-2000;
  }
  double ruleB = -((Math.random()*300)+150)*ruleY; //y-intercept = -ruleB/ruleY
  double ruleX = 0;
  while (ruleX ==0){
    ruleX = -(Math.random()*4-2)*ruleY; //m = -goalX/goalY
  }
  double[] model = {ruleX, ruleY, ruleB};
  return model;
}

//Makes the data in an nx2 array, with the 1st value being the x value and the 2nd value being the y value for each point
int[][] makeData(int n){
  int[][] data = new int[n][2];
  for (int[] point : data){
    point[0] = (int)(Math.random()*sizeX);
    point[1] = (int)(Math.random()*sizeY);
  }
  return data;
}

//Draws a line with the given rules, differently for goals and learned classifier
void drawLine(double[] rules, int c){
  color dGreen = color(0, 120, 0);
  color white = color(255, 255, 255);
  color yellow = color(255, 255, 0);
  color dMagenta = color(160, 0, 160);
  if (c==0){
    stroke(dGreen);
  } else if(c==1){
    stroke(white);
  } else if(c==2){
    stroke(yellow);
  } else if(c==3){
    stroke(dMagenta);
  }
  //y = -(r_x)/(r_y)*X - (r_b)/(r_y)
  line(0, (float)(-rules[2]/rules[1]), sizeX, (float)(-rules[0]/rules[1]*sizeX-rules[2]/rules[1]));
}

//Takes labelled data and draws it, darker if it is training and lighter if is is testing
void drawData(int[][] data, boolean train){
  for (int[] point : data){
    color dRed = color(160, 0, 0);
    color dBlue = color(0, 50, 160);
    color red = color(255, 0, 0);
    color blue = color(0, 0, 255);
    color yellow = color(255, 255, 0);
    noStroke();
    if ((point[2] == 0)&&train){
      fill(dRed);    //Class 1 training data is dark red
    } else if ((point[2] == 1)&&train){
      fill(dBlue);   //Class 0 training data is dark blue
    } else{
      fill(yellow);
    }
    ellipse(point[0], point[1], 3, 3);
  }
}
