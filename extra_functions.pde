int sign(int i) {
    if(i==0){
      return 0;
    }if(i>0){
      return 1;
    }else{
      return -1;
    }
}
int sign(float f) {
    if(f==0){
      return 0;
    }if(f>0){
      return 1;
    }else{
      return -1;
    }
}

int sumFactoral(int num){
  if(num<=0){
    return num;
  }
  return(sumFactoral(num-1)+num);
}

void saveArray(float[] fArray, String fileName){
  PrintWriter outPut;
  
  outPut = createWriter(dataPath("") + "/" + fileName);
  outPut.append(Arrays.toString(fArray));
  outPut.flush();
  outPut.close();
}

float[] readArray(String fileName){
  BufferedReader reader;
  
  reader = createReader(dataPath("") + "/" + fileName);
  try {
    String line = reader.readLine();
    line=line.replaceAll("[\\[\\](){}]","");
    String[] array = line.split(", ");
    float[] arrayInt = new float[array.length];
    for(int i=0;i<array.length;i++){
      arrayInt[i]=float(array[i]);
    }
    return arrayInt;
    
  } catch (IOException e) {
    e.printStackTrace();
  }
  float[] nullArray={};
  return nullArray;
}