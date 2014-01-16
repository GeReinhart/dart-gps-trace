part of gps_trace;


class TraceRawDataPurger{
  
  static const num ALIGNMENT_ALLOWED_ERROR_STEP =  0.005 ;
  static const num SMOOTHING_DENSITY_THRESHOLD =  1000/30 ;
  static const num SMOOTHING_THRESHOLD =  10;
  
  num idealMaxPointNumber;
  
  TraceRawDataPurger(this.idealMaxPointNumber);
  
  PurgerResult purge(TraceRawData input){
    
    TraceRawData purgedTraceRawData = input;
    PurgerData purgerData = _analyse(input);
    
    purgedTraceRawData = _purgeAlignedPoints(purgedTraceRawData,purgerData) ;
    purgedTraceRawData = _applySmoothing(purgedTraceRawData,purgerData) ;
    purgedTraceRawData = _applyElevetionAverage(purgedTraceRawData,purgerData) ;
    
    return new PurgerResult(purgedTraceRawData,purgerData);
  }

  TraceRawData _applySmoothing(TraceRawData data, PurgerData purgerData){
    TraceRawData purgedTraceRawData = data;
    
    if ( purgerData.originalDensity > SMOOTHING_DENSITY_THRESHOLD ){
      purgedTraceRawData = _applySmoothingWithThreshold(purgedTraceRawData,purgerData,SMOOTHING_THRESHOLD);

      PurgerAction action = new PurgerAction();
      action.action= "ApplyElevetionSmoothing" ;
      action.parameterName ="IgnoreElevetionThreshold" ;
      action.parameterValue =SMOOTHING_THRESHOLD;
      purgerData.actions.add(action); 
    }
    
    return purgedTraceRawData; 
  }

  
  TraceRawData _applySmoothingWithThreshold(TraceRawData data, PurgerData purgerData, num smoothingThreshold){
    for(int i = 1 ; i < data.points.length - 1; i++  ){
      TracePoint previousPoint = data.points.elementAt(i-1);
      TracePoint currentPoint = data.points.elementAt(i);
      TracePoint nextPoint = data.points.elementAt(i+1);
      
      if (_isImportantPoint(purgerData,currentPoint)){
        continue;
      }
      
      if (  currentPoint.elevetion - smoothingThreshold > previousPoint.elevetion 
         || currentPoint.elevetion + smoothingThreshold < previousPoint.elevetion
         ){
        currentPoint.elevetion = (  previousPoint.elevetion + nextPoint.elevetion  ) / 2 ;
      }
    }
    return data;
  }
  
  TraceRawData _applyElevetionAverage(TraceRawData data, PurgerData purgerData){
    TraceRawData purgedTraceRawData = data ;
    int pointsToMergeEachSide = (purgerData.originalDensity / 10).truncate() - 4 ;
    if (pointsToMergeEachSide>0){
      purgedTraceRawData = _applyElevetionAverageWithMergeWidth(purgedTraceRawData,purgerData,pointsToMergeEachSide);
      PurgerAction action = new PurgerAction();
      action.action= "ApplyElevetionAverage" ;
      action.parameterName ="ElevationMergedFromXPoints" ;
      action.parameterValue =pointsToMergeEachSide*2  +1 ;
      purgerData.actions.add(action);      
    }
    return purgedTraceRawData;
  }
  
  TraceRawData _applyElevetionAverageWithMergeWidth(TraceRawData data, PurgerData purgerData, int pointsToMergeEachSide){
    
    for(int i = pointsToMergeEachSide ; i < data.points.length - pointsToMergeEachSide -1 ; i++  ){
      TracePoint currentPoint = data.points.elementAt(i);
      
      if (_isImportantPoint(purgerData,currentPoint)){
        continue;
      }      
      
      num elevetion= 0;
      for ( int j = i-pointsToMergeEachSide ; j  <= i + pointsToMergeEachSide ; j++    ){
        elevetion+=data.points.elementAt(j).elevetion;
      }
      currentPoint.elevetion = elevetion / (pointsToMergeEachSide*2+1) ;
    }
    return data;
  }   
  
  TraceRawData _purgeAlignedPoints(TraceRawData data,PurgerData purgerData){
    TraceRawData purgedTraceRawData = data ;
    PurgerAction action = new PurgerAction();
    action.action= "PurgeAlignedPoints" ;
    action.parameterName ="ErrorPercentage" ;
    if (data.points.length >  idealMaxPointNumber  ){
      purgerData.actions.add(action);
      for (int i=1 ; i<= 2 ; i++ ){
        purgedTraceRawData = _purgeAlignedPointsWithAllowedError(data,purgerData,ALIGNMENT_ALLOWED_ERROR_STEP*i) ;
        action.parameterValue =ALIGNMENT_ALLOWED_ERROR_STEP*i ;
        if (  purgedTraceRawData.points.length <=  idealMaxPointNumber ){
          return purgedTraceRawData;
        }
      }
    }
    return purgedTraceRawData; 
  }
  
  TraceRawData _purgeAlignedPointsWithAllowedError(TraceRawData data,PurgerData purgerData, num alignmentAllowedError){
    
    TraceRawData purgedRawData = new TraceRawData();
    List<TracePoint> points = new List<TracePoint>() ;
    DistanceComputer distanceComputer = new DistanceComputer();
    
    
    points.add(data.points.elementAt(0)) ;
    for(int i = 1 ; i < data.points.length - 1; i++  ){
      TracePoint previousPoint = data.points.elementAt(i-1);
      TracePoint currentPoint = data.points.elementAt(i);
      TracePoint nextPoint = data.points.elementAt(i+1);
      
      if (_isImportantPoint(purgerData,currentPoint)){
        points.add(currentPoint) ;
        continue;
      }      
      
      double  previousToCurrent = distanceComputer.distance(previousPoint, currentPoint) ;
      double  currentToNext = distanceComputer.distance(currentPoint, nextPoint) ;
      double  previousToNext = distanceComputer.distance(previousPoint, nextPoint) ;

      if (  (previousToCurrent+currentToNext) * (1-alignmentAllowedError) <  previousToNext ){
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
    purgerData.originalDensity = pointDensityComputer.pointDensity;
    purgerData.originalLength  = lengthComputer.length;
    purgerData.importantPoints = importantPointsComputer.importantPoints;
    return purgerData;
  }

  bool _isImportantPoint(PurgerData purgerData, TracePoint currentPoint) {
    return purgerData.importantPoints != null && purgerData.importantPoints.contains(currentPoint);
  }
  
}



class PurgerResult{
  TraceRawData rawData ;
  PurgerData purgerData;
  
  PurgerResult(this.rawData, this.purgerData);
}


class PurgerData{
  num originalDensity;
  num originalLength;
  List<PurgerAction> actions = new List<PurgerAction>();
  List<TracePoint> importantPoints = new List<TracePoint>();
}

class PurgerAction{
  String action ;
  String parameterName ;
  num parameterValue ;
  
  String toString() => "${action} with ${parameterName}=${parameterValue}" ;
}
