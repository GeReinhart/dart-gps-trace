part of gps_trace;

class SmoothingLevel{
  static const NO     = const SmoothingLevel._(0);
  static const LOW    = const SmoothingLevel._(1);
  static const MEDIUM = const SmoothingLevel._(2);
  static const HIGH   = const SmoothingLevel._(3);

  static get values => [ NO, LOW, MEDIUM, HIGH];

  final int value;

  const SmoothingLevel._(this.value);

  String toString(){
    switch (value) {
      case 0 : return "no" ;
      case 1 : return "low" ;
      case 2 : return "medium" ;
      case 3 : return "high" ;
    }
    return "no";
  }

  static SmoothingLevel fromString(String smoothingLevel){
    if ( smoothingLevel == null || smoothingLevel != null && smoothingLevel.isEmpty  ){
      return SmoothingLevel.NO ;
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
    return SmoothingLevel.NO ;
  }

}

class SmoothingParameters{

  bool applySmooting ;
  int numberOfMergedPoints ;
  int maxDistanceBetweenMergedPoints ;

  SmoothingParameters(this.numberOfMergedPoints, this.maxDistanceBetweenMergedPoints) : applySmooting = true ;
  SmoothingParameters.noSmoothing() : applySmooting = false ;
  
  static Map<SmoothingLevel,SmoothingParameters> params = new Map<SmoothingLevel,SmoothingParameters>();
  
  static SmoothingParameters get(SmoothingLevel smoothingLevel){
    
    if(params.isEmpty){
      int distanceStep = 35 ;
      params[ SmoothingLevel.NO ]    = new SmoothingParameters.noSmoothing();
      params[ SmoothingLevel.LOW ]   = new SmoothingParameters( (2*1)+1,  distanceStep*1);
      params[ SmoothingLevel.MEDIUM ]= new SmoothingParameters( (2*2)+1,  distanceStep*2);
      params[ SmoothingLevel.HIGH ]  = new SmoothingParameters( (2*5)+1,  distanceStep*5);
    }
    
    return params.containsKey(smoothingLevel) ? params[smoothingLevel] :  params[SmoothingLevel.NO] ;
  }
  
}





