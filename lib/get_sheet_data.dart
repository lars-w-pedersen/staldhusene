import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class Allergens {
  final bool meat;
  final bool gluten;
  final bool lactose;
  final bool milk;
  final bool nuts;
  final bool freshFruit;
  final bool carrots;

  const Allergens(this.meat, this.gluten, this.lactose, this.milk, this.nuts, this.freshFruit, this.carrots);
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
  final String date;
  final String menu;
  final bool editable;
  final Allergens chefCanAvoid;
  final Participation? participation;

  const DinnerEvent(this.date, this.menu, this.editable, this.chefCanAvoid, this.participation);

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

class GoogleSheetsApiData {
  String url;
  String clientId;
  String? spreadsheetId;
  String clientEmail;
  String privateKey;

  GoogleSheetsApiData(
      {required this.clientEmail,
        required this.clientId,
        required this.privateKey,
        required this.url});

  void extractIdFromUrl(String url) {
    Uri uri = Uri.parse(url);

    // Extract spreadsheet ID
    String path = uri.path;
    List<String> pathSegments = path.split('/');

    if (pathSegments.length > 2) {
      spreadsheetId = pathSegments[3];
    }
  }

  Future<List<DinnerEvent>> accessGoogleSheetData() async {
    extractIdFromUrl(url);

    // Your Google Sheets API credentials
    final credentials = ServiceAccountCredentials.fromJson({
      'client_id': clientId,
      // Your service account email
      'client_email': clientEmail,
      // Your private key
      'private_key': privateKey,
      // Google Sheets API scope
      'scopes': [SheetsApi.spreadsheetsReadonlyScope],
      'type': 'service_account'
    });

    final client = await clientViaServiceAccount(
        credentials, [SheetsApi.spreadsheetsReadonlyScope]);

    // Google Sheets API instance
    final sheets = SheetsApi(client);
    // Spreadsheet ID and range

    try {
      var response = await sheets.spreadsheets.values.get(spreadsheetId!, "KOK!A:AF", majorDimension: 'COLUMNS');

      var dateColumn = response.values![0];
      var daysBeforeColumn = response.values![3];
      var timeOfDayBeforeColumn = response.values![4];
      var houseColumn = response.values![5];

      var menuColumn = response.values![23];
      var meatAllergenColumn = response.values![24];
      var glutenAllergenColumn = response.values![25];
      var lactoseAllergenColumn = response.values![26];
      var milkAllergenColumn = response.values![27];
      var nutsAllergenColumn = response.values![28];
      var freshFruitAllergenColumn = response.values![29];
      var carrotsAllergenColumn = response.values![30];


      List<DinnerEvent> list = [];

      for (int i=2;i<dateColumn.length && i<houseColumn.length;i++) {
        var date = getDate(dateColumn[i] as String);
        if (houseColumn[i] as String != "" && DateTime.now().subtract(const Duration(days: 1)).isBefore(date)) {
          list.add(DinnerEvent(getDinnerEventDateAsString(date), menuColumn[i] as String, isEditable(date, int.parse(daysBeforeColumn[i] as String), int.parse(timeOfDayBeforeColumn[i] as String)), Allergens(meatAllergenColumn[i] as String == "TRUE", true, true, true, false, false, false), null));
        }
      }

      return list;
    } finally {
      // Close the HTTP client to release resources
      client.close();
    }
  }

  bool isEditable(DateTime dinnerEventDate, int daysBefore, int hourOfDayBefore) {
    var lastDayToEdit = dinnerEventDate.subtract(Duration(days: daysBefore));
    var cutOfDate = DateTime(lastDayToEdit.year, lastDayToEdit.month, lastDayToEdit.day, hourOfDayBefore);
    return DateTime.now().isBefore(cutOfDate);
  }

  DateTime getDate(String dateStr) {
    var dateSplit = dateStr.split("/");
    return DateTime.parse("${DateTime.now().year}-${dateSplit[1]}-${dateSplit[0]}");
  }

  String getDinnerEventDateAsString(DateTime date) {
    if (date.day == DateTime.now().day) {
      return "I dag";
    }

    String day = getDayAsString(date);

    DateTime endOfWeek = DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));
    if (date.isBefore(endOfWeek)) {
      return day;
    }

    return "$day d. ${date.day}/${date.month}";
  }

  String getDayAsString(DateTime date) {
    switch(date.weekday) {
      case 1:
        return "Mandag";
      case 2:
        return "Tirsdag";
      case 3:
        return "Onsdag";
      case 4:
        return "Torsdag";
      case 5:
        return "Fredag";
      case 6:
        return "Lørdag";
      case 7:
        return "Søndag";
      default:
        return "??";
    }
  }
}