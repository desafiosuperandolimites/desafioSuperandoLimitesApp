part of '../env.dart';

class TermosDeUsoWidget extends StatelessWidget {
  const TermosDeUsoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '1. Aceitação dos Termos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Ao acessar e utilizar o aplicativo, você concorda em cumprir e respeitar estes Termos de Uso, bem como a nossa Política de Privacidade.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '2. Cadastro e Acesso',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Para utilizar nosso aplicativo, você precisará criar uma conta, fornecendo informações pessoais como nome, e-mail, data de nascimento entre outros. Ao se cadastrar, você declara que as informações fornecidas são verdadeiras e se compromete a mantê-las atualizadas.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '3. Uso Permitido',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Você pode usar o aplicativo para fins pessoais e não comerciais. Você não deve usar o aplicativo para qualquer atividade ilegal ou que viole os direitos de terceiros.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4. Privacidade e Proteção de Dados',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Nós respeitamos sua privacidade e estamos comprometidos em proteger seus dados pessoais. A coleta e o tratamento de dados pessoais são realizados de acordo com a Lei Geral de Proteção de Dados (LGPD). Ao utilizar o aplicativo, você consente com a coleta, uso e compartilhamento de suas informações conforme descrito em nossa Política de Privacidade.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4.1 Coleta de Dados',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Coletamos informações que você fornece diretamente, como nome, e-mail, bem como dados de uso e performance, distância percorrida, entre outros.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4.2 Uso de Dados',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Os dados coletados são utilizados para personalizar sua experiência no aplicativo, melhorar nossos serviços, realizar análise de performance, enviar comunicações, e processar pagamentos.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4.3 Compartilhamento de Dados',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Podemos compartilhar seus dados com terceiros em situações específicas, como para processar pagamentos, cumprir obrigações legais, ou melhorar nossos serviços. Garantimos que os terceiros com quem compartilhamos seus dados estão em conformidade com a LGPD.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4.4 Armazenamento e Segurança',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Seus dados pessoais são armazenados em servidores seguros e adotamos medidas técnicas e administrativas para protegê-los contra acesso não autorizado, perda, ou destruição.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '4.5 Direitos do Usuário',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Você tem o direito de acessar, corrigir, ou excluir seus dados pessoais, bem como de revogar o consentimento para o tratamento de seus dados. Para exercer esses direitos, entre em contato conosco através do nosso canal de atendimento ao usuário.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '5. Propriedade Intelectual',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Todo o conteúdo disponível no aplicativo, incluindo textos, imagens, gráficos, logotipos, e software, é de nossa propriedade ou licenciado para nós e está protegido por leis de direitos autorais e propriedade intelectual. Você não pode copiar, modificar, distribuir, ou reproduzir qualquer parte do aplicativo sem nossa autorização expressa.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '6. Limitação de Responsabilidade',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'O aplicativo é fornecido "como está", sem garantias de qualquer tipo, expressas ou implícitas. Não garantimos que o aplicativo estará sempre disponível, livre de erros ou seguro. Em nenhuma circunstância seremos responsáveis por danos indiretos, incidentais, ou consequentes relacionados ao uso do aplicativo.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '7. Modificações nos Termos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Podemos alterar estes Termos de Uso a qualquer momento. Notificaremos você sobre qualquer alteração significativa por meio do aplicativo ou por e-mail. O uso contínuo do aplicativo após as alterações implica aceitação dos novos termos.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '8. Rescisão',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Você pode encerrar sua conta a qualquer momento. Também nos reservamos o direito de encerrar ou suspender seu acesso ao aplicativo se você violar estes Termos de Uso.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '9. Legislação Aplicável e Foro',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Estes Termos de Uso são regidos pelas leis do Brasil. Qualquer disputa relacionada a estes Termos será resolvida no foro da comarca da sua residência.\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          Text(
            '10. Contato',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Se você tiver qualquer dúvida sobre estes Termos de Uso ou sobre o tratamento de seus dados pessoais, entre em contato conosco através do e-mail: [superandolimites@gmail.com]\n\n',
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
