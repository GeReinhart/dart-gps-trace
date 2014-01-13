part of gps_trace;


class TraceRawDataPurger{
  
  static const num ALIGNMENT_ALLOWED_ERROR =  0.015 ;
  static const num SMOOTHING_DENSITY_THRESHOLD =  1000/30 ;
  static const num SMOOTHING_THRESHOLD =  10;
  static const num EVERAGE_ELEVETION_POINTS_NUMBER =  9;
  
  num maxDensity ;
  num maxPointNumber;
  
  TraceRawDataPurger(this.maxDensity, this.maxPointNumber);
  
  TraceRawData purge(TraceRawData input){
    
    PurgerData purgerData = _analyse(input);
    TraceRawData purgedTraceRawData = input;
    if ( purgerData.density > SMOOTHING_DENSITY_THRESHOLD ){
      purgedTraceRawData = _purgeAlignedPoints(input,purgerData) ;
      purgedTraceRawData = _applySmoothing(purgedTraceRawData,purgerData,SMOOTHING_THRESHOLD);
      purgedTraceRawData = _applyElevetionAverage(purgedTraceRawData,purgerData);
    }
    return purgedTraceRawData;
  }

  TraceRawData _applySmoothing(TraceRawData data, PurgerData purgerData, num smoothingThreshold){
    for(int i = 1 ; i < data.points.length - 1; i++  ){
      TracePoint previousPoint = data.points.elementAt(i-1);
      TracePoint currentPoint = data.points.elementAt(i);
      TracePoint nextPoint = data.points.elementAt(i+1);
      
      if (  currentPoint.elevetion - smoothingThreshold > previousPoint.elevetion 
         || currentPoint.elevetion + smoothingThreshold < previousPoint.elevetion
         ){
        currentPoint.elevetion = (  previousPoint.elevetion + nextPoint.elevetion  ) / 2 ;
      }
    }
    return data;
  }
  
  TraceRawData _applyElevetionAverage(TraceRawData data, PurgerData purgerData){
    int pointsToMergeEachSide = (EVERAGE_ELEVETION_POINTS_NUMBER-1)~/2 ;
    
    for(int i = pointsToMergeEachSide ; i < data.points.length - pointsToMergeEachSide -1 ; i++  ){
      TracePoint currentPoint = data.points.elementAt(i);
      num elevetion= 0;
      for ( int j = i-pointsToMergeEachSide ; j  <= i + pointsToMergeEachSide ; j++    ){
        elevetion+=data.points.elementAt(j).elevetion;
      }
      currentPoint.elevetion = elevetion / (pointsToMergeEachSide*2+1) ;
    }
    return data;
  }   
  
  TraceRawData _purgeAlignedPoints(TraceRawData data, PurgerData purgerData){
    
    TraceRawData purgedRawData = new TraceRawData();
    List<TracePoint> points = new List<TracePoint>() ;
    DistanceComputer distanceComputer = new DistanceComputer();
    
    
    points.add(data.points.elementAt(0)) ;
    for(int i = 1 ; i < data.points.length - 1; i++  ){
      TracePoint previousPoint = data.points.elementAt(i-1);
      TracePoint currentPoint = data.points.elementAt(i);
      TracePoint nextPoint = data.points.elementAt(i+1);
      
      double  previousToCurrent = distanceComputer.distance(previousPoint, currentPoint) ;
      double  currentToNext = distanceComputer.distance(currentPoint, nextPoint) ;
      double  previousToNext = distanceComputer.distance(previousPoint, nextPoint) ;

      if (  (previousToCurrent+currentToNext) * (1-ALIGNMENT_ALLOWED_ERROR) <  previousToNext ){
        if (  previousPoint.elevetion <= currentPoint.elevetion 
          &&   currentPoint.elevetion <=  nextPoint.elevetion 
          ||
              previousPoint.elevetion >= currentPoint.elevetion 
          &&   currentPoint.elevetion >=  nextPoint.elevetion          
          ){
        }
        continue ;
      }
      points.add(currentPoint) ;
    }
    points.add(data.points.elementAt(data.points.length-1)) ;
    
    purgedRawData.points = points;
    
    return purgedRawData;
  }
  
  
  PurgerData _analyse(TraceRawData data){
    StreamController pointStream = new StreamController.broadcast( sync: true);
    PointDensityComputer pointDensityComputer = new PointDensityComputer(pointStream.stream);
    LengthComputer lengthComputer = new LengthComputer(pointStream.stream);
    ImportantPointsComputer importantPointsComputer = new ImportantPointsComputer(pointStream.stream); 

    for (var iter = data.points.iterator; iter.moveNext();) {
      pointStream.add(iter.current) ;
    }
    pointStream.close();
    
    PurgerData purgerData = new PurgerData();
    purgerData.density = pointDensityComputer.pointDensity;
    purgerData.length  = lengthComputer.length;
    purgerData.importantPoints = importantPointsComputer.importantPoints;
    return purgerData;
  }

}


class PurgerData{
  num density;
  num length;
  List<TracePoint> importantPoints = new List<TracePoint>();
}
