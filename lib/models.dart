class Allergens {
  final bool meat;
  final bool gluten;
  final bool lactose;
  final bool milk;
  final bool nuts;
  final bool freshFruit;
  final bool onions;
  final bool carrots;

  const Allergens(this.meat, this.gluten, this.lactose, this.milk, this.nuts, this.freshFruit, this.onions, this.carrots);
}

class Participation {
  final int adults;
  final int children;
  final bool takeaway;
  final Allergens allergens;

  const Participation(this.adults, this.children, this.takeaway, this.allergens);

  String participationText() {
    return '${takeaway ? "Takeaway" : "Deltager"} ($adults ${adults == 1 ? 'voksen' : 'voksne'}, $children ${children == 1 ? 'barn' : 'børn'})';
  }
}

class DinnerEvent {
  final int index;
  final String date;
  final String menu;
  final bool editable;
  final Allergens chefCanAvoid;
  final Participation? participation;

  const DinnerEvent(this.index, this.date, this.menu, this.editable, this.chefCanAvoid, this.participation);

  String participationText() {
    if (participation != null) {
      return participation!.participationText();
    } else if (editable) {
      return 'Tilmeld';
    } else {
      return 'Tilmelding lukket';
    }
  }
}

class DinnerInformation {
  final List<DinnerEvent> events;
  final String? houseNumber;
  final Participation? prefillInformation;

  const DinnerInformation(this.events, this.houseNumber, this.prefillInformation);
}

final List<int> houses = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57];
