
import 'dart:io';
import 'dart:async';
import 'package:unittest/unittest.dart';

import '../lib/gps_trace.dart';

main() {
  
  TraceAnalyser traceAnalyser = new TraceAnalyser();
  SmoothingParameters high = SmoothingParameters.get( SmoothingLevel.HIGH );
  SmoothingParameters medium = SmoothingParameters.get( SmoothingLevel.MEDIUM );
  SmoothingParameters low = SmoothingParameters.get( SmoothingLevel.LOW );
  SmoothingParameters no = SmoothingParameters.get( SmoothingLevel.NO );
  

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
  
  Future<TraceAnalysis> buildTraceAnalysisFromGpxFile(File gpxFile,{bool applyPurge: false,
    int idealMaxPointNumber:3500, 
    SmoothingParameters smoothingParameters:null}){
    return gpxFile.readAsString().then((gpxFileContent) {
      return traceAnalyser.buildTraceAnalysisFromGpxFileContent(gpxFileContent,applyPurge: applyPurge,
           idealMaxPointNumber:idealMaxPointNumber, 
           smoothingParameters:smoothingParameters);
    });
  }
  
  test('closests points', (){
      
    File file = new File("test/resources/ott-gpx1.0.gpx"); 
    buildTraceAnalysisFromGpxFile(file).then((trace){
      printTrace(trace);
      
      TracePoint point = trace.points[10] ;
      
      List<TracePoint> closePoints = trace.closePointsFrom(point, 100);
      
      expect(closePoints.length, equals(2));
      expect(closePoints.first.latitude, equals(point.latitude));
      expect(closePoints.first.longitude, equals(point.longitude));
      expect(closePoints.last.latitude, equals(point.latitude));
      expect(closePoints.last.longitude, equals(point.longitude));
      
    });
      
  });

  
  test('Analyse a gpx 1.0 file', () {
     File file = new File("test/resources/ott-gpx1.0.gpx"); 
     buildTraceAnalysisFromGpxFile(file).then((trace){
       printTrace(trace);
       expect(trace.points.length, equals(100));
       expect(trace.up, equals(5286));
     });
     
   });
  
  test('Calculate inclination', (){
    
    InclinationComputer inclinationComputer = new InclinationComputer();
    expect( inclinationComputer.inclination(100, 100),  equals(45));
    expect( inclinationComputer.inclination(100, 200),  equals(27));
    expect( inclinationComputer.inclination(100, 300),  equals(18));
    expect( inclinationComputer.inclination(100, 400),  equals(14));
    
  });
    
  
  
  
  test('Get smooting by String', (){
    SmoothingParameters mediumParameter = SmoothingParameters.get( SmoothingLevel.fromString("medium" ));
    expect(medium, equals(mediumParameter));
  });
  
  test('Calculate distance between 2 points', () {
    TracePoint start =new TracePoint.basic(45.140394900,5.719580050);
    TracePoint end =new TracePoint.basic(45.190577800,5.726594030);
    DistanceComputer distanceComputer = new DistanceComputer();
    double distance = distanceComputer.distance(start, end) ;
    expect(distance.round(), equals(5607));
  });  
  
 test('Analyse a gpx 1.1 file', () {
    File file = new File("test/resources/openrunner.com.1255360.gpx"); // Chamchaude
    buildTraceAnalysisFromGpxFile(file).then((trace){
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
      expect(trace.points[104].distance, equals(3467.202540589613));
      expect(trace.startPoint.latitude, equals(45.28948));    
      expect(trace.startPoint.longitude, equals(5.76706));    
      expect(trace.startPoint.elevetion, equals(1321));
      expect(trace.up, equals(925));
      expect(trace.inclinationUp, equals(24));  
    });
    
  });
 

 
 
 test('Check difficulty between a long flat trace and short trace with a bit of elevetion is still consistent', () {
   File file = new File("test/resources/la-boussole-foullee_de_crossey.gpx");
   buildTraceAnalysisFromGpxFile(file).then((trace){
     
     num foulleeDifficulty = trace.difficulty ;
     
     file = new File("test/resources/la-boussole-la_saintelyon.gpx");
     buildTraceAnalysisFromGpxFile(file).then((trace){
       num sainteLyonDifficulty = trace.difficulty ;
       expect ( foulleeDifficulty*2 , lessThan(sainteLyonDifficulty  ) ) ;
     });
   });
 });
 

 
 test('Check nearly flat trace do not have 0 up value', () {
   File file = new File("test/resources/eric-sainte_victoire___barrages_bimont_et_zola.gpx");
   buildTraceAnalysisFromGpxFile(file, smoothingParameters: low).then((trace){
     printTrace(trace);
     expect ( trace.up , greaterThan(0  ) ) ;
     expect ( trace.up , lessThan(200  ) ) ;

   });
 });
 

 
  
  void checkUpAndLengthComputing(String filePath, SmoothingParameters smoothingParameters, num expectedUp, num expectedLength ){
    
    File file = new File(filePath);
    buildTraceAnalysisFromGpxFile(file,  applyPurge: true,
         idealMaxPointNumber:3500, smoothingParameters:smoothingParameters
               ).then((trace){
      
    
      print("=============: ${filePath}");
      printTrace(trace) ;
      
      num errorPercentage = 1.5 / 100 ;
      expect ( trace.length , greaterThan( expectedLength * (1-errorPercentage)  ) ) ;
      expect ( trace.length , lessThan( expectedLength * (1+errorPercentage)  ) ) ;
      
      errorPercentage = 5 / 100 ;
      expect ( trace.up , greaterThan( expectedUp * (1-errorPercentage)  ) ) ;
      expect ( trace.up , lessThan( expectedUp * (1+errorPercentage)  ) ) ;
      
      
    });
    
  }  

  test('Check gpx file up and length computing values are consistent compared to other websites', () {

    checkUpAndLengthComputing("test/resources/sonicronan-grande_boucle_autour_de_perquelin.gpx",no, 1850, 23700) ;
    // http://www.openrunner.com/index.php?id=1255360 (chamchaude)
    checkUpAndLengthComputing("test/resources/openrunner.com.1255360.gpx",low, 758, 7665) ;
    // http://www.openrunner.com/index.php?id=2310762 (ut4m)
    checkUpAndLengthComputing("test/resources/openrunner.com.2310762.gpx",high, 11000, 167832) ;
    // http://www.openrunner.com/index.php?id=3112821 (utmb)
    checkUpAndLengthComputing("test/resources/openrunner.com.3112821.gpx",medium, 9800, 165037) ;
    // http://www.openrunner.com/index.php?id=2863888 (echappee belle)
    checkUpAndLengthComputing("test/resources/openrunner.com.2863888.gpx",low, 11000, 136142) ;
  });


  void checkProfile(String filePath ){
    
    File file = new File(filePath);
    buildTraceAnalysisFromGpxFile(file).then((originalTrace){
      
      print("==== Check profile =========: ${filePath}");
      num originalLength = originalTrace.length ;
      print("originalTrace.points.length: ${originalTrace.points.length} ");
      TraceRawData dataProfile =  traceAnalyser.buildProfile(originalTrace.rawData, maxProfilePointsNumber:500);
      expect ( dataProfile.points.length , lessThan( 600) ) ;
      print("dataProfile.points.length: ${dataProfile.points.length} ");
      
    });
    
  }  
  
  
  test('Check the profiler', () {
    checkProfile("test/resources/openrunner.com.2310762.gpx") ;
  });
 
  void checkSmoothingDoNotChangeData(File file){
    buildTraceAnalysisFromGpxFile(file, applyPurge: true,smoothingParameters:no).then((noSmoothingTrace){
      
      print("==== Check smoothing do not change data =========: ${file}");
      print("noSmoothingUp: ${noSmoothingTrace.up} ");
      TraceRawData data = noSmoothingTrace.rawData;
      
      TraceAnalysis lowSmoothingTrace = traceAnalyser.buildTraceAnalysisFromRawData(data, applyPurge: false,smoothingParameters:low);
      print("lowSmoothingUp: ${lowSmoothingTrace.up} ");
      TraceAnalysis mediumSmoothingTrace = traceAnalyser.buildTraceAnalysisFromRawData(data, applyPurge: false,smoothingParameters:medium);
      print("mediumSmoothingUp: ${mediumSmoothingTrace.up} ");
      TraceAnalysis highSmoothingTrace = traceAnalyser.buildTraceAnalysisFromRawData(data, applyPurge: false,smoothingParameters:high);
      print("highSmoothingUp: ${highSmoothingTrace.up} ");
      TraceAnalysis noSmoothingTrace2 = traceAnalyser.buildTraceAnalysisFromRawData(data, applyPurge: false,smoothingParameters:no);
      print("noSmoothingUp2: ${noSmoothingTrace2.up} ");
      TraceAnalysis highSmoothingTrace2 = traceAnalyser.buildTraceAnalysisFromRawData(data, applyPurge: false,smoothingParameters:high);
      print("highSmoothingUp2: ${highSmoothingTrace2.up} ");
      
      expect ( noSmoothingTrace.up , equals( noSmoothingTrace2.up) ) ;
      expect ( highSmoothingTrace.up , equals( highSmoothingTrace2.up) ) ;
     });
  }
  
  test('Check smoothing do not change data', () {
    checkSmoothingDoNotChangeData(new File("test/resources/la-boussole-ultra_ardechois.gpx")) ;
    checkSmoothingDoNotChangeData(new File("test/resources/openrunner.com.2310762.gpx")) ;
  });
  

}
