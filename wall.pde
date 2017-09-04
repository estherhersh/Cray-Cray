import boofcv.processing.*; //<>// //<>// //<>// //<>// //<>// //<>//
import boofcv.struct.image.*;

PImage input;
PImage undistorted;

int wMappedKinect =201;
int hMappedKinect = 201;
int wKinect=512;
int hKinect=424;


public class Wall {
  //corners deff by qudrints as seen by the user
  Corner q1;//topRight;
  Corner q2;//topLeft;
  Corner q3;//bottomLeft;
  Corner q4;//bottomRight;

  ArrayList<CalibrationPoint> calibrationPoints=new ArrayList<CalibrationPoint>();


  float[]refrenceUnscewedDepthScreen= new float[wMappedKinect*hMappedKinect];
  float[]refrenceUnscewedXScreen= new float[wMappedKinect*hMappedKinect];
  float[]refrenceUnscewedYScreen= new float[wMappedKinect*hMappedKinect];
  boolean[]isLockedUnscewedDepthPixels= new boolean[wMappedKinect*hMappedKinect];


  boolean[] lockedPossitions;//lock positions in the physical space
  int[] depthPossitions;//depth positions in the physical space
  boolean[] isCorner;

  double percentageHight;
  double percentageWidth;


  int mappedX;
  int mappedY;


  int calibrationPointRegMaxX=wKinect;//registered image mins and maxs
  int calibrationPointRegMaxY=hKinect;
  int calibrationPointRegMinX=0;
  int calibrationPointRegMinY=0;
  //CalibrationPoint

  public Wall() {
  }

