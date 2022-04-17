import 'package:earthquake_monitor/src/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EarthquakeHome extends StatefulWidget {
  EarthquakeHome() : super();

  final String title = "Earthquakes";

  @override
  EarthquakeHomeState createState() => EarthquakeHomeState();
}

class EarthquakeHomeState extends State<EarthquakeHome> {
  static Uri FEED_URL =
      Uri.parse('http://earthquakes.bgs.ac.uk/feeds/WorldSeismology.xml');

  RssFeed _feed = RssFeed();
  String _title = '';

  static const String loadingText = "Loading...";
  static const String feedLoadErrorText = "Error loading feed.";
  static const String feedOpenErrorText = "Error opening feed.";

  late GlobalKey<RefreshIndicatorState> _refreshKey;

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
    updateTitle(feedOpenErrorText);
  }

  load() async {
    updateTitle(loadingText);
    loadFeed().then((result) {
      if (null == result || result.toString().isEmpty) {
        // Notify user of error.
        updateTitle(feedLoadErrorText);
        return;
      }
      // If there is no error, load the RSS data into the _feed object.
      updateFeed(result);
      // Reset the title.
      updateTitle("Earthquakes");
    });
  }

  Future<RssFeed?> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(FEED_URL);
      return RssFeed.parse(response.body);
    } catch (e) {
      // handle any exceptions here
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  header() {
    return AppBar(
      title: Text(
        "Earthquakes",
        style: TextStyle(
          color: const Color(0xff0e172c),
          fontSize: 32,
          fontFamily: GoogleFonts.oswald().fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
          child: Container(
            color: Color(0xff0e172c),
            height: 2,
          ),
          preferredSize: Size.fromHeight(2)),
    );
  }

  body() {
    return isFeedEmpty()
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(),
            color: Color(0xffc1fba4),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: header(),
        backgroundColor: const Color(0xfff9f8fc),
        body: body(),
      ),
    );
  }

  list() {
    return ListView.separated(
      itemCount: _feed.items!.length,
      itemBuilder: (context, index) {
        final item = _feed.items![index];
        List<String> earthquakesInfo = item.description!.split(';');
        List<String> coords =
            earthquakesInfo[2].split(':').toString().split(',');
        String magnitude = earthquakesInfo[4].split(':')[1].toString();
        String quakeDate = DateFormat().format(item.pubDate!).toString();
        LatLng latlng = LatLng(double.tryParse(coords[1].trim()) ?? 0.0,
            double.tryParse(coords[2].replaceAll(']', '')) ?? 0.0);

        return ListTile(
          leading: map(latlng),
          title: title(earthquakesInfo[1].trim()),
          subtitle: magniSubtitle(quakeDate, magnitude),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EarthquakeDetails(earthquakesInfo)));
          },
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          width: 351,
          height: 1,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xff0e172c),
              width: 1,
            ),
          ),
        );
      },
    );
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xff0e172c),
        fontSize: 24,
        fontFamily: GoogleFonts.oswald().fontFamily,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  subtitle(subTitle) {
    return Text(
      subTitle,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          fontFamily: GoogleFonts.oswald().fontFamily,
          color: Color(0xff0e172c)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  magniSubtitle(subTitle, magnitude) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          subTitle,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              fontFamily: GoogleFonts.oswald().fontFamily,
              color: Color(0xff0e172c)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: getMagniColour(double.tryParse(magnitude) ?? 0)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Text(
                magnitude,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    fontFamily: GoogleFonts.oswald().fontFamily,
                    color: Color(0xff0e172c)),
              ),
            ))
      ],
    );
  }

  map(coords) {
    return Container(
      width: 80,
      height: 80,
      child: FlutterMap(
        options: MapOptions(
          center: coords,
          zoom: 3.0,
          interactiveFlags: InteractiveFlag.none,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return Text("");
            },
          )
        ],
      ),
    );
  }

  getMagniColour(magnitude) {
    if (magnitude <= 1) {
      return Color(0xffd3e4cd);
    } else if (magnitude > 1 && magnitude <= 2) {
      return Color(0xffadc2a9);
    } else if (magnitude > 2 && magnitude <= 3) {
      return Color(0xff99a799);
    } else if (magnitude > 3 && magnitude <= 4) {
      return Color(0xffffbc80);
    } else if (magnitude > 4 && magnitude <= 5) {
      return Color(0xffff9f45);
    } else if (magnitude > 5 && magnitude <= 6) {
      return Color(0xfff76e11);
    } else if (magnitude > 6 && magnitude <= 7) {
      return Color(0xfffc4f4f);
    } else if (magnitude > 7 && magnitude <= 8) {
      return Color(0xff9c0f48);
    } else {
      return Color(0xff470d21);
    }
  }
}
