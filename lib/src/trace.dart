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
  
  TraceAnalysis();

  TraceAnalysis.fromTraceAnalysis( TraceAnalysis traceAnalysis,TraceRawData rawData){
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
  }
  
  TraceAnalysis.fromRawData( TraceRawData rawData){
    _loadFromRawData( rawData );
  }
 
  void  _loadFromRawData( TraceRawData rawData  ){

    StreamController pointStream = new StreamController.broadcast( sync: true);

    UpperPointComputer upperPointComputer = new UpperPointComputer(pointStream.stream);
    LowerPointComputer lowerPointComputer = new LowerPointComputer(pointStream.stream);    
    LengthComputer lengthComputer = new LengthComputer(pointStream.stream);
    UpComputer upComputer = new UpComputer(pointStream.stream);
    DownComputer downComputer = new DownComputer(pointStream.stream);
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
    
  }
    
  List<TracePoint> get points => _points;
  
  List<TracePoint> get importantPoints => _importantPoints;
  
  TraceRawData get rawData => new  TraceRawData.fromPoints( _points  ) ;

  void addPoint(TracePoint point) => _points.add(point) ;
  
  TracePoint get upperPoint => _upperPoint;

  TracePoint get lowerPoint => _lowerPoint;
  
  TracePoint get startPoint =>  _points.isNotEmpty ? _points.first : null ;
  
  num get length => _length ;
  
  num get down => _down ;
  
  num get up => _up ;

  num get lengthUp =>   _lengthUp ;
  
  num get lengthFlat => _lengthFlat ;
  
  num get lengthDown => _lengthDown ;
  
  num get inclinationUp => _inclinationUp ;
  
  num get inclinationDown => _inclinationDown ;
  
  num get difficulty => _difficulty ;
 
  num get pointDensity => _pointDensity ;
  
  void setInclination(num inclinationUp, num inclinationDown ){
    _inclinationUp = inclinationUp;
    _inclinationDown = inclinationDown;
  }
}

