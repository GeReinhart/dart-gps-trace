part of gps_trace;

class TraceAnalysis {
 
  List<TracePoint> _points = new List<TracePoint> ();
  num _pointDensity = 0;  // number of points per kilometer

  List<TracePoint> _importantPoints = new List<TracePoint> ();
  
  TracePoint _upperPoint = null ;
  TracePoint _lowerPoint = null ;
  
  num _lengthUp = 0 ; // in meters  
  num _upRelatedToDistanceUp = 0 ; // in meters 
  num _lengthFlat = 0 ; // in meters
  num _lengthDown = 0 ; // in meters 
  num _downRelatedToDistanceDown =0 ; // in meters 
  
  num _inclinationUp = 0;
  num _inclinationDown = 0;
  
  num _length = 0;  // in meters
  num _down = 0 ; // in meters
  num _up = 0 ; // in meters
  
  num _difficulty = 0;
  
  SmoothingParameters _smoothingParameters = SmoothingParameters.get(SmoothingLevel.NO) ;
  
  TraceAnalysis();

  TraceAnalysis.fromTraceAnalysis( TraceAnalysis traceAnalysis,TraceRawData rawData, {SmoothingLevel  smoothingLevel: SmoothingLevel.NO}  ){
    _points = rawData.points ;
    _pointDensity = traceAnalysis.pointDensity;
    _importantPoints = traceAnalysis.importantPoints;
    _upperPoint = traceAnalysis.upperPoint ;
    _lowerPoint = traceAnalysis.lowerPoint ;
    
    _lengthUp = traceAnalysis.lengthUp ;   
    _lengthFlat =  traceAnalysis.lengthFlat ;
    _lengthDown = traceAnalysis.lengthDown ;  
    
    _inclinationUp = traceAnalysis.inclinationUp;
    _inclinationDown = traceAnalysis.inclinationDown;
    
    _length = traceAnalysis.length; 
    _down = traceAnalysis.down ; 
    _up = traceAnalysis.up ; 
    
    _difficulty = traceAnalysis.difficulty;
   
    _smoothingParameters = SmoothingParameters.get(smoothingLevel);
  }
  
  TraceAnalysis.fromRawData( TraceRawData rawData,  {elevetionThreshold:20,minDistanceThreshold:100}){
    _loadFromRawData( rawData, elevetionThreshold:elevetionThreshold,minDistanceThreshold:minDistanceThreshold );
  }
 
