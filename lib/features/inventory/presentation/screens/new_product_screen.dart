import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/product.dart';
import '../../domain/sale_unit.dart';
import '../../domain/inventory_provider.dart';
import '../../domain/category.dart';
import 'barcode_scanner_screen.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key, this.product});

  final Product? product;
  bool get isEditing => product != null;

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _barcode = TextEditingController();
  final _price = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _categoriaId;
  Category? _categoriaObjeto;
  SaleUnit _unit = SaleUnit.unit;
  bool _active = true;
  File? _imagenFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadCategories();
    });

    if (widget.isEditing) {
      _name.text = widget.product!.nombre;
      _description.text = widget.product!.descripcion ?? '';
      _barcode.text = widget.product!.codigoBarras ?? '';
      _price.text = widget.product!.precioVenta.toStringAsFixed(2);
      _categoriaId = widget.product!.categoriaId;
      _categoriaObjeto = widget.product!.categoria;
      _unit = widget.product!.tipoVenta;
      _active = widget.product!.activo;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _barcode.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar imagen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.teal),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.teal),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imagenFile != null || widget.product?.imagenUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar imagen'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagenFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _onCategoriaChanged(String? nuevaCategoriaId) {
    setState(() {
      _categoriaId = nuevaCategoriaId;
      final provider = context.read<InventoryProvider>();
      _categoriaObjeto = provider.categories.firstWhere(
        (c) => c.id == nuevaCategoriaId,
        orElse: () => Category(id: nuevaCategoriaId ?? '', tiendaId: '', nombre: 'Sin categoría'),
      );
    });
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<InventoryProvider>();
    provider.ensureInitialized(context);
    final realTiendaId = provider.tiendaId;

    if (realTiendaId == null || realTiendaId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se pudo identificar la tienda.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (_categoriaId == null || _categoriaId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Debes seleccionar una categoría.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (_categoriaObjeto == null || _categoriaObjeto!.id != _categoriaId) {
      _categoriaObjeto = provider.categories.firstWhere(
        (c) => c.id == _categoriaId,
        orElse: () => Category(id: _categoriaId!, tiendaId: realTiendaId, nombre: 'Categoría'),
      );
    }

    double precioFinal = 0.0;
    try {
      precioFinal = double.parse(_price.text.replaceAll(',', '.'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: El precio no es válido.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final newProduct = Product(
      id: widget.product?.id ?? '',
      tiendaId: realTiendaId,
      categoriaId: _categoriaId!,
      nombre: _name.text.trim(),
      descripcion: _description.text.trim().isEmpty ? null : _description.text.trim(),
      codigoBarras: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      tipoVenta: _unit,
      unidadMedida: _unit == SaleUnit.unit ? 'unidad' : 'kg',
      precioVenta: precioFinal,
      activo: _active,
      imagenUrl: widget.product?.imagenUrl,
      categoria: _categoriaObjeto,
    );

    setState(() => _isUploading = true);

    try {
      Product? productoFinal;
      
      if (widget.isEditing) {
        productoFinal = await provider.updateProduct(widget.product!.id, newProduct, imagenFile: _imagenFile);
      } else {
        productoFinal = await provider.createProduct(newProduct, imagenFile: _imagenFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(productoFinal);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nuevo Producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Agrega un artículo a tu lista',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              
              // ✅ SELECTOR DE IMAGEN CIRCULAR
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: _imagenFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imagenFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.product?.imagenUrl != null && _imagenFile == null
                              ? ClipOval(
                                  child: Image.network(
                                    widget.product!.imagenUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añadir imagen',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ✅ NOMBRE DEL PRODUCTO
              const Text(
                'Nombre del producto',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ingresa el nombre',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del producto' : null,
              ),
              const SizedBox(height: 20),

              // ✅ ELEGIR CATEGORÍA
              const Text(
                'Elegir categoría',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  final categories = provider.categories.where((c) => c.activo).toList();
                  final categoriaExiste = categories.any((c) => c.id == _categoriaId);
                  final valorInicial = categoriaExiste ? _categoriaId : null;

                  return DropdownButtonFormField<String>(
                    value: valorInicial,
                    hint: const Text('Selecciona una categoría'),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: categories.map((Category c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombre),
                      );
                    }).toList(),
                    onChanged: _onCategoriaChanged,
                    validator: (v) => v == null ? 'Selecciona una categoría' : null,
                  );
                },
              ),
              const SizedBox(height: 20),

              // ✅ SE VENDE POR
              const Text(
                'Se vende por',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SaleUnitChip(
                      label: 'Unidad',
                      selected: _unit == SaleUnit.unit,
                      onTap: () => setState(() => _unit = SaleUnit.unit),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SaleUnitChip(
                      label: 'Kilo (kg)',
                      selected: _unit == SaleUnit.kilo,
                      onTap: () => setState(() => _unit = SaleUnit.kilo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ DESCRIPCIÓN
              const Text(
                'Descripción (Opcional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Describe el producto',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ CÓDIGO DE BARRAS CON ESCÁNER FUNCIONAL
              const Text(
                'Código de barras',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _barcode,
                decoration: InputDecoration(
                  hintText: 'Escanea o ingresa el código',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: AppColors.teal, size: 24),
                    onPressed: () async {
                      // ✅ ABRIR EL ESCÁNER (SIN const)
                      final scannedCode = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (_) => BarcodeScannerScreen(), // ✅ Sin const
                        ),
                      );
                      
                      // ✅ SI SE ESCANEÓ UN CÓDIGO, PONERLO EN EL CAMPO
                      if (scannedCode != null && mounted) {
                        setState(() {
                          _barcode.text = scannedCode;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código escaneado exitosamente'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ PRECIO VENTA
              const Text(
                'Precio venta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: 'S/. ',
                  prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                  hintText: '0.00',
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Precio inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ✅ PRODUCTO ACTIVO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Producto Activo',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                    activeColor: AppColors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ BOTÓN GUARDAR
              ElevatedButton(
                onPressed: _isUploading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleUnitChip extends StatelessWidget {
  const _SaleUnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.teal : Colors.black87,
          ),
        ),
      ),
    );
  }
}