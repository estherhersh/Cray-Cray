

float getBinValue(Mat _hist, int index){
  if(_hist.height()>0){
    return (float)_hist.get(index, 0)[0];
  }
  return 0.0;
}


class ColorBands{
  ArrayList<ColorBand> bands;
  MyHistogram hist;
  //ColorBands(MyHistogram hist_){
  //  ColorBands(_hist.bins);
  //}
  
  ColorBands(MyHistogram hist_){
    hist=hist_;
    bands=getBands(hist_);
  }
  
  //float getValueAt(int index){
  //  if(index<this.hist.length){
  //    return (float)this.hist.get(index, 0)[0];
  //  }
  //  return 0;
  //}
  ColorBand getMaxBand(){
    ColorBand maxBand = null;
    for(int i=0;i<bands.size();i++){
      if(maxBand == null || hist.bins[this.bands.get(i).peak] > hist.bins[maxBand.peak]){
        maxBand=this.bands.get(i);
      }
    }
    return maxBand;
  }
  ArrayList<ColorBand> getThreshholdBands(float threshold, float minPeak){
    ArrayList<ColorBand> threshholdBands = new ArrayList<ColorBand>();
    for(int i=0;i<bands.size();i++){
      //if(getValueAt(bands.get(i).peak)*threshold > getValueAt(bands.get(i).left) &&
      //getValueAt(bands.get(i).peak)*threshold > getValueAt(bands.get(i).right)){
      if(hist.bins[bands.get(i).peak]*threshold > hist.bins[bands.get(i).left] &&
      hist.bins[bands.get(i).peak]*threshold > hist.bins[bands.get(i).right] &&
      hist.bins[bands.get(i).peak] > minPeak){
        threshholdBands.add(bands.get(i));
      }
    }
    return threshholdBands;
  }
  
  ArrayList<ColorBand> getBands(MyHistogram hist_){
    ArrayList<ColorBand> bands = new ArrayList<ColorBand>();
    for(int i=1; i<hist.length-1;i++){
      if((float)hist_.bins[i] > (float)hist_.bins[i-1] && (float)hist_.bins[i] > (float)hist_.bins[i+1]){
        bands.add(new ColorBand(hist_, i));
      }
    }
    return bands;
  }
  
}

class ColorBand{
  int left;
  int right;
  int peak;
  ColorBand(MyHistogram _hist, int _peak){
    this.peak=_peak;
    this.left=this.getLeft(_hist,_peak);
    this.right=this.getRight(_hist,_peak);
  }
  int getLeft(MyHistogram _hist, int _peak){
    for(int i=_peak;i>0;i--){
      if((float)_hist.bins[i] < (float)_hist.bins[((i-1)+_hist.length)%_hist.length] && (float)_hist.bins[i] < (float)_hist.bins[(i+1)%_hist.length]){
        return i;
      }
    }
    return 1;
  }
  int getRight(MyHistogram _hist, int _peak){
    for(int i=_peak;i<_hist.length;i++){
      if((float)_hist.bins[i] < (float)_hist.bins[((i-1)+_hist.length)%_hist.length] && (float)_hist.bins[i] < (float)_hist.bins[(i+1)%_hist.length]){
        return i;
      }
    }
    return _hist.length;
  }
  color getColor(){
    color myColor;
    pushStyle();
      colorMode(HSB);
      println("Peak   : "+peak);
      myColor=color(peak,255,255);
    popStyle();
    return myColor;
  }
}