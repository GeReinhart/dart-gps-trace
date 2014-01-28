
import 'dart:io';
import 'package:unittest/unittest.dart';

import '../lib/gps_trace.dart';

main() {
  
  test('Calculate distance between 2 points', () {
    TracePoint start =new TracePoint.basic(45.140394900,5.719580050);
    TracePoint end =new TracePoint.basic(45.190577800,5.726594030);
    DistanceComputer distanceComputer = new DistanceComputer();
    double distance = distanceComputer.distance(start, end) ;
    expect(distance.round(), equals(5607));
  });  
  
 test('Analyse a gpx file', () {
    File file = new File("test/resources/openrunner.com.1255360.gpx"); // Chamchaude
    TraceAnalysis.fromGpxFile(file).then((trace){
      expect(trace.upperPoint.elevetion, equals(2041));
      expect(trace.lowerPoint.elevetion, equals(1321));
      expect(trace.points.length, equals(105));
      expect(trace.points[0].latitude, equals(45.28948));    
      expect(trace.points[0].longitude, equals(5.76706));    
      expect(trace.points[0].elevetion, equals(1321));
      expect(trace.points[0].distance, equals(0));  
      expect(trace.points[104].latitude, equals(45.28948));    
      expect(trace.points[104].longitude, equals(5.76706));    
      expect(trace.points[104].elevetion, equals(1321));     
      expect(trace.points[104].distance, equals(7659.886211803909));
      expect(trace.startPoint.latitude, equals(45.28948));    
      expect(trace.startPoint.longitude, equals(5.76706));    
      expect(trace.startPoint.elevetion, equals(1321));
      expect(trace.up, equals(720));
      expect(trace.inclinationUp, equals(34));  
    });
    
  });
 
 
 test('Check difficulty between a long flat trace and short trace with a bit of elevetion is still consistent', () {
   File file = new File("test/resources/la-boussole-foullee_de_crossey.gpx");
   TraceAnalysis.fromGpxFile(file).then((trace){
     
     num foulleeDifficulty = trace.difficulty ;
     
     file = new File("test/resources/la-boussole-la_saintelyon.gpx");
     TraceAnalysis.fromGpxFile(file).then((trace){
       num sainteLyonDifficulty = trace.difficulty ;
       expect ( foulleeDifficulty*2 , lessThan(sainteLyonDifficulty  ) ) ;
     });
   });
 });
 
 
  void printTrace(TraceAnalysis trace){
    print("difficulty: ${trace.difficulty}");
    print("length: ${trace.length} ");
    print("pointDensity: ${trace.pointDensity}");
    print("points.length: ${trace.points.length}");
    print("up: ${trace.up}");
    print("down: ${trace.down}");
    print("upperPoint.elevetion: ${trace.upperPoint.elevetion}");
    print("lowerPoint.elevetion: ${trace.lowerPoint.elevetion}");
    print("inclinationUp: ${trace.inclinationUp}");
  }
  
  void checkUpAndLengthComputing(String filePath,  num expectedUp, num expectedLength ){
    
    File file = new File(filePath);
    TraceAnalysis.fromGpxFile(file).then((originalTrace){
      
      num originalDifficulty = originalTrace.difficulty ;
      num originalDensity = originalTrace.pointDensity ;
      num originalLength = originalTrace.length ;
      num originalNumberOfPoints = originalTrace.points.length ;
      num originalUp =  originalTrace.up;
      TracePoint orignialUpperPoint =  originalTrace.upperPoint ;
      List<TracePoint> orignalPoints = originalTrace.points;

      
      TraceAnalysis purgeTrace = originalTrace.computeNewPurgedTraceAnalysis(idealMaxPointNumber: 3500);
      
      print("=============: ${filePath}");
      printTrace(purgeTrace) ;
      
      num errorPercentage = 1.5 / 100 ;
      expect ( purgeTrace.length , greaterThan( expectedLength * (1-errorPercentage)  ) ) ;
      expect ( purgeTrace.length , lessThan( expectedLength * (1+errorPercentage)  ) ) ;
      
      errorPercentage = 3 / 100 ;
      expect ( purgeTrace.up , greaterThan( expectedUp * (1-errorPercentage)  ) ) ;
      expect ( purgeTrace.up , lessThan( expectedUp * (1+errorPercentage)  ) ) ;
      
      
    });
    
  }  
   
  
  test('Check gpx file up and length computing values are consistent compared to other websites', () {
    
    // http://www.openrunner.com/index.php?id=1255360 (chamchaude)
    checkUpAndLengthComputing("test/resources/openrunner.com.1255360.gpx", 703, 7665) ;
    // http://www.openrunner.com/index.php?id=2310762 (ut4m)
    checkUpAndLengthComputing("test/resources/openrunner.com.2310762.gpx", 10115, 167832) ;
    // http://www.openrunner.com/index.php?id=3112821 (utmb)
    checkUpAndLengthComputing("test/resources/openrunner.com.3112821.gpx", 8810, 165037) ;
    // http://www.openrunner.com/index.php?id=2647279 (grands ducs)
    checkUpAndLengthComputing("test/resources/openrunner.com.2647279.gpx", 4735, 76449) ;
    // http://www.openrunner.com/index.php?id=2863888 (echappee belle)
    checkUpAndLengthComputing("test/resources/openrunner.com.2863888.gpx", 10403, 136142) ;
  });

  void checkProfile(String filePath ){
    
    File file = new File(filePath);
    TraceAnalysis.fromGpxFile(file).then((originalTrace){
      
      print("=============: ${filePath}");
      num originalLength = originalTrace.length ;
      print("originalTrace.points.length: ${originalTrace.points.length} ");
      TraceRawData dataProfile = originalTrace.computeProfile() ;
      expect ( dataProfile.points.length , lessThan( 600) ) ;
      print("dataProfile.points.length: ${dataProfile.points.length} ");
      
    });
    
  }  
  
  
  test('Check the profiler', () {
    checkProfile("test/resources/openrunner.com.2310762.gpx") ;
  });
  
  
  
  
}
