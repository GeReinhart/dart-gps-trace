
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
  
  test('Load purge gpx file', () {
    File file = new File("test/resources/13523.gpx");
    TraceAnalysis.fromGpxFile(file).then((trace){
      
      num originalDifficulty = trace.difficulty ;
      num originalDensity = trace.pointDensity ;
      num originalLength = trace.length ;
      num originalNumberOfPoints = trace.points.length ;
      num originalUp =  trace.up;
      TracePoint orignialUpperPoint =  trace.upperPoint ;
      List<TracePoint> orignalPoints = trace.points;

      print("trace.difficulty: ${trace.difficulty}");
      print("trace.length: ${trace.length}");
      print("trace.pointDensity: ${trace.pointDensity}");
      print("trace.points.length: ${trace.points.length}");
      print("trace.up: ${trace.up}");
      print("trace.upperPoint.elevetion: ${trace.upperPoint.elevetion}");
      print("trace.lowerPoint.elevetion: ${trace.lowerPoint.elevetion}");
      
      TraceRawDataPurger traceRawDataPurger = new TraceRawDataPurger( 1000/20 , 1200  ) ;
      
      TraceRawData data = new TraceRawData();
      data.points = new List<TracePoint>();
      data.points.addAll(orignalPoints);
      var purgedData = traceRawDataPurger.purge(data);
      
      TraceAnalysis purgeTrace = new TraceAnalysis.fromPoints(purgedData);
      
      print("purgeTrace.difficulty: ${purgeTrace.difficulty}");
      print("purgeTrace.length: ${purgeTrace.length}");
      print("purgeTrace.pointDensity: ${purgeTrace.pointDensity}");
      print("purgeTrace.points.length: ${purgeTrace.points.length}");
      print("purgeTrace.up: ${purgeTrace.up}");
      print("purgeTrace.upperPoint.elevetion: ${purgeTrace.upperPoint.elevetion}");
      print("purgeTrace.lowerPoint.elevetion: ${purgeTrace.lowerPoint.elevetion}");
      
    });
  });
  
}
