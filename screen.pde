class Screen{
  PGraphics displayGraphic;
  PImage imgColoringBookCrayon;
  //int w, h;
  int offsetL, offsetT;
  Screen(int w_, int h_, int offsetL_, int offsetT_){
    //this.w = w_; 
    //this.h = h_;
    this.offsetL = offsetL_;
    this.offsetT = offsetT_;
    
    imgColoringBookCrayon = loadImage("data/crayon.png");
    
    this.displayGraphic = createGraphics(w_, h_);
    this.displayGraphic.beginDraw();
    this.displayGraphic.endDraw();
  }
  
  void clear(){
    this.displayGraphic.beginDraw();
    this.displayGraphic.clear();
    this.displayGraphic.endDraw();
  }
 
  //drawing the actual line(beg position, end position, color)
  void addLine(float fx1, float fy1, float fx2, float fy2, color color_){
    int x1 = floor(fx1*this.displayGraphic.width);
    int y1 = floor(fy1*this.displayGraphic.height);
    int x2 = floor(fx2*this.displayGraphic.width);
    int y2 = floor(fy2*this.displayGraphic.height);
    
    this.displayGraphic.beginDraw();
    this.displayGraphic.stroke(color_);
    this.displayGraphic.strokeWeight(4);
    
    int thicknessLine=(5);
    int numberMarks = floor(dist(x1, y1, x2, y2) / 3);

    this.displayGraphic.beginDraw();
    this.displayGraphic.stroke(color_);
    
    for (int i = 0; i < numberMarks; i++) {
      for (int j = 0; j < 5; j++) {
        float t=(float)i/(float)numberMarks;

        int xCenter=x1+floor((x2-x1)*t);
        int yCenter=y1+floor((y2-y1)*t);

        this.displayGraphic.strokeWeight(random(1, 10));
        float theta = random(0, PI*2);

        this.displayGraphic.line(xCenter, yCenter, xCenter + cos(theta) * thicknessLine, yCenter + sin(theta) * thicknessLine);
      }
    }
    
    //this.displayGraphic.line( x1,  y1,  x2,  y2);
    this.displayGraphic.endDraw();
  }
  
  void addPoint(float fx1, float fy1, color color_){
    //background(0,30);
    int x1 = floor(fx1*this.displayGraphic.width);
    int y1 = floor(fy1*this.displayGraphic.height);
    this.displayGraphic.beginDraw();
    
    
    this.displayGraphic.stroke(color_);
    this.displayGraphic.fill(color_);
    
    this.displayGraphic.ellipse(x1,y1,15,15);
    //this.displayGraphic.line( x1,  y1,  x2,  y2);
    this.displayGraphic.endDraw();
  }
  void addText(String text_, float fx1, float fy1, color color_){
    background(0,30);
    
    int x1 = floor(fx1*this.displayGraphic.width);
    int y1 = floor(fy1*this.displayGraphic.height);
    this.displayGraphic.beginDraw();
    this.displayGraphic.textSize(20);
    
    this.displayGraphic.stroke(color_);
    this.displayGraphic.fill(color_);
    
    this.displayGraphic.text(text_, x1,y1);
    //this.displayGraphic.line( x1,  y1,  x2,  y2);
    this.displayGraphic.endDraw();
  }

  void display(){
    image(this.displayGraphic , this.offsetL, this.offsetT);
    if(showColoringBook){
      //this.imgColoringBookCrayon.resize(0, this.displayGraphic.height);
      image(this.imgColoringBookCrayon , this.offsetL + 100,0);
    }
  }
  
  
}