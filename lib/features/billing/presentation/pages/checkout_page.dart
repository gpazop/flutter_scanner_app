import 'package:billing_app/core/utils/sol_currency.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _printed = false;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    final billingBloc = context.read<BillingBloc>();
    return PopScope<void>(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop && _printed) {
            billingBloc.add(ClearCartEvent());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cobro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () => context.pop(),
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listenWhen: (previous, current) =>
                !previous.printSuccess && current.printSuccess,
            listener: (context, state) {
              _printed = true;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Recibo impreso correctamente'),
                  backgroundColor: Colors.green));
            },
            builder: (context, billingState) {
              final totalAmount = SolCurrency.format(billingState.totalAmount);
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                final orderTable = Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Table(
                        border: const TableBorder(
                          horizontalInside: BorderSide(color: borderColor),
                          bottom: BorderSide(color: borderColor),
                        ),
                        children: [
                          // Header row
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                  bottom: BorderSide(color: borderColor)),
                            ),
                            children: [
                              _buildHeaderCell('Producto', TextAlign.left),
                              _buildHeaderCell('Precio unit.', TextAlign.right),
                              _buildHeaderCell('Total', TextAlign.right),
                            ],
                          ),
                          // Items rows
                          ...billingState.cartItems.map((item) {
                            return TableRow(
                              children: [
                                _buildDataCell(
                                  '${item.quantity} x ${item.product.name}',
                                  TextAlign.left,
                                ),
                                _buildDataCell(
                                    SolCurrency.format(item.product.price),
                                    TextAlign.right,
                                    isSubtitle: true),
                                _buildDataCell(SolCurrency.format(item.total),
                                    TextAlign.right,
                                    isBold: true),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
                final footer = Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24), right: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDemoQr(totalAmount),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL A COBRAR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  totalAmount,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        onPressed: () {
                          if (shopState is ShopLoaded) {
                            context.read<BillingBloc>().add(PrintReceiptEvent(
                                shopName: shopState.shop.name,
                                address1: shopState.shop.addressLine1,
                                address2: shopState.shop.addressLine2,
                                phone: shopState.shop.phoneNumber,
                                footer: shopState.shop.footerText));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se pudieron cargar los datos del negocio.'),
                                    backgroundColor: Colors.red));
                          }
                        },
                        label: 'Imprimir recibo',
                        icon: Icons.print,
                        isLoading: billingState.isPrinting,
                      ),
                    ],
                  ),
                );

                if (MediaQuery.sizeOf(context).height < 480) {
                  return ListView(children: [orderTable, footer]);
                }

                return Column(
                  children: [
                    Expanded(child: SingleChildScrollView(child: orderTable)),
                    footer,
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildDemoQr(String totalAmount) {
    final qrText = 'QR de ejemplo. Monto $totalAmount';

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const Text(
            'QR de ejemplo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox.square(
            dimension: 180,
            child: Semantics(
              image: true,
              label: qrText,
              child: PrettyQrView.data(data: qrText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    final content = Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: isSubtitle ? 12 : 14,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        color: isSubtitle ? Colors.grey[500] : Colors.black87,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: align == TextAlign.right
          ? FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: content,
            )
          : content,
    );
  }
}
