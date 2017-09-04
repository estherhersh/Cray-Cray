void calbration(){
  if(calibrationPhase == 1){
    futhestDepth = getFuthestDepth(futhestDepth,depthImgScaled);
    futhestDepth = fillInMissingPixXConvergence(futhestDepth);
    calibrationPhase++;
    image(futhestDepth,futhestDepth.width*2,0);
  }else if(calibrationPhase == 2){
    stroke(255,0,0);
    image(kinect2.getRegisteredImage(),0,0);
    fill(255,100);
    rect(0,0,kinect2.depthWidth,tipFocuseAreaTop);
    fill(255,100);
    rect(0,tipFocuseAreaBottom, kinect2.depthWidth,kinect2.depthHeight-tipFocuseAreaBottom);
    //tipTopPoint=200;
    //tipBottomPoint =400;
    
  }else if(calibrationPhase == 3){
    //if(keyPressed){
    //  if(key == 'l'){
    //    leftCrop = mouseX;
    //  }else if(key == 'r'){
    //    rightCrop  = mouseX;
    //  }else if(key == 't'){
    //    offsetTop  = mouseY;
    //  }else if(key == 'b'){
    //    offsetBottom  = height-mouseY;
    //  }
    //}
    
    pushStyle();
    stroke(255,0,0);
    fill(255);
    strokeWeight(4);

    rect(leftCrop,offsetTop,rightCrop-leftCrop,height-offsetTop-offsetBottom);
    image(kinect2.getRegisteredImage(),50,height-kinect2.getRegisteredImage().height);
    popStyle();
    
    
  }else if(calibrationPhase == 4){
    
    //ellipse(300,300,300,300);
    

    //pointsGraphic=createGraphics(wScreen, hScreen);
    
    
    
    
    

    //calibrationGraphic=createGraphics(width, height);
    displayCalibrationPoint();
    //calibrationGraphic.beginDraw();
    
    //calibrationGraphic.beginDraw();
    //calibrationGraphic.background(0,255,0);
    //calibrationGraphic.ellipse(512/2+100,424/2,50,50);
    //calibrationGraphic.endDraw();
    image(calibrationGraphic, 0,0,width, height);
    //myScreen.display();
    
    
    //PGraphics testG=createGraphics(512, 424);
    //testG.beginDraw();
    //testG.fill(255,0,0);
    //testG.ellipse(512/2,424/2,50,50);
    //testG.beginDraw();
    
    //if(millis()%1000<3){
    //  println("should draw");
    //}
    
  }
    

}


//compaiers 2 images findes the furthere (brighter point)
//for added relaability I could use some easing or verification of surrounding points so that random noise that apease far away is not calibrated towards
PImage getFuthestDepth(PImage imgA, PImage imgB){
  PImage brighterImage = new PImage(imgA.width,imgA.height);
  brighterImage.loadPixels();
  imgA.loadPixels();
  imgB.loadPixels();
  //println(imgA.width + ", "  + imgA.height + " : " + imgB.width + ", "  + imgB.height);
  for(int i =0;i<imgA.pixels.length; i++){
    if(brightness(imgA.pixels[i])<brightness(imgB.pixels[i])){
      brighterImage.pixels[i]=imgB.pixels[i];
    }else{
      brighterImage.pixels[i]=imgA.pixels[i];
    }
  }
  //image(brighterImage, 512*2, 0);
  return brighterImage;
}

PImage getMovingDepth(PImage imgCur, PImage imgBackground, PImage registeredImage){
  //println(imgCur.height + " : " + imgBackground.height + " : " + registeredImage.height + " : ");
  PImage movingImage = new PImage(imgCur.width,imgBackground.height);
  movingImage.loadPixels();
  imgCur.loadPixels();
  imgBackground.loadPixels();
  registeredImage.loadPixels();
  float depthDiff;
  
  
  //image(imgBackground,imgBackground.width,0);
  //image(imgCur,imgCur.width,imgCur.height);
  for(int i =0;i<imgCur.pixels.length; i++){
    depthDiff = brightness(imgBackground.pixels[i])-brightness(imgCur.pixels[i]);
    
    
    
    if(depthDiff>deltaDepth ){
        movingImage.pixels[i]=registeredImage.pixels[i];
        
        //if(brightness(movingImage.pixels[i])==0){
        //  movingImage.pixels[i]=color(0,0);
        //}
    }
    
    //??
    //if(brightness(movingImage.pixels[i])<20){
    //  movingImage.pixels[i]=color(0,0);
    //}
  }
  //image(movingImage,movingImage.width,0);
  //textSize(35);  
  
  //for(int i =0;i<imgCur.pixels.length; i++){
  //  if(brightness(movingImage.pixels[i])<20){
  //    movingImage.pixels[i]=color(0,0);
  //  }
  //}
  
  //image(movingImage,512*1,424);
  
  return movingImage;
}


int calibrationPointSize=15;

void displayCalibrationPoint() {
  calibrationGraphic.beginDraw();
  calibrationGraphic.strokeWeight(7);
  calibrationGraphic.stroke(0,0,255);
  calibrationGraphic.fill(0,0,255);
  calibrationGraphic.clear();
  //calibrationGraphic.background(255,0,0);
 
  
       
  
  //println(calibrationGraphic.width);
  
  
  //calibrationGraphic.rect(width/2,height/2,50,50);
  //calibrationGraphic.stroke(255);

  //int xPossition=width-height*calibrationCountW/numCalibrationPointsW-leftCrop;
  //int yPossition=(height)*calibrationCountH/numCalibrationPointsH+offsetTop;
  
  int widthDrawArea=rightCrop - leftCrop;
  int heightDrawArea=height - offsetTop - offsetBottom;
  int xPossition = widthDrawArea*calibrationCountW/(numCalibrationPointsW-1) + leftCrop;
  int yPossition=heightDrawArea*calibrationCountH/(numCalibrationPointsH-1)+offsetTop;

  calibrationGraphic.ellipse(xPossition, yPossition, 15, 15);

  //calibrationGraphic.stroke(0,0,255);
  calibrationGraphic.noFill();
  calibrationGraphic.ellipse(xPossition, yPossition, calibrationPointSize, calibrationPointSize);


  if (calibrationPointSize>15) {
    calibrationPointSize-=1;
  } else {
    calibrationPointSize=150;
  }
  calibrationGraphic.endDraw();
}



PImage fillInMissingPixXConvergence(PImage image_){
  image_.loadPixels();
    float congergenceThreshhold=.1;
    float congergence = 1000;
    PImage snapshot = image_.copy();
    snapshot.loadPixels();
    while(congergence>congergenceThreshhold){
      congergence=0;
      //wont fill in deges
      for(int i=1;i<image_.width-1;i++){
        for(int j=1;j<image_.height-1;j++){
          int index = i+j*image_.width;
          if(brightness(snapshot.pixels[index])==0){
            
            float brightnessLeft=brightness(image_.pixels[index-1]);
            float brightnessRight=brightness(image_.pixels[index+1]);
            color newColor;
            if( brightnessLeft!=0 && brightnessRight != 0){
              newColor=color((brightnessLeft+brightnessRight)/2);
            }else if(brightnessLeft!=0 || brightnessRight != 0){
              //dont divide by 2;
              newColor=color((brightnessLeft+brightnessRight));
            }else{
              newColor=image_.pixels[index];
            }
            
            
            congergence += abs(brightness(newColor)-brightness(image_.pixels[index]));
            image_.pixels[index]=newColor;
          }
        }
     }
    }
    return image_;
}