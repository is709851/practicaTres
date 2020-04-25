import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practica_tres/models/barcode_item.dart';
import 'package:practica_tres/models/image_label_item.dart';
import 'package:barcode_scan/barcode_scan.dart';

part 'application_event.dart';
part 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  List<ImageLabelItem> _listLabeledItems = List();
  List<BarcodeItem> _listBarcodeItems = List();

  List<ImageLabelItem> get getLabeledItemsList => _listLabeledItems;
  List<BarcodeItem> get getBarcodeItemsList => _listBarcodeItems;

  File _picture;

  @override
  ApplicationState get initialState => ApplicationInitial();

  @override
  Stream<ApplicationState> mapEventToState(
    ApplicationEvent event,
  ) async* {
    // Simula estar cargando datos remotos o locales
    if (event is FakeFetchDataEvent) {
      yield LoadingState();
      await Future.delayed(Duration(milliseconds: 1500));
      yield FakeDataFetchedState();
    }
    // pasar imagen a ui para pintarla
    else if (event is TakePictureEvent) {
      await _takePicture();
      if (_picture != null) {
        yield PictureChosenState(image: _picture);
      } else {
        yield ErrorState(message: "No se ha seleccionado imagen");
      }
    }
    // detectar objetos en imagenes
    else if (event is ImageDetectorEvent) {
      yield LoadingState();
      await _imgLabeling(_picture);
      yield FakeDataFetchedState();
    }
    // detectar barcoes y qr en imagenes
    else if (event is BarcodeDetectorEvent) {
      yield LoadingState();
      await _barcodeScan(_picture);
      yield FakeDataFetchedState();
    }
  }

  Future<void> _takePicture() async {
    _picture = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 320,
      maxWidth: 320,
    );
  }

  Future<void> _imgLabeling(File imageFile) async {
    // TODO
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    List<ImageLabel> labels = await labeler.processImage(visionImage);

    List<int> imageBytes = imageFile.readAsBytesSync();
    String imageB64 = base64Encode(imageBytes); 
    
    String texto;
    String id;
    double similitud;

    for (ImageLabel label in labels){
      texto = label.text;
      id = label.entityId;
      similitud = label.confidence;
    }

    _listLabeledItems.add(new ImageLabelItem(
        identificador: id, 
        imagenBase64: imageB64, 
        similitud: similitud, 
        texto: texto,
      ));
  labeler.close();
  }

  Future<void> _barcodeScan(File imageFile) async {
    // TODO
    ScanResult scanResult = await BarcodeScanner.scan(); 

    List<int> imageBytes = imageFile.readAsBytesSync();
    String imageB64 = base64Encode(imageBytes); 

    FirebaseVisionImage image = FirebaseVisionImage.fromFile(imageFile);
    BarcodeDetector detector = FirebaseVision.instance.barcodeDetector();
    List<Barcode> barcodes = await detector.detectInImage(image);
    Rect bounds;
    BarcodeURLBookmark url;
    String titUrl;
    List<Offset> corners;
    for(Barcode barcode in barcodes){
      bounds = barcode.boundingBox;
      url = barcode.url;
      titUrl = barcode.url.title;
      corners = barcode.cornerPoints;
    }

    _listBarcodeItems.add(new BarcodeItem(
      tipoCodigo: scanResult.format.toString(),
      codigo: scanResult.formatNote,
      areaDeCodigo: bounds,
      imagenBase64: imageB64,
      url: url,
      tituloUrl: titUrl,
      puntosEsquinas: corners,
    ));
    
  }

}