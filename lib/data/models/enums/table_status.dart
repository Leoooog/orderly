enum TableStatus {
  seated,
  ordered,
  ready,
  eating,
  closed,
  unknown, free; //TODO: FREE È DA RIMUOVERE DOPO AVER AGGIUSTATO TUTTO

  static TableStatus fromString(String value) {
    return TableStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TableStatus.seated,
    );
  }

  String toJson() => name;
}