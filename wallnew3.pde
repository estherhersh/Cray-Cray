// Daniel Shiffman
// Depth thresholding example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

// Original example by Elie Zananiri
// http://www.silentlycrashing.net
import java.io.FileNotFoundException;
//package com.tutorialspoint;
import java.util.Arrays;


import org.openkinect.freenect.*;
import org.openkinect.processing.*;


import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;

//import processing.core.*;
import org.opencv.core.Mat;

Kinect2 kinect2;

OpenCV maskOpenCV;

// Depth image
PImage threshholdImg;
PImage depthImgScaled;
//PImage depthImg
PImage registeredImg;

PImage futhestDepth;



// Which pixels do we care about?
int minDepth =  400;
int maxDepth =  2500; //4.5m

// What is the kinect's angle
float angle;

boolean calibration=true;

int calibrationPhase=0;

int deltaDepth=10;
int tipDepth=7;

PImage dst;
ArrayList<Contour> contours;
ArrayList<PImage> contourImages;
ArrayList<PImage> depthImages;

Screen myScreen;


PApplet parent;

Tips tips;

//calibration stuff
int numCalibrationPointsW = 3;
int numCalibrationPointsH = 3;
int numCalibrationPoints = numCalibrationPointsW * numCalibrationPointsH;
//int[][] calibrationPoints;



PGraphics calibrationGraphic;

//int leftCrop, rightCrop;

Wall myWall;
int calibrationCount=0;
int calibrationCountW=0;// which point is being calibrated
int calibrationCountH=0;

String fileName="log2.txt";
PrintWriter outputStream;

int tipDistanceThreshold=15;

//this is for cropping kinect image
int tipFocuseAreaTop=150;
int tipFocuseAreaBottom =270;




int offsetTop=280;
int offsetBottom=70;

int leftCrop, rightCrop;

int resizeFactor = 1;

boolean showColoringBook=false;

void setup() {
  parent = this;
  //size(1920, 1080);
  //size(900, 700);
  fullScreen(2);
  
  leftCrop=1010;
  rightCrop=width-510;
  
  String fileName="log2.txt";
  try {
    outputStream = new PrintWriter(fileName);
  }
  catch(FileNotFoundException e) {
    e.printStackTrace();
  }
  

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initRegistered();
  kinect2.initDevice(0);
  
  

  // Blank image
  threshholdImg = new PImage(kinect2.depthWidth/resizeFactor, (tipFocuseAreaBottom - tipFocuseAreaTop)/resizeFactor);
  //futhestDepth = new PImage(kinect2.depthWidth, tipFocuseAreaBottom - tipFocuseAreaTop);
  
  //registeredImageTestingPerposs = new OpenCV(this, 512, 424);
  maskOpenCV = new OpenCV(this, 512/resizeFactor, (tipFocuseAreaBottom - tipFocuseAreaTop)/resizeFactor);
  //registeredImageRemoveBackground.startBackgroundSubtraction(50, 3, 0.1);
  
  delay(2000);
 
  
  futhestDepth = kinect2.getDepthImage().get(0, tipFocuseAreaTop, 512,tipFocuseAreaBottom-tipFocuseAreaTop);
  futhestDepth.resize(futhestDepth.width/resizeFactor,0);
  contourImages  = new ArrayList<PImage>();
  
  
  
  
  //calibrationPoints=new int[numCalibrationPointsW*numCalibrationPointsH][2];
  
  calibrationGraphic=createGraphics(width, height);
  calibrationGraphic.beginDraw();
  calibrationGraphic.endDraw();
  
  myWall=new Wall();
  
  
  tips = new Tips();
  
  //rightCrop=10;
  //leftCrop=width-10;
  
}

