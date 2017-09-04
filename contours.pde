//void displayContours(ArrayList<Contour> contours_, ArrayList<PImage> imges_) {
//  pushStyle();
//  //Histogram[] 
//  ArrayList<int[]> hist=new ArrayList<int[]>();
//  ArrayList<MyContour> myContours =new ArrayList<MyContour>();

//  for (int i=0; i<imges_.size(); i++) {   
//    myContours.add(new MyContour(contours_.get(i), imges_.get(i)));
//  }
  
//  for (int i=0; i<myContours.size(); i++) {
    
//    myContours.get(i).display();

//  }
//}

ArrayList<PImage> getImagesInContours(ArrayList<Contour> contours_, PImage image_, int maxContours){
  ArrayList<PImage> focussedImages=new ArrayList<PImage>();
  
  PImage selectedArea;
  for(int i=0; i<contours_.size() && i<maxContours;i++){
    if(contours_.get(i).area()<600/(resizeFactor*resizeFactor)){
      break;
    }
    selectedArea = getImageInContour(contours_.get(i),image_);
    
    focussedImages.add(selectedArea);
    
  }
  return focussedImages;
}

//do I need a new PIMage?
PImage getImageInContour(Contour contour_, PImage image_){
  PGraphics mask=createGraphics(image_.width,image_.height);
  
  //prevent overridingPImage Adress
  image_=image_.copy();

  mask.beginDraw();
  mask.endDraw();
  mask.clear();
  mask=getMaskingGraphic(contour_, mask);
  image_.mask(mask);
  
  return image_;
}



PGraphics getMaskingGraphic(Contour contour_,PGraphics graphic){
  //graphic
  ArrayList<PVector> points = contour_.getPoints(); 
  graphic.beginDraw();
  graphic.beginShape();
    for (PVector p : points) {
      graphic.vertex(p.x, p.y);
    }
  graphic.endShape(PConstants.CLOSE);
  graphic.endDraw();
  //image(graphic,512*2,424);
  return graphic;
}





//color getPeakColor(PImage image_){
//  MyHistogram hist = new MyHistogram(image_, "HUE");
//  ColorBands colorBands=new ColorBands(hist);
//  ColorBand peakBand = colorBands.getMaxBand();
//  return peakBand.getColor();
//}



PVector getClosestPointY(Contour cont_){
  ArrayList<processing.core.PVector> points = cont_.getPoints();
  //int maxPointValue=0;
  PVector maxPoint=new PVector(-10,-10);
  for(int i=0;i<points.size();i++){
    if(points.get(i).y>maxPoint.y){
      maxPoint = points.get(i);
    }
  }
  return maxPoint;
}

PVector getAvragePosition(PImage img_){
  int sumX=0;
  int sumY=0;
  int numPoints=0;
  img_.loadPixels();
  for(int i=0;i<img_.width;i++){
    for(int j=0;j<img_.height;j++){
      if(alpha(img_.pixels[i+j*img_.width])>10){
        sumX+=i;
        sumY+=j;
        numPoints++;
      }
    }
  }
  return new PVector((float)sumX/numPoints, (float)sumY/numPoints);
}

PVector getAvragePosition(PImage img_, float offsetX, float offsetY){
  PVector avragePoint = getAvragePosition(img_);
  avragePoint.x += offsetX;
  avragePoint.y += offsetY;
  return avragePoint;
}
int getAvrageBrightness(PImage img_){
  int sumB=0;
  int numPoints=0;
  img_.loadPixels();
  for(int i=0;i<img_.width;i++){
    for(int j=0;j<img_.height;j++){
      if(alpha(img_.pixels[i+j*img_.width])>0){
        sumB += brightness(img_.pixels[i+j*img_.width]);
        numPoints++;
      }
    }
  }
  //???? why would this ever happen
  if(numPoints==0){numPoints=1;};
  return sumB/numPoints;
}


ArrayList<PVector> getClosestPointsY(Contour cont_){
  ArrayList<processing.core.PVector> points = cont_.getPoints();
  
  ArrayList<processing.core.PVector> closestPoints = new ArrayList<processing.core.PVector>();
  //int maxPointValue=0;
  //PVector maxPoint=new PVector(-10,-10);
  
  int pointsSize = points.size();
 
  for(int i=1;i<pointsSize+1;i++){
    //println((i+1)%pointsSize + " : : " + (i-1)%pointsSize);
    if(points.get(i%pointsSize).y>points.get((i-1)%pointsSize).y && points.get(i%pointsSize).y>points.get(((i+1)%pointsSize)).y){
    //if(points.get(i).y>points.get((i-1)%pointsSize).y){
    //if(points.get(i).y>points.get(i-1).y ).y){
      closestPoints.add(points.get(i));
    }
  }
  return closestPoints;
}

