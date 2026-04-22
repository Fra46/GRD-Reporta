import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';

class ReportEventPage extends StatefulWidget {
  const ReportEventPage({super.key});

  @override
  State<ReportEventPage> createState() =>
      _ReportEventPageState();
}

class _ReportEventPageState
    extends State<ReportEventPage> {
  final EventController controller =
      Get.put(EventController());

  final formKey =
      GlobalKey<FormState>();

  final tipoController =
      TextEditingController();

  final municipioController =
      TextEditingController();

  final corregimientoController =
      TextEditingController();

  final ubicacionController =
      TextEditingController();

  final descripcionController =
      TextEditingController();

  final observacionController =
      TextEditingController();

  final personasController =
      TextEditingController();

  final familiasController =
      TextEditingController();

  final indirectasController =
      TextEditingController();

  final viviendasAController =
      TextEditingController();

  final viviendasDController =
      TextEditingController();

  final hectareasController =
      TextEditingController();

  String criticidad =
      'baja';

  bool hayAfectacion =
      false;

  @override
  void dispose() {
    tipoController.dispose();
    municipioController.dispose();
    corregimientoController
        .dispose();
    ubicacionController
        .dispose();
    descripcionController
        .dispose();
    observacionController
        .dispose();

    personasController
        .dispose();
    familiasController
        .dispose();
    indirectasController
        .dispose();
    viviendasAController
        .dispose();
    viviendasDController
        .dispose();
    hectareasController
        .dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!formKey.currentState!
        .validate()) return;

    await controller.createEvent(
      tipoEvento:
          tipoController.text,
      municipio:
          municipioController.text,
      corregimiento:
          corregimientoController
              .text,
      ubicacion:
          ubicacionController.text,
      descripcion:
          descripcionController
              .text,
      criticidad:
          criticidad,
      hayAfectacion:
          hayAfectacion,

      observacion:
          observacionController
              .text,

      personasAfectadas:
          int.tryParse(
                personasController
                    .text,
              ) ??
              0,

      familiasAfectadas:
          int.tryParse(
                familiasController
                    .text,
              ) ??
              0,

      familiasIndirectas:
          int.tryParse(
                indirectasController
                    .text,
              ) ??
              0,

      viviendasAfectadas:
          int.tryParse(
                viviendasAController
                    .text,
              ) ??
              0,

      viviendasDestruidas:
          int.tryParse(
                viviendasDController
                    .text,
              ) ??
              0,

      hectareasAfectadas:
          double.tryParse(
                hectareasController
                    .text,
              ) ??
              0,
    );

    Get.back();
  }

  InputDecoration deco(
      String label) {
    return InputDecoration(
      labelText: label,
      border:
          const OutlineInputBorder(),
    );
  }

  Widget gap() =>
      const SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Nuevo Reporte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
                  18),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller:
                      tipoController,
                  decoration:
                      deco(
                    'Tipo de evento',
                  ),
                  validator:
                      (v) => v!
                              .trim()
                              .isEmpty
                          ? 'Requerido'
                          : null,
                ),

                gap(),

                TextFormField(
                  controller:
                      municipioController,
                  decoration:
                      deco(
                    'Municipio',
                  ),
                  validator:
                      (v) => v!
                              .trim()
                              .isEmpty
                          ? 'Requerido'
                          : null,
                ),

                gap(),

                TextFormField(
                  controller:
                      corregimientoController,
                  decoration:
                      deco(
                    'Corregimiento',
                  ),
                ),

                gap(),

                TextFormField(
                  controller:
                      ubicacionController,
                  decoration:
                      deco(
                    'Ubicación',
                  ),
                ),

                gap(),

                TextFormField(
                  controller:
                      descripcionController,
                  maxLines: 3,
                  decoration:
                      deco(
                    'Descripción',
                  ),
                ),

                gap(),

                DropdownButtonFormField(
                  value:
                      criticidad,
                  decoration:
                      deco(
                    'Criticidad',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                          'baja',
                      child:
                          Text(
                        'Baja',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'media',
                      child:
                          Text(
                        'Media',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'alta',
                      child:
                          Text(
                        'Alta',
                      ),
                    ),
                  ],
                  onChanged:
                      (v) {
                    criticidad =
                        v!;
                  },
                ),

                gap(),

                SwitchListTile(
                  value:
                      hayAfectacion,
                  title: const Text(
                    '¿Hay afectación?',
                  ),
                  onChanged:
                      (v) {
                    setState(() {
                      hayAfectacion =
                          v;
                    });
                  },
                ),

                if (hayAfectacion)
                  Column(
                    children: [
                      gap(),

                      TextFormField(
                        controller:
                            personasController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Personas afectadas',
                        ),
                      ),

                      gap(),

                      TextFormField(
                        controller:
                            familiasController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Familias afectadas',
                        ),
                      ),

                      gap(),

                      TextFormField(
                        controller:
                            indirectasController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Familias indirectas',
                        ),
                      ),

                      gap(),

                      TextFormField(
                        controller:
                            viviendasAController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Viviendas afectadas',
                        ),
                      ),

                      gap(),

                      TextFormField(
                        controller:
                            viviendasDController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Viviendas destruidas',
                        ),
                      ),

                      gap(),

                      TextFormField(
                        controller:
                            hectareasController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            deco(
                          'Hectáreas afectadas',
                        ),
                      ),
                    ],
                  ),

                gap(),

                TextFormField(
                  controller:
                      observacionController,
                  maxLines: 3,
                  decoration:
                      deco(
                    'Observación',
                  ),
                ),

                const SizedBox(
                    height: 24),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        ElevatedButton(
                      onPressed: controller
                              .isLoading
                              .value
                          ? null
                          : _save,
                      child: controller
                              .isLoading
                              .value
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Guardar reporte',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}