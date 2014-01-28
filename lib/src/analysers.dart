part of gps_trace;

class TraceAnalyser{
  
  GpxFileParser _gpxFileParser ;
  TraceRawDataProfiler _profiler ;
  TraceRawDataPurger _traceRawDataPurger  ;
  
  TraceAnalyser(){
    _gpxFileParser = new GpxFileParser();
    _profiler = new TraceRawDataProfiler();
    _traceRawDataPurger = new TraceRawDataPurger() ;
  }
  
  Future<TraceAnalysis> buildTraceAnalysisFromGpxFile(File gpxFile,
        {bool applyPurge: false,
         int idealMaxPointNumber:3500, 
         SmoothingParameters smoothingParameters:null}
              ){
    return gpxFile.readAsString().then((gpxFileContent) { 
        TraceRawData rawData = _gpxFileParser.parseFromContentFile(gpxFileContent) ;
        
        return buildTraceAnalysisFromRawData(rawData,
                                          applyPurge: applyPurge,
                                          idealMaxPointNumber:idealMaxPointNumber, 
                                          smoothingParameters:smoothingParameters) ;
      }
    );
  }
  
  TraceAnalysis buildTraceAnalysisFromRawData(TraceRawData rawData,
        {bool applyPurge: false,
         int idealMaxPointNumber:3500, 
         SmoothingParameters smoothingParameters:null}
              ){
        
        if (applyPurge){
          _traceRawDataPurger.deleteAlignedPoints( rawData, idealMaxPointNumber);
        }
        if (smoothingParameters != null && smoothingParameters.applySmooting){
          
          PurgerResult smoothData = _traceRawDataPurger.applySmoothingWithElevetionAverage(rawData, cloneData: true,
                                             pointsToMergeEachSide: (smoothingParameters.numberOfMergedPoints-1) ~/ 2,
                                             maxDistanceWithinMergedPoints: smoothingParameters.maxDistanceBetweenMergedPoints ) ;
          
          TraceAnalysis smoothTraceAnalysis = new TraceAnalysis.fromRawData(smoothData.rawData) ;
          
          return new TraceAnalysis.fromTraceAnalysis(smoothTraceAnalysis, rawData) ;
        }else{
          return new TraceAnalysis.fromRawData(rawData) ;
        }
     
  }
  
  
  TraceRawData  buildProfile(TraceRawData data, {int maxProfilePointsNumber:500} ){
    return _profiler.profile(data,maxProfilePointsNumber:maxProfilePointsNumber) ;
  }
  
}
