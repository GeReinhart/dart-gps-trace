
import 'package:petitparser/xml.dart';

import 'beans.dart' ;

class GpxFileParser{
  
  TraceRawData parseFromContentFile(String gpxFileContent){

      TraceRawData traceRawData = new TraceRawData();
      List<TracePoint> points = traceRawData.points;
      
      var parser = new XmlParser();
      XmlDocument xmlDocument = parser.parse(gpxFileContent).value;
      Iterator allNodesIter= xmlDocument.where((xmlNode) =>(xmlNode is XmlElement )).iterator ;
      
      TracePoint previousPoint = null;
      for (; allNodesIter.moveNext();) {
        XmlNode trkptNode = allNodesIter.current;
        XmlElement trkptElement = (trkptNode as XmlElement);
        XmlName name = trkptElement.name;
        if (name.toString() != "trkpt"){
          continue;
        }
        if ((trkptElement.parent  as XmlElement).name.toString()  != "trkseg"){
          continue;
        }
        
        try{
          TracePoint currentPoint = new TracePoint();
          currentPoint.latitude  =  double.parse( trkptElement.getAttribute("lat") );
          currentPoint.longitude =  double.parse( trkptElement.getAttribute("lon") );        
          
          Iterator eleIterator =  trkptElement.where((xmlNode) =>(xmlNode is XmlElement ) ).iterator ;
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
          
          points.add(currentPoint) ;
          previousPoint = currentPoint;
        }catch(e) {
          print('Loading gpx file error: $e'); 
        }
      }
      return traceRawData;
    }
}