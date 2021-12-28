

class Candidate {

  String? id;
  String? name;
  int? votes;

  Candidate({
    this.id,
    this.name,
    this.votes
  });

  factory Candidate.fromMap( Map<String, dynamic> obj ) 
    => Candidate(
      id: obj['id'],
      name: obj['name'],
      votes: obj['votes']
    );
  


}