  void  _loadFromRawData( TraceRawData rawData,  {elevetionThreshold:20,minDistanceThreshold:100}  ){

    StreamController pointStream = new StreamController.broadcast( sync: true);

    UpperPointComputer upperPointComputer = new UpperPointComputer(pointStream.stream);
    LowerPointComputer lowerPointComputer = new LowerPointComputer(pointStream.stream);    
    LengthComputer lengthComputer = new LengthComputer(pointStream.stream);
    UpComputer upComputer = new UpComputer(pointStream.stream, elevetionThreshold:elevetionThreshold,minDistanceThreshold:minDistanceThreshold);
    DownComputer downComputer = new DownComputer(pointStream.stream, elevetionThreshold:elevetionThreshold,minDistanceThreshold:minDistanceThreshold);
    DifficultyComputer difficultyComputer = new DifficultyComputer(pointStream.stream);
    PointsComputer pointsComputer = new PointsComputer(pointStream.stream);
    ImportantPointsComputer importantPointsComputer = new ImportantPointsComputer(pointStream.stream); 
    PointDensityComputer pointDensityComputer = new PointDensityComputer(pointStream.stream);
    LengthUpFlatDownComputer lengthUpFlatDownComputer = new LengthUpFlatDownComputer(pointStream.stream);
    
    for (var iter = rawData.points.iterator; iter.moveNext();) {
      pointStream.add(iter.current) ;
    }
    pointStream.close();
    
    this._upperPoint = upperPointComputer.upperPoint ;  
    this._lowerPoint = lowerPointComputer.lowerPoint ;
    this._length = lengthComputer.length;
    this._lengthFlat = ( this._length - _lengthUp - _lengthDown).toInt() ;  
    this._up = upComputer.up;
    this._down = downComputer.down;
    this._difficulty = difficultyComputer.difficulty;
    this._points = pointsComputer.points;
    this._importantPoints = importantPointsComputer.importantPoints;
    this._pointDensity = pointDensityComputer.pointDensity;
    this._inclinationUp = lengthUpFlatDownComputer.inclinationUp;
    this._inclinationDown = lengthUpFlatDownComputer.inclinationDown;
    this._lengthUp = lengthUpFlatDownComputer.lengthUp ;
    this._lengthDown = lengthUpFlatDownComputer.lengthDown ;
    
    num firstPointElevetion = rawData.points.first.elevetion;
    num lastPointElevetion = rawData.points.last.elevetion;
    if ( _upperPoint.elevetion - firstPointElevetion > _up ){
      _up = _upperPoint.elevetion - firstPointElevetion ;
    }
    if ( _upperPoint.elevetion - lastPointElevetion > _down ){
      _down = _upperPoint.elevetion - lastPointElevetion ;
    }    
    if ( _lowerPoint.elevetion - lastPointElevetion > _up ){
      _up = _lowerPoint.elevetion - lastPointElevetion ;
    }
    if ( _upperPoint.elevetion - lastPointElevetion > _down ){
      _down = _upperPoint.elevetion - lastPointElevetion ;
    }
    if ( _upperPoint.index > _lowerPoint.index &&
         _upperPoint.elevetion - _lowerPoint.elevetion > _up ){
      _up = _upperPoint.elevetion - _lowerPoint.elevetion ;
    }
    if ( _upperPoint.index < _lowerPoint.index &&
         _upperPoint.elevetion - _lowerPoint.elevetion > _down ){
      _down = _upperPoint.elevetion - _lowerPoint.elevetion ;
    }    
    
  }
    
  
  List<TracePoint> closePointsFrom(TracePoint point, num distanceMax, {num distanceMinBetween2ClosePoints: 1000}) {
    List<TracePoint> closePoints = new List<TracePoint>();
    DistanceComputer distanceComputer = new DistanceComputer();
    _points.forEach((loopPoint){
      if (distanceComputer.distance(point, loopPoint) < distanceMax ){
        if (   closePoints.isEmpty 
            || _distanceMinBetween(closePoints,loopPoint) > distanceMinBetween2ClosePoints ){
          closePoints.add(loopPoint);      
        }
      }
    });
    return closePoints ;
  }
  
  num _distanceMinBetween(List<TracePoint> points, TracePoint anotherPoint){
    num distanceMin = null;
    points.forEach((loopPoint){
      num currentDistance = ( anotherPoint.distance - loopPoint.distance).abs() ;
      if (distanceMin == null){
        distanceMin = currentDistance ;
      }else{
        if ( distanceMin >  currentDistance ){
          distanceMin = currentDistance ;
        }
      }
    });
    return distanceMin ;
  }
  
  
  List<TracePoint> get points => _points;
  
  List<TracePoint> get importantPoints => _importantPoints;
  
  TraceRawData get rawData => new  TraceRawData.fromPoints( _points  ) ;

  void addPoint(TracePoint point) => _points.add(point) ;
  
  TracePoint get upperPoint => _upperPoint;

  TracePoint get lowerPoint => _lowerPoint;
  
  TracePoint get startPoint =>  _points.isNotEmpty ? _points.first : null ;
  
  num get length => _length ;
  void set length(num length) { this._length = length ;} 
  
  num get down => _down ;
  
  num get up => _up ;
  void set up(num up) { this._up = up ;} 
  
  num get lengthUp =>   _lengthUp ;
  
  num get lengthFlat => _lengthFlat ;
  
  num get lengthDown => _lengthDown ;
  
  num get inclinationUp => _inclinationUp ;
  
  num get inclinationDown => _inclinationDown ;
  
  num get difficulty => _difficulty ;
 
  num get pointDensity => _pointDensity ;
  
  SmoothingParameters get smoothingParameters => _smoothingParameters ;
  
  void setInclination(num inclinationUp, num inclinationDown ){
    _inclinationUp = inclinationUp;
    _inclinationDown = inclinationDown;
  }
}

