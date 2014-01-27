part of gps_trace;

class SmoothingLevel {
  static const AUTO   = const SmoothingLevel._(0);
  static const NO     = const SmoothingLevel._(1);
  static const LOW    = const SmoothingLevel._(2);
  static const MEDIUM = const SmoothingLevel._(3);
  static const HIGH   = const SmoothingLevel._(4);

  static get values => [AUTO, NO, LOW, MEDIUM, HIGH];

  final int value;

  const SmoothingLevel._(this.value);

  String toString(){
    switch (value) {
      case SmoothingLevel.AUTO  : return "auto" ;
      case SmoothingLevel.NO    : return "no" ;
      case SmoothingLevel.LOW   : return "low" ;
      case SmoothingLevel.MEDIUM: return "medium" ;
      case SmoothingLevel.HIGH  : return "high" ;
    }
    return "auto";
  }

  static SmoothingLevel fromString(String smoothingLevel){
    if ( smoothingLevel == null || smoothingLevel != null && smoothingLevel.isEmpty  ){
      return SmoothingLevel.AUTO ;
    }
    String smoothingLevelLC = smoothingLevel.toLowerCase() ;
    if (smoothingLevelLC  == SmoothingLevel.NO.toString() ){
      return SmoothingLevel.NO ;
    }
    if (smoothingLevelLC  == SmoothingLevel.LOW.toString() ){
      return SmoothingLevel.LOW ;
    }
    if (smoothingLevelLC  == SmoothingLevel.MEDIUM.toString() ){
      return SmoothingLevel.MEDIUM ;
    }    
    if (smoothingLevelLC  == SmoothingLevel.HIGH.toString() ){
      return SmoothingLevel.HIGH ;
    }     
    return SmoothingLevel.AUTO ;
  }

}

class SmoothingParameters{

  bool applySmooting ;
  bool autoSmooting ;
  int numberOfMergedPoints ;
  int maxDistanceBetweenMergedPoints ;

  SmoothingParameters(this.numberOfMergedPoints, this.maxDistanceBetweenMergedPoints) : applySmooting = true, autoSmooting = false ;
  SmoothingParameters.noSmoothing() : applySmooting = false, autoSmooting = false ;
  SmoothingParameters.autoSmoothing() : applySmooting = false, autoSmooting = true ;
  
  static Map<SmoothingLevel,SmoothingParameters> params = new Map<SmoothingLevel,SmoothingParameters>();
  
  static SmoothingParameters get(SmoothingLevel smoothingLevel){
    
    if(params.isEmpty){
      int distanceStep = 35 ;
      params[ SmoothingLevel.NO ]    = new SmoothingParameters.noSmoothing();
      params[ SmoothingLevel.AUTO ]  = new SmoothingParameters.autoSmoothing();
      params[ SmoothingLevel.LOW ]   = new SmoothingParameters( (2*1)+1,  distanceStep*1);
      params[ SmoothingLevel.MEDIUM ]= new SmoothingParameters( (2*2)+1,  distanceStep*2);
      params[ SmoothingLevel.HIGH ]  = new SmoothingParameters( (2*4)+1,  distanceStep*4);
    }
    
    return params.containsKey(smoothingLevel) ? params[smoothingLevel] :  params[SmoothingLevel.AUTO] ;
  }
  
}





