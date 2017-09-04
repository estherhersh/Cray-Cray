float tipContinuatyThreshhold = .1; // percent of sceen size

class Tips{
  ArrayList<Tip> holdoverTips;
  
  //Tips(ArrayList<Contour> contours_, ArrayList<PImage> imges_, ArrayList<PImage> depthImages_){
  Tips(){
    holdoverTips=new ArrayList<Tip>();
  }
  
  void update(ArrayList<Contour> contours_, ArrayList<PImage> imges_, ArrayList<PImage> depthImages_){
    ArrayList<Tip> newTips = new ArrayList<Tip>();
    for (int i=0; i<imges_.size(); i++) { 
      Tip newTip = new Tip(contours_.get(i), imges_.get(i), depthImages_.get(i));
      //if(newTip.position.y > tipFocuseAreaTop && newTip.position.y < tipFocuseAreaBottom){
      newTips.add(newTip);
      //}
    }
    
    //holdoverTips = newTips;
    if(holdoverTips.size()==0){
      holdoverTips=newTips;
    }else{
      mergeNewTips(newTips);
    }
  }
  void mergeNewTips(ArrayList<Tip> newTips_){
    //cycle through all old tips and see if any alighn near new tips
    for(Tip tipNew:newTips_){
      for(Tip tipOld:this.holdoverTips){
        if(isSameTip(tipOld,tipNew)){
          tipNew.addLastPoint(tipOld.mappedTipPoints, tipOld.myColor);
          this.holdoverTips.remove(tipOld);
          break;
        }
      }
    }
    
    
    //remove old tips that have been missing too long
    //for(Tip tipOld: this.holdoverTips){
    for(int i=0;i< this.holdoverTips.size();i++){
      if(!this.holdoverTips.get(i).notFound()){//returns false if missing 3 times increnments missing
        this.holdoverTips.remove(i);
        i--;//subtract 1 because just removed oneand dont want to skip
      }
    }
    
    //add the new tips
    for(Tip tipNew:newTips_){
      this.holdoverTips.add(tipNew);
    }
  }
  
  boolean isSameTip(Tip prev, Tip cur){
    if(//prev.myColor == cur.myColor && 
    dist(prev.mappedTipPercent.x, prev.mappedTipPercent.y, cur.mappedTipPercent.x, cur.mappedTipPercent.y) <tipContinuatyThreshhold &&
    abs(prev.myContour.crossSections.aveHue - cur.myContour.crossSections.aveHue)<30){
      return true;
    }
    return false;
  }
  void display(){
    
    for(int i=0;i<this.holdoverTips.size();i++){
      this.holdoverTips.get(i).display();

      //translate(100,0);
    }
    
    
    pushMatrix();
    for(Tip tip : holdoverTips){
      text((int)tip.position.x  + ", " + (int)tip.position.y + ", " +(int)tip.position.z + "    " + hue(tip.myColor), 100,500);
      translate(0,100);
    }
    popMatrix();
    
    
  }
  
  void drawLines(){
    for(int i = 0; i<holdoverTips.size();i++){
      if(holdoverTips.get(i).isOnWall()){
        holdoverTips.get(i).drawLine();
      }
    }
  }
}


class Tip{
  MyContour myContour;
  color myColor;
  int colorScore=100;
  PImage depthTipImage;
  //int depth;
  PVector position;
  
  int continusFinds=0;
  int continusMissing=0;
  
  //x for across y for depth
  ArrayList<PVector> mappedTipPoints=new ArrayList<PVector>();
  PVector mappedTipPercent, pmappedTipPercent;
  
  boolean isFound=false;
  
  //boolean stayedOnWall;
  
  Tip(Contour contour, PImage imageSection, PImage depthImage){
    this.myContour = new MyContour(contour, imageSection, depthImage); 
    this.myColor = myContour.getColor();
    //this.depth = myContour.getDepth();
    
    
    
    this.position=myContour.tipPosition;
    
    
    
    this.setMappedTip();

  }
  
  //void (PVector mappedTipPercent_, int continusFinds_){
  //  this.pmappedTipPercent = mappedTipPercent_;
  //  this.continusFinds = continusFinds_ + 1;
  //  this.isFound=true;
  //  this.continusMissing=0;
  //}
  