  public void displayOutline() {
    //infoGraphic.beginDraw();
    //infoGraphic.clear();
    //infoGraphic.stroke(255, 0, 0);
    //infoGraphic.line(q1.x, q1.y, q2.x, q2.y);
    //infoGraphic.line(q4.x, q4.y, q3.x, q3.y);
    //infoGraphic.endDraw();
  }


 
  public void setFixedScreens() {
    
    
    for (int i=0; i<calibrationPoints.size(); i++) {
      int xScreen=calibrationPoints.get(i).xScreen;
      int yScreen=calibrationPoints.get(i).yScreen;

      int indexScreen=xScreen+yScreen*wMappedKinect;

      //println(xScreen +","+yScreen+"*"+wMappedKinect +"="+yScreen*wMappedKinect+ " :"+indexScreen);

      isLockedUnscewedDepthPixels[indexScreen]=true;

      refrenceUnscewedDepthScreen[indexScreen]=calibrationPoints.get(i).d;
      refrenceUnscewedXScreen[indexScreen]=calibrationPoints.get(i).x;
      refrenceUnscewedYScreen[indexScreen]=calibrationPoints.get(i).y;
    }

    
    // Fill in the edge points
    println("Converge Depth");
    refrenceUnscewedDepthScreen=setFixedScreen(refrenceUnscewedDepthScreen, 5);
    saveArray(refrenceUnscewedDepthScreen, "depth.txt");
    



    println("Converge X");
    refrenceUnscewedXScreen=setFixedScreen(refrenceUnscewedXScreen, 20);
    saveArray(refrenceUnscewedXScreen, "x.txt");
    
    println("Converge Y");
    refrenceUnscewedYScreen=setFixedScreen(refrenceUnscewedYScreen, 1);
    saveArray(refrenceUnscewedYScreen, "y.txt");
   
    
    output("\n");
    output(Arrays.toString(myWall.refrenceUnscewedDepthScreen));





    //fixedDepthScreen[index]=closeRight.d+closeLeft.d+
  }
  
  
  private float[] setFixedScreen(float[] arrayIn, float converganceThreshhold) {

    float convergenceCheck=1000;
    while (convergenceCheck>.01) {//check convergence edge
      convergenceCheck=0;//reset

      for (int i=1; i<wMappedKinect-1; i++) {//topRow

        int j=0;
        float sumX=0;
        if (!isLockedUnscewedDepthPixels[i+j*wMappedKinect]) {
          for (int k=-1; k<=1; k+=2) {
            sumX+=arrayIn[(i+k)+(j)*wMappedKinect];
          }
          convergenceCheck+=abs(arrayIn[i+j*wMappedKinect]-sumX/2 );

          arrayIn[i+j*wMappedKinect]=sumX/2;
        }
      }
      for (int i=1; i<wMappedKinect-1; i++) {//bottomRow
        int j=hMappedKinect-1;
        float sumX=0;
        if (!isLockedUnscewedDepthPixels[i+j*wMappedKinect]) {
          for (int k=-1; k<=1; k+=2) {
            sumX+=arrayIn[(i+k)+(j)*wMappedKinect];
          }
          convergenceCheck+=abs(arrayIn[i+j*wMappedKinect]-sumX/2 );

          arrayIn[i+j*wMappedKinect]=sumX/2;
        }
      }

      for (int j=1; j<hMappedKinect-1; j++) {//leftSide
        int i=0;
        float sumY=0;
        if (!isLockedUnscewedDepthPixels[i+j*wMappedKinect]) {
          for (int l=-1; l<=1; l+=2) {
            sumY+=arrayIn[(i)+(j+l)*wMappedKinect];
          }
          convergenceCheck+=abs(arrayIn[i+j*wMappedKinect]-sumY/2 );

          arrayIn[i+j*wMappedKinect]=sumY/2;
        }
      }
      for (int j=1; j<hMappedKinect-1; j++) {//rightSide
        int i=wMappedKinect-1;
        float sumY=0;
        if (!isLockedUnscewedDepthPixels[i+j*wMappedKinect]) {
          for (int l=-1; l<=1; l+=2) {
            sumY+=arrayIn[(i)+(j+l)*wMappedKinect];
          }
          convergenceCheck+=abs(arrayIn[i+j*wMappedKinect]-sumY/2 );

          arrayIn[i+j*wMappedKinect]=sumY/2;
        }
      }
      //println(convergenceCheck+"*");
    }

    //if (directionFastConverge==1) {
    //  for (int i=1; i<wMappedKinect-1; i++) {//speedup middle points
    //    for (int j=1; j<hMappedKinect-1; j++) {
    //      arrayIn[i+j*wMappedKinect]=arrayIn[0+j*wMappedKinect]*j/hMappedKinect +arrayIn[(wMappedKinect-1)+j*wMappedKinect]*(hMappedKinect-j)/hMappedKinect;
    //    }
    //  }
    //} else if (directionFastConverge==2) {
    //  for (int j=1; j<hMappedKinect-1; j++) {//speedup middle points
    //    for (int i=1; i<wMappedKinect-1; i++) {
    //      arrayIn[i+j*wMappedKinect]=arrayIn[i+0*wMappedKinect]*i/wMappedKinect +arrayIn[(i)+(hMappedKinect-1)*wMappedKinect]*(wMappedKinect-i)/wMappedKinect;
    //    }
    //  }
    //}

    int numberCyclesMax=100000;
    int numberCycles=0;
    convergenceCheck=100;//middle
    println("Start");
    while (convergenceCheck>converganceThreshhold  && numberCyclesMax>numberCycles) {//check convergence
      numberCycles++;
      convergenceCheck=0;//reset
      for (int i=1; i<wMappedKinect-1; i++) {
        for (int j=1; j<hMappedKinect-1; j++) {
          int index=i+j*wMappedKinect;
          if (!isLockedUnscewedDepthPixels[index]) {
            float sumX=0;
            int countX=0;
            float sumY=0;
            int countY=0;
            for (int k=-1; k<=1; k+=2) {


              sumX+=arrayIn[(i+k)+(j)*wMappedKinect];
              countX++;
            }
            for (int l=-1; l<=1; l+=2) {

              sumY+=arrayIn[(i)+(j+l)*wMappedKinect];
              countY++;
            }

            if (countX==2 && countY==2) {
              float diff=(sumX+sumY)/4 - arrayIn[(i)+(j)*wMappedKinect];
              convergenceCheck+=abs(diff);
              //arrayIn[(i)+(j)*w]=(sumX+sumY)/4;
              arrayIn[(i)+(j)*wMappedKinect]+=diff;
            }
          }
        }
      }
    }



    //for (int j=0; j<wMappedKinect; j++) {
    //  for (int i=0; i<wMappedKinect; i++) {
    //    outputStream.print(arrayIn[i+j*wMappedKinect]+" , ");
    //  }
    //  outputStream.println();
    //}
    //outputStream.println();
    //outputStream.println(" __ ");
    //outputStream.println();

    return arrayIn;
  }

  public void addPoint(int screenPXIn, int screenPYIn, int tipXIn, int tipYIn, int tipDIn) {

    calibrationPoints.add(new CalibrationPoint(screenPXIn, screenPYIn, tipXIn, tipYIn, tipDIn));
  }

  //public void setXYDPossitions(int[] depthsIn) {
  //  setlLockedPossitions();
  //  setCorrnerPossitions();


