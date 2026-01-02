enum TableSessionStatus {
  seated,
  ordered,
  ready,
  eating,
  closed,
  unknown, free; //TODO: FREE È DA RIMUOVERE DOPO AVER AGGIUSTATO TUTTO

  static TableSessionStatus fromString(String value) {
    return TableSessionStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TableSessionStatus.seated,
    );
  }

  String toJson() => name;
}

enum TableStatus {
  free,
  occupied,
  reserved, // per future implementazioni di prenotazioni
}