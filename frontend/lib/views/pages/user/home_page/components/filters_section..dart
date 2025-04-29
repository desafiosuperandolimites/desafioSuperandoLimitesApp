part of '../../../../env.dart';

void _filterEventos(
    setState, selectedStatus, _idGrupoUsuarioLogado, searchQuery) {
  setState(() {
    filteredEventos = eventos.where((evento) {
      // 1. Se o evento está inativo, já retorna false
      if (!evento.situacao) {
        return false;
      }

      // 2. Depois faz as demais verificações (finalizado, inscrito, etc.)
      final bool finalizado = isEventoFinalizado(evento.dataFimInscricoes);
      final bool inscrito = evento.isSubscribed;
      final bool mesmoGrupo = evento.idGrupoEvento == _idGrupoUsuarioLogado;

      bool passesFilter =
          mesmoGrupo && ((!finalizado) || (finalizado && inscrito));

      switch (selectedStatus) {
        case 'Inscrito':
          passesFilter = mesmoGrupo && inscrito && !finalizado;
          break;
        case 'Inscrever':
          passesFilter = mesmoGrupo && !inscrito && !finalizado;
          break;
        case 'Finalizados':
          passesFilter = mesmoGrupo && finalizado && inscrito;
          break;
      }

      return passesFilter &&
          evento.nome.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  });
}
