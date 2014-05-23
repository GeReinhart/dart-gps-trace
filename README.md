# GPS trace

[![Build Status](https://drone.io/github.com/GeReinhart/dart-gps-trace/status.png)](https://drone.io/github.com/GeReinhart/dart-gps-trace/latest)

GPS trace library allow you to parse and analyse GPS files.

## Installation

Add the Gps trace dependency to your project’s pubspec.yaml.

    dependencies:
      gps_trace: "0.1.0"

Then, run `pub get`.

## Usage
    
    import "package:gps_trace/gps_trace.dart";
    
    main() {

     TraceAnalyser traceAnalyser = new TraceAnalyser();

     File file = new File("test/resources/my_favorite_trail.gpx"); 

     traceAnalyser.buildTraceAnalysisFromGpxFile(file).then((trace){

         print("Trace length: ${trace.length} meters");
         print("Positive elevetion: ${trace.up}");
         print("Highest point elevetion: ${trace.upperPoint.elevetion}");


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
