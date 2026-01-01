class Restaurant {
  // --- IDENTITÀ ---
  final String id;              // ID univoco (es. "ristorante_da_mario")
  final String name;            // Nome visualizzato (es. "Osteria da Mario")
  final String? logoUrl;        // URL del logo per scontrini/header
  final String? description;    // Slogan o descrizione breve

  // --- LOCALIZZAZIONE (Richiesto) ---
  final String currencySymbol;  // Es. "€", "$", "£"
  final String locale;          // Es. "it_IT", "en_US" (per formattare date e numeri)

  // --- DATI FISCALI & CONTATTO ---
  final String address;         // Indirizzo completo
  final String vatNumber;       // Partita IVA (per scontrino)
  final String? phoneNumber;
  final String? email;
  final String? website;

  // --- REGOLE DI CONTO ---
  final double coverCharge;        // Costo fisso "Coperto" per persona (es. 2.00)
  final double serviceFeePercent;  // Percentuale servizio (es. 10%) - comune all'estero

  // --- CONFIGURAZIONE EXTRA ---
  final String? wifiSsid;       // Per generare QR Code Wi-Fi clienti
  final String? wifiPassword;

  Restaurant({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    required this.currencySymbol,
    required this.locale,
    required this.address,
    required this.vatNumber,
    this.phoneNumber,
    this.email,
    this.website,
    this.coverCharge = 0.0,
    this.serviceFeePercent = 0.0,
    this.wifiSsid,
    this.wifiPassword,
  });

  // --- FACTORY PER DEFAULT (Utile per i test o offline iniziale) ---
  factory Restaurant.empty() {
    return Restaurant(
      id: 'demo_restaurant',
      name: 'Ristorante Demo',
      currencySymbol: '€',
      locale: 'it_IT',
      address: 'Via Roma 1, Milano',
      vatNumber: '00000000000',
    );
  }

  // --- SERIALIZZAZIONE (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'currencySymbol': currencySymbol,
      'locale': locale,
      'address': address,
      'vatNumber': vatNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'coverCharge': coverCharge,
      'serviceFeePercent': serviceFeePercent,
      'wifiSsid': wifiSsid,
      'wifiPassword': wifiPassword,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      logoUrl: json['logoUrl'],
      description: json['description'],
      currencySymbol: json['currencySymbol'] ?? '€',
      locale: json['locale'] ?? 'it_IT',
      address: json['address'] ?? '',
      vatNumber: json['vatNumber'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      coverCharge: (json['coverCharge'] as num?)?.toDouble() ?? 0.0,
      serviceFeePercent: (json['serviceFeePercent'] as num?)?.toDouble() ?? 0.0,
      wifiSsid: json['wifiSsid'],
      wifiPassword: json['wifiPassword'],
    );
  }

  // --- COPY WITH (Per modifiche immutabili) ---
  Restaurant copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    String? currencySymbol,
    String? locale,
    String? address,
    String? vatNumber,
    String? phoneNumber,
    String? email,
    String? website,
    double? coverCharge,
    double? serviceFeePercent,
    String? wifiSsid,
    String? wifiPassword,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      locale: locale ?? this.locale,
      address: address ?? this.address,
      vatNumber: vatNumber ?? this.vatNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      coverCharge: coverCharge ?? this.coverCharge,
      serviceFeePercent: serviceFeePercent ?? this.serviceFeePercent,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
    );
  }
}