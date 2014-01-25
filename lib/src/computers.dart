part of gps_trace;

class UpperPointComputer{
  
  TracePoint _upperPoint ;
  
  UpperPointComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point == null){
      return;
    }
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
    if(point==null){
      return;
    }
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
    if(point==null){
      return;
    }    
    if(  _previousPoint != null ){
      _length += distanceComputer.distance(_previousPoint, point);
    }
    _previousPoint = point ;
  }
  
  get length => _length.round();
}

class PointDensityComputer{
  
  LengthComputer _distanceComputer ;
  num _pointNumber = 0 ;
  
  PointDensityComputer(Stream stream){
    _distanceComputer = new LengthComputer(stream);
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point==null){
      return;
    }    
    _pointNumber++ ;
  }
  
  get pointDensity => _pointNumber == 0 ? 0 : _pointNumber / _distanceComputer.length * 1000;  
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
    if(point==null){
      return;
    }    
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
  num _elevetionThreshold ;
  num _minDistanceThreshold ;
  num _up = 0.0 ;
  TracePoint _lowBase ;
  TracePoint _upBase ;
  
  UpComputer(Stream stream, {elevetionThreshold:60,minDistanceThreshold:200}){
    this._elevetionThreshold = elevetionThreshold;
    this._minDistanceThreshold = minDistanceThreshold;
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point==null){
      return;
    }    
    if(point.elevetion==null){
      return;
    }  
    if(  _previousPoint == null ){
      _lowBase = point;
      _upBase = point ;
    }else{
      
      if ( _lowBase.elevetion > point.elevetion  ){
          // lower than the lower point
          _lowBase = point ;
          _upBase = point ;
      }else{
          // higher than the lower point 
          if ( _upBase.elevetion < point.elevetion ){
             // higher than the higher point
             _upBase = point ;
          }else{
             // between lower and higher point
             if ( _upBase.elevetion - _elevetionThreshold  > point.elevetion){
                // register the up
                num distanceLowUp = distanceComputer.distance(_upBase,_lowBase).abs() ;
                if( distanceLowUp > _minDistanceThreshold  ){
                 _up += _upBase.elevetion - _lowBase.elevetion ;
                 _lowBase = point ;
                 _upBase = point;
                }
             }
          }
       }
    }
    _previousPoint = point ;
  }
  
  int get up => _up.round();
}

class DownComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  num _elevetionThreshold ;
  num _minDistanceThreshold ;
  num _down = 0.0 ;
  TracePoint _lowBase ;
  TracePoint _upBase ;
  
  DownComputer(Stream stream, {elevetionThreshold:60,minDistanceThreshold:200}){
    this._elevetionThreshold = elevetionThreshold;
    this._minDistanceThreshold = minDistanceThreshold;
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point==null){
      return;
    }    
    if(point.elevetion==null){
      return;
    }  
    if(  _previousPoint == null ){
      _lowBase = point;
      _upBase = point ;
    }else{
      
      if ( _upBase.elevetion < point.elevetion  ){
          // higer than the higher point
          _lowBase = point ;
          _upBase = point ;
      }else{
          // lower than the higher point 
          if ( _lowBase.elevetion > point.elevetion ){
             // lower than the lower point
            _lowBase = point ;
          }else{
             // between lower and higher point
             if ( _lowBase.elevetion + _elevetionThreshold  < point.elevetion){
                // register the low
                num distanceLowUp = distanceComputer.distance(_upBase,_lowBase).abs() ;
                if( distanceLowUp > _minDistanceThreshold  ){
                 _down += _upBase.elevetion - _lowBase.elevetion ;
                 _lowBase = point ;
                 _upBase = point;
                }
             }
          }
       }
    }
    _previousPoint = point ;
  }
  
  int get down => _down.round();
}

class AvgElevetionComputer{
  
  num _elevetionSum = 0 ;
  num _pointsNumber=0 ;
      
  AvgElevetionComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    _elevetionSum +=  point.elevetion  ;  
    _pointsNumber++;
  }
  
  get avgElevetion => _pointsNumber==0?0:   (_elevetionSum/_pointsNumber).round() ;
}

class DifficultyComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  UpComputer upComputer ;
  DownComputer downComputer ;
  LengthComputer lengthComputer;
  AvgElevetionComputer avgElevetionComputer;
  
  num _difficulty = 0;
  
  DifficultyComputer(Stream stream){
    upComputer= new UpComputer(stream);
    downComputer= new DownComputer(stream);
    lengthComputer = new LengthComputer(stream);
    avgElevetionComputer = new AvgElevetionComputer(stream);
  }
  
  
  static const double ONE_KILOMETER_LENGTH_FACTOR = 1.00  ;
  static const double ONE_HUNDRED_UP_FACTOR       = 0.75  ; 
  static const double ONE_HUNDRED_DOWN_FACTOR     = 0.25 ;
  static const double ELEVETION_THRESHOLD = 1500.0;
  
  void _computeDifficulty(){
    
    if (_difficulty>0){
      return;
    }
    
    num length            = lengthComputer.length ;
    num currentDifficulty = length / 1000 *  ONE_KILOMETER_LENGTH_FACTOR;
    currentDifficulty     += upComputer.up / 100 * ONE_HUNDRED_UP_FACTOR ;
    currentDifficulty     += downComputer.down / 100 * ONE_HUNDRED_DOWN_FACTOR;

    double elevetionFactor = 1.0 ;
    num avgElevetion = avgElevetionComputer.avgElevetion ;
    if (avgElevetion > ELEVETION_THRESHOLD){
        elevetionFactor = (avgElevetion / ELEVETION_THRESHOLD) ;
     }
    _difficulty = (currentDifficulty * elevetionFactor).round() ;
  }
  
  num get difficulty { 
    _computeDifficulty();
    return _difficulty;
  }
  
}

class PointsComputer{
  
  DistanceComputer distanceComputer = new DistanceComputer();
  TracePoint _previousPoint ;
  double _length = 0.0 ;
  List<TracePoint> _points = new List<TracePoint> ();
  
  PointsComputer(Stream stream){
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point==null){
      return;
    }    
    if(  _previousPoint != null ){
      _length += distanceComputer.distance(_previousPoint, point);
    }
    point.distance = _length;
    _points.add(point) ;
    _previousPoint = point;
  }
  
  List<TracePoint>  get points => _points;
}

class ImportantPointsComputer{
  
  LowerPointComputer lowerPointComputer;
  UpperPointComputer upperPointComputer;
  TracePoint firstPoint = null;
  TracePoint lastPoint = null;
  
  ImportantPointsComputer(Stream stream){
    lowerPointComputer = new LowerPointComputer(stream);
    upperPointComputer = new UpperPointComputer(stream);
    stream.listen((point) => _compute(point as TracePoint)) ;
  }
  
  void _compute(TracePoint point){
    if(point==null){
      return;
    }    
    if(  firstPoint == null ){
      firstPoint = point;
    }
    lastPoint = point;
  }

  List<TracePoint>  get importantPoints {
    List<TracePoint> points = new List<TracePoint>();
    points.add( firstPoint   ) ;
    points.add( lowerPointComputer.lowerPoint   ) ;
    points.add( upperPointComputer.upperPoint   ) ;
    points.add( lastPoint   ) ;
    return points;
  }
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
    
    return  distance ==0 ? 0 :  (Math.tan(  elevetionDiff/distance ) * 100).round() ;
  }
}

class BaryCenterComputer{
  TracePoint baryCenter(List<TracePoint> points){
    if (points == null || points != null &&  points.isEmpty){
      return null ;
    }
    if (points.length == 1){
      return points.first ;
    }
    TracePoint baryCenter = new TracePoint();
    points.forEach((point){ 
      baryCenter.elevetion += point.elevetion ;
      baryCenter.latitude += point.latitude ;
      baryCenter.longitude += point.longitude ;
    });
    
    baryCenter.elevetion = baryCenter.elevetion / points.length ;
    baryCenter.latitude = baryCenter.latitude / points.length ;
    baryCenter.longitude = baryCenter.longitude / points.length ;
    
    return baryCenter ;
  }
}

