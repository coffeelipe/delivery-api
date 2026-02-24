class Store {
  final String id;
  final String name;

  const Store({
    required this.id,
    required this.name,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Store && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Stores {
  static const cocoBambuLojaTeste = Store(
    id: 'f052054c-e0a0-4768-ab55-7cb7ead57371',
    name: 'Coco Bambu Loja Teste',
  );

  static const cocoBambuChiqueChique = Store(
    id: '98765432-abcd-ef00-1234-567890abcdef',
    name: 'COCO BAMBU CHIQUE CHIQUE',
  );

  static const List<Store> all = [
    cocoBambuLojaTeste,
    cocoBambuChiqueChique,
  ];

  static Store? findById(String id) {
    try {
      return all.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  static Store? findByName(String name) {
    try {
      return all.firstWhere((store) => store.name == name);
    } catch (e) {
      return null;
    }
  }
}
