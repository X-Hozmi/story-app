import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:story_app/data/model/serialization/story.dart';
import 'package:story_app/widgets/expandable_text.dart';

class StoryDetailInfo extends StatefulWidget {
  final Story story;
  final double tinggiLayar;
  final Function(LatLng) onCheckLocation;

  const StoryDetailInfo({
    super.key,
    required this.story,
    required this.tinggiLayar,
    required this.onCheckLocation,
  });

  @override
  State<StoryDetailInfo> createState() => _StoryDetailInfoState();
}

class _StoryDetailInfoState extends State<StoryDetailInfo> {
  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    _getPlacemark();
  }

  Future<void> _getPlacemark() async {
    if (widget.story.lat != null &&
        widget.story.lon != null &&
        widget.story.lat != 0.0 &&
        widget.story.lon != 0.0) {
      try {
        final info = await geo.placemarkFromCoordinates(
            widget.story.lat!, widget.story.lon!);
        setState(() {
          placemark = info.first;
        });
      } catch (e) {
        setState(() {
          placemark = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLocationValid = widget.story.lat != null &&
        widget.story.lon != null &&
        widget.story.lat != 0.0 &&
        widget.story.lon != 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.story.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                DateFormat('dd MMMM yyyy').format(widget.story.createdAt),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.grey),
        SizedBox(height: widget.tinggiLayar * 0.02),
        const Text(
          'Deskripsi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        ExpandableText(
          text: widget.story.description,
        ),
        const Divider(color: Colors.grey),
        SizedBox(height: widget.tinggiLayar * 0.02),
        const Text(
          'Lokasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        InkWell(
          onTap: isLocationValid
              ? () => widget
                  .onCheckLocation(LatLng(widget.story.lat!, widget.story.lon!))
              : null,
          child: Text(
            isLocationValid && placemark != null
                ? '${placemark!.street}, ${placemark!.subLocality}, ${placemark!.locality}, ${placemark!.postalCode}, ${placemark!.country}'
                : isLocationValid
                    ? 'Loading...'
                    : 'Lokasi tidak tersedia',
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocationValid ? Colors.blue : Colors.black,
              fontSize: 18,
              decoration: isLocationValid
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