void displayClosestPointsY(Contour cont_){
  ArrayList<processing.core.PVector> closestPoints = getClosestPointsY(cont_);
    for(int i=0;i<closestPoints.size();i++){
    ellipse(closestPoints.get(i).x, closestPoints.get(i).y, 10,10);
  }
}

void displayClosestPointY(Contour cont_){
  PVector closestPoint = getClosestPointY(cont_);
  ellipse(closestPoint.x, closestPoint.y, 10,10);
}

class MyContour{
  Contour contour;
  PVector tipMaxY;
  PVector tipPosition;
  PVector tipImgCornerOffset;
  
  Sections crossSections;
  
  
  int[] depthArray;
  int[] depthArrayTip;
  PImage image, tipImage, tipImageFiltered;
  PImage depthImag, tipDepthImag , tipDepthImagFiltered;
  int tipSizeW=90;
  int tipSizeH=30;
  //int[] hist;
  //MyHistogram colorHist;
  MyHistogram depthHist;
  
  //ColorBands colorBands;
  ColorBand peakBand;
  
  MyContour(Contour contour_, PImage img_, PImage depth_){
    this.contour=contour_;
    this.image = img_;
    this.depthImag = depth_;
    this.tipMaxY=getClosestPointY(this.contour);
    
    image(this.image,0,0);
    
    tipImgCornerOffset = new PVector((int)this.tipMaxY.x-tipSizeW/2, (int)this.tipMaxY.y-tipSizeH);
    
    
    this.tipImage= this.image.get((int)tipImgCornerOffset.x,(int)tipImgCornerOffset.y,tipSizeW,tipSizeH);
    
    
    
    //this.tipImageFiltered=new PImage(this.tipImage.width, this.tipImage.height);
    
    
    this.tipDepthImag = this.depthImag.get((int)tipImgCornerOffset.x,(int)tipImgCornerOffset.y,tipSizeW,tipSizeH);
    //hist=getHistogram(tipImage);
    //this.colorHist=new MyHistogram(tipImage);
    this.depthHist=new MyHistogram(tipDepthImag, "B");
    
    this.setBands();
    
    setFilteredImageTip();
    
    //this is the tips position avrage in the x y plane not depth
    //tipAvrage = getAvragePosition(this.tipImage, tipImgCornerOffset.x, tipImgCornerOffset.y);
    
    crossSections = new Sections(this.tipImage, this.tipDepthImag, tipImgCornerOffset.x, tipImgCornerOffset.y);
    
    this.tipPosition = crossSections.position;
    this.tipPosition.z= getDepth();
    //crossSections.display();
  }
  void setFilteredImageTip(){
    this.tipImageFiltered=new PImage(this.tipImage.width, this.tipImage.height);
    this.tipDepthImagFiltered=new PImage(this.tipImage.width, this.tipImage.height);
    this.tipImage.loadPixels();
    this.tipImageFiltered.loadPixels();
    this.tipDepthImagFiltered.loadPixels();
    
    for(int i = 0; i<this.tipImage.pixels.length; i++){
      color pixel = this.tipImage.pixels[i];
      
      if(peakBand !=null){
        if(alpha(pixel)>=10 && hue(pixel)>=this.peakBand.left && hue(pixel)<=this.peakBand.right){
          this.tipImageFiltered.pixels[i]=this.tipImage.pixels[i];
          this.tipDepthImagFiltered.pixels[i]=this.tipDepthImag.pixels[i];
          
        }
      }else if(alpha(pixel)>=10 && brightness(pixel)>10){
          this.tipImageFiltered.pixels[i]=this.tipImage.pixels[i];
          this.tipDepthImagFiltered.pixels[i]=this.tipDepthImag.pixels[i];
      }
    }
  }
  
  void setBands(){
    //MyHistogram hist = new MyHistogram(image_, "HUE");
    //this.colorBands=new ColorBands(this.colorHist);
    //this.peakBand = colorBands.getMaxBand();
    //return peakBand.getColor();
  }
  color getColor(){
    return crossSections.myColor;
  }
  int getDepth(){
    //return depthHist.peak();
    return getAvrageBrightness(tipDepthImagFiltered);
  }
  
  void display(){
    this.contour.draw();
    fill(0,255,0);
    //ellipse(this.tipMaxY.x, this.tipMaxY.y,10,10);
    image(tipImage,tipImgCornerOffset.x,tipImgCornerOffset.y);
    ellipse(this.tipPosition.x, this.tipPosition.y,10,10);
    
    hue(this.getColor());
    text(this.crossSections.aveHue,700,200);
    text(this.getColor(),600,50);
    //text(this.colorHist.peak(),650,100);
    //colorHist.display(512*4,424*(1),512, 424);
  }
  
}