  //  for (int h=0; h<3; h++) {//avrage number of times
  //    for (int i=0; i<wMappedKinect; i++) {
  //      for (int j=0; j<hMappedKinect; j++) {
  //        int index=i+j*wMappedKinect;
  //        if (!lockedPossitions[index] && !isCorner[index]) {
  //          int sumDepths=0;
  //          int numberPoints=0;
  //          for (int k=-1; k<=1; k++) {
  //            for (int l=-1; l<=1; l++) {
  //              try {//just incase it is an edge
  //                if (!lockedPossitions[(i+k)+(j+l)*wMappedKinect]) {

  //                  sumDepths+=depthsIn[(i+k)+(j+l)*wMappedKinect];
  //                  numberPoints++;
  //                }
  //              }
  //              catch(ArrayIndexOutOfBoundsException name) {
  //              }
  //            }
  //          }

  //          depthsIn[index]=sumDepths/numberPoints;
  //        }
  //      }
  //    }
  //  }
  //  for (int i=0; i<wMappedKinect; i++) {
  //    for (int j=0; j<hMappedKinect; j++) {
  //      int index=i+j*wMappedKinect;
  //      if (!lockedPossitions[index]) {
  //      } else {
  //        depthsIn[index]=-1;
  //      }
  //    }
  //  }

  //  depthPossitions = depthsIn;
  //}

  public void fillInMissingDepths() {
    boolean[] isMissingDepthInfo=new boolean[depthPossitions.length];
    float[] tempDepthsFloat=new float[depthPossitions.length];


    for (int i=0; i<wKinect; i++) {//sets which pixels are misssing data and fills in floating point array
      for (int j=0; j<hKinect; j++) {
        int index=i+j*wKinect;
        if (depthPossitions[index]<=0) {
          isMissingDepthInfo[index]=true;
        }
        tempDepthsFloat[index]=depthPossitions[index];
      }
    }

    float convergence=100;

    while (convergence>1) {
      convergence=0;
      for (int i=1; i<wKinect-1; i++) {//fill in missing depth pixels dont bother with edges
        for (int j=1; j<hKinect-1; j++) {
          int index=i+j*wKinect;
          if (isMissingDepthInfo[index]) {
            float sumPoints=tempDepthsFloat[i-1+j*wKinect]+tempDepthsFloat[i+1+j*wKinect]+tempDepthsFloat[i+(j-1)*wKinect]+tempDepthsFloat[i+(j+1)*wKinect];
            convergence+=abs(tempDepthsFloat[index]-sumPoints/4);
            tempDepthsFloat[index]=sumPoints/4;
          }
        }
      }
      //println(convergence);
    }


    for (int i=0; i<wKinect; i++) {//set depthPossitions
      for (int j=0; j<hKinect; j++) {
        int index=i+j*wKinect;
        if (isMissingDepthInfo[index]) {
          depthPossitions[index]=(floor(tempDepthsFloat[index]));
        }
        //else{
        //  depthPossitions[index]=floor(tempDepthsFloat[index]);
        //}
      }
    }
  }



  public void setlLockedPossitions() {
    lockedPossitions=new boolean[wMappedKinect*hMappedKinect];

    for (int i=0; i<wMappedKinect; i++) {//which points are fixxed and which are avraged
      for (int j=0; j<hMappedKinect; j++) {
        int index=i+j*wMappedKinect;

        double[] mappedPercent=mapPositionToScreen(i, depth(i, j));
        if (mappedPercent[0]>=-0.05  && mappedPercent[1]>=-0.05 ) {//&& mappedPercent[1]<=1.05 && mappedPercent[0]<=1.05) {
          lockedPossitions[index]=false;
        } else {
          lockedPossitions[index]=true;
        }
      }
    }
  }



  //************************************************************************************************************************************
  //public float[] getClosestPosition(int xIn, int depthIn) {
  //  float[] xClosestValue=new float[hMappedKinect];//holds all the closest x Positions in a row
  //  int[] xClosestPossition=new int[hMappedKinect];

  //  for (int j=0; j<hMappedKinect; j++) {//cycle through rows
  //    xClosestValue[j]=999999;
  //    for (int i=0; i<wMappedKinect; i++) {//cycle through columbs
  //      if (abs(xClosestValue[j]-xIn)>abs(refrenceUnscewedXScreen[i+j*wMappedKinect]-xIn)) { 
  //        xClosestValue[j]=refrenceUnscewedXScreen[i+j*wMappedKinect];
  //        xClosestPossition[j]=i;//position of closest X value in this row
  //      }
  //    }
  //  }
  
