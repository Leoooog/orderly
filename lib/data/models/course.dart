enum Course {
  entree(0, "Entrée / Bevande"),
  course1(1, "1ª Uscita"),
  course2(2, "2ª Uscita"),
  dessert(3, "Dessert / Caffè");

  final int id;
  final String label;
  const Course(this.id, this.label);


}