import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey _globalKey = new GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
      return Uint8List(0);
    }
  }

  String emulationFor(String modelName) {
    String emulation = 'StarGraphic';
    if (modelName != '') {
      final em = StarMicronicsUtilities.detectEmulation(modelName: modelName);
      emulation = em!.emulation!;
    }
    return emulation;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName?.isNotEmpty != null) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    String raster = "        Star Clothing Boutique\n" +
                        "             123 Star Road\n" +
                        "           City, State 12345\n" +
                        "\n" +
                        "Date:MM/DD/YYYY          Time:HH:MM PM\n" +
                        "--------------------------------------\n" +
                        "SALE\n" +
                        "SKU            Description       Total\n" +
                        "300678566      PLAIN T-SHIRT     10.99\n" +
                        "300692003      BLACK DENIM       29.99\n" +
                        "300651148      BLUE DENIM        29.99\n" +
                        "300642980      STRIPED DRESS     49.99\n" +
                        "30063847       BLACK BOOTS       35.99\n" +
                        "\n" +
                        "Subtotal                        156.95\n" +
                        "Tax                               0.00\n" +
                        "--------------------------------------\n" +
                        "Total                           156.95\n" +
                        "--------------------------------------\n" +
                        "\n" +
                        "Charge\n" +
                        "156.95\n" +
                        "Visa XXXX-XXXX-XXXX-0123\n" +
                        "Refunds and Exchanges\n" +
                        "Within 30 days with receipt\n" +
                        "And tags attached\n";
                    commands.appendBitmapText(text: raster);
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
              },
              child: Text('Print from text'),
            ),
            TextButton(
              onPressed: () async {
                //FilePickerResult file = await FilePicker.platform.pickFiles();
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);
                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName?.isNotEmpty != null) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    commands.appendBitmap(
                        path:
                            'https://c8.alamy.com/comp/MPCNP1/camera-logo-design-photograph-logo-vector-icons-MPCNP1.jpg');
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Print from url'),
            ),
            SizedBox(
              width: 576, // 3'' only
              child: RepaintBoundary(
                key: _globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('This is a text to print as image , for 3\''),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final img = await _capturePng();
                setState(() {
                  isLoading = true;
                });
                //FilePickerResult file = await FilePicker.platform.pickFiles();
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                print(list);

                list.forEach((port) async {
                  print(port.portName);
                  if (port.portName!.isNotEmpty) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    commands.appendBitmapByte(
                      byteData: img,
                      diffusion: true,
                      bothScale: true,
                      alignment: StarAlignmentPosition.Left,
                    );
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Print from genrated image'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                List<PortInfo> list =
                    await StarPrnt.portDiscovery(StarPortType.All);
                SmartDialog.showToast('Đã phát hiện ${list.length} thiết bị');

                list.forEach((port) async {
                  if (port.portName!.isNotEmpty) {
                    print(await StarPrnt.getStatus(
                      portName: port.portName!,
                      emulation: emulationFor(port.modelName!),
                    ));

                    PrintCommands commands = PrintCommands();
                    commands.appendBitmapWidget(
                      context: context,
                      widget: FNBInvoice(),
                      diffusion: true,
                      bothScale: true,
                      alignment: StarAlignmentPosition.Left,
                    );
                    commands.push({'appendCutPaper': "FullCutWithFeed"});
                    print(await StarPrnt.sendCommands(
                        portName: port.portName!,
                        emulation: emulationFor(port.modelName!),
                        printCommands: commands));
                  }
                });
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Print from widget'),
            ),
          ],
        ),
      ),
    );
  }
}

class FNBInvoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Text(
            'Cửa hàng Gà rán',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('147 Tân Mai, Hoàng Mai, Hà Nội'),
          SizedBox(height: 16.0),
          Text('Thời gian: 04/6/2023'),
          SizedBox(height: 16.0),
          Text(
            'Khách hàng:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Trần Văn Phúc'),
          Text('59 Trương Định'),
          SizedBox(height: 16.0),
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sản phẩm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Số lượng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Thành tiền',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Gà rang muối'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('1'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('221.000₫'),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Miến xào'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('1'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('40.000₫'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Thành tiền: \$261.000₫',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Thuế (10%): \$26.100',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Tổng thu: \$287.000₫',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Thông tin thanh toán:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Phương thức thanh toán: Credit Card'),
          Text('Số thẻ: XXXX XXXX XXXX 1234'),
          SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrettyQr(
                image: NetworkImage('https://static.wixstatic.com/media/0ad60f_66d5cf27ed82406eac1f74fcc396c4e9~mv2.png/v1/fill/w_165,h_120,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/WHITE_edited.png'),
                size: 80,
                data: 'https://www.google.ru',
                errorCorrectLevel: QrErrorCorrectLevel.M,
                typeNumber: null,
                roundEdges: true,
              ),
              Text(
                'Thank you for your order!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
