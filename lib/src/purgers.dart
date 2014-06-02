part of gps_trace;


class TraceRawDataPurger{
  
  static const num ALIGNMENT_ALLOWED_ERROR_STEP =  0.005 ;
  static const num SMOOTHING_DENSITY_THRESHOLD =  1000/30 ;
  static const num SMOOTHING_THRESHOLD =  10;
  
  TraceRawDataPurger();
  
  PurgerResult purge(TraceRawData data, int idealMaxPointNumber, { bool cloneData: false }){
    
    TraceRawData purgedTraceRawData =   cloneData ? data.clone() : data ;
    PurgerData purgerData = _analyse(data);
    
    purgedTraceRawData = deleteAlignedPoints(purgedTraceRawData,idealMaxPointNumber,purgerData:purgerData).rawData ;
    purgedTraceRawData = applySmoothingWithThreshold(purgedTraceRawData,purgerData:purgerData).rawData ;
    purgedTraceRawData = applySmoothingWithElevetionAverage(purgedTraceRawData,purgerData:purgerData).rawData ;
    
    return new PurgerResult(purgedTraceRawData,purgerData);
  }

  PurgerResult applySmoothingWithThreshold(TraceRawData data, { bool cloneData: false , PurgerData purgerData : null  }){
      
    PurgerResult result = _initPurgerResult(  data,  cloneData,  purgerData );
    
    if ( result.purgerData.originalDensity > SMOOTHING_DENSITY_THRESHOLD ){
      result.rawData = _applySmoothingWithThreshold(result.rawData,result.purgerData,SMOOTHING_THRESHOLD);

      PurgerAction action = new PurgerAction();
      action.action= "ApplyElevetionSmoothing" ;
      action.parameterName ="IgnoreElevetionThreshold" ;
      action.parameterValue =SMOOTHING_THRESHOLD;
      result.addPurgerAction(action); 
    }
    
    return result; 
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
  
  PurgerResult applySmoothingWithElevetionAverage(TraceRawData data,
                                                  { bool cloneData: false,
                                                   PurgerData purgerData : null,
                                                   int pointsToMergeEachSide: null,
                                                   int maxDistanceWithinMergedPoints: null}){
    
    PurgerResult result = _initPurgerResult(  data,  cloneData,  purgerData );
  
    if(  pointsToMergeEachSide == null ){
       pointsToMergeEachSide = (purgerData.originalDensity / 10).truncate() - 4 ;
    }
    if(  maxDistanceWithinMergedPoints == null ){
      maxDistanceWithinMergedPoints = pointsToMergeEachSide * 25 ;
    }    
    
    if (pointsToMergeEachSide>0){
      result.rawData = _applySmoothingWithElevetionAverage(result.rawData,result.purgerData,pointsToMergeEachSide,maxDistanceWithinMergedPoints);
      PurgerAction action = new PurgerAction();
      action.action= "ApplyElevetionAverage" ;
      action.parameterName ="ElevationMergedFromXPoints" ;
      action.parameterValue =pointsToMergeEachSide*2  +1 ;
      result.addPurgerAction(action);      
    }
    return result;
  }
  
  TraceRawData _applySmoothingWithElevetionAverage(TraceRawData data, PurgerData purgerData, int pointsToMergeEachSide, int maxDistanceWithinMergedPoints){
    
    DistanceComputer distanceComputer = new DistanceComputer();
    for(int i = pointsToMergeEachSide ; i < data.points.length - pointsToMergeEachSide -1 ; i++  ){
      TracePoint currentPoint = data.points.elementAt(i);
      
      if (_isImportantPoint(purgerData,currentPoint)){
        continue;
      }      
      
      List<TracePoint> pointsToMerge = new List();
      pointsToMerge.add(currentPoint);
      for ( int j = i-pointsToMergeEachSide ; j  <= i + pointsToMergeEachSide ; j++    ){
        TracePoint pointToMergeCandidate = data.points.elementAt(j);
        if (distanceComputer.distance(currentPoint, pointToMergeCandidate) <=  maxDistanceWithinMergedPoints ){
          pointsToMerge.add(pointToMergeCandidate);
        }
      }
      num elevetion= 0;
      pointsToMerge.forEach(  (point) => elevetion += point.elevetion  ) ;
      currentPoint.elevetion = elevetion / pointsToMerge.length ;
    }
    return data;
  }   
  
  PurgerResult deleteAlignedPoints(TraceRawData data, int idealMaxPointNumber, { bool cloneData: false , PurgerData purgerData : null  }){
    PurgerResult result = _initPurgerResult(  data,  cloneData,  purgerData );
    
    PurgerAction action = new PurgerAction();
    action.action= "PurgeAlignedPoints" ;
    action.parameterName ="ErrorPercentage" ;
    if (result.rawDataSize >  idealMaxPointNumber  ){
      result.addPurgerAction(action);
      for (int i=1 ; i<= 2 ; i++ ){
        result.rawData = _deleteAlignedPoints(result.rawData,result.purgerData,ALIGNMENT_ALLOWED_ERROR_STEP*i) ;
        action.parameterValue =ALIGNMENT_ALLOWED_ERROR_STEP*i ;
        if (  result.rawDataSize <=  idealMaxPointNumber ){
          return result;
        }
      }
    }
    return result; 
  }
   
  TraceRawData _deleteAlignedPoints(TraceRawData data,PurgerData purgerData, num alignmentAllowedError){
    
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

  PurgerResult _initPurgerResult( TraceRawData data, bool cloneData , PurgerData purgerData ){
    if (purgerData == null){
      purgerData = new PurgerData();
    }
    TraceRawData purgedTraceRawData = data ;
    if (cloneData){
      purgedTraceRawData = data.clone();
    }
    return  new PurgerResult(purgedTraceRawData,purgerData);
  }
  
  bool _isImportantPoint(PurgerData purgerData, TracePoint currentPoint) {
    return purgerData.importantPoints != null && purgerData.importantPoints.contains(currentPoint);
  }
  
}



class PurgerResult{
  TraceRawData rawData ;
  PurgerData purgerData;
  
  PurgerResult(this.rawData, this.purgerData);
  
  void addPurgerAction(PurgerAction action){
    purgerData.actions.add(action);
  }
  int get rawDataSize => rawData.points.length ;
  
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
