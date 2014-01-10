
import 'dart:io';
import 'dart:async';
import 'dart:math' as Math ;

import 'beans.dart' ;
import 'parsers.dart' ;
import 'computers.dart' ;

class TraceAnalysis {
 
  List<TracePoint> _points = new List<TracePoint> ();
  
  TracePoint _upperPoint ;
  TracePoint _lowerPoint ;
  
  num _distanceUp = 0 ; // in meters  > 2% inclination
  num _upRelatedToDistanceUp =0 ; // in meters 
  num _distanceFlat ; // in meters
  num _distanceDown ; // in meters < 2% inclination
  num _downRelatedToDistanceDown =0 ; // in meters 
  
  num _inclinationUp = 0;
  num _inclinationDown = 0;
  
  num _length = 0;  // in meters
  num _down = 0 ; // in meters
  num _up = 0 ; // in meters
  
  num _difficulty = 0;

  String gpxUrl ;
  
  StreamController pointStream = new StreamController.broadcast( sync: true);
  
  TraceAnalysis();

  TraceAnalysis.fromPoints( TraceRawData rawData){
    _loadFromRawData( rawData );
  }
  
  TraceAnalysis.fromGpxFileContent(String gpxFileContent){
    _loadFromContent( gpxFileContent );
  }
  
  static Future<TraceAnalysis> fromGpxFile(File gpxFile){
    return gpxFile.readAsString().then((content) => new TraceAnalysis.fromGpxFileContent(content));
  }
  
  
  void  _loadFromContent( String gpxFileContent ){

    GpxFileParser gpxFileParser = new GpxFileParser() ;
    TraceRawData rawData = gpxFileParser.parseFromContentFile(gpxFileContent) ;
    
    _loadFromRawData( rawData  );
  }
  
  void  _loadFromRawData( TraceRawData rawData  ){
        
    List<TracePoint> points = rawData.points ;
    
    UpperPointComputer upperPointComputer = new UpperPointComputer(pointStream.stream);
    LowerPointComputer lowerPointComputer = new LowerPointComputer(pointStream.stream);    
    LengthComputer lengthComputer = new LengthComputer(pointStream.stream);
    LengthUpFlatDownComputer lengthUpFlatDownComputer = new LengthUpFlatDownComputer(pointStream.stream);
    UpComputer upComputer = new UpComputer(pointStream.stream);
    DownComputer downComputer = new DownComputer(pointStream.stream);
    DifficultyComputer difficultyComputer = new DifficultyComputer(pointStream.stream);
    PointsComputer pointsComputer = new PointsComputer(pointStream.stream);
    
    for (var iter = points.iterator; iter.moveNext();) {
      TracePoint currentPoint = iter.current;
      pointStream.add(currentPoint) ;
      _points.add(currentPoint) ;
    }

    pointStream.close();
    
    this._upperPoint = upperPointComputer.upperPoint ;  
    this._lowerPoint = lowerPointComputer.lowerPoint ;
    this._length = lengthComputer.length;
    this._distanceUp = lengthUpFlatDownComputer.lengthUp ;
    this._distanceDown = lengthUpFlatDownComputer.lengthDown ;
    this._distanceFlat = lengthUpFlatDownComputer.lengthFlat ;  
    this._inclinationUp = lengthUpFlatDownComputer.inclinationUp;
    this._inclinationDown = lengthUpFlatDownComputer.inclinationDown;
    this._up = upComputer.up;
    this._down = downComputer.down;
    this._difficulty = difficultyComputer.difficulty;
    this._points = pointsComputer.points;
  }
    
  List<TracePoint> get points => _points;

  void addPoint(TracePoint point) => _points.add(point) ;
  
  TracePoint get upperPoint => _upperPoint;

  TracePoint get lowerPoint => _lowerPoint;
  
  TracePoint get startPoint =>  _points.isNotEmpty ? _points.first : null ;
  
  num get length => _length ;
  
  num get down => _down ;
  
  num get up => _up ;

  num get distanceUp =>   _distanceUp.round() ;
  
  num get distanceFlat => _distanceFlat.round() ;
  
  num get distanceDown => _distanceDown.round() ;
  
  num get inclinationUp => _inclinationUp ;
  
  num get inclinationDown => _inclinationDown ;
  
  int get difficulty => _difficulty ;
 
}

