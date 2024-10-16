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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<DinnerInformation> dinnerEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      setState(() {
        dinnerEvents = fetchDinnerEvents();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
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
                              textColor: getTileTextColor(snapshot.data!.events[index], Theme.of(context).brightness == Brightness.dark),
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
        bottomNavigationBar: buildBottomBar(),
      ),
    );
  }

  Color? getTileTextColor(DinnerEvent dinnerEvent, bool isDarkTheme) {
    if(dinnerEvent.participation != null) {
      return isDarkTheme ? Colors.green.shade300 : Colors.green;
    }

    return null;
  }

  Widget buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FutureBuilder<DinnerInformation>(
        future: dinnerEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            if(snapshot.data!.houseNumber != null) {
              return Text('Husnummer: Pilotvej ${snapshot.data!.houseNumber}');
            }
          }
          return Text('');
        },
      )
    );
  }

  DropdownMenu<String> buildHouseNumberDropdownMenu() {
    return DropdownMenu<String>(
      label: const Text('Husnummer'),
      width: 200,
      onSelected: (String? value) {
        globals.houseNumber = value!;
        SharedPreferencesAsync().setString('houseNumber', value);
        setState(() {
          dinnerEvents = fetchDinnerEvents();
        });
      },
      dropdownMenuEntries: houses.map<DropdownMenuEntry<String>>((int number) {
            return DropdownMenuEntry<String>(
              value: '$number',
              label: 'Pilotvej $number',
            );
          }).toList(),
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