  public PVector getClosestPosition(int xIn, int depthIn) {
    float[] xClosestValue=new float[hMappedKinect];//holds all the closest x Positions in a row
    int[] xClosestPossition=new int[hMappedKinect];

    for (int j=0; j<hMappedKinect; j++) {//cycle through rows
      xClosestValue[j]=999999;
      for (int i=0; i<wMappedKinect; i++) {//cycle through columbs
        if (abs(xClosestValue[j]-xIn)>abs(refrenceUnscewedXScreen[i+j*wMappedKinect]-xIn)) { 
          xClosestValue[j]=refrenceUnscewedXScreen[i+j*wMappedKinect];
          xClosestPossition[j]=i;//position of closest X value in this row
        }
      }
    }


    float dClosestValue=99999;
    int dClosestPossition=0;

    for (int j=0; j<hMappedKinect; j++) {//cycle through rows
      if (abs(dClosestValue-depthIn)>abs(refrenceUnscewedDepthScreen[xClosestPossition[j]+j*wMappedKinect]-depthIn)) {
        dClosestValue=refrenceUnscewedDepthScreen[xClosestPossition[j]+j*wMappedKinect];
        dClosestPossition=j;
      }
    }

    //println("-"+xClosestPossition[dClosestPossition]);
    float closestMappedPercentX=(float)xClosestPossition[dClosestPossition]/(float)wMappedKinect;
    float closestMappedPercentY=(float)dClosestPossition/(float)hMappedKinect;

    // println(closestMappedPercentX);

    //float[] mappedPercent={1-closestMappedPercentX, closestMappedPercentY};

    //return new PVector(1-closestMappedPercentX, closestMappedPercentY);
    return new PVector(closestMappedPercentX, closestMappedPercentY);
  }


  public void setCorrnerPossitions() {
    isCorner=new boolean[wMappedKinect*hMappedKinect];

    //corners
    isCorner[q1.x+wMappedKinect*q1.y]=true;
    isCorner[q4.x+wMappedKinect*q4.y]=true;
    isCorner[q2.x+wMappedKinect*q2.y]=true;
    isCorner[q3.x+wMappedKinect*q3.y]=true;
  }

  public int[] smoothDepthFromCornerPoints(int[] depthsIn) {

    int numberChangedPoints=1;
    while (numberChangedPoints>0) {//check convergence
      numberChangedPoints=0;//reset
      for (int i=0; i<wMappedKinect; i++) {
        for (int j=0; j<hMappedKinect; j++) {
          int index=i+j*wMappedKinect;
          if (!lockedPossitions[index] && !isCorner[index]) {
            int sumDepths=0;
            int numberPoints=0;
            for (int k=-1; k<=1; k++) {
              for (int l=-1; l<=1; l++) {
                try {//just incase it is an edge
                  if (!lockedPossitions[(i+k)+(j+l)*wMappedKinect]) {

                    sumDepths+=depthsIn[(i+k)+(j+l)*wMappedKinect];
                    numberPoints++;
                  }
                }
                catch(ArrayIndexOutOfBoundsException name) {
                }
              }
            }
            numberChangedPoints+=depthsIn[index]-sumDepths/numberPoints;
            depthsIn[index]=sumDepths/numberPoints;
          }
        }
      }
    }


    for (int i=0; i<wMappedKinect; i++) {
      for (int j=0; j<hMappedKinect; j++) {
        int index=i+j*wMappedKinect;
        if (!lockedPossitions[index]) {
        } else {
          depthsIn[index]=-1;
        }
      }
    }

    //for (int i=0; i<w; i++) {
    //  for (int j=0; j<h; j++) {
    //    if (lockedPossitions[i+w*j]) {
    //      registeredImage.pixels[i+w*j]=color(255, 0, 0);
    //    }
    //  int}
    //}
    //registeredImage.updatePixels();

    return depthsIn;
  }

  //public int getClosestY(int xIn, int depthIn) {
  //  int depthDiff=9999;
  //  int yOut=0;
  //  for(int j=0; j<h;j++){
  //    if(depthDiff>abs(depthPossitions[xIn+w*j]-depthIn)){
  //      depthDiff=depthPossitions[xIn+w*j];
  //      yOut=j;
  //    }
  //  }
  //  return yOut;
  //}

  public double[] mapPositionToScreen(int xIn, int depthIn) {

    percentageHight=getMappedPercent(xIn, depthIn, q3, q2, q4, q1);
    percentageWidth=getMappedPercent(xIn, depthIn, q2, q1, q3, q4);


    double[] mappedPoints={percentageWidth, percentageHight};
    return mappedPoints;
  }

