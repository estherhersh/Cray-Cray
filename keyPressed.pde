void keyPressed() {
  if(calibrationPhase == 1){
    //change perfect black to white futhestDepth
    futhestDepth.loadPixels();
    
    float congergenceThreshhold=.1;
    float congergence = 1000;
    PImage snapshot = futhestDepth.copy();
    snapshot.loadPixels();
    while(congergence>congergenceThreshhold){
      congergence=0;
      //wont fill in deges
      for(int i=1;i<futhestDepth.width-1;i++){
        for(int j=1;j<futhestDepth.height-1;j++){
          int index = i+j*futhestDepth.width;
          if(brightness(snapshot.pixels[index])==0){
            
            float brightnessLeft=brightness(futhestDepth.pixels[index-1]);
            float brightnessRight=brightness(futhestDepth.pixels[index+1]);
            color newColor;
            if( brightnessLeft!=0 && brightnessRight != 0){
              newColor=color((brightnessLeft+brightnessRight)/2);
            }else if(brightnessLeft!=0 || brightnessRight != 0){
              //dont divide by 2;
              newColor=color((brightnessLeft+brightnessRight));
            }else{
              newColor=futhestDepth.pixels[index];
            }
            
            
            congergence += abs(brightness(newColor)-brightness(futhestDepth.pixels[index]));
            futhestDepth.pixels[index]=newColor;
          }
        }
     }
    }
  }
    if(key == 'l'){
      int wCroppedWall=rightCrop-leftCrop;
      int hCroppedWall=height-offsetBottom-offsetTop;
      myScreen = new Screen(wCroppedWall, hCroppedWall, leftCrop, offsetTop);
      println("loading data...");
      myWall.refrenceUnscewedDepthScreen = readArray("depth.txt");
      myWall.refrenceUnscewedXScreen = readArray("x.txt");
      myWall.refrenceUnscewedYScreen = readArray("y.txt");
      calibration = false;
      calibrationPhase=5;
    }
  else if(calibrationPhase == 2){
    
    if(key == 't'){
      tipFocuseAreaTop = mouseY;
    }else if(key == 'b'){
      tipFocuseAreaBottom  = mouseY;
    }
  }
  if(calibrationPhase == 3){
    if(key == 'f'){
      leftCrop = mouseX;
    }else if(key == 'r'){
      rightCrop  = mouseX;
    }else if(key == 't'){
      offsetTop  = mouseY;
    }else if(key == 'b'){
      offsetBottom  = height-mouseY;
    }
  }else if(calibrationPhase == 4){
    
    
    
    
    setNextCalibrationPoint();
  }
  
 
  
  
  
  if (key == 'a') {
    minDepth = constrain(minDepth+100, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-100, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+100, minDepth, 1165952918);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-100, minDepth, 1165952918);
  }else if (key =='p'){
    calibrationPhase++;
  }else if (key =='+' || key =='='){
    deltaDepth++;
  }else if (key =='-'){
    deltaDepth--;
  }else if (key ==')' || key =='0'){
    tipDepth++;
    println(tipDepth);
  }else if (key =='('|| key =='9'){
    tipDepth--;
    println(tipDepth);
  }else if(key == '>' || key == '.'){
    tipDistanceThreshold++;
  }else if(key == '<' || key == ','){
    tipDistanceThreshold--;
  }else if( key =='c'){
    myScreen.clear();
  }else if(key =='b'){
    showColoringBook=!showColoringBook;
  }
  
  
  //else if( key ==' '){
  //  if(tips.tipsList.size()>0){
  //    if(tips.tipsList.get(0).myColor.equals("Blue")){
  //      myWall.addPoint((wMappedKinect-1)*calibrationCountW/numCalibrationPointsW, (hMappedKinect-1)*calibrationCountH/numCalibrationPointsH, (int)tips.tipsList.get(0).position.x, (int)tips.tipsList.get(0).position.y, tips.tipsList.get(0).depth);
  //    }else{
  //      pushStyle();
  //      textSize(30);
  //      text("use the blue crayon!",20,height/2);
  //      popStyle();
  //    }
  //  }
  //}
  
  
  
}