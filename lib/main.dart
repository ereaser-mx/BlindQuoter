import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(HomDecoApp());

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

        //Botones
        child: Center(
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
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  MenuButton({required this.icon, required this.label, this.onTap});

  //Creador del botón del menú
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

// Pantalla de cotización
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

  //Metodo para calcular el precio por metro cuadrado según la tela
  double calcularPrecioM2(String tela) {
    switch (tela) {
      case 'Woodline':
        return 750;
      case 'Blackout':
        return 700;
      case 'Dimmout':
        return 950;
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

  //Modulo para generar el PDF
  void generarPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    double total = pedidos.fold(0, (sum, p) => sum + double.parse(p['costo']));

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Homdeco',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Fecha: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                ),
                pw.Text(
                  'Pedido:',
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
                              p['ancho'].toString(),
                              p['alto'].toString(),
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

  // Construcción de la pantalla de cotización
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Cotizador", style: TextStyle(color: Colors.white)),
      ),

      // Contenido de la pantalla
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
                  ['Woodline', 'Blackout', 'Dimmout']
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
                // Botones para agregar pedido y generar PDF
                ElevatedButton(
                  // Botón para agregar pedido y limpiar los campos
                  onPressed: () {
                    agregarPedido();
                    anchoController.clear();
                    altoController.clear();
                    control = 'Izquierdo';
                  },
                  child: Text("Agregar"),
                ),
                SizedBox(width: 16),
                // Botón para generar PDF
                ElevatedButton(
                  onPressed: pedidos.isEmpty ? null : generarPDF,
                  child: Text("Generar PDF"),
                ),
                // Botón para limpiar la lista de pedidos
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      pedidos.clear();
                    });
                  },
                  child: Text("X"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Pedido",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              // Tabla de pedidos
              child: DataTable(
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
                              DataCell(Text(p['ancho'].toString())),
                              DataCell(Text(p['alto'].toString())),
                              DataCell(Text(p['precio'].toString())),
                              DataCell(Text(p['costo'])),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
