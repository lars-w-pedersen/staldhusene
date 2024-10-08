import 'package:flutter/material.dart';
import 'dart:math';

import 'get_sheet_data.dart';

Future<List<DinnerEvent>> fetchDinnerEvents() async {

  String privateKey = """-----BEGIN PRIVATE KEY-----
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
-----END PRIVATE KEY-----""";


  var response = await GoogleSheetsApiData(
      clientEmail: 'staldhusene-app-service-acc@staldhusene-app.iam.gserviceaccount.com',
      clientId: '104866680526764500509',
      privateKey: privateKey,
      url: 'https://docs.google.com/spreadsheets/d/16ASTBB0dUuX_EIiz_MhSeDRf_HaYixi5wk3EDa15Xa4'
  ).accessGoogleSheetData();


  return response;

    /*[
    DinnerEvent('I dag', 'her: $response', false, Allergens(true, true, true, true, false, false, false), Participation(p, 1, false, Allergens(true, false, false, false, false, false, false))),
    DinnerEvent('Onsdag', 'Bønne burritos med super grøn salat', true, Allergens(true, true, true, true, false, false, false), Participation(1, 2, true, Allergens(true, false, false, false, false, false, false))),
    DinnerEvent('Torsdag', 'Ris taffel med kylling og en vegetar variant', false, Allergens(true, true, true, true, false, false, false), null),
    DinnerEvent('Tirsdag d. 4/10', 'Ris taffel med kylling og en vegetar variant', true, Allergens(true, true, true, true, false, false, false), null)
  ];*/
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<DinnerEvent>?> dinnerEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dinnerEvents = fetchDinnerEvents();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fællesspisning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fællesspisning'),
        ),
        body: Center(
          child: FutureBuilder<List<DinnerEvent>?>(
            future: dinnerEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(child: ListTile(
                      title: Text('${snapshot.data![index].date}: ${snapshot.data![index].participationText()}'),
                      subtitle: Text(snapshot.data![index].menu),
                      enabled: snapshot.data![index].editable,
                      onTap: () {
                        _navigateAndDisplaySelection(context, snapshot.data![index]);
                      },
                    ),
                    );
                  },
                );
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

  Future<void> _navigateAndDisplaySelection(BuildContext context, DinnerEvent dinnerEvent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailScreen(),
        settings: RouteSettings(
          arguments: dinnerEvent,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result) {
      setState(() {
        dinnerEvents = fetchDinnerEvents();
      });
    }
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  DetailScreenState createState() {
    return DetailScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class DetailScreenState extends State<DetailScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;

    return Scaffold(
      appBar: AppBar(
        title: Text(dinnerEvent.date),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(dinnerEvent.menu),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Tilmeld'),
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      )
    );
  }
}
