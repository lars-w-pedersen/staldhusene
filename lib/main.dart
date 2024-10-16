import 'package:flutter/material.dart';
import 'get_sheet_data.dart';
import 'models.dart';
import 'detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

Future<DinnerInformation> fetchDinnerEvents() async {

  var response = await GoogleSheetsApiData().accessGoogleSheetData(globals.houseNumber, globals.prefillInformation, null);

  globals.houseNumber = response.houseNumber;
  globals.prefillInformation = response.prefillInformation;

  return response;
}

Future<DinnerInformation> updateDinnerEventParticipation(int index, Participation participation) async {
  var response = await GoogleSheetsApiData().updateDinnerEventParticipation(index, participation, globals.houseNumber!);

  globals.houseNumber = response.houseNumber;
  globals.prefillInformation = response.prefillInformation;

  return response;
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<DinnerInformation> dinnerEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dinnerEvents = fetchDinnerEvents();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      dinnerEvents = fetchDinnerEvents();
    });
  }

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fællesspisning',
      themeMode: ThemeMode.system,
      darkTheme: darkTheme,
      theme: lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fællesspisning'),
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder<DinnerInformation>(
            future: dinnerEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                if(snapshot.data!.houseNumber == null) {
                  // No saved house number is found so we show a dropdown where the user can select house number
                  return buildHouseNumberDropdownMenu();
                } else {
                  if(snapshot.data!.events.isEmpty) {
                    return Text('Der er ikke nogen fremtidige middage planlagt');
                  } else {
                    return RefreshIndicator(  // Enables dragging down to refresh data in dinner event list
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(), // Needed for enabling drag down to refresh even when page is to short to be scrollable
                        itemCount: snapshot.data!.events.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text('${snapshot.data!.events[index].date}: ${snapshot.data!.events[index].participationText()}'),
                              subtitle: Text(snapshot.data!.events[index].menu),
                              enabled: snapshot.data!.events[index].editable,
                              onTap: () {
                                _navigateAndDisplaySelection(context, snapshot.data!.events[index]);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  DropdownMenu<String> buildHouseNumberDropdownMenu() {
    return DropdownMenu<String>(
      label: const Text('Husnummer'),
      onSelected: (String? value) {
        globals.houseNumber = value!;
        SharedPreferencesAsync().setString('houseNumber', value);
        setState(() {
          dinnerEvents = fetchDinnerEvents();
        });
      },
      dropdownMenuEntries: [
        DropdownMenuEntry<String>(value: 'P3', label: 'Pilotvej 3'),
        DropdownMenuEntry<String>(value: 'P4', label: 'Pilotvej 4'),
        DropdownMenuEntry<String>(value: 'P5', label: 'Pilotvej 5'),
        DropdownMenuEntry<String>(value: 'P6', label: 'Pilotvej 6'),
        DropdownMenuEntry<String>(value: 'P7', label: 'Pilotvej 7'),
        DropdownMenuEntry<String>(value: 'P8', label: 'Pilotvej 8'),
        DropdownMenuEntry<String>(value: 'P9', label: 'Pilotvej 9'),
        DropdownMenuEntry<String>(value: 'P10', label: 'Pilotvej 10'),
        DropdownMenuEntry<String>(value: 'P11', label: 'Pilotvej 11'),
        DropdownMenuEntry<String>(value: 'P12', label: 'Pilotvej 12'),
        DropdownMenuEntry<String>(value: 'P13', label: 'Pilotvej 13'),
        DropdownMenuEntry<String>(value: 'P14', label: 'Pilotvej 14'),
        DropdownMenuEntry<String>(value: 'P15', label: 'Pilotvej 15'),
        DropdownMenuEntry<String>(value: 'P16', label: 'Pilotvej 16'),
        DropdownMenuEntry<String>(value: 'P17', label: 'Pilotvej 17'),
        DropdownMenuEntry<String>(value: 'P18', label: 'Pilotvej 18'),
        DropdownMenuEntry<String>(value: 'P19', label: 'Pilotvej 19'),
        DropdownMenuEntry<String>(value: 'P20', label: 'Pilotvej 20'),
        DropdownMenuEntry<String>(value: 'P21', label: 'Pilotvej 21'),
        DropdownMenuEntry<String>(value: 'P23', label: 'Pilotvej 23'),
        DropdownMenuEntry<String>(value: 'P24', label: 'Pilotvej 24'),
        DropdownMenuEntry<String>(value: 'P25', label: 'Pilotvej 25'),
        DropdownMenuEntry<String>(value: 'P26', label: 'Pilotvej 26'),
        DropdownMenuEntry<String>(value: 'P27', label: 'Pilotvej 27'),
        DropdownMenuEntry<String>(value: 'P28', label: 'Pilotvej 28'),
        DropdownMenuEntry<String>(value: 'P29', label: 'Pilotvej 29'),
        DropdownMenuEntry<String>(value: 'P30', label: 'Pilotvej 30'),
        DropdownMenuEntry<String>(value: 'P31', label: 'Pilotvej 31'),
        DropdownMenuEntry<String>(value: 'P32', label: 'Pilotvej 32'),
        DropdownMenuEntry<String>(value: 'P33', label: 'Pilotvej 33'),
        DropdownMenuEntry<String>(value: 'P35', label: 'Pilotvej 35'),
        DropdownMenuEntry<String>(value: 'P37', label: 'Pilotvej 37'),
        DropdownMenuEntry<String>(value: 'P39', label: 'Pilotvej 39'),
        DropdownMenuEntry<String>(value: 'P41', label: 'Pilotvej 41'),
        DropdownMenuEntry<String>(value: 'P43', label: 'Pilotvej 43'),
        DropdownMenuEntry<String>(value: 'P45', label: 'Pilotvej 45'),
        DropdownMenuEntry<String>(value: 'P47', label: 'Pilotvej 47'),
        DropdownMenuEntry<String>(value: 'P49', label: 'Pilotvej 49'),
        DropdownMenuEntry<String>(value: 'P51', label: 'Pilotvej 51'),
        DropdownMenuEntry<String>(value: 'P53', label: 'Pilotvej 53'),
        DropdownMenuEntry<String>(value: 'P55', label: 'Pilotvej 55'),
        DropdownMenuEntry<String>(value: 'P57', label: 'Pilotvej 57'),
      ]
    );
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context, DinnerEvent dinnerEvent) async {
    final Participation? participation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailScreen(),
        settings: RouteSettings(
          arguments: dinnerEvent,
        ),
      ),
    );

    if (!context.mounted) return;

    if (participation != null) {
      // details screen returned a participation so we update the dinner event with the new information
      setState(() {
        dinnerEvents = updateDinnerEventParticipation(dinnerEvent.index, participation);
      });
    }
  }
}
