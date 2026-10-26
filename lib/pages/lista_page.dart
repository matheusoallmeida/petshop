import 'package:flutter/material.dart';

import '../../database/banco_dados.dart';
import 'cadastro_page.dart';
import '../resumo_page.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final banco = BancoDados.instance;
  final buscaController = TextEditingController();

  List<Map<String, dynamic>> atendimentos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarAtendimentos();
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  Future<void> carregarAtendimentos() async {
    final dados = await banco.listar(busca: buscaController.text);

    if (!mounted) return;

    setState(() {
      atendimentos = dados;
      carregando = false;
    });
  }

  String formatarValor(dynamic valor) {
    return 'R\$ ${(valor as num).toDouble().toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> abrirCadastro({Map<String, dynamic>? atendimento}) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPage(atendimento: atendimento),
      ),
    );

    if (resultado != null) {
      final id = resultado['id'] as int?;

      if (id == null) {
        await banco.inserir(resultado);
      } else {
        final dados = Map<String, dynamic>.from(resultado)..remove('id');

        await banco.atualizar(id, dados);
      }

      await carregarAtendimentos();
    }
  }

  Future<void> excluirAtendimento(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atendimento'),
        content: const Text('Deseja realmente excluir este atendimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await banco.excluir(id);
      await carregarAtendimentos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atendimento excluído com sucesso!')),
      );
    }
  }

  Future<void> abrirResumo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResumoPage()),
    );

    await carregarAtendimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pet Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: abrirResumo,
            tooltip: 'Resumo financeiro',
            icon: const Icon(Icons.bar_chart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirCadastro(),
        icon: const Icon(Icons.add),
        label: const Text('Novo atendimento'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: buscaController,
                onChanged: (_) => carregarAtendimentos(),
                decoration: InputDecoration(
                  hintText: 'Buscar pet ou tutor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      buscaController.clear();
                      carregarAtendimentos();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: carregando
                    ? const Center(child: CircularProgressIndicator())
                    : atendimentos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 70,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum atendimento encontrado.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cadastre um novo atendimento para começar.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: atendimentos.length,
                        itemBuilder: (context, index) {
                          final item = atendimentos[index];

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.teal.shade50,
                                    child: Icon(
                                      Icons.pets,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['pet'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('Tutor: ${item['tutor']}'),
                                        Text('Serviço: ${item['servico']}'),
                                        Text('Data: ${item['data']}'),
                                        const SizedBox(height: 5),
                                        Text(
                                          formatarValor(item['valor']),
                                          style: TextStyle(
                                            color: Colors.teal.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected: (opcao) {
                                      if (opcao == 'editar') {
                                        abrirCadastro(atendimento: item);
                                      } else if (opcao == 'excluir') {
                                        excluirAtendimento(item['id']);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'editar',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'excluir',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Excluir'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
