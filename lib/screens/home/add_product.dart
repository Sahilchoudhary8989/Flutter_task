// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:productify/screens/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _imageLoading = false;
  String _imageString = "";
  Uint8List? _imageBytes;

  bool _loading = false;

  bool _productAdded = false;

  void _handleSave() async {
    try {
      setState(() {
        _loading = true;
      });
      if (!_formKey.currentState!.validate()) {
        throw "Please fill all the fields";
      }
      if (_imageString.isEmpty) {
        throw "Please select an image";
      }
      String productName = _productNameController.text;
      String productPrice = _productPriceController.text;

      Map product = {
        "name": productName,
        "price": productPrice,
        "image": _imageString,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? products = prefs.getString("productify-products");
      List productList = products == null ? [] : jsonDecode(products);

      bool isProductExist = productList.any((element) {
        return element["name"] == productName;
      });

      if (isProductExist) {
        throw "Product already exists";
      }

      productList.add(product);

      await prefs.setString("productify-products", jsonEncode(productList));

      setState(() {
        _loading = false;
        _productAdded = true;
        _productNameController.clear();
        _productPriceController.clear();
        _imageBytes = null;
        _imageString = "";
      });
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint(e.toString());
      showSnackBar(
        context: context,
        title: e.toString(),
        duration: 2000,
        type: "error",
      );
    }
  }

  void _getImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        String path = result.files.single.path!;
        File imageFile = File(path);
        Uint8List imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        setState(() {
          _imageBytes = imageBytes;
          _imageString = base64Image;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: getWidth(context, 100),
            height: getHeight(context, 100),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(0),
                      color: Colors.white,
                    ),
                    // width: 500,
                    width: double.infinity,
                    height: 284,
                    child: _imageBytes == null
                        ? InkWell(
                            onTap: () {
                              if (_imageLoading) return;
                              _getImage();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _imageLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.black,
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          if (_imageLoading) return;

                                          _getImage();
                                        },
                                        icon: const Icon(
                                          Icons.drive_folder_upload_outlined,
                                          color: Colors.black,
                                          size: 40,
                                        ),
                                      ),
                                const SizedBox(height: 1),
                                Text(
                                  _imageLoading
                                      ? "Loading Image ..."
                                      : "Browse Image",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (!_imageLoading)
                                  const Text(
                                    "*Click to browse",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Stack(
                            // fit: StackFit.expand,
                            children: [
                              Image.memory(
                                _imageBytes!,
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 284,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  tooltip: "Remove Image",
                                  onPressed: () {
                                    setState(() {
                                      _imageBytes = null;
                                      _imageString = "";
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color.fromARGB(255, 118, 255, 76),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  heightSpace(30),
                  TextFormField(
                    controller: _productNameController,
                    textAlign: TextAlign.start,
                    cursorColor: Colors.black,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      fillColor: Color.fromARGB(179, 255, 255, 255),
                      filled: true,
                      hintText: "Product Name",
                      hintStyle: TextStyle(color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      // hintText: hintText,
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "Product name is required";
                      }
                      return null;
                    },
                  ),
                  heightSpace(30),
                  TextFormField(
                    controller: _productPriceController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    cursorColor: Colors.black,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      fillColor: Color.fromARGB(179, 255, 255, 255),
                      filled: true,
                      hintText: "Product Price",
                      hintStyle: TextStyle(color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      // hintText: hintText,
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "Product price is required";
                      }
                      return null;
                    },
                  ),
                  heightSpace(30),
                  ElevatedButton(
                    onPressed: _loading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _loading ? "Processing..." : "Save",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_loading)
                          const SizedBox(
                            width: 10,
                          ),
                        if (_loading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
