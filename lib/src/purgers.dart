part of gps_trace;


class TraceRawDataPurger{
  
  num maxDensity ;
  num maxPointNumber;
  
  TraceRawDataPurger(this.maxDensity, this.maxPointNumber);
  
  TraceRawData purge(TraceRawData input){
    
    PurgerData purgerData = _analyse(input);
    num currentDensity = purgerData.density;
    num currentPointNumber = input.points.length;
    if ( currentDensity<=maxDensity && currentPointNumber<=maxPointNumber  ){
      return input;
    }

    num densityWithMaxPointNumber = maxPointNumber / purgerData.length * 1000 ;
    if (densityWithMaxPointNumber > maxDensity){
      return _purgeByDensityMax(input,purgerData,maxDensity);
    }else{
      return _purgeByDensityMax(input,purgerData,densityWithMaxPointNumber);
    }
  }
  
  TraceRawData _purgeByDensityMax(TraceRawData data, PurgerData purgerData, num maxDensity){
    
    TraceRawData purgedRawData = new TraceRawData();
    BaryCenterComputer baryCenterComputer = new BaryCenterComputer();

    double numberCurrentPointsToReplace = purgerData.density / maxDensity ;

    List<TracePoint> points = new List<TracePoint>() ;
    List<TracePoint> pointsToMerge = new List<TracePoint>() ;
    int numberPointComputed= 0;
    for (var iter = data.points.iterator; iter.moveNext();) {
      TracePoint currentPoint = iter.current ;
      numberPointComputed++;
      
      if ( purgerData.importantPoints.contains(currentPoint)  ){
        // Important point
        if(pointsToMerge.isNotEmpty){
          points.add(baryCenterComputer.baryCenter(pointsToMerge));
          pointsToMerge = new List<TracePoint>() ;
        }
        points.add(currentPoint);
      }
      else{
        // Not important point
        double avgCurrentPointsReplaced = numberPointComputed/points.length ;
        if (  avgCurrentPointsReplaced > numberCurrentPointsToReplace    ) {
          points.add(baryCenterComputer.baryCenter(pointsToMerge)) ;
          pointsToMerge = new List<TracePoint>() ;
          pointsToMerge.add(currentPoint) ;
        }else{
          pointsToMerge.add(currentPoint) ;
        }
      }
    }
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
