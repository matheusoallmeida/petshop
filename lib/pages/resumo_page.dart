import 'package:flutter/material.dart';

import '../database/banco_dados.dart';

class ResumoPage extends StatefulWidget {
  const ResumoPage({super.key});

  @override
  State<ResumoPage> createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  final banco = BancoDados.instance;

  double total = 0;
  int quantidade = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarResumo();
  }

  Future<void> carregarResumo() async {
    final valorTotal = await banco.totalArrecadado();
    final totalAtendimentos = await banco.quantidadeAtendimentos();

    if (!mounted) return;

    setState(() {
      total = valorTotal;
      quantidade = totalAtendimentos;
      carregando = false;
    });
  }

  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo financeiro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(25),
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
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 65,
                        color: Colors.teal.shade700,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Resumo do Pet Shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 35,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 8),
                            const Text('Total arrecadado'),
                            const SizedBox(height: 8),
                            Text(
                              formatarValor(total),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pets,
                              size: 35,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            const Text('Atendimentos cadastrados'),
                            const SizedBox(height: 8),
                            Text(
                              '$quantidade',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      OutlinedButton.icon(
                        onPressed: carregarResumo,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Atualizar resumo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
