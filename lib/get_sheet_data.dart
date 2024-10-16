import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class GoogleSheetsApiData {

  /// Id of current 'Mad i Staldhusene' sheet.
  String spreadsheetId = '1emwEYlB8GEi7Cn7hpNelwRktI2Ebze7MBXuz62N5buw';

  /// Create, Update or Delete participation in a dinner event.
  ///
  /// Returns an updated list of Dinner Events.
  Future<DinnerInformation> updateDinnerEventParticipation(int index, Participation participation, String houseNumber) async {
    final client = await getClient();

    // Google Sheets API instance
    final sheets = SheetsApi(client);

    try {
      Object adultCount = participation.adults == 0 ? '' : participation.adults;
      Object childrenCount = participation.children == 0 ? '' : participation.children;

      List<Object> values = [
        participation.takeaway ? '' : adultCount,
        participation.takeaway ? '' : childrenCount,
        participation.takeaway ? adultCount : '',
        participation.takeaway ? childrenCount : '',
        participation.allergens.meat,
        participation.allergens.gluten,
        participation.allergens.lactose,
        participation.allergens.milk,
        participation.allergens.nuts,
        participation.allergens.freshFruit,
        participation.allergens.onions,
        participation.allergens.carrots,
      ];

      String range = "P$houseNumber!D${index+1}:O${index+1}";
      await sheets.spreadsheets.values.update(ValueRange(range: range, majorDimension: "ROWS", values: [values]), spreadsheetId, range, valueInputOption: 'USER_ENTERED');

      Participation? prefillInformation;

      // If adults is 0 the participation is deleted so we do not store prefill information.
      if(participation.adults != 0) {
        await savePrefillInformation(participation);
        prefillInformation = participation;
      }

      // Get updated dinner event list
      return await accessGoogleSheetData(houseNumber, prefillInformation, client);

    } finally {
      // Close the HTTP client to release resources
      client.close();
    }
  }

  /// Returns list of future Dinner Events.
  Future<DinnerInformation> accessGoogleSheetData(String? houseNumber, Participation? prefillInformation, AutoRefreshingAuthClient? client) async {

    List<DinnerEvent> list = [];
    var sharedPreferences = SharedPreferencesAsync();
    houseNumber ??= await sharedPreferences.getString('houseNumber');

    // If no housenumber is set then return empty list
    if(houseNumber == null) {
      return DinnerInformation(list, null, null);
    }

    prefillInformation ??= await getPrefillInformation(sharedPreferences);

    bool closeClient = false;
    if(client == null) {
      client = await getClient();
      closeClient = true;
    }

    // Google Sheets API instance
    var sheets = SheetsApi(client);

    try {
      var response = await sheets.spreadsheets.values.get(spreadsheetId, "KOK!A:AF", majorDimension: 'COLUMNS');

      var dateColumn = response.values![0]; // A: column with date of event
      var daysBeforeColumn = response.values![3]; // D: column specifying how many days before sign up closes
      var timeOfDayBeforeColumn = response.values![4]; // E: column specifying time of day where sign up closes
      var houseColumn = response.values![5]; // F: column specifying which house buys the food. This is used to figure out if a dinner event is planned on this date
      var menuColumn = response.values![23]; // X: column with the menu of the dinner event

      // Get all participation data from the house sheet
      var participationRowResponse = await sheets.spreadsheets.values.get(spreadsheetId, "P$houseNumber!D:O");

      for (int i=2;i<dateColumn.length && i<houseColumn.length;i++)
      {
        var date = parseDate(dateColumn[i] as String);
        if (dinnerEventIsPlanned(houseColumn[i]) && isTodayOrInFuture(date))
        {
          Participation? participation = getParticipation(participationRowResponse.values![i]);
          bool editable = isEditable(date, daysBeforeColumn[i], timeOfDayBeforeColumn[i]);

          list.add(DinnerEvent(i, getDinnerEventDateAsString(date), menuColumn[i] as String, editable, getAllergensCook(response.values, i), participation));
        }
      }

      return DinnerInformation(list, houseNumber, prefillInformation);
    } finally {
      if(closeClient) {
        // Close the HTTP client to release resources
        client.close();
      }
    }
  }

  bool dinnerEventIsPlanned(Object? houseColumnData) => houseColumnData as String != "";

  Future<Participation?> getPrefillInformation(SharedPreferencesAsync sharedPreferences) async {
    int? adultCount = await sharedPreferences.getInt('adultCount');

    if(adultCount == null) {
      // No saved prefill information
      return null;
    }

    return Participation(
        adultCount,
        await sharedPreferences.getInt('childrenCount') ?? 0,
        false, // We do not prefill takeaway
        Allergens(
            await sharedPreferences.getBool('meat') ?? false,
            await sharedPreferences.getBool('gluten') ?? false,
            await sharedPreferences.getBool('lactose') ?? false,
            await sharedPreferences.getBool('milk') ?? false,
            await sharedPreferences.getBool('nuts') ?? false,
            await sharedPreferences.getBool('freshFruit') ?? false,
            await sharedPreferences.getBool('onions') ?? false,
            await sharedPreferences.getBool('carrots') ?? false
        )
    );
  }

  Future<void> savePrefillInformation(Participation participation) async {
    var sharedPreferences = SharedPreferencesAsync();
    await sharedPreferences.setInt('adultCount', participation.adults);
    await sharedPreferences.setInt('childrenCount', participation.children);
    await sharedPreferences.setBool('meat', participation.allergens.meat);
    await sharedPreferences.setBool('gluten', participation.allergens.gluten);
    await sharedPreferences.setBool('lactose', participation.allergens.lactose);
    await sharedPreferences.setBool('milk', participation.allergens.milk);
    await sharedPreferences.setBool('nuts', participation.allergens.nuts);
    await sharedPreferences.setBool('freshFruit', participation.allergens.freshFruit);
    await sharedPreferences.setBool('onions', participation.allergens.onions);
    await sharedPreferences.setBool('carrots', participation.allergens.carrots);
  }

  Future<AutoRefreshingAuthClient> getClient() async {
    // Your Google Sheets API credentials
    final credentials = ServiceAccountCredentials.fromJson({
      'client_id': '104866680526764500509',
      // Your service account email
      'client_email': 'staldhusene-app-service-acc@staldhusene-app.iam.gserviceaccount.com',
      // Your private key
      'private_key': """-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDOIeZUXNCwGhLF
ixtvPTBFIBf4epMT18BdFwqGmLYG8zli95nxyofpIvkCZ9uEi/t5xOF0O4j6LRCg
414vMr4/jsIAEjDvD054GHR489XY4NBso8gc1/HO4Ht2q3usoeFqPUBWwkU9riBB
ZoG00xR2YTds3DJsARz+PoixIC2qUy+ei9S3aZs07AZ5PBQO5yRjUkQ7VsWtLit3
5jOt8rmoenNGS8fp065uXrtpq99bW973NEnlPRFYYxrfaIHvtIjxBYlvuwIjdctY
ITco5ZoO0CSheUSgtLA2gHRHrai2Az1adHo2HjPwSjmnBnaI95nfaWGvR2RigxeG
h3/857B9AgMBAAECggEAFNs7Odf2SYsp0REFIpk3VBcuNbb5QK24yfJ13y5+ZG+h
o9DXo65RWBZwyXyGqn+bXzO7eA46Cs4ae5zlv7LLqxSfrnAowVd0IhSfXEmXno0I
qaVcrwZucfcmptgs+EeczioKY3zekqIWo2diwlAFJwEpIXuaInFuZI8hN4LA/BWl
+EP+4LnKTTT9PucmK5Mpq3TNh94v2hcHLKvq+EsJcRhUIEmlIrQ+7qV6QHmZWqS7
UdznxwumpqJGSIBRD7+JFbrEOLw03xPvHAz92WTawztZUGY5Dv7w0JJ4HLgf5jVC
ggHQBSyZnK0PVOsC1n68ySLHJy2B9b+WSglaQV8cQQKBgQD6XjXP42mlkQNGnapm
i9StDhfBC9Uv9d/1CWFPd+MNGhDoFtZ0KQ2A1MEBJmf1vdqmotiviIkApIviDSH+
MJpiUDt1jea8WBXjGhbJBJQ0HqjRYOucy2fFhWrVKiVq5KRVopcn2a/gFLQDGRQk
QXEKGAH66AAjuXg8BXo0CsNSUQKBgQDSxPNphlYW9TQNp29ajqQoZbIADUXo8Ok/
DXVsj7SSpW4+wl1ztKzxiE34a87TVHU2/nMW8oTSktXCE4k0fBjEeuIrh1Gkrae1
SER/k791m+jqe9UPXhVeh7nTzldNmFe8PKifa5RTHRN9tQqxCfbvOBz+2fA6ZWvV
67JxtrZkbQKBgF3o1HpjrI7js7zbCr1oGZ/Ht3U7gP16VkTM/ekW6N1TN6A2YL41
X9FA/Bv4UepFCiySzIAa0HijP6zMjEGR7XaO7Z6MWU2wJJWIhZ9kzko2bdALcJTh
Xs0h3A6UvnA3zsQoNlZGOsfsPBElaP6oZUQJ+UQpnVPJD6ZDz7CRkO3hAoGBAJt0
7Nw+Wy0fuj7/6h/u6aFqMLndEF1Zo5AAC0YBUHyBTCk6DteSwaR8lpXOXoR83N+t
GZIpWlI+Py+gXSi7B0GUKVFVw6Ak/Xe2T9+RSDwkvMyGfYWSLUzF6wgQP1BaNwv9
6Zl8LbCH16J2b+ZYpSuYRbqrYIaR29GywLEixLCZAoGAD08kW0k+s71y2YSNDPzX
jZXXjtdpvxGwdtJsTCXVtekbScGxkmc6WmyhDYCsls2VZh25MkiYsWwgVZAKORk4
M9IQHxtcPvUaT5IIzsXqjhFWGoIcVEnavcEkcY9PfKSIEBLhWxJFFn9D42heFwBK
kHEIoS0UqyZqdcMCZpaOo8o=
-----END PRIVATE KEY-----""",
      // Google Sheets API scope
      'scopes': [SheetsApi.spreadsheetsScope],
      'type': 'service_account'
    });

    return await clientViaServiceAccount(
        credentials, [SheetsApi.spreadsheetsScope]);
  }

  Participation? getParticipation(List<Object?> values)
  {
    int adultsParticipants = int.tryParse(values[0] as String) ?? 0;
    int childrenParticipants = int.tryParse(values[1] as String) ?? 0;
    int adultsTakeaway = int.tryParse(values[2] as String) ?? 0;
    int childrenTakeaway = int.tryParse(values[3] as String) ?? 0;

    bool isTakeaway = (adultsTakeaway + childrenTakeaway) > 0;
    bool isParticipation = (adultsParticipants + childrenParticipants) > 0;

    if (!isParticipation && !isTakeaway) {
      return null;
    }

    int adults = isTakeaway ? adultsTakeaway : adultsParticipants;
    int children = isTakeaway ? childrenTakeaway : childrenParticipants;
    return Participation(adults, children, isTakeaway, getAllergensParticipant(values));
  }

  Allergens getAllergensParticipant(List<Object?> values) {
    var meatAllergen = values[4] as String == "TRUE";
    var glutenAllergen = values[5] as String == "TRUE";
    var lactoseAllergen = values[6] as String == "TRUE";
    var milkAllergen = values[7] as String == "TRUE";
    var nutsAllergen = values[8] as String == "TRUE";
    var freshFruitAllergen = values[9] as String == "TRUE";
    var onionsAllergen = values[10] as String == "TRUE";
    var carrotsAllergen = values[11] as String == "TRUE";

    return Allergens(meatAllergen, glutenAllergen, lactoseAllergen, milkAllergen, nutsAllergen, freshFruitAllergen, onionsAllergen, carrotsAllergen);
  }

  bool isTodayOrInFuture(DateTime date) {
    var yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.isAfter(yesterday);
  }

  Allergens getAllergensCook(List<List<Object?>>? values, int index) {
    var meatAllergenColumn = values![24];
    var glutenAllergenColumn = values[25];
    var lactoseAllergenColumn = values[26];
    var milkAllergenColumn = values[27];
    var nutsAllergenColumn = values[28];
    var freshFruitAllergenColumn = values[29];
    var onionsAllergenColumn = values[30];
    var carrotsAllergenColumn = values[31];

    return Allergens(
        meatAllergenColumn[index] as String == "TRUE",
        glutenAllergenColumn[index] as String == "TRUE",
        lactoseAllergenColumn[index] as String == "TRUE",
        milkAllergenColumn[index] as String == "TRUE",
        nutsAllergenColumn[index] as String == "TRUE",
        freshFruitAllergenColumn[index] as String == "TRUE",
        onionsAllergenColumn[index] as String == "TRUE",
        carrotsAllergenColumn[index] as String == "TRUE");
  }

  bool isEditable(DateTime dinnerEventDate, Object? daysBeforeColumnData, Object? hourOfDayBeforeColumnData) {
    int daysBefore = int.parse(daysBeforeColumnData as String);
    int hourOfDayBefore = int.parse(hourOfDayBeforeColumnData as String);

    var lastDateToEdit = dinnerEventDate.subtract(Duration(days: daysBefore));
    var cutOfDateTime = DateTime(lastDateToEdit.year, lastDateToEdit.month, lastDateToEdit.day, hourOfDayBefore);
    return DateTime.now().isBefore(cutOfDateTime);
  }

  DateTime parseDate(String dateStr) {
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