void draw() {
  background(0);
  //scale(.5);
  // Draw the raw image
  contourImages.clear();
  
  registeredImg = kinect2.getRegisteredImage().get(0, tipFocuseAreaTop, 512,tipFocuseAreaBottom-tipFocuseAreaTop);
  registeredImg.resize(registeredImg.width/resizeFactor,0);
  depthImgScaled = kinect2.getDepthImage().get(0, tipFocuseAreaTop, 512,tipFocuseAreaBottom-tipFocuseAreaTop);
  depthImgScaled.resize(depthImgScaled.width/resizeFactor,0);
  
  registeredImg.loadPixels();
  depthImgScaled.loadPixels();
  //image(kinect2.getDepthImage(), 0, 0);
  
  //println(depthImg.height);
  if(calibrationPhase>1){
    registeredImg = getMovingDepth(depthImgScaled,futhestDepth, registeredImg);
  }
  
  
  
  
  int[] rawDepth = kinect2.getRawDepth();
  
  rawDepth = Arrays.copyOfRange(rawDepth, tipFocuseAreaTop*512, tipFocuseAreaBottom*512);
  
  
  for (int i=0; i < threshholdImg.pixels.length; i++) {
    if (rawDepth[i*resizeFactor] >= minDepth && rawDepth[i*resizeFactor] <= maxDepth && brightness(registeredImg.pixels[i])>10) {
      threshholdImg.pixels[i] = color(255);
    } else {
      threshholdImg.pixels[i] = color(0);
    }
  }
  

  maskOpenCV.loadImage(threshholdImg);
  
  contours = maskOpenCV.findContours(false, true);
  
  contourImages = getImagesInContours(contours, registeredImg, 3);
  depthImages = getImagesInContours(contours, depthImgScaled, 3);
  
  
  //for(int i =0 ; i< contourImages.size();i++){
  //  image(contourImages.get(i),512*3,424*i);
  //}
  
  
  tips.update(contours, contourImages, depthImages);
  //displayContours(contours, contourImages);
  
  

  // Draw the thresholded image
  threshholdImg.updatePixels();
  
  //println("# images " + contourImages.size());
  //rect(kinect2.depthWidth,0,kinect2.depthWidth,kinect2.depthHeight);
  //for(PImage contourImage : contourImages){
    //image(contourImage,kinect2.depthWidth, 0);
  //}
  //image(threshholdImg, kinect2.depthWidth, 0);
  
  
  
  
  if(calibration){
    calbration();
    image(registeredImg,0,registeredImg.height*4);
    
    tips.display();
  }else{
    tips.drawLines();
    
    //myScreen.addLine(0,0,.8,.8,color(255,0,0));
    myScreen.display();
    //if(millis()%100<1){    println("drawing lines??");  }
    //for(int i =0;i<tips.holdoverTips.size();i++){
    //  tips.drawLines();
      
    //  //if(tips.tipsList.get(i).myColor.equals("Blue")){
        
    //  //  if(tips.tipsList.get(i).isOnWall()){
    //  //    fill(0,0,255);
    //  //    if(millis()%100<3){
    //  //      println("is on wall");
    //  //    }
    //  //  }else{
    //  //    //fill(0,0,255,.5);
    //  //    fill(255,0,0);
    //  //    if(millis()%100<3){
    //  //      println("is not wall !!!");
    //  //    }
    //  //  }
    //  //  PVector mappedPercentTip=myWall.getClosestPosition((int)tips.tipsList.get(i).position.x, tips.tipsList.get(i).depth);
        
    //  //  //myScreen(
        
    //  //  ellipse(mappedPercentTip.x*width,mappedPercentTip.y*height,20,20);
        
    //  //}
    //}
  }
  

  fill(255);
  textSize(25);
  text("FrameRate: " + frameRate, 10, 30);
  //text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
  
  fill(255,0,0);

  
}









void output(float[] array, int widthArray){
  String row = "";
  for(int i=0;i<array.length;i++){
    if(i%widthArray == 0){
      row.concat("\n");
      row="";
    }
    
    
    row.concat(String.valueOf(array[i]));
    row.concat("\t");
    
    
    
  }
}
void output(String text){
  outputStream.append(text);
  outputStream.flush();
}

void setNextCalibrationPoint(){
  if(tips.holdoverTips.size()>0 && tips.holdoverTips.get(0).myColor == color(0,0,255)){
      
      //output(" /n ");
      println((wMappedKinect-1)*calibrationCountW/(numCalibrationPointsW-1) + " : "  +
      (hMappedKinect-1)*calibrationCountH/(numCalibrationPointsH-1) + " : " + 
      (int)tips.holdoverTips.get(0).position.x + " : " + 
      (int)tips.holdoverTips.get(0).position.y + " : " + 
      tips.holdoverTips.get(0).position.z);
      
      //output(" /n ");
      
      
      //??? why am are these cast to int ?
      myWall.addPoint((wMappedKinect-1)*calibrationCountW/(numCalibrationPointsW-1), 
      (hMappedKinect-1)*calibrationCountH/(numCalibrationPointsH-1), 
      (int)tips.holdoverTips.get(0).position.x, 
      (int)tips.holdoverTips.get(0).position.y, 
      (int)tips.holdoverTips.get(0).position.z);
      
      // why is it minus 1 ???
      if(calibrationCount<numCalibrationPoints-1){
        calibrationCount++;
        calibrationCountW = calibrationCount % numCalibrationPointsW;
        calibrationCountH = floor(calibrationCount / numCalibrationPointsW);
        //println("!!!! : " + calibrationCountW);
      }else{
        rect(0,0,width,height);
        int wCroppedWall=rightCrop-leftCrop;
        int hCroppedWall=height-offsetBottom-offsetTop;
        myScreen = new Screen(wCroppedWall, hCroppedWall, leftCrop, offsetTop);
        //set the fixed points then edges then center
        myWall.setFixedScreens();
        myWall.setMinMaxScreen();
  
        calibration = false;
        calibrationPhase++;
      }
    }else{
      println("No tip!");
    }
}
void mouseClicked(){
  if(calibrationPhase == 4){
    setNextCalibrationPoint();
  }
}