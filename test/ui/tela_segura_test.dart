import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/ui/comum.dart';

void main() {
  testWidgets('conteúdo fica acima da barra de navegação do celular', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    // Barra de navegação (edge-to-edge) de 48 dp.
    tester.view.padding = const FakeViewPadding(bottom: 48 * 2.75);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48 * 2.75);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: TelaSegura(
        appBar: AppBar(title: const Text('Enviar')),
        body: Column(children: [
          const Spacer(),
          FilledButton(onPressed: () {}, child: const Text('Marcar como enviado')),
        ]),
      ),
    ));
    final alturaTela = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final botao = tester.getRect(find.text('Marcar como enviado'));
    expect(botao.bottom, lessThanOrEqualTo(alturaTela - 48));
  });
}
