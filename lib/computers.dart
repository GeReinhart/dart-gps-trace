
import 'dart:async';
import 'dart:math' as Math ;

import 'beans.dart' ;

class UpperPointComputer{
  
  TracePoint _upperPoint ;
  
  UpperPointComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _upperPoint == null ){
      _upperPoint = point ;
    }else{
      if (  _upperPoint.elevetion < point.elevetion ){
        _upperPoint = point ;
      }
    }
  }
  
  get upperPoint => _upperPoint ;
  
}

class LowerPointComputer{
  
  TracePoint _lowerPoint ;
  
  LowerPointComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _lowerPoint == null ){
      _lowerPoint = point ;
    }else{
      if (  _lowerPoint.elevetion > point.elevetion ){
        _lowerPoint = point ;
      }
    }
  }
  
  get lowerPoint => _lowerPoint ;
  
}

class LengthComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  num _length = 0 ;
  
  LengthComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _previousPoint != null ){
      _length += distanceComputer.distance(_previousPoint, point);
    }
    _previousPoint = point ;
  }
  
  get length => _length.round();
}

class LengthUpFlatDownComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  InclinationComputer inclinationComputer = new InclinationComputer();
  
  TracePoint _previousPoint ;
  num _lengthUp = 0 ;
  num _lengthDown = 0 ;
  num _lengthFlat = 0 ;
  
  num _upRelatedToLengthUp = 0;
  num _downRelatedToLengthDown = 0;
  
  LengthUpFlatDownComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _previousPoint != null ){
      num distance = distanceComputer.distance(_previousPoint, point);
      num elevationDiff= point.elevetion - _previousPoint.elevetion   ;
      int inclination = inclinationComputer.inclination(elevationDiff, distance);
      
      if( inclination > 2 ){
        _lengthUp += distance ;
        _upRelatedToLengthUp += elevationDiff ;
      }else if (inclination < -2 ){
        _lengthDown += distance ;
        _downRelatedToLengthDown -= elevationDiff ;
      }else{
        _lengthFlat += distance ;
      }
    }
    _previousPoint = point ;
  }
  
  num get lengthUp => _lengthUp.round();
  num get lengthDown => _lengthDown.round();
  num get lengthFlat => _lengthFlat.round();
  num get upRelatedToLengthUp => _upRelatedToLengthUp.round();
  num get downRelatedToLengthDown => _downRelatedToLengthDown.round();
  
  num get inclinationUp {
    if(_lengthUp == 0){
      return 0;
    }    
   return inclinationComputer.inclination(_upRelatedToLengthUp,_lengthUp) ; 
  }

  num get inclinationDown {
    if(_lengthDown == 0){
      return 0;
    }    
   return inclinationComputer.inclination(_downRelatedToLengthDown,_lengthDown) ; 
  }
  
} 

class UpComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  num _up = 0 ;
  
  UpComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _previousPoint != null ){
      if (  _previousPoint.elevetion  < point.elevetion  ){
        _up += point.elevetion - _previousPoint.elevetion ;  
      }
    }
    _previousPoint = point ;
  }
  
  get up => _up.round();
}

class DownComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  num _down = 0 ;
  
  DownComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _previousPoint != null ){
      if (  _previousPoint.elevetion  > point.elevetion  ){
        _down += - point.elevetion + _previousPoint.elevetion ;  
      }
    }
    _previousPoint = point ;
  }
  
  get down => _down.round();
}

class DifficultyComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  InclinationComputer inclinationComputer = new InclinationComputer();
  
  TracePoint _previousPoint ;
  
  List<DistanceInclinationElevetion> _distancesByInclination = new List<DistanceInclinationElevetion> ();
  Map<String,DistanceInclinationElevetion> _distancesByInclinationMap = new Map<String,DistanceInclinationElevetion>();

  num _difficulty = 0;
  
  DifficultyComputer(Stream stream){
    stream.listen((point) => _computePoint(point as TracePoint),
             onDone: () => _computeDifficulty()  ) ;
  }
  
  void _computePoint(TracePoint point){
    if(  _previousPoint != null ){
      num distance = distanceComputer.distance(_previousPoint, point);
      num elevationDiff= point.elevetion - _previousPoint.elevetion   ;
      int inclination = inclinationComputer.inclination(elevationDiff, distance);
      
      if (  !_distancesByInclinationMap.containsKey(inclination.toString()) ){
        _distancesByInclinationMap[inclination.toString()] =  new DistanceInclinationElevetion(inclination.toDouble(),distance,point.elevetion);
      }else{
        _distancesByInclinationMap[inclination.toString()].incDistance(distance) ; 
      }
      
    }
    _previousPoint = point ;
  }
  
  static const double FLAT_INCLINATION_WEIGHT = 1/1000 ;
  static const double DOWN_INCLINATION_WEIGHT = 1/1000 / 5 * 1 ; 
  static const double UP_INCLINATION_WEIGHT   = 1/1000 / 5 * 3 ;
  
  void _computeDifficulty(){
    
    for (int i = -100; i <= 100; i++) {
      if (_distancesByInclinationMap.containsKey(i.toString())){
        _distancesByInclination.add(_distancesByInclinationMap[i.toString()]);
      }
    }
    
    double currentDifficulty = 0.toDouble();
    for (DistanceInclinationElevetion di in _distancesByInclination) {
      
      double loopDifficulty = 0.toDouble();
      if ( di.inclination >=  -2 &&  di.inclination <=  2 ){
        loopDifficulty = di.distance * FLAT_INCLINATION_WEIGHT ;
      }else if ( di.inclination < 0 ){
        loopDifficulty = (di.distance * FLAT_INCLINATION_WEIGHT) +  ( di.distance *  (-di.inclination) * DOWN_INCLINATION_WEIGHT ) ;
      }else{
        loopDifficulty = (di.distance * FLAT_INCLINATION_WEIGHT) +  ( di.distance *  di.inclination * UP_INCLINATION_WEIGHT ) ;
      }
      
      double elevetionFactor = 1.0 ;
      if (di.elevetion > 1000){
        elevetionFactor = di.elevetion / 1000 ; 
      }
      currentDifficulty += (loopDifficulty * elevetionFactor) ;
    }
    _difficulty = currentDifficulty.round() ;
    
  }
  
  num get difficulty { 
    _computeDifficulty();
    return _difficulty.round();
  }
  
}

class PointsComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  num _length = 0 ;
  List<TracePoint> _points = new List<TracePoint> ();
  
  PointsComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(  _previousPoint != null ){
      _length += distanceComputer.distance(_previousPoint, point);
    }
    point.distance = _length;
    _points.add(point) ;
    _previousPoint = point;
  }
  
  List<TracePoint>  get points => _points;
}



class DistanceComputer{
  /* 
  Distance http://www.movable-type.co.uk/scripts/latlong.html
 
  Distance in meters
  */
  double distance(TracePoint start, TracePoint end){
    
    double R = 6371.0; 
    double dLat = ( end.latitude   - start.latitude  ) * Math.PI / 180; 
    double dLon = ( end.longitude  - start.longitude ) * Math.PI / 180;
    double lat1 = (                  start.latitude  ) * Math.PI / 180; 
    double lat2 = (                    end.latitude  ) * Math.PI / 180; 
    
    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    double distance = R * c ;
    return  distance * 1000;
  }
}

class InclinationComputer{
  int inclination(num elevetionDiff, num distance){
    return (Math.tan(  elevetionDiff/distance ) * 100).round() ;
  }
}
