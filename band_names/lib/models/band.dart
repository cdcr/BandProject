class Band {
  String id;
  String name;
  int votes;

  Band(this.id, this.name, this.votes);

  factory Band.fromMap(Map<String, dynamic> obj) => Band(
      obj.containsKey('id') ? obj['id'] : 'no-id',
      obj.containsKey('id') ? obj['name'] : 'no-name',
      obj.containsKey('id') ? obj['votes'] : 0);
}
