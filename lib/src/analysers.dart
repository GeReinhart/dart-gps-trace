part of gps_trace;

class TraceAnalyser{
  
  GpxFileParser _gpxFileParser ;
  TraceRawDataProfiler _profiler ;
  TraceRawDataPurger _traceRawDataPurger  ;
  
  TraceAnalyser( {int maxProfilePointsNumber:500} ){
    _gpxFileParser = new GpxFileParser();
    _profiler = new TraceRawDataProfiler();
    _traceRawDataPurger = new TraceRawDataPurger() ;
  }
  
  Future<TraceAnalysis> buildTraceAnalysisFromGpxFile(File gpxFile,
        {bool applyPurge: false,
         int idealMaxPointNumber:3500, 
         SmoothingParameters smootingParameters:null}
              ){
    return gpxFile.readAsString().then((gpxFileContent) { 
        TraceRawData rawData = _gpxFileParser.parseFromContentFile(gpxFileContent) ;
        
        return buildTraceAnalysisFromRawData(rawData,
                                          applyPurge: applyPurge,
                                          idealMaxPointNumber:idealMaxPointNumber, 
                                          smootingParameters:smootingParameters) ;
      }
    );
  }
  
  TraceAnalysis buildTraceAnalysisFromRawData(TraceRawData rawData,
        {bool applyPurge: false,
         int idealMaxPointNumber:3500, 
         SmoothingParameters smootingParameters:null}
              ){
        
        if (applyPurge){
          _traceRawDataPurger.deleteAlignedPoints( rawData, idealMaxPointNumber);
        }
        if (smootingParameters != null && smootingParameters.applySmooting){
          
          PurgerResult smoothData = _traceRawDataPurger.applySmoothingWithElevetionAverage(rawData, cloneData: true,
                                             pointsToMergeEachSide: (smootingParameters.numberOfMergedPoints-1) ~/ 2,
                                             maxDistanceWithinMergedPoints: smootingParameters.maxDistanceBetweenMergedPoints ) ;
          
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
