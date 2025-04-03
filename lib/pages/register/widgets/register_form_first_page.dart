import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';
import 'package:park_wallet/constants/input_formatters/cpf_input_formatter.dart';
import 'package:park_wallet/constants/input_formatters/date_input_formatter.dart';
import 'package:park_wallet/pages/register/controllers/register_controller.dart';
import 'package:park_wallet/pages/widgets/app_button.dart';

class RegisterFormFirstPage extends GetView<RegisterController>{
  const RegisterFormFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: controller.nameCtrl,
          decoration: InputDecoration(
            labelText: 'Nome Completo',
            hintText: 'Insira seu nome completo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
              counterText: ""

          ),
          maxLength: 255,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.cpfCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(14), // 11 números + 3 pontuações
            CpfInputFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'CPF',
            hintText: '000.000.000-00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
              counterText: ""
          ),
        ),

        const SizedBox(height: 16),

          TextField(
            controller: controller.dateCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              DateInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Data de nascimento',
              hintText: 'dd/mm/aaaa',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  try {
                    final text = controller.dateCtrl.text;
                    final parts = text.split('/');
                    DateTime initialDate = DateTime.now();

                    if (parts.length == 3) {
                      final day = int.tryParse(parts[0]);
                      final month = int.tryParse(parts[1]);
                      final year = int.tryParse(parts[2]);

                      if (day != null && month != null && year != null) {
                        final tempDate = DateTime(year, month, day);
                        if (tempDate.isBefore(DateTime.now())) {
                          initialDate = tempDate;
                        }
                      }
                    }

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      controller.selectedDate.value = picked;
                      controller.dateCtrl.text = controller.formatDate(picked);
                    }
                  } catch (e) {
                    // fallback em caso de erro inesperado
                    print('Erro ao abrir o calendário: $e');
                  }
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              final parts = value.split('/');
              if (parts.length == 3 && parts[0].length == 2 && parts[1].length == 2 && parts[2].length == 4) {
                try {
                  final day = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final year = int.parse(parts[2]);
                  final parsedDate = DateTime(year, month, day);
                  controller.selectedDate.value = parsedDate;
                } catch (_) {
                  // data inválida
                }
              }
            },
          ),


        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: "Cancelar",
                onPressed: controller.cancel,
                backgroundColor: AppColors.red,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: "Próximo",
                onPressed: controller.nextPage,
                backgroundColor: AppColors.sapphire,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
