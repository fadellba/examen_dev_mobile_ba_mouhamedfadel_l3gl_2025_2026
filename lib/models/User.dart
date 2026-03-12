/// Les modeles sont immutables(final) pour éviter les
/// modifications et facliter la gestion d'etat
class User {
  /// Identifiant unique de l'utilisateur (UUID)
 final String id;

 /// Nom complet de l'utilisateur
 final String name;

 final String email;

 final String password;

 final String? avatar;

 final DateTime createdAt;

 /// Constructeur (Le mouleur)
 User({
   required this.id,
   required this.name,
   required this.email,
   required this.password,
   this.avatar,
   DateTime? createdAt,
}) : createdAt = createdAt ?? DateTime.now();

 /// Le tolier
 /// Crée une copie de l'utilisateur avec des champs modifies
 /// Ex: final updatedUser = user.copyWith(name: 'Babacar NDIAYE')
 /// Permet de faire la mjr sans passer par les setters
 /// utiliser par le provider pour mettre a jour la vue
 User copyWith({
   String? id,
   String? name,
   String? email,
   String? password,
   String? avatar,
   DateTime? createdAt,
}) {
   return User(
       id: id ?? this.id,
       name: name ?? this.name,
       email: email ?? this.email,
       password: password ?? this.password,
       avatar: avatar ?? this.avatar,
       createdAt: createdAt ?? this.createdAt
   );
 }

 /// les douaniers

 /// L'Exportateur (Serilisation)
 /// C'est une methode qui transforme ton objet complexe en un dictionnaire (Map<String, dynamic>).
 /// Utile pour sauvegarder dans shared_preferences ou envoyer a une API
 Map<String, dynamic> toMap() {
   return {
     'id': id,
     'name': name,
     'email': email,
     'password': password,
     'avatar': avatar,
     //'createdAt': createdAt
     'createdAt': createdAt?.toIso8601String(),
   };
 }

 /// L'Importateur (Deserilisation)
 /// C'est un constructeur "factory".
 /// Il prend une Map reçue du stockage et tente de reconstruire l'objet Dart.
 factory User.fromMap(Map<String, dynamic> map) {
   return User(
     id: map['id']?.toString() ?? '',
     name: map['name']?.toString() ?? 'Utilisateur',
     email: map['email']?.toString() ?? '',
     password: map['password']?.toString() ?? '',
     avatar: map['avatar']?.toString(),
     createdAt: map['createdAt'] != null
         ? DateTime.tryParse(map['createdAt'].toString())
         : null,
   );
 }

 @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}