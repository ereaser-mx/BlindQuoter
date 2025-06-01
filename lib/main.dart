import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(HomDecoApp());

// This is a simple Flutter application that serves as a home screen for a
// home decoration app called "HOMDECO". It includes a navigation drawer, a
// menu with options to quote, view clients, and orders, and a screen for
// calculating quotes for window coverings. The quote screen allows users to
// input dimensions, select fabric types, and control options, and generates
// a PDF with the quote details. The app uses the `pdf` and `printing` packages
// to create and print the PDF documents.
class HomDecoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HOMDECO',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

// HomeScreen is the main screen of the application, displaying a menu with
// options to quote, view clients, and orders. It also includes a navigation
// drawer and a custom AppBar with a title and an "Inicio" button.
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('HOMDECO', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Inicio", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: Drawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              icon: Icons.calculate,
              label: "Cotizar",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CotizarScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            MenuButton(icon: Icons.contacts, label: "Clientes"),
            SizedBox(height: 20),
            MenuButton(icon: Icons.warehouse, label: "Pedidos"),
          ],
        ),
      ),
    );
  }
}

// MenuButton is a custom widget that represents a button in the menu with an
// icon and a label. It uses a GestureDetector to handle taps and displays
// a Card with an icon and text. The button can be customized with an icon,
// label, and an optional onTap callback.
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  MenuButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            children: [
              Icon(icon, size: 40),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// CotizarScreen is a StatefulWidget that allows users to input dimensions
// and select fabric types for window coverings. It calculates the cost based
// on the input values and generates a PDF with the quote details. The screen
// includes text fields for width and height, a dropdown for fabric selection,
// radio buttons for control options, and buttons to add the quote and generate
// the PDF. The quotes are displayed in a DataTable format, and the PDF is
// generated using the `pdf` and `printing` packages.

class CotizarScreen extends StatefulWidget {
  @override
  _CotizarScreenState createState() => _CotizarScreenState();
}

class _CotizarScreenState extends State<CotizarScreen> {
  final anchoController = TextEditingController();
  final altoController = TextEditingController();
  String? tela;
  String control = 'Izquierdo';

  List<Map<String, dynamic>> pedidos = [];

  double calcularPrecioM2(String tela) {
    switch (tela) {
      case 'Screen':
        return 750;
      case 'Blackout':
        return 700;
      case 'Woodline':
        return 750;
      default:
        return 200;
    }
  }

  void agregarPedido() {
    final ancho = double.tryParse(anchoController.text);
    final alto = double.tryParse(altoController.text);
    if (ancho == null || alto == null || tela == null) return;

    final area = ancho * alto;
    final precioM2 = calcularPrecioM2(tela!);
    final costo = area * precioM2;

    setState(() {
      pedidos.add({
        'descripcion': '$tela ($control)',
        'precio': precioM2,
        'costo': costo.toStringAsFixed(2),
        'ancho': ancho.toStringAsFixed(2),
        'alto': alto.toStringAsFixed(2),
      });
    });
  }

  void generarPDF() async {
    final pdf = pw.Document();

    double total = pedidos.fold(0, (sum, p) => sum + double.parse(p['costo']));

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cotización de Persianas',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: [
                    'Descripción',
                    'Ancho (m)',
                    'Alto (m)',
                    '\$/m2',
                    'Costo (\$)',
                  ],
                  data:
                      pedidos
                          .map(
                            (p) => [
                              p['descripcion'],
                              p['ancho'],
                              p['alto'],
                              p['precio'].toString(),
                              p['costo'],
                            ],
                          )
                          .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cotizador")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Datos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: anchoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Ancho (m)'),
            ),
            TextField(
              controller: altoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Alto (m)'),
            ),
            DropdownButton<String>(
              value: tela,
              hint: Text("Tela"),
              items:
                  ['Screen', 'Blackout', 'Woodline']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) => setState(() => tela = value!),
            ),
            Row(
              children: [
                Text("Control: "),
                Row(
                  children: [
                    Radio(
                      value: 'Izquierdo',
                      groupValue: control,
                      onChanged: (value) => setState(() => control = value!),
                    ),
                    Text("Izquierdo"),
                    Radio(
                      value: 'Derecho',
                      groupValue: control,
                      onChanged: (value) => setState(() => control = value!),
                    ),
                    Text("Derecho"),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: agregarPedido,
                  child: Text("Agregar"),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: pedidos.isEmpty ? null : generarPDF,
                  child: Text("Generar PDF"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Pedido",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DataTable(
              columns: [
                DataColumn(label: Text("Descripción")),
                DataColumn(label: Text("Ancho (m)")),
                DataColumn(label: Text("Alto (m)")),
                DataColumn(label: Text("\$/m2")),
                DataColumn(label: Text("Costo (\$)")),
              ],
              rows:
                  pedidos
                      .map(
                        (p) => DataRow(
                          cells: [
                            DataCell(Text(p['descripcion'])),
                            DataCell(Text(p['ancho'])),
                            DataCell(Text(p['alto'])),
                            DataCell(Text(p['precio'].toString())),
                            DataCell(Text(p['costo'])),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