  void addLastPoint(ArrayList<PVector> mappedTipPoints_, color pColor){
    this.mappedTipPoints = mappedTipPoints_;
    this.mappedTipPoints.add(this.mappedTipPercent);
    //this.continusFinds = continusFinds_ + 1;
    this.isFound=true;
    this.continusMissing=0;
    
    if(pColor == this.myColor){
      colorScore=100;
    }else if(this.colorScore>50 && this.myColor == color(255)){
      this.myColor = pColor;
      this.colorScore-=5;
    }else if(this.colorScore>0){
      this.myColor = pColor;
      this.colorScore-=10;
    }
  }
  boolean notFound(){
    if(continusMissing>2){
      return false;
    }
    this.continusMissing++;
    this.isFound=false;
    return true;
  }
  void setMappedTip(){
    
    //this.mappedTipPercentP=mappedTipPercent;
    this.mappedTipPercent = myWall.getClosestPosition((int)this.position.x, (int)this.position.z);
    //this.mappedTipPercentP = this.mappedTipPercent;
  }
  
  void drawLine(){
    //myScreen.addLine(mappedTipPercent.x, mappedTipPercent.y, mappedTipPercentP.x, mappedTipPercentP.y, myColor);
    //if(this.isFound){
      //myScreen.addPoint(mappedTipPercent.x, mappedTipPercent.y, myColor);
      //if(this.pmappedTipPercent 
      //myScreen.addPoint(this.mappedTipPercent.x, this.mappedTipPercent.y, this.myColor);
      
      if(this.mappedTipPoints.size()>3){
        //prevent jumps by drawing one back
        //println(this.mappedTipPoints.size()-2);
        //println(this.mappedTipPoints.get(this.mappedTipPoints.size()-3).y);
        //println(this.mappedTipPoints.size());
        //println(this.mappedTipPoints.get(this.mappedTipPoints.size()-1).y);
        
        //if(abs(this.mappedTipPoints.get(this.mappedTipPoints.size()-3).y - this.mappedTipPoints.get(this.mappedTipPoints.size()-1).y) <
        //abs(this.mappedTipPoints.get(this.mappedTipPoints.size()-2).y - this.mappedTipPoints.get(this.mappedTipPoints.size()-1).y)){
        //  this.mappedTipPoints.get(this.mappedTipPoints.size()-2).y = 
        //  (this.mappedTipPoints.get(this.mappedTipPoints.size()-3).y - this.mappedTipPoints.get(this.mappedTipPoints.size()-1).y)/2;
        //}
        
        myScreen.addLine(this.mappedTipPoints.get(this.mappedTipPoints.size()-1).x,this.mappedTipPoints.get(this.mappedTipPoints.size()-1).y,
        this.mappedTipPoints.get(this.mappedTipPoints.size()-2).x,this.mappedTipPoints.get(this.mappedTipPoints.size()-2).y, this.myColor);
      }
      //myScreen.addLine(this.mappedTipPercent.x, this.mappedTipPercent.y,this.pmappedTipPercent.x, this.pmappedTipPercent.y, this.myColor);
      //myScreen.addText(Integer.toString(continusFinds), mappedTipPercent.x, mappedTipPercent.y, color(255,0,0));
    //}
    //else{
    //  myScreen.addPoint(mappedTipPercent.x, mappedTipPercent.y, color(255,0,0));
    //}
    
    //if(this.mappedTipPercentP != null){
    //  //println(" printing a line !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //  myScreen.addLine(mappedTipPercent.x, mappedTipPercent.y, mappedTipPercentP.x, mappedTipPercentP.y, myColor);
    //}else{
    //  myScreen.addPoint(mappedTipPercent.x, mappedTipPercent.y, myColor);
    //}
  }
  
  
  boolean isOnWall() {
    //PVector mappedPercentTip=myWall.getClosestPosition((int)this.position.x, this.depth);
    setMappedTip();
    int index = floor(this.mappedTipPercent.x*(wMappedKinect-1))+ 
    floor(mappedTipPercent.y*(hMappedKinect-1)*(wMappedKinect-1));
    
    
    //if(millis()%100<2){
    //  println("This position Y : " + this.position.y + 
    //  "\t Wall depth at this point : " + myWall.refrenceUnscewedYScreen[index]);
    //}
    
    pushMatrix();
    translate(width-150,50);
    strokeWeight(5);
    stroke(255);
    fill(255,0,0);
    line(0,0,tipDistanceThreshold*5,0);
    ellipse(0,0,10,10);
    ellipse(myWall.refrenceUnscewedYScreen[index] - this.position.y,0,10,10);
    popMatrix();
    
    if (myWall.refrenceUnscewedYScreen[index] - this.position.y <tipDistanceThreshold) {
      return true;
      
    }

    
    
    
    return false;
  }
  
  void display(){
    this.myContour.display();
  }
}