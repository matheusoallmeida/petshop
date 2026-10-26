import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  final Map<String, dynamic>? atendimento;

  const CadastroPage({super.key, this.atendimento});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final formKey = GlobalKey<FormState>();

  final petController = TextEditingController();
  final tutorController = TextEditingController();
  final servicoController = TextEditingController();
  final dataController = TextEditingController();
  final valorController = TextEditingController();

  bool get editando => widget.atendimento != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      final item = widget.atendimento!;

      petController.text = item['pet'];
      tutorController.text = item['tutor'];
      servicoController.text = item['servico'];
      dataController.text = item['data'];
      valorController.text = (item['valor'] as num).toString();
    } else {
      dataController.text =
          '${DateTime.now().day.toString().padLeft(2, '0')}/'
          '${DateTime.now().month.toString().padLeft(2, '0')}/'
          '${DateTime.now().year}';
    }
  }

  @override
  void dispose() {
    petController.dispose();
    tutorController.dispose();
    servicoController.dispose();
    dataController.dispose();
    valorController.dispose();
    super.dispose();
  }

  void salvar() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final valor = double.tryParse(
      valorController.text.trim().replaceAll(',', '.'),
    );

    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um valor válido.')));
      return;
    }

    final Map<String, dynamic> dados = {
      'pet': petController.text.trim(),
      'tutor': tutorController.text.trim(),
      'servico': servicoController.text.trim(),
      'data': dataController.text.trim(),
      'valor': valor,
    };

    if (editando) {
      dados['id'] = widget.atendimento!['id'];
    }

    Navigator.pop(context, dados);
  }

  Widget campoTexto({
    required String label,
    required IconData icone,
    required TextEditingController controller,
    required String mensagemErro,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return mensagemErro;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar atendimento' : 'Novo atendimento'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.pets, size: 55, color: Colors.teal.shade700),

                  const SizedBox(height: 12),

                  Text(
                    editando ? 'Atualize os dados' : 'Dados do atendimento',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  campoTexto(
                    label: 'Nome do pet',
                    icone: Icons.pets,
                    controller: petController,
                    mensagemErro: 'Informe o nome do pet',
                  ),

                  const SizedBox(height: 16),

                  campoTexto(
                    label: 'Nome do tutor',
                    icone: Icons.person,
                    controller: tutorController,
                    mensagemErro: 'Informe o nome do tutor',
                  ),

                  const SizedBox(height: 16),

                  campoTexto(
                    label: 'Serviço realizado',
                    icone: Icons.medical_services,
                    controller: servicoController,
                    mensagemErro: 'Informe o serviço',
                  ),

                  const SizedBox(height: 16),

                  campoTexto(
                    label: 'Data (DD/MM/AAAA)',
                    icone: Icons.calendar_month,
                    controller: dataController,
                    mensagemErro: 'Informe a data',
                  ),

                  const SizedBox(height: 16),

                  campoTexto(
                    label: 'Valor (R\$)',
                    icone: Icons.attach_money,
                    controller: valorController,
                    mensagemErro: 'Informe o valor',
                    tipo: const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 25),

                  FilledButton.icon(
                    onPressed: salvar,
                    icon: const Icon(Icons.save),
                    label: Text(
                      editando ? 'Salvar alterações' : 'Cadastrar atendimento',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
