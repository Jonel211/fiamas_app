import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Constantes de layout (idénticas al detalle de fiados) ───
const double _receiptQuantityWidth = 54;
const double _receiptUnitPriceWidth = 76;
const double _receiptAmountWidth = 76;
const double _receiptColumnGap = 6;
const double _receiptProductUnitGap = 12;
const double _receiptUnitAmountGap = 12;

const List<FontFeature> _receiptTabularFigures = [FontFeature.tabularFigures()];

const TextStyle _receiptHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.inkMuted,
);

const TextStyle _receiptNumericHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.inkMuted,
  fontFeatures: _receiptTabularFigures,
);

const TextStyle _receiptUnitPriceStyle = TextStyle(
  fontSize: 14,
  color: AppColors.ink,
  fontFeatures: _receiptTabularFigures,
);

const TextStyle _receiptAmountStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.ink,
  fontFeatures: _receiptTabularFigures,
);

/// Encabezado de columnas del recibo: Cant. | Producto | P. Unit. | Importe
class ProductReceiptHeaderRow extends StatelessWidget {
  const ProductReceiptHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: _receiptQuantityWidth,
          child: Text('Cant.', style: _receiptHeaderStyle),
        ),
        SizedBox(width: _receiptColumnGap),
        Expanded(child: Text('Producto', style: _receiptHeaderStyle)),
        SizedBox(width: _receiptProductUnitGap),
        SizedBox(
          width: _receiptUnitPriceWidth,
          child: Text(
            'P. Unit.',
            textAlign: TextAlign.right,
            style: _receiptNumericHeaderStyle,
          ),
        ),
        SizedBox(width: _receiptUnitAmountGap),
        SizedBox(
          width: _receiptAmountWidth,
          child: Text(
            'Importe',
            textAlign: TextAlign.right,
            style: _receiptNumericHeaderStyle,
          ),
        ),
      ],
    );
  }
}

/// Fila de producto del recibo.
class ProductReceiptRow extends StatelessWidget {
  const ProductReceiptRow({
    super.key,
    required this.quantityLabel,
    required this.productName,
    required this.unitPrice,
    required this.amount,
  });

  final String quantityLabel;
  final String productName;
  final String unitPrice;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _receiptQuantityWidth,
            child: Text(
              quantityLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: _receiptColumnGap),
          Expanded(
            child: Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: _receiptProductUnitGap),
          SizedBox(
            width: _receiptUnitPriceWidth,
            child: Text(
              unitPrice,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _receiptUnitPriceStyle,
            ),
          ),
          const SizedBox(width: _receiptUnitAmountGap),
          SizedBox(
            width: _receiptAmountWidth,
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _receiptAmountStyle,
            ),
          ),
        ],
      ),
    );
  }
}