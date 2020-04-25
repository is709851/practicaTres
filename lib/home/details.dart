import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:practica_tres/models/barcode_item.dart';
import 'package:practica_tres/models/image_label_item.dart';

class Details extends StatefulWidget {
  final BarcodeItem barcode;
  final ImageLabelItem imageLabeled;
  Details({
    Key key,
    this.barcode,
    this.imageLabeled,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    // convierte la string base 64 a bytes para poder pintar Image.memory(Uint8List)
    if (widget.barcode != null) {
      imageBytes = base64Decode(widget.barcode.imagenBase64);
      return Scaffold(
      appBar: AppBar(title: Text("Detalles")),
      body: Center(
        child: //Text("ToDo: Imagen con rectangulo y algunos datos"),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            Expanded(
              child: Column(children: <Widget>[
                Container(
                  width: 250,
                  height: 250,
                  margin: EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(imageBytes)
                    ),
                    border: Border.all(
                      color: Colors.purple
                    )
                  ),
                  child: null,
                )
              ],),
              flex: 1,
            ),
            Expanded(
              child: Column(children: <Widget>[
                Text('Codigo: ${widget.barcode.codigo}'),
                SizedBox(height: 8,),
                Text('Tipo de codigo: ${widget.barcode.tipoCodigo}'),
                SizedBox(height: 8,),
                Text('Area del codigo: ${widget.barcode.areaDeCodigo}'),
                SizedBox(height: 8,),
                Text('URL: ${widget.barcode.url}'),
                SizedBox(height: 8,),
                Text('Titulo url: ${widget.barcode.tituloUrl}'),
                SizedBox(height: 8,),
                Text('Puntos de esquinas: ${widget.barcode.puntosEsquinas}'),
              ],),
            )
          ],),
        )
      ),
    );
  } else {
      imageBytes = base64Decode(widget.imageLabeled.imagenBase64);

      return Scaffold(
        appBar: AppBar(title: Text("Detalles")),
        body: Center(
          child: //Text("ToDo: Imagen con rectangulo y algunos datos"),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
              Expanded(
                child: Column(children: <Widget>[
                  Container(
                  width: 250,
                  height: 250,
                  margin: EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(imageBytes)
                    ),
                    border: Border.all(
                      color: Colors.purple
                    )
                  ),
                  child: null,
                )
                ],),
              ),
              Expanded(
                child: Column(children: <Widget>[
                  Text('Id: ${widget.imageLabeled.identificador}'),
                  SizedBox(height: 8,),
                  Text('Texto: ${widget.imageLabeled.texto}'),
                  SizedBox(height: 8,),
                  Text('Similitud: ${widget.imageLabeled.similitud}'),
                ],),
              )
            ],),
          )
        ),
      );
    }
  }
}

class RectPainter extends CustomPainter {
  final List<Offset> pointsList;

  RectPainter({@required this.pointsList});

  @override
  bool shouldRepaint(CustomPainter old) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(pointsList[0], pointsList[2]);
    final line = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, line);
  }
}
