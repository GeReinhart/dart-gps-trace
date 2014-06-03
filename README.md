# GPS trace

[![Build Status](https://drone.io/github.com/GeReinhart/dart-gps-trace/status.png)](https://drone.io/github.com/GeReinhart/dart-gps-trace/latest)

GPS trace library allow you to parse and analyse GPS files.
Can be used on client or server side.

## Installation

Add the Gps trace dependency to your project’s pubspec.yaml.

    dependencies:
      gps_trace: "0.1.1"

Then, run `pub get`.

## Usage on server
    
    import "package:gps_trace/gps_trace.dart";
    
    main() {

     TraceAnalyser traceAnalyser = new TraceAnalyser();
     File gpxFile = new File("test/resources/my_favorite_trail.gpx"); 

     gpxFile.readAsString().then((gpxFileContent) {
         traceAnalyser.buildTraceAnalysisFromGpxFileContent(gpxFileContent).then((trace){
     
           print("Trace length: ${trace.length} meters");
           print("Positive elevetion: ${trace.up}");
           print("Highest point elevetion: ${trace.upperPoint.elevetion}");
               
         });
     });


    }


## Features

* Parsing GPX files 1.0 and 1.1
* Trace attributes :
  * trace length in meters
  * highest point elevetion in meters
  * lowest point elevetion in meters
  * positive elevetion in meters 
  * negative elevetion in meters 
  * average inclination up
  * average inclination down
* Purge aligned points
* Smoothing 
  * by elevetion average between close points
  * by elevetion threshold
 
## Who is using it ?
* http://www.la-boussole.info 
