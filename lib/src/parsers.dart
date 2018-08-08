part of gps_trace;

class GpxFileParser{
  
  TraceRawData parseFromContentFile(String gpxFileContent){

      TraceRawData traceRawData = new TraceRawData();
      List<TracePoint> points = traceRawData.points;
      
      XmlDocument xmlDocument = parse(gpxFileContent);
      Iterator allNodesIter= xmlDocument.descendants.where((xmlNode) =>(xmlNode is XmlElement )).iterator ;
      num index = 0;
      TracePoint previousPoint = null;
      for (; allNodesIter.moveNext();) {
        XmlNode trkptNode = allNodesIter.current;
        XmlElement trkptElement = (trkptNode as XmlElement);
        XmlName name = trkptElement.name;
        if (name.toString() != "trkpt" && name.toString() != "rtept"){
          continue;
        }
        String parent = (trkptElement.parent  as XmlElement).name.toString();
        if (parent  != "trkseg" && parent != "rte"){
          continue;
        }
        
        try{
          TracePoint currentPoint = new TracePoint();
          currentPoint.latitude  =  double.parse( trkptElement.getAttribute("lat") );
          currentPoint.longitude =  double.parse( trkptElement.getAttribute("lon") );        
          
          Iterator eleIterator =  trkptElement.descendants.where((xmlNode) =>(xmlNode is XmlElement ) ).iterator ;
          for  ( ;eleIterator.moveNext() ;){
            XmlElement eleElement = eleIterator.current;
            if (eleElement.name.toString() != "ele"){
              continue;
            }
            currentPoint.elevetion = double.parse( eleElement.firstChild.toString() );
          }
          if ( currentPoint.elevetion == null && previousPoint != null ){
            currentPoint.elevetion = previousPoint.elevetion;
          }
          currentPoint.index = index;
          points.add(currentPoint) ;
          previousPoint = currentPoint;
          index++;
        }catch(e) {
          print('Loading gpx file error: $e'); 
        }
      }
      return traceRawData;
    }
}