
import 'dart:io';
import 'package:unittest/unittest.dart';

import '../lib/gps_trace.dart';

main() {
  
 test('Load gpx file', () {
    File file = new File("test/resources/12590.gpx");
    TraceAnalysis.fromGpxFile(file).then((trace){
      expect(trace.upperPoint.elevetion, equals(238));
      expect(trace.lowerPoint.elevetion, equals(208.029999));
      expect(trace.points.length, equals(158));
      expect(trace.points[0].latitude, equals(45.140394900));    
      expect(trace.points[0].longitude, equals(5.719580050));    
      expect(trace.points[0].elevetion, equals(238));
      expect(trace.points[0].distance, equals(0));  
      expect(trace.points[157].latitude, equals(45.190577800));    
      expect(trace.points[157].longitude, equals(5.726594030));    
      expect(trace.points[157].elevetion, equals(209));     
      expect(trace.points[157].distance, equals(8224.307927187921));
      expect(trace.startPoint.latitude, equals(45.140394900));    
      expect(trace.startPoint.longitude, equals(5.719580050));    
      expect(trace.startPoint.elevetion, equals(238));
      
      expect(trace.difficulty, equals(8));
      expect(trace.length, equals(8224));
      expect(trace.down, equals(35));
      expect(trace.distanceUp, equals(0));
      expect(trace.distanceFlat, equals(8176));
      expect(trace.distanceDown, equals(49));
      expect(trace.inclinationUp, equals(0));
      expect(trace.inclinationDown, equals(3));
    });
    
    file = new File("test/resources/12590_with_errors.gpx");
    TraceAnalysis.fromGpxFile(file).then((trace){
      expect(trace.length, equals(8224));   
      expect(trace.up, equals(480));
      expect(trace.down, equals(509));
    });
    
    file = new File("test/resources/16231.gpx");
    TraceAnalysis.fromGpxFile(file).then((trace){
      expect(trace.length, equals(35855));   
      expect(trace.up, equals(1316));
      expect(trace.down, equals(1316));
    });

    file = new File("test/resources/12645.gpx");
    TraceAnalysis.fromGpxFile(file).then((trace){
      expect(trace.length, equals(21966));   
      expect(trace.up, equals(1031));
      expect(trace.down, equals(1591));
    });
  });
 
 
  test('Calculate distance between 2 points', () {
    TracePoint start =new TracePoint.basic(45.140394900,5.719580050);
    TracePoint end =new TracePoint.basic(45.190577800,5.726594030);
    DistanceComputer distanceComputer = new DistanceComputer();
    double distance = distanceComputer.distance(start, end) ;
    expect(distance.round(), equals(5607));
  });
  
  void checkTrace(String filePath,  num expectedUp, num expectedLength ){
    
    File file = new File(filePath);
    TraceAnalysis.fromGpxFile(file).then((originalTrace){
      
      print("=============: ${filePath}");
      
      num originalDifficulty = originalTrace.difficulty ;
      num originalDensity = originalTrace.pointDensity ;
      num originalLength = originalTrace.length ;
      num originalNumberOfPoints = originalTrace.points.length ;
      num originalUp =  originalTrace.up;
      TracePoint orignialUpperPoint =  originalTrace.upperPoint ;
      List<TracePoint> orignalPoints = originalTrace.points;

      print("originalTrace.difficulty: ${originalTrace.difficulty}");
      print("originalTrace.length: ${originalTrace.length} (expected ${expectedLength})");
      print("originalTrace.pointDensity: ${originalTrace.pointDensity}");
      print("originalTrace.points.length: ${originalTrace.points.length}");
      print("originalTrace.up: ${originalTrace.up} (expected ${expectedUp})");
      print("originalTrace.upperPoint.elevetion: ${originalTrace.upperPoint.elevetion}");
      print("originalTrace.lowerPoint.elevetion: ${originalTrace.lowerPoint.elevetion}");
      
      TraceRawDataPurger traceRawDataPurger = new TraceRawDataPurger(3500) ;
      
      TraceRawData data = new TraceRawData();
      data.points = new List<TracePoint>();
      data.points.addAll(orignalPoints);
      PurgerResult purgedData = traceRawDataPurger.purge(data);
      
      TraceAnalysis purgeTrace = new TraceAnalysis.fromPoints(purgedData.rawData);
      
      purgedData.purgerData.actions.forEach( (action) => print( " done : " + action.toString())  ) ;
      
      print("purgeTrace.difficulty: ${purgeTrace.difficulty}");
      print("purgeTrace.length: ${purgeTrace.length} (expected ${expectedLength})");
      print("purgeTrace.pointDensity: ${purgeTrace.pointDensity}");
      print("purgeTrace.points.length: ${purgeTrace.points.length}");
      print("purgeTrace.up: ${purgeTrace.up} (expected ${expectedUp})");
      print("purgeTrace.upperPoint.elevetion: ${purgeTrace.upperPoint.elevetion}");
      print("purgeTrace.lowerPoint.elevetion: ${purgeTrace.lowerPoint.elevetion}");
      
      num errorPercentage = 0.025 ;
      expect ( purgeTrace.length , greaterThan( expectedLength * (1-errorPercentage)  ) ) ;
      expect ( purgeTrace.length , lessThan( expectedLength * (1+errorPercentage)  ) ) ;
      
      errorPercentage = 0.06 ;
      expect ( purgeTrace.up , greaterThan( expectedUp * (1-errorPercentage)  ) ) ;
      expect ( purgeTrace.up , lessThan( expectedUp * (1+errorPercentage)  ) ) ;
      
      
    });
    
  }  
   
  
  test('Purge gpx file check values compared to other websites', () {
    
    // http://www.openrunner.com/index.php?id=2310762 (ut4m)
    checkTrace("test/resources/openrunner.com.2310762.gpx", 10115, 167832) ;
    // http://www.openrunner.com/index.php?id=3112821 (utmb)
    checkTrace("test/resources/openrunner.com.3112821.gpx", 8810, 165037) ;
    // http://www.tracegps.com/fr/parcours/circuit4027.htm (grands ducs)
    checkTrace("test/resources/tracegps.com.4027.gpx", 5389, 81780) ;
    
    
  });

  
  
  
  
  
}
