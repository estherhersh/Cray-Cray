class Sections {
  Section[] sections;
  float depth;
  PVector position;
  //float avrageX=0;
  float avrageXWeighted=0;
  color myColor;
  int aveHue;
  Section tipSection;
  
  Sections(PImage tipColor, PImage tipDepth, float tipCornerOffsetX, float tipCornerOffsetY){
    tipDepth.loadPixels();
    sections = new Section[tipDepth.height];
    for(int j =0;j<tipDepth.height;j++){
      sections[j]=new Section(Arrays.copyOfRange(tipColor.pixels, j*tipDepth.width, (j+1)*tipDepth.width-1), 
      Arrays.copyOfRange(tipDepth.pixels, j*tipDepth.width, (j+1)*tipDepth.width-1), j);
    }
    setTip();
    
    this.position=new PVector(tipCornerOffsetX + avrageXWeighted,tipCornerOffsetY + tipSection.yIndex, tipSection.avrageDepth);
    this.aveHue=getAvrageHue();
    this.myColor = getColor(aveHue);
    
    textSize(50);
    text(aveHue,800,800);

  }
  
  color getColor(int avgrageHue_){
    
    if(avgrageHue_> 10   && avgrageHue_ < 50 ){//yellow
      return color(255,255,0);
    }else if(avgrageHue_> 90   && avgrageHue_ < 180  ){//green
      return color(0,255,0);
    }else if(avgrageHue_> -120   && avgrageHue_ < -90  ){ //145   && peak < 165 //blue
      return color(0, 0, 255);
    }else if(avgrageHue_> -60   && avgrageHue_ < 0  ){ //red
      return color(255,0,0);
    }else{
      return color(255);
    }
  }
  
  int getAvrageHue(){
    float sumSin=0;
    float sumCos=0;
    for(int i=2;i<sections.length; i++){
      if(sections[i].isPartOfMarker){
        sumSin += sin((sections[i].avrgeHue)/255*2*PI);
        sumCos += cos((sections[i].avrgeHue)/255*2*PI);
        
      }
    }
    return (int)(atan2(sumSin,sumCos)/(PI*2)*255);
    
  }

  
  void setTip(){

    int numContinuity=0;
    
   
    for(int i=2;i<sections.length; i++){
      
      if(i>=2){
        
        float pleftSlope = (sections[i-1].left - sections[i-2].left);
        float leftSlope = (sections[i].left - sections[i-1].left);
        
        float prightSlope = (sections[i-1].right - sections[i-2].right);
        float rightSlope = (sections[i].right - sections[i-1].right);
        if(
        
        abs(pleftSlope -leftSlope)<.5*sections[i-1].width &&
        abs(prightSlope -rightSlope)<.5*sections[i-1].width &&
        (abs((sections[i].avrgeHue)-sections[i-1].avrgeHue)<10 || 
        abs(sections[i].avrgeHue +255 -sections[i-1].avrgeHue)<10 || 
        abs(sections[i].avrgeHue - 255 -sections[i-1].avrgeHue)<10) 
        
        ){
          
          avrageXWeighted = (avrageXWeighted*(sumFactoral(numContinuity))+sections[i].middle*(numContinuity+1))/sumFactoral(numContinuity+1);
          
          numContinuity++;
          sections[i].isPartOfMarker=true;
          
          
          
          //avrageX += (avrageX * numContinuity + sections[i].middle)/(numContinuity+1);
        
        }else if(numContinuity>3){
          //tipEndFound=true;
          tipSection = sections[i-1];
          break;
        }
        if(i==sections.length-1){
          tipSection = sections[i];
        }
      }
    }
  }
  
  void display(){
    pushMatrix();
    translate(800,800);
    for(int i=0;i<sections.length;i++){
      translate(0,1);
      //println(i + "  :  " + sections[i].width);
      sections[i].display();
    }
    popMatrix();
  }
}

class Section{
  int width=0;
  float middle;
  float left;
  float right;
  int numVoids=0;
  float avrageDepth;
  boolean isPartOfMarker=false;
  int yIndex;
  int sumSaturation=0;
  float avrgeSaturation;
  int sumBrightness=0;
  float avrgeBrightness;
  //int sumHue=0;
  float sumSin=0;
  float sumCos=0;
  //int sumHue=0;
  float avrgeHue;
  Section(int[] rowColorPix, int[] rowDepthPix, int yIndex_){
    int sum=0;
    int sumIndex = 0;
    int tempVoidCount=0;
    int sumDepth = 0;
    yIndex=yIndex_;
    
    boolean startVoidCount=false;
    
    
    for(int i =0; i<rowColorPix.length;i++){
      if(brightness(rowColorPix[i])>0){
        startVoidCount=true;
        sum++;
        sumIndex += i;
        
        sumDepth += brightness(rowDepthPix[i]);
        
        
        //sumHue += hue(rowColorPix[i]);
        sumSin += sin(hue(rowColorPix[i])/255*2*PI);
        sumCos += cos(hue(rowColorPix[i])/255*2*PI);
        
       
       
        
        sumSaturation += saturation(rowColorPix[i]);
        
        sumBrightness += brightness(rowColorPix[i]);
        
        
        
        if(tempVoidCount>1){
          numVoids+=tempVoidCount;
          
          //if few dead point through away
          //if(tempVoidCount<3){
            
          //}
          
          tempVoidCount=0;
        }
      }else if(startVoidCount){
        tempVoidCount++;
        
      }
    }
    middle = (float)sumIndex/sum;
    left = middle-(float)sum/((float)sum/2);
    right = middle+(float)sum/((float)sum/2);
    avrageDepth = (float)sumDepth/sum;
    
    //this adresses 255 and 0 being similar hue
    
    //float angleSum = sumHue/255*(2*PI);
    avrgeHue = atan2(sumSin,sumCos)/(PI*2)*255;
    
    
    
    //avrgeHue = (float)sumHue/sum;
    avrgeSaturation = (float)sumSaturation/sum;
    avrgeBrightness = (float)sumBrightness/sum;
    width=sum;
    
  } 

  
  void display(){
    if(isPartOfMarker){
      stroke(0,255,0);
      strokeWeight(1);
      line(-width/2+middle,0,width/2+middle,0);
      stroke(255,0,0);
      strokeWeight(3);
      point(middle,0);
    }else{
      stroke(255,0,0);
      strokeWeight(1);
      line(-width/2+middle,0,width/2+middle,0);
      stroke(0);
      strokeWeight(3);
      point(middle,0);
    }
    
  }
    
}