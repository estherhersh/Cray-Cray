class MyHistogram{
  int[] bins;
  int length;
  MyHistogram(PImage imageSection){
    imageSection.loadPixels();
    this.bins = new int[256];
    for (int i = 0; i < imageSection.width; i++) {
      for (int j = 0; j < imageSection.height; j++) {
        color c=imageSection.pixels[i+j*imageSection.width];
        if(alpha(c)>100){
          int bright = int(hue(c));
          this.bins[bright]++; 
        }
      }
    }
    this.bins[0]=0; 
    this.bins[255]=0;
    
    
    this.length=this.bins.length;
  }
  MyHistogram(PImage imageSection, String mode){
    if(mode.equals("HUE")){
      imageSection.loadPixels();
      this.bins = new int[256];
      for (int i = 0; i < imageSection.width; i++) {
        for (int j = 0; j < imageSection.height; j++) {
          color c=imageSection.pixels[i+j*imageSection.width];
          if(alpha(c)>100){
            int bright = int(hue(c));
            this.bins[bright]++; 
          }
        }
      }
    }else if(mode.equals("B")){
      imageSection.loadPixels();
      this.bins = new int[256];
      for (int i = 0; i < imageSection.width; i++) {
        for (int j = 0; j < imageSection.height; j++) {
          color c=imageSection.pixels[i+j*imageSection.width];
          if(alpha(c)>100){
            int bright = int(brightness(c));
            this.bins[bright]++; 
          }
        }
      }
    }
    this.bins[0]=0; 
    this.bins[255]=0;
  }
  
  
  
  int peak() {  
    int max = 0;
    int maxIndex=0;

    for(int i=0; i < this.bins.length; i++){
        if(this.bins[i]>max){
          max=this.bins[i];
          maxIndex=i;
        }
    }
    
    return maxIndex;
  }
  color getColor(){
    int peak = this.peak();
    if(peak> 25   && peak < 45 ){
      return color(255,255,0);
    }else if(peak> 100   && peak < 115  ){
      return color(0,255,0);
    }else if(peak> 145   && peak < 175  ){ //145   && peak < 165
      return color(0, 0, 255);
    }else if(peak> 235   && peak < 245  ){
      return color(255,0,0);
    }else{
      return color(255);
    }
  }
  
  
  
  //int getMean(){
  //  int sumBins=0;
  //  int numberPoints=0;
  //  for(int i =0;i<this.bins.length;i++){
  //    sumBins+=i*this.bins[i];
  //  }
  //}
  
  void display(int xPos, int yPos, int h, int w){
    stroke(0);
    pushMatrix();
    translate(xPos, yPos);
    float binWidth=(float)w/this.bins.length;
    //float maxBinHeight=(float)w/hist.length;
    ellipse(0,0,30,30);
    for(int i=0;i<this.bins.length;i++){
      //ellipse(600,600,600,600);
      rect(i*binWidth, 0, binWidth, (float)h*this.bins[i]*-0.0005);
      //rect(i*binWidth, 0, binWidth, -10);
    }
    popMatrix();
  }
}