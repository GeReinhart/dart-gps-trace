part of gps_trace;


class TraceRawDataProfiler{
  
  num _minProfilePointsNumber ;
  
  TraceRawDataProfiler({minProfilePointsNumber:500}){
    this._minProfilePointsNumber = minProfilePointsNumber ;
  }
  
  TraceRawData profile(TraceRawData data){
    
    TraceRawData clonedData = data.clone();
    if ( clonedData.points.length < _minProfilePointsNumber * 1.5 ){
      return clonedData;
    }
    _applyElevetionAverage(clonedData) ;
    
    int sliceSize = (clonedData.points.length / _minProfilePointsNumber * 3).truncate() ;
    
    TraceRawData profileData = new TraceRawData() ;
    TracePoint lowerPoint = data.points.elementAt(0);
    TracePoint higherPoint  = data.points.elementAt(0);
    
    for(int i = 0 ; i < clonedData.points.length - 1; i++  ){
      TracePoint currentPoint = data.points.elementAt(i);
      bool newSlice = i%sliceSize == 0 && i>0;

      if (newSlice){
        TracePoint previousPoint = data.points.elementAt(i-1);
        if ( lowerPoint.index <  higherPoint.index  ){ 
          profileData.points.add(lowerPoint);
          profileData.points.add(higherPoint); 
        }
        if ( lowerPoint.index >  higherPoint.index  ){
          profileData.points.add(higherPoint);
          profileData.points.add(lowerPoint);
        }
        if ( lowerPoint.index ==  higherPoint.index  ){
          profileData.points.add(higherPoint);
        }
        profileData.points.add(previousPoint);
        
        lowerPoint = currentPoint;
        higherPoint = currentPoint;
      }else{
        if( currentPoint.elevetion <  lowerPoint.elevetion ){
          lowerPoint = currentPoint;
        }
        if( currentPoint.elevetion >  higherPoint.elevetion ){
          higherPoint = currentPoint;
        }        
      }
    }
    
    return profileData;
  }

  TraceRawData _applyElevetionAverage(TraceRawData profileData){
    TraceRawDataPurger purger = new TraceRawDataPurger( _minProfilePointsNumber * 2);
    PurgerData  purgerData =  purger.analyse(profileData) ;
    int pointsToMergeEachSide = (purgerData.originalDensity / 10).truncate();
    purger.applyElevetionAverageWithMergeWidth(profileData, purgerData, pointsToMergeEachSide) ;
  }
  
}