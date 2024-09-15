import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/add_story_provider.dart';
import 'package:story_app/provider/auth_provider.dart';
import '../provider/upload_provider.dart';
import '../provider/api_provider.dart';

class AddStoryScreen extends StatefulWidget {
  final LatLng latLon;
  final Function() onStoryAdded;
  final Function() onGetLocation;

  const AddStoryScreen({
    super.key,
    required this.latLon,
    required this.onStoryAdded,
    required this.onGetLocation,
  });

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    _getPlacemark();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Story"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String?>(
          future: authProvider.getToken(),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (tokenSnapshot.hasError) {
              return const Center(child: Text('Error retrieving token'));
            } else if (tokenSnapshot.hasData) {
              final token = tokenSnapshot.data;
              if (token == null) {
                return const Center(child: Text('Token tidak ditemukan'));
              }
              return SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        child:
                            context.watch<AddStoryProvider>().imagePath == null
                                ? const Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.image,
                                      size: 100,
                                    ),
                                  )
                                : _showImage(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _onGalleryView(),
                            child: const Text("Gallery"),
                          ),
                          ElevatedButton(
                            onPressed: () => _onCameraView(),
                            child: const Text("Camera"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: 5,
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan deskripsi',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: widget.onGetLocation,
                        child: AbsorbPointer(
                          child: TextField(
                            maxLines: 3,
                            controller: locationController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Ambil Lokasi',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _onUpload(token),
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No token found'));
            }
          },
        ),
      ),
    );
  }

  Future<void> _getPlacemark() async {
    if (widget.latLon.latitude != 0.0 && widget.latLon.longitude != 0.0) {
      try {
        final info = await geo.placemarkFromCoordinates(
            widget.latLon.latitude, widget.latLon.longitude);
        setState(() {
          placemark = info.first;
          locationController.text =
              '${placemark!.street}, ${placemark!.subLocality}, ${placemark!.locality}, ${placemark!.postalCode}, ${placemark!.country}';
        });
      } catch (e) {
        setState(() {
          placemark = null;
        });
      }
    }
  }

  _onUpload(String token) async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final uploadProvider = context.read<UploadProvider>();
    final apiProvider = context.read<ApiProvider>();

    final homeProvider = context.read<AddStoryProvider>();
    final imagePath = homeProvider.imagePath;
    final imageFile = homeProvider.imageFile;
    if (imagePath == null || imageFile == null) return;

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();

    final newBytes = await uploadProvider.compressImage(bytes);

    await uploadProvider.upload(
      newBytes,
      fileName,
      descriptionController.text,
      widget.latLon,
      token,
    );

    if (uploadProvider.uploadResponse != null) {
      homeProvider.setImageFile(null);
      homeProvider.setImagePath(null);
      widget.onStoryAdded();
      apiProvider.resetStories();
      await apiProvider.getStories(token);
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(uploadProvider.message)),
    );
  }

  _onGalleryView() async {
    final provider = context.read<AddStoryProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<AddStoryProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<AddStoryProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }
}
