// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:productify/screens/home/add_product.dart';
import 'package:productify/screens/login.dart';
import 'package:productify/screens/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCntroller = TextEditingController();

  List _products = [];
  List _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? products = prefs.getString("productify-products");
      if (products == null) {
        throw "No products found";
      }
      setState(() {
        _products = jsonDecode(products);
        _products = _products.reversed.toList();
        _filteredProducts = _products;
      });
      debugPrint("Products:adddddddddddddddddddd $_products");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handleSearch(String value) {
    try {
      if (value.isEmpty) {
        setState(() {
          _filteredProducts = _products;
        });
        return;
      }
      setState(() {
        _filteredProducts = _products
            .where((element) => element["name"]
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()))
            .toList();
      });
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(
        context: context,
        title: "Unable to search",
        duration: 1000,
        type: "error",
      );
    }
  }

  void _handleLogout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("productify-token");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }));
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(
        context: context,
        title: "Unable to Logout",
        duration: 2000,
        type: "error",
      );
    }
  }

  void _handleAddProduct() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const AddProduct();
          },
        ),
      );
      debugPrint("adddddddddddddddddddd: $result");
      if (result == true) {
        _loadData();
        debugPrint("adddddddddddddddddddd: refreshed");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handleDeleteProduct(String name) async {
    try {
      setState(() {
        _products.removeWhere((element) => element["name"] == name);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("productify-products", jsonEncode(_products));
      showSnackBar(
        context: context,
        title: "Product deleted",
        duration: 1000,
        type: "success",
      );
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(
        context: context,
        title: "Unable to delete",
        duration: 1000,
        type: "error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Products",
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: const Color.fromARGB(255, 196, 221, 240),
            ),
            child: IconButton(
              onPressed: () {
                _handleLogout();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: getWidth(context, 100),
          height: getHeight(context, 100),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                cursorHeight: 19,
                controller: _searchCntroller,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
                onChanged: _handleSearch,
                decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi-Fi Shops & Services",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Audio shop on Rustaveli Ave 57.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        )),
                    Text("This shop offers both product and services.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
              heightSpace(30),
              _filteredProducts.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: getHeight(context, 30)),
                      child: Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(
                            color: Colors.grey.withOpacity(.5),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0;
                                i < _filteredProducts.length;
                                i += 2)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _productCard(_filteredProducts[i]),
                                    if (i + 1 < _filteredProducts.length)
                                      _productCard(_filteredProducts[i + 1]),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleAddProduct();
        },
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.blue,
            width: 1,
          ),
        ),
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _productCard(Map item) {
    return Container(
      // margin: const EdgeInsets.all(10),
      width: getWidth(context, 43),
      height: getHeight(context, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.memory(
                  base64Decode(item["image"]),
                  width: getWidth(context, 43),
                  height: getHeight(context, 20),
                  fit: BoxFit.fill,
                ),
              ),
              heightSpace(15),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  item["name"] ?? "",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
              heightSpace(15),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "₹ ${item["price"].toString()}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                _handleDeleteProduct(item["name"]);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