  private int getYOnScreen(double percentWidthIn, double percentHeightIn ) {

    double wieghtedY1=q2.y+(q1.y-q2.y)*(percentWidthIn);
    double wieghtedY2=q3.y+(q4.y-q3.y)*(percentWidthIn);

    double yOut=wieghtedY1+(wieghtedY2-wieghtedY1)*(1-percentHeightIn);
    //double leftPointY=q3.y+(q2.y-q3.y)*(percentHeightIn);


    //double rightPointY=q4.y+(q1.y-q4.y)*(percentHeightIn);

    //double yOut=leftPointY+(rightPointY-leftPointY)*(1-percentWidthIn);

    //return (int)yOut;

    return (int)yOut;
  }


  //c1 to c2 make first line
  //c3 to c4 make second line
  //xIn and yIn define the point
  private double getMappedPercent(int xIn, int dIn, Corner c1, Corner c2, Corner c3, Corner c4) {  

    double A=((c1.d-c2.d)*(c4.x-c3.x-c2.x+c1.x)-(c4.d-c3.d-c2.d+c1.d)*(c1.x-c2.x));   //t^2 quadratic vareables

    double B=((c1.d-c2.d)*(c3.x-c1.x)+(dIn-c1.d)*(c4.x-c3.x-c2.x+c1.x)-((c4.d-c3.d-c2.d+c1.d)*(xIn-c1.x)+(c1.x-c2.x)*(c3.d-c1.d)));
    double C=(dIn -c1.d)*(c3.x-c1.x)-(c3.d-c1.d)*(xIn-c1.x);

    double[] roots=quadraticEquationRoot(A, B, C);

    for (int i=0; i<roots.length; i++) {
      if (roots[i]>-.1 && roots[i]<1.1) {
        return roots[i];
      }
    }
    return -1;//point was not on screen
  }



  private  double[] quadraticEquationRoot(double a, double b, double c) {    
    double[] roots=new double[2]; //This is now a double, too.
    roots[0] = (-b + Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);
    roots[1] = (-b - Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);

    return roots;
  }



  public void setCornerFR(int xIn, int yIn, int dIn) {
    q1=new Corner(xIn, yIn, dIn);
  }
  public void setCornerFL(int xIn, int yIn, int dIn) {
    q2=new Corner(xIn, yIn, dIn);
  }
  public void setCornerCR(int xIn, int yIn, int dIn) {
    q4=new Corner(xIn, yIn, dIn);
  }
  public void setCornerCL(int xIn, int yIn, int dIn) {
    q3=new Corner(xIn, yIn, dIn);
  }


  public void setMinMaxScreen() {
    for(int i=0;i<calibrationPoints.size();i++){
    if (calibrationPointRegMaxX<calibrationPoints.get(i).xScreen) {
      calibrationPointRegMaxX=calibrationPoints.get(i).xScreen;
    }
    if (calibrationPointRegMaxY<calibrationPoints.get(i).yScreen) {
      calibrationPointRegMaxY=calibrationPoints.get(i).yScreen;
    }

    if (calibrationPointRegMinX>calibrationPoints.get(i).xScreen) {
      calibrationPointRegMinX=calibrationPoints.get(i).xScreen;
    }
    if (calibrationPointRegMinY>calibrationPoints.get(i).yScreen) {
      calibrationPointRegMinY=calibrationPoints.get(i).yScreen;
    }
  }
  }
}



//________________corner object
public class Corner {

  public int x;
  public int y;
  public int d;
  //public int indexCorner;

  public Corner(int xIn, int yIn, int dIn) {
    x=xIn;
    y=yIn;
    d=dIn;

    //print(mouseX*wKinect/width+":"+ mouseY*hKinect/height+":"+ depth(mouseX*wKinect/width, mouseY*hKinect/height));

    println(x+" , "+y+" , "+d);
  }
}

public class CalibrationPoint {

  public int x;
  public int y;
  public int d;

  public int xScreen;
  public int yScreen;


  //public int indexCorner;

  public CalibrationPoint(int xInScreen, int yInScreen, int xTipIn, int yTipIn, int dTipIn) {
    x=xTipIn;
    y=yTipIn;
    d=dTipIn;

    xScreen=xInScreen;
    yScreen=yInScreen;

    //println(xScreen +" , "+ yScreen+":"+x+" , "+y+" , "+d);

    
  }
}

int depth(int indexIn) {
  try{
  return depthImgScaled.pixels[indexIn];
  }
  catch(IndexOutOfBoundsException e){
    return 0;
  }
}

int depth(int xIn, int yIn) {
  return depth(xIn+yIn*kinect2.depthWidth